package Mojo::Pg::Abstract;

use warnings;
use strict;

use Mojo::Pg::Database;
use SQL::Abstract::PgLimit;

our $abstract = SQL::Abstract::PgLimit->new();

sub import {
	for my $method (qw(select insert update delete)) {
		no strict 'refs';
		*{"Mojo::Pg::Database::$method"} = sub {
			shift->query($abstract->$method(@_));
		}
	}
}

1;

__END__

=head1 NAME

Mojo::Pg::Abstract - Some of L<SQL::Abstract> for L<Mojo::Pg::Database>.

=head1 SYNOPSIS

  use Mojo::Pg;
  use Mojo::Pg::Abstract;

  my $pg = Mojo::Pg->new(...);
  my $db = $pg->db;

  $my $results = $db->select($table, \@fields, \%where, \@order, $limit, $offset);
  say $results->text;

  $results = $db->insert($table, \@values || \%fieldvals, \%options);

  $results = $db->update($table, \%fieldvals, \%where);

  $results = $db->delete($table, \%where);

=head1 DESCRIPTION

Wrap C<select>, C<insert>, C<update>, C<delete> from L<SQL::Abstract::PgLimit> and add them as a methods
of L<Mojo::Pg::Database>.

Generated SQL query and bind params will be passed to L<Mojo::Pg::Database/query>. As that, methods will
return L<Mojo::Pg::Results> for result.

=head1 SHARED VARS

=head2 $Mojo::Pg::Abstract::abstract;

  $Mojo::Pg::Abstract::abstract = SQL::Abstract::PgLimit->new(case => 'lower');

A pointer to L<SQL::Abstract::PgLimit> object. In case you want to call some other methods, pass options
to constructor or replace it with other similar class.

=head1 SEE ALSO

L<SQL::Abstract>, L<SQL::Abstract::PgLimit>.

=cut
