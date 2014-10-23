package MooseX::NonMoose::Meta::Role::Constructor;
BEGIN {
  $MooseX::NonMoose::Meta::Role::Constructor::VERSION = '0.11';
}
use Moose::Role;
# ABSTRACT: constructor method trait for L<MooseX::NonMoose>


around can_be_inlined => sub {
    my $orig = shift;
    my $self = shift;

    my $meta = $self->associated_metaclass;
    my $super_new = $meta->find_method_by_name($self->name);
    my $super_meta = $super_new->associated_metaclass;
    if (Class::MOP::class_of($super_meta)->can('does_role')
     && Class::MOP::class_of($super_meta)->does_role('MooseX::NonMoose::Meta::Role::Class')) {
        return 1;
    }

    return $self->$orig(@_);
};

sub _find_next_nonmoose_constructor_package {
    my $self = shift;
    my $new = $self->name;
    my $meta = $self->associated_metaclass;
    for my $method (map { $_->{code} } $meta->find_all_methods_by_name($new)) {
        next if $method->associated_metaclass->meta->can('does_role')
             && $method->associated_metaclass->meta->does_role('MooseX::NonMoose::Meta::Role::Class');
        return $method->package_name;
    }
    # this should never happen (it should find Moose::Object at least)
    $meta->throw_error("Couldn't find a non-Moose constructor for " . $meta->name);
}

sub _generate_fallback_constructor {
    my $self = shift;
    my ($class_var) = @_;
    my $new = $self->name;
    my $meta = $self->associated_metaclass;
    my $super_new_class = $self->_find_next_nonmoose_constructor_package;
    my $arglist = $meta->find_method_by_name('FOREIGNBUILDARGS')
                ? "${class_var}->FOREIGNBUILDARGS(\@_)"
                : '@_';
    my $instance = "${class_var}->${super_new_class}::$new($arglist)";
    "${class_var}->Moose::Object::new(__INSTANCE__ => $instance, \@_)"
}

sub _generate_instance {
    my $self = shift;
    my ($var, $class_var) = @_;
    my $new = $self->name;
    my $meta = $self->associated_metaclass;
    my $super_new_class = $self->_find_next_nonmoose_constructor_package;
    my $arglist = $meta->find_method_by_name('FOREIGNBUILDARGS')
                ? "${class_var}->FOREIGNBUILDARGS(\@_)"
                : '@_';
    my $instance = "${class_var}->${super_new_class}::$new($arglist)";
    return "my $var = $instance;\n"
         . "if (!Scalar::Util::blessed($var)) {\n"
         . "    " . $self->_inline_throw_error(
               "'The constructor for $super_new_class did not return a blessed instance'"
           ) . ";\n"
         . "}\n"
         . "elsif (!$var->isa($class_var)) {\n"
         . "    if (!$class_var->isa(Scalar::Util::blessed($var))) {\n"
         . "        " . $self->_inline_throw_error(
               "\"The constructor for $super_new_class returned an object whose class is not a parent of $class_var\""
           ) . ";\n"
         . "    }\n"
         . "    else {\n"
         . "        " . $self->_meta_instance->inline_rebless_instance_structure($var, $class_var) . ";\n"
         . "    }\n"
         . "}\n";
}

no Moose::Role;

1;

__END__
=pod

=head1 NAME

MooseX::NonMoose::Meta::Role::Constructor - constructor method trait for L<MooseX::NonMoose>

=head1 VERSION

version 0.11

=head1 SYNOPSIS

  package My::Moose;
  use Moose ();
  use Moose::Exporter;

  Moose::Exporter->setup_import_methods;
  sub init_meta {
      shift;
      my %options = @_;
      Moose->init_meta(%options);
      Moose::Util::MetaRole::apply_metaclass_roles(
          for_class               => $options{for_class},
          metaclass_roles         => ['MooseX::NonMoose::Meta::Role::Class'],
          constructor_class_roles =>
              ['MooseX::NonMoose::Meta::Role::Constructor'],
      );
      return Class::MOP::class_of($options{for_class});
  }

=head1 DESCRIPTION

This trait implements inlining of the constructor for classes using the
L<MooseX::NonMoose::Meta::Role::Class> metaclass trait; it has no effect unless
that trait is also used. See those docs and the docs for L<MooseX::NonMoose>
for more information.

=head1 AUTHOR

Jesse Luehrs <doy at tozt dot net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Jesse Luehrs.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

