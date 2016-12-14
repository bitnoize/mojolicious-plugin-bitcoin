use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

use_ok( 'MojoX::Bitcoin' );
use_ok( 'Mojolicious::Plugin::Bitcoin' );

done_testing();
