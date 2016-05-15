#Mojolicious::Plugin::PgDB

Fix [Mojolicious](https://metacpan.org/pod/Mojolicious),
[Mojo::Pg](https://metacpan.org/pod/Mojo::Pg) and
[SQL::Abstract](https://metacpan.org/pod/SQL::Abstract) together with a piece of
duct tape.

```perl
  use Mojolicious::Lite;
 
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

```

Look at embedded documentation for details and examples.

### Migrations command

```
  # show currently active and latest available versions
  ./app.pl migrations -a -l

  # migrate to latest or selected version
  ./app.pl migrations --migrate
  ./app.pl migrations --migrate 2
```
