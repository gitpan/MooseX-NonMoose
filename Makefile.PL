
use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  DISTNAME  => 'MooseX-NonMoose',
  NAME      => 'MooseX::NonMoose',
  AUTHOR    => 'Jesse\ Luehrs\ \<doy\ at\ tozt\ dot\ net\>',
  ABSTRACT  => 'foreign\ inheritance\ for\ Moose',
  VERSION   => '0.06',
  EXE_FILES => [ qw() ],
  (eval { ExtUtils::MakeMaker->VERSION(6.31) } ? (LICENSE => 'perl') : ()),
  PREREQ_PM    => {
    "Moose" => '0.90',
  },
  test => {TESTS => 't/*.t'}
);

