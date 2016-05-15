package Mojolicious::Plugin::PgDB::Command::migrations;
use Mojo::Base 'Mojolicious::Command';

use Getopt::Long
  qw(GetOptionsFromArray :config bundling no_auto_abbrev no_ignore_case);

has description => 'Migrate DB using Mojo::Pg migrations.';
has usage => sub { shift->extract_usage };


sub run {
  my ($self, @args) = @_;

  my $conf       = $self->app->config->{migrations};
  my $migrations = $self->app->pg->migrations;

  GetOptionsFromArray \@args,
    'a|active' => \(my $active),
    'f|file=s' => \(my $file = ''),
    'l|latest' => \(my $latest),
    'migrate'  => \(my $migrate),
    'n|name=s' => \$conf->{name};

  $migrations->name($conf->{name}) if $conf->{name};

  die $self->usage unless $migrate || $active || $latest;

  say 'Current version: ', $migrations->active if $active;

  # Migrations from file.
  if ($file || ($conf->{from} //= '') eq 'file') {
    $migrations->from_file($file || $conf->{file});

  }

  # Migrations from data section.
  elsif ($conf->{from} eq 'data') {
    $migrations->from_data(@{$conf->{section} || []});

  }

  else { die "Unknown migrations source.\n" }

  say 'Latest version:  ', $migrations->latest if $latest;

  $migrations->migrate(shift @args) if $migrate;
}

1;

=encoding utf8

=head1 NAME

Mojolicious::Plugin::PgDB::Command::migrations - Migrate DB with L<Mojo::Pg>
migrations.

=head1 SYNOPSIS

  Usage: APPLICATION migrations [OPTIONS] [VERSION]

    ./app.pl migrations -al
    ./app.pl migrations --migrate
    ./app.pl migrations --migrate -n myapp
    ./app.pl migrations --migrate -f ./sql/migrations.sql 3

  Options:
    -a, --active  Show currently active version
    -f, --file    File to extract migrations from
    -l, --latest  Show latest available version
    --migrate     Migrate to selected version
    -n, --name    Name of the set of migrations to use

  Without version specified will migrate to latest available version. Command
  line options have higher precedence then config values.

=head1 DESCRIPTION

L<Mojolicious::Plugin::PgDB::Command::migrations> will migrate from
C<active> to a different version. Check L<Mojo::Pg::Migrations> for details.

Migration data can be loaded from data section or file. Configuration will be
loaded from C<migrations> section of app config.

  {
    migrations => {
      name => 'myapp',
      from => 'file',
      file => './sql/migrations.sql'
    }
  }

or 

  {
    migrations => {
      from    => 'data',
      section => ['main', 'file_name']
    }
  }

=head1 CONFIG OPTIONS

=head2 data

Arrayref with namespace and file name to extract migrations from.

=head2 file

Name of a file for extract migrations.

=head2 from

Source from where extract migrations. Can be C<file> or C<data>.

=head2 name

Name for this set of migrations.

=head1 ATTRIBUTES

L<Mojolicious::Plugin::PgDB::Command::migrations> inherits all attributes from
L<Mojolicious::Command> and implements the following new ones.

=head2 description

  my $description = $app->description;
  $app            = $app->description('Foo');

Short description of this command, used for the command list.

=head2 usage

  my $usage = $app->usage;
  $app      = $app->usage('Foo');

Usage information for this command, used for the help screen.

=head1 METHODS

L<Mojolicious::Plugin::PgDB::Command::migrations> inherits all methods from
L<Mojolicious::Command> and implements the following new ones.

=head2 run

  $app->run(@ARGV);

Run this command.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicious.org>.

=cut
