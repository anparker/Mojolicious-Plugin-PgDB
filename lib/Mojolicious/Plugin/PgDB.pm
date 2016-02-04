package Mojolicious::Plugin::PgDB;
use Mojo::Base 'Mojolicious::Plugin';

use Mojo::Pg;
use Mojo::Pg::Abstract;
use Module::Runtime 'require_module';

our $VERSION = '0.2';

sub register {
	my ($self, $app, $conf) = @_;
	$conf ||= {};

	die 'Missing connection string.' unless $conf->{pgstring};
	$conf->{dbiopts}->{$_} //= 1
		for (qw(AutoCommit AutoInactiveDestroy RaiseError));

	$app->attr(pg => sub { Mojo::Pg->new($conf->{pgstring})->options($conf->{dbiopts})->search_path($conf->{schema}) });
	$app->helper(db => sub { shift->app->pg->db });

	$app->pg->on(connection => sub {
			# $pg, $dbh

			# $_[1]->do('SET search_path TO ?, public', {}, $conf->{schema})
			# 	if $conf->{schema};

			if (ref $conf->{on_connect} eq 'ARRAY') {
				$_[1]->do($_) for @{$conf->{on_connect}};
			}
		});

	if ($conf->{debug}) {
		require_module 'DBIx::QueryLog';
		DBIx::QueryLog->import();
		DBIx::QueryLog->skip_bind(1);

		my ($total_queries, $total_time) = (0, 0);

		$DBIx::QueryLog::OUTPUT = sub {
			my %p = @_;

			my $msg = "[DBI] Query: \"$p{sql}\"";

			if (@{$p{bind_params}}) {
				$msg .= ' with params: ("'.join('", "', @{$p{bind_params}}).'")';
			}

			$msg .= " took: $p{time} sec.";

			$app->log->debug($msg);
			$total_queries++;
			$total_time += $p{time};
		};

		$app->plugins->on(after_dispatch => sub {
				shift->app->log->debug('Total queries: '.$total_queries.' over '.$total_time.' sec.');
				$total_queries = $total_time = 0;
		});

	}
}

1;

__END__

=encoding utf8

=head1 NAME

Mojolicious::Plugin::PgDB - L<Mojo::Pg> with L<SQL::Abstract> flavour.

=head1 SYNOPSIS

  use Mojolicious::Lite'
 
  plugin 'PgDB' => {
    pgstring => 'postgresql://user:pass@localhost/db1',
    dbiopts => {
      AutoCommit => 1,
      RaiseError => 1,
      PrintError => 0,
      AutoInactiveDestroy => 1,
    },
    schema => ['foo', 'public'],
    on_connect => [ q{set timezone to 'UTC'} ],
    debug => 0,
  };

  get '/' => sub {
    my $c = shift;

    my $user = $c->db->select('users', ['user_id', 'e-mail', 'info'], {login => $c->param('login')})->hash;
    $c->render(me => $user);
  };

  app->start;

=head1 DESCRIPTION

A piece of duct tape for L<Mojo::Pg>, L<SQL::Abstract> and L<Mojolicious>.

Creates all necessary stuff and provides helper to access it. Look at L<Mojo::Pg::Abstract> for details.

=head1 OPTIONS

=head2 dbiopts

  plugin PgDB => {dbiopts => {AutoCommit => 1, RaiseError => 1}};

Options for database handles. Check L<Mojo::Pg/options> and attributes section of L<DBI>. C<AutoCommit>,
C<AutoInactiveDestroy> and C<RaiseError> will be enabled by default.

=head2 debug

  plugin PgDB => {debug => 1};

Will load L<DBIx::QueryLog>, register hook and set up logging of SQL queries and their execution time to
app's debug log.

=head2 on_connect

  plugin PgDB => {on_connect => [q{SET timezone TO 'UTC'}]};

Execute set of queries on every new DB handler. No checks for malicious insertions!

=head2 pgstring
 
  plugin PgDB => {pgstring => 'postgresql://user:pass@localhost/db1'};

Connection string that will be passed to L<Mojo::Pg/new>. Peek at L<Mojo::Pg/from_string> for examples. Mandatory.

=head2 schema

  plugin PgDB => {schema => [qw(foo bar public)]};

List of PostgreSQL schemas for search path. See L<Mojo::Pg/search_path>.

=head1 APP ATTRIBUTES

=head2 pg

  my $db = $app->pg->db;

A reference to L<Mojo::Pg> object.

=head1 HELPERS

=head2 db

  my $results = $c->db->query(...);

Get L<Mojo::Pg::Database> object. Just a shortcut to L<Mojo::Pg/db>.

=head1 METHODS

L<Mojolicious::Plugin::PgDB> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=head2 register

  $plugin->register(Mojolicious->new);

Register plugin in L<Mojolicious> application.

=head1 SEE ALSO

L<Mojo::Pg>, L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicious.org>.

=cut

