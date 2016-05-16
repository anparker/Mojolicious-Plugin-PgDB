package SQL::Abstract::PgLimit;
use parent 'SQL::Abstract';

use warnings;
use strict;
use utf8;

use Carp 'carp';

sub select {
  my $self = shift;
  my ($source, $fields, $where, $order, $limit, $offset) = @_;

  carp 'Wrong argument for limit. Should be a positive number.'
    if $limit && $limit !~ /^\d+$/;
  carp 'Wrong argument for offset. Should be a positive number.'
    if $offset && $offset !~ /^\d+$/;

  my ($sql, @bind) = $self->SUPER::select($source, $fields, $where, $order);

  if (defined $limit) {
    $sql .= ' LIMIT ?';
    push @bind, $limit;
  }

  if (defined $offset) {
    $sql .= ' OFFSET ?';
    push @bind, $offset;
  }

  return wantarray ? ($sql, @bind) : $sql;
}

1;

__END__

=head1 NAME

SQL::Abstract::PgLimit - SQL::Abstract with limits.

=head1 SYNOPSIS

  use SQL::Abstract::PgLimit;

  my $sql = SQL::Abstract::PgLimit->new();

  my ($query, @bind) = $sql->select($source, \@fields, \%where, \@order, $limit, $offset);

  my ($query, @bind) = $sql->select('table', '*', {}, undef, 10);
  my ($query, @bind) = $sql->select('table', '*', {}, undef, 10, 20);
  my ($query, @bind) = $sql->select('table', '*', {}, undef, undef, 10);

=head1 DESCRIPTION

Extends L<SQL::Abstract/select> with limit functionality.

L</select> will accept two additional argumets C<$limit> and C<$offset>. If C<$limit> is undefined,
LIMIT clause will be omitted.

Everything else is unchanged.

NOTE: This will only work with PostreSQL. If you need a versatile solution, look at L<SQL::Abstract::Limit>.

=head1 SEE ALSO

L<SQL::Abstract>.

=cut
