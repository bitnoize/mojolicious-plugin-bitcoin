# Mojolicious::Plugin::Bitcoin

Bitcoin JSON-RPC client for Mojolicious

### Futures

* Non-blocking / blocking access to bitcoind.
* Separate module for stand-alone use: MojoX::Bitcoin.

### Build Debian package

```
$ sudo apt-get install build-essential devscripts
$ dpkg-buildpackage -us -uc -b
$ dpkg -i ../libmojolicious-plugin-bitcoin-perl*.deb
```

### Non-blocking usage example via Lite app

```
use Mojolicious::Lite;

plugin 'Bitcoin' => { url => "wallet:secret\@localhost:8332" };

get '/' => sub {
  my $c = shift->render_later;

  $c->delay(
    sub {
      my ( $delay ) = @_;

      $c->app->bitcoin->getinfo( [ ] => $delay->begin );
    },

    sub {
      my ( $delay, $err, $rpc ) = @_;

      die "getinfo failed: $err" if $err;
      die "getinfo error:  $rpc->{error}" if $rpc->{error};

      $c->render( json => $rpc->{result} );
    }
  );
};

app->start;
```

### Blocking usage example via standalone script

```
use Mojo::Base -base;

use MojoX::Bitcoin;
use Data::Dumper;

my $bitcoin = MojoX::Bitcoin->new( url => "wallet:secret\@localhost:8332" );
my $rpc = $bitcoin->getinfo( [ ] );

say Dumper $rpc->{result};
```
