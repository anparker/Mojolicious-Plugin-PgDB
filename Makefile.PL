use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'Mojolicious::Plugin::PgDB',
  VERSION_FROM => 'lib/Mojolicious/Plugin/PgDB.pm',
  AUTHOR       => 'A Good Programmer <nospam@cpan.org>',
  PREREQ_PM    => {'Mojolicious' => '6.40'},
  test         => {TESTS => 't/*.t'}
);
