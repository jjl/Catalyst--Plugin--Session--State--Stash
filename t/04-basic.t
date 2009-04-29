#!/usr/bin/perl                                                                                                       

use strict;
use warnings;

use Test::More tests => 8;
use Test::MockObject;
use Test::MockObject::Extends;

# Get a stash
my $m;
BEGIN { use_ok( $m = "Catalyst::Plugin::Session::State::Stash" ) }

# Mock a catalyst controller
my $cxt =
  Test::MockObject::Extends->new("Catalyst::Plugin::Session::State::Stash");

$cxt->set_always( config   => {} );
$cxt->set_always( session  => {} );
$cxt->set_always( stash    => {} );
$cxt->set_false("debug");

my $sessionid;
$cxt->mock( sessionid => sub { shift; $sessionid = shift if @_; $sessionid } );

can_ok( $m, "setup_session" );

$cxt->setup_session;

is( $cxt->config->{session}{stash_key},
    '_session', "default cookie name is set" );

can_ok( $m, "get_session_id" );

ok( !$cxt->get_session_id, "no session id yet");

$cxt->set_always( stash => { '_session' => {id => 1}, 'session_id' => {id => 2}  } );

is( $cxt->get_session_id, "1", "Pull newfound session id" );

$cxt->config->{session}{stash_key} = "session_id";

is( $cxt->get_session_id, "2", "Pull session id from second key" );

can_ok( $m, "set_session_id" );