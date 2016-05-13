use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'Mojolicious::Plugin::PgDB',
  VERSION_FROM => 'lib/Mojolicious/Plugin/PgDB.pm',
  AUTHOR       => 'Andre Parker <andreparker@gmail.com>',
  PREREQ_PM =>
    {'Mojolicious' => '6.61', 'Mojo::Pg' => '2.26', 'SQL::Abstract' => '1.81'},
  test => {TESTS => 't/*.t'}
);
