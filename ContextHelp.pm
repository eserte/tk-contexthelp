# -*- perl -*-

#
# $Id: ContextHelp.pm,v 1.1 1998/02/17 18:06:44 eserte Exp $
# Author: Slaven Rezic
#
# Copyright (C) 1998 Slaven Rezic. All rights reserved.
# This package is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# Mail: eserte@cs.tu-berlin.de
# WWW:  http://user.cs.tu-berlin.de/~eserte/
#

package Tk::ContextHelp;
use Tk::InputO;
use strict;
use vars qw($VERSION @ISA);
$VERSION = '0.01';
@ISA = qw(Tk::Toplevel);

Construct Tk::Widget 'ContextHelp';

sub Populate {
    my($w, $args) = @_;
    $w->SUPER::Populate($args);

    $w->overrideredirect(1);
    $w->withdraw;
    $w->bind('<Button-1>' => sub { $w->withdraw });

    $w->{'label'} = $w->Label->pack;
}

sub activate {
    my($w) = @_;
    my $top = $w->parent->toplevel;
    my $inp_only = $top->InputO
      (-width  => $top->width,
       -height => $top->height,
       -cursor => ['@' . Tk->findINC('context_help.xbm'), 'black'],
      )->place(-x => 0, -y => 0);
    $w->{'inp_only'} = $inp_only;
    $inp_only->bind('<Button-1>' => sub {
			my $e = $_[0]->XEvent;
			my($x, $y) = ($e->x, $e->y);
			$w->deactivate;
			my($rootx, $rooty) = ($x+$top->rootx, $y+$top->rooty);
			my $under = $top->containing($rootx, $rooty);
			if (!defined $under ||
			    !exists $w->{'msg'}{$under}) {
			    $top->bell;
			} else {
			    $w->{'label'}->configure
			      (-text => $w->{'msg'}{$under});
			    $w->geometry("+$rootx+$rooty");
			    $w->deiconify;
			    $w->raise;
			    $w->update;
			}
		    });
    $inp_only->bind('<Button-2>' => [$w, 'deactivate']);
    $inp_only->bind('<Button-3>' => [$w, 'deactivate']);
    $inp_only->bind('<Key>'  => [$w, 'deactivate']);
}

sub deactivate {
    my($w) = @_;
    if (Tk::Exists($w->{'inp_only'})) {
	$w->{'inp_only'}->destroy;
	delete $w->{'inp_only'};
    }
}

sub attach {
    my($w, $client, %args) = @_;
    $w->{'msg'}{$client} = delete $args{-msg};
    $client->OnDestroy([$w, 'detach', $client]);
}

sub detach {
    my($w, $client) = @_;
    delete $w->{'msg'}{$client};
}

sub CHButton {
    my($w, $top, %args) = @_;
    $args{-bitmap} = '@' . Tk->findINC('context_help.xbm')
      unless $args{-bitmap};
    $args{-command} = [$w, 'activate'];
    my $b = $top->Button(%args);
}

1;
__END__
# Below is the stub of documentation for your module. You better edit it!

=head1 NAME

Tk::ContextHelp - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Tk::ContextHelp;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Tk::ContextHelp was created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head1 AUTHOR

Slaven Rezic <eserte@cs.tu-berlin.de>

=head1 SEE ALSO

perl(1).

=cut
