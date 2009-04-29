package Catalyst::Plugin::Session::State::Stash;
use base qw/Catalyst::Plugin::Session::State Class::Accessor::Fast/;

use strict;
use warnings;
use MRO::Compat;

our $VERSION = "0.10";

BEGIN { __PACKAGE__->mk_accessors(qw/_deleted_session_id _prepared/) }

sub _session_stash_key {
    my ($c) = @_;

    $c->config->{session}->{stash_key};
}

sub _get_session {
    my ($c) = @_;
    
    $c->stash->{$c->_session_stash_key};
}

sub _set_session {
    my ( $c,$key,$value) = @_;
    
    $c->stash->{$c->_session_stash_key}->{$key} = $value;
}

sub setup_session {
    my $c = shift;

    $c->config->{session}->{stash_key}
        ||= '_session';
}

sub prepare_action {
    my $c = shift;
    my $id = $c->get_session_id;
    $c->_prepared(1);
    if ( $id ) {
        $c->sessionid( $id );
    }
    $c->maybe::next::method( @_ );
}

sub get_session_id {
    my $c = shift;
    if(!$c->_deleted_session_id and my $session = $c->_get_session) {
        my $sid = $session->{id};
        return $sid if $sid;
    }
    $c->maybe::next::method(@_);
}

sub set_session_id {
    my ( $c, $sid ) = @_;
    $c->_set_session(id => $sid);
    $c->maybe::next::method($sid);
}

sub get_session_expires {
    my $c = shift;
    my $session = $c->_get_session;
    defined $session->{expires} ? $session->{expires} : undef;
}

sub set_session_expires {
    my ( $c, $expires ) = @_;
    
    $c->_set_session(expires => time() + $expires);
    $c->maybe::next::method($expires)
}

sub delete_session_id {
    my ($c, $sid ) = @_;
    $c->_deleted_session_id(1);
    undef $c->{stash}->{$c->_session_stash_key};
    $c->maybe::next::method($sid);
}


1;
__END__

=pod

=head1 NAME

Catalyst::Plugin::Session::State::Stash - Maintain session IDs using the stash

=head1 SYNOPSIS

 use Catalyst qw/Session Session::State::Stash Session::Store::Foo/;

=head1 DESCRIPTION

An alternative state storage plugin that allows you some more flexibility in
dealing with session storage. This plugin loads and saves the session ID from
and to the stash.

=head1 METHODS

=over 4

=item delete_session_id

Deletes the session. Unfortunately I've been unable to squash a bug that will
stop you from opening a new session in the same execution, however.
Patches welcome!

=item get_session_id

Gets the current session id.

=item set_session_id

Sets the session id to the C<shift>.

=item get_session_expires

Gets when the current session expires.

=item set_session_expires

Sets how many seconds from now the session should expire.

=back

=head1 EXTENDED METHODS

=over 4

=item prepare_action

Loads the id off the stash.

=item setup_session

Defaults the C<stash_key> parameter to C<_session>.

=back

=head1 CONFIGURATION

=over 4

=item stash_key

The name of the hash key to use. Defaults to C<_session>.

=item expires
    
How long the session should last in seconds.

=back

For example, you could stick this in MyApp.pm:

  __PACKAGE__->config( session => {
     stash_key  => 'session_id',
  });

=head1 BUGS

You can't delete a session then create a new one. If this is important to you,
patches welcome. It is not important to me and fixing this for completeness
is pretty low on my list of priorities.

=head1 CAVEATS

Manual work may be involved to make better use of this.

If you are writing a stateful web service with
L<Catalyst::Plugin::Server::XMLRPC>, you will probably only have to deal with 
loading, as when saving, the ID will already be on the stash.

=head1 SEE ALSO

L<Catalyst>, L<Catalyst::Plugin::Session>, L<Catalyst::Plugin::Session::State>,
L<Catalyst::Plugin::Session::State::Cookie> (what you probably want).

=head1 AUTHORS

James Laver E<lt>perl -e 'printf qw/%s@%s.com cpan jameslaver/'E<gt>

=head1 CONTRIBUTORS

This module is derived from L<Catalyst::Plugin::Session::State::Cookie> code.

Thanks to anyone who wrote code for that.

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
