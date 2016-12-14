package MojoX::Bitcoin;
use Mojo::Base -base;

use Mojo::UserAgent;
use Mojo::JSON qw/encode_json/;
use Mojo::Util qw/monkey_patch decode/;

use Carp qw/croak/;

has ioloop  => sub { Mojo::IOLoop->singleton };
has ua      => sub { Mojo::UserAgent->new };
has url     => sub { "localhost:8332" };
has account => "";
has id      => 0;

sub new {
  my $self = shift->SUPER::new( @_ );

  # Tune JSON-RPC connection for minimum latency
  $self->ua->max_redirects( 0 )->connect_timeout( 3 )->request_timeout( 5 );

  return $self;
}

# Bitcoin v0.13.99 API

my @methods = qw/
  getbestblockhash
  getblock
  getblockchaininfo
  getblockcount
  getblockhash
  getblockheader
  getchaintips
  getdifficulty
  getmempoolancestors
  getmempooldescendants
  getmempoolentry
  getmempoolinfo
  getrawmempool
  gettxout
  gettxoutproof
  gettxoutsetinfo
  verifychain
  verifytxoutproof

  getinfo
  stop

  generate
  generatetoaddress

  getblocktemplate
  getmininginfo
  getnetworkhashps
  prioritisetransaction
  submitblock

  addnode
  clearbanned
  disconnectnode
  getaddednodeinfo
  getconnectioncount
  getnettotals
  getnetworkinfo
  getpeerinfo
  listbanned
  ping
  setban

  createrawtransaction
  decoderawtransaction
  decodescript
  fundrawtransaction
  getrawtransaction
  sendrawtransaction
  signrawtransaction

  createmultisig
  createwitnessaddress
  estimatefee
  estimatepriority
  estimatesmartfee
  estimatesmartpriority
  signmessagewithprivkey
  validateaddress
  verifymessage

  abandontransaction
  addmultisigaddress
  addwitnessaddress
  backupwallet
  dumpprivkey
  dumpwallet
  encryptwallet
  getaccount
  getaccountaddress
  getaddressesbyaccount
  getbalance
  getnewaddress
  getrawchangeaddress
  getreceivedbyaccount
  getreceivedbyaddress
  gettransaction
  getunconfirmedbalance
  getwalletinfo
  importaddress
  importprivkey
  importprunedfunds
  importpubkey
  importwallet
  keypoolrefill
  listaccounts
  listaddressgroupings
  listlockunspent
  listreceivedbyaccount
  listreceivedbyaddress
  listsinceblock
  listtransactions
  listunspent
  lockunspent
  move
  removeprunedfunds
  sendfrom
  sendmany
  sendtoaddress
  setaccount
  settxfee
  signmessage
/;

for my $method ( @methods ) {
  monkey_patch __PACKAGE__, lc $method => sub {
    return shift->_call( $method => @_ )
  };
}

sub _call {
  my ( $self, $method, $params, $cb ) = @_;

  $self->id( $self->id + 1 );

  my $headers = { Content_Type => 'application/json' };

  my $body = encode_json {
    id => $self->id, method => $method, params => $params
  };

  if ( $cb ) {
    $self->ioloop->delay->steps(
      sub {
        my ( $delay ) = @_;

        $self->ua->post( $self->url, $headers, $body => $delay->begin );
      },

      sub {
        my ( $delay, $tx ) = @_;

        return $cb->( $self, undef, $tx->res->json ) if $tx->success;

        return $cb->( $self, $self->_error( $method, $tx ) );
      }
    );
  }

  else {
    my $tx = $self->ua->post( $self->url, $headers, $body );

    return $tx->res->json if $tx->success;

    die $self->_error( $method, $tx );
  }
}

sub _error {
  my ( $self, $method, $tx ) = @_;

  $tx->error->{message} = decode 'UTF-8', $tx->error->{message};

  if ( $tx->error->{code} ) {
    my $format = "%s HTTP error: %s %s";
    my @values = ( $method, @{ $tx->error }{ qw/code message/ } );

    return sprintf $format, @values;
  }

  else {
    my $format = "%s connection error: %s";
    my @values = ( $method, $tx->error->{message} );

    return sprintf $format, @values;
  }
}


1;
