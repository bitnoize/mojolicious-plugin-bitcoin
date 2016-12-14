package Mojolicious::Plugin::Bitcoin;
use Mojo::Base 'Mojolicious::Plugin';

use MojoX::Bitcoin;

our $VERSION = '0.07';

sub register {
  my ( $plugin, $app, $conf ) = @_;

  my $bitcoin = MojoX::Bitcoin->new(
    map { $_ => $conf->{ $_ } } grep { exists $conf->{ $_ } } qw/url account/
  );

  $app->attr( bitcoin => sub { $bitcoin } );
}


1;
