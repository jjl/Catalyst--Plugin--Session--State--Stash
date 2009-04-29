#!/usr/bin/perl                                                                                                       

use strict;
use warnings;

use URI::Escape;
use Test::More;

BEGIN {
    eval { require Test::WWW::Mechanize::Catalyst };
    plan skip_all =>
      "This test requires Test::WWW::Mechanize::Catalyst in order to run"
      if $@;
    plan skip_all => 'Test::WWW::Mechanize::Catalyst >= 0.40 required' if $Test::WWW::Mechanize::Catalyst::VERSION < 0.40;
}

{

    package TestApp;
    use Catalyst qw/                                                                                                  
      Session                                                                                                         
      Session::Store::Dummy                                                                                           
      Session::State::Stash
      -Debug                                                                                      
      /;

    sub start_session : Local {
        my ( $self, $c ) = @_;
        $c->session->{counter} = 1;
        $c->res->body($c->stash->{_session}->{id});
    }
    
    sub page : Local {
        my ( $self, $c, $id ) = @_;
        $c->stash ( '_session' => {id => $id} );
        $c->res->body( "Hi! hit number " . ++$c->session->{counter} );
    }
        
    sub stream : Local {
        my ( $self, $c, $id ) = @_;
        $c->stash ( '_session' => {id => $id} );
        my $count = ++$c->session->{counter};
	    $c->res->body("hit number $count");
    }
    
    sub deleteme : Local {
        my ( $self, $c, $id ) = @_;
        $c->stash ( '_session' => {id => $id} );
        my $id2 = $c->get_session_id;
	    $c->delete_session;
        my $id3 = $c->get_session_id;
        
        # In the success case, print 'Pass'
        if (defined $id2 &&
            defined $id3 &&
            $id2 ne $id3
        ) {
            $c->res->body('PASS');
        } else {
            #In the failure case, provide debug info
            $c->res->body("FAIL: Matching ids, $id3");
        }
    }
    
    __PACKAGE__->setup;
}

use Test::WWW::Mechanize::Catalyst qw/TestApp/;

my $m = Test::WWW::Mechanize::Catalyst->new;

#Number of tests to run. A begin block every 10 will ensure the count is correct
my $tests;
plan tests => $tests;

$m->get_ok( "http://localhost/start_session", "get page" );
my $session = uri_escape($m->content);

$m->get_ok( "http://localhost/page/$session", "get page" );
$m->content_contains( "hit number 2", "session data restored" );

$m->get_ok( "http://localhost/stream/$session", "get stream" );
$m->content_contains( "hit number 3", "session data restored" );

BEGIN { $tests += 5; }

$m->get_ok( "http://localhost/stream/$session", "get page" );
$m->content_contains( "hit number 4", "session data restored" );
$m->get_ok( "http://localhost/deleteme/$session", "get page" );

TODO: {
    local $TODO = "Changing sessions is broken and I've had no success fixing it. Patches welcome";
    $m->content_is( 'PASS' , 'session id changed' );
}
BEGIN { $tests += 4; }  