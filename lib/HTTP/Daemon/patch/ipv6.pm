package HTTP::Daemon::patch::ipv6;

use 5.010001;
use strict;
no warnings;

use parent qw(Module::Patch);

our $VERSION = '0.01'; # VERSION

sub patch_data {
    return {
        versions => {
            '6.01' => {
                subs => {
                    url => $HTTP::Daemon::p_url,
                },
            },
        },
    };
}

package HTTP::Daemon;
require HTTP::Daemon;
no strict;
no warnings;
our $p_url = sub {
    my $orig = shift;

    my $self = shift;
    my $url = $self->_default_scheme . "://";
    my $addr = $self->sockaddr;
    if (!$addr || $addr eq INADDR_ANY || $self->isa("IO::Socket::INET6")) {
        require Sys::Hostname;
        $url .= lc Sys::Hostname::hostname();
    }
    elsif ($addr eq INADDR_LOOPBACK) {
        $url .= inet_ntoa($addr);
    }
    else {
        $url .= gethostbyaddr($addr, AF_INET) || inet_ntoa($addr);
    }
    my $port = $self->sockport;
    $url .= ":$port" if $port != $self->_default_port;
    $url .= "/";
    $url;
};

1;
# ABSTRACT: Patch module for HTTP::Daemon


__END__
=pod

=head1 NAME

HTTP::Daemon::patch::ipv6 - Patch module for HTTP::Daemon

=head1 VERSION

version 0.01

=head1 SYNOPSIS

 use HTTP::Daemon;
 use HTTP::Daemon::patch::ipv6;

=head1 DESCRIPTION

This module contains patch for HTTP::Daemon::url() for
https://rt.cpan.org/Ticket/Display.html?id=71395

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

