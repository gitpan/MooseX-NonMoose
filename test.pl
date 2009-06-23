#!/usr/bin/perl
use strict;
use warnings;

package Foo;
our $VERSION = '0.04';


sub new { bless {}, __PACKAGE__ }

package Foo::Moose;
our $VERSION = '0.04';

use Moose;
use MooseX::NonMoose;
extends 'Foo';

package main;
our $VERSION = '0.04';

warn Foo::Moose->new;
