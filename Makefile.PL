#!/usr/bin/env perl

use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'Mojolicious::Plugin::Bitcoin',
  VERSION_FROM => 'lib/Mojolicious/Plugin/Bitcoin.pm',
  ABSTRACT     => 'Bitcoin JSON-RPC client for Mojolicious',
  LICENSE      => 'artistic_2',
  AUTHOR       => 'Dmitry Krutikov <mitya@openmailbox.org>',
  PREREQ_PM    => {
    'Mojolicious' => '5.54',
  },
  test         => { TESTS => 't/*.t' }
);
