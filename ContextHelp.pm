# -*- perl -*-

#
# $Id: ContextHelp.pm,v 1.2 1998/02/18 00:05:21 eserte Exp $
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
    $w->bind('<Button-1>' => [ $w, 'deactivate']);
    $w->bind('<Button-2>' => [ $w, 'deactivate']);
    $w->bind('<Button-3>' => [ $w, 'deactivate']);
    $w->bind('<Key>'      => [ $w, 'deactivate']); # XXX geht nicht?

    my $widget = delete $args->{'-widget'} || 'Label';
    $w->{'label'} = $w->$widget()->pack;
    $w->{'state'} = 'withdrawn';

    $w->ConfigSpecs
      (-installcolormap => ["PASSIVE", "installColormap", "InstallColormap", 0],
       -background      => [$w->{'label'}, "background", "Background", "#C0C080"],
       -font            => [$w->{'label'}, "font", "Font", "-*-helvetica-medium-r-normal--*-120-*-*-*-*-*-*"],
       -borderwidth     => ["SELF", "borderWidth", "BorderWidth", 1],
       DEFAULT          => [$w->{'label'}],
      );
}

sub activate {
    my($w, $state) = @_;
    $state = 'context' unless $state;
    $w->deactivate unless $state eq 'wait';
    my $top = $w->parent->toplevel;
    my $inp_only = $top->InputO
      (-width  => $top->width,
       -height => $top->height,
      )->place(-x => 0, -y => 0, -relwidth => 1.0, -relheight => 1.0);
    if ($state eq 'context') {
	$inp_only->configure
	  (-cursor => ['@' . Tk->findINC('context_help.xbm'), 'black']);
    }
    $w->{'inp_only'} = $inp_only;
    $w->{'state'} = $state;
    $inp_only->bind('<Button-1>' => sub {
			if ($w->{'state'} eq 'context') {
			    my $e = $_[0]->XEvent;
			    my($x, $y) = ($e->x, $e->y);
			    $w->deactivate;
			    my($rootx, $rooty) = ($x+$top->rootx,
						  $y+$top->rooty);
			    my $under = $top->containing($rootx, $rooty);
			    # underlying widget and its parents
			    while(defined $under) {
				if (exists $w->{'msg'}{$under}) {
				    if ($w->cget(-installcolormap)) {
					$w->colormapwindows($top);
				    }
				    $w->{'label'}->configure
				      (-text => $w->{'msg'}{$under});
				    $w->geometry("+$rootx+$rooty");
				    $w->deiconify;
				    $w->raise;
				    $w->update;
				    $w->activate('wait');
				    return;
				}
				$under = $under->parent;
			    }
			    $top->bell;
			}
			$w->deactivate;
		    });
    $inp_only->bind('<Button-2>'  => [$w, 'deactivate']);
    $inp_only->bind('<Button-3>'  => [$w, 'deactivate']);
    $inp_only->bind('<Key>'       => [$w, 'deactivate']); # XXX geht nicht?
}

sub deactivate {
    my($w) = @_;
    $w->withdraw;
    $w->{'state'} = 'withdrawn';
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

sub HelpButton {
    my($w, $top, %args) = @_;
    $args{-bitmap} = '@' . Tk->findINC('context_help.xbm')
      unless $args{-bitmap};
    $args{-command} = [$w, 'activate'];
    my $b = $top->Button(%args);
}

1;
__END__

=head1 NAME

Tk::ContextHelp - context-sensitive help with perl/Tk

=head1 SYNOPSIS

  use Tk::ContextHelp;

  $ch = $top->ContextHelp;
  $ch->attach($widget, -msg => ...);

  $top->HelpButton->pack;

=head1 DESCRIPTION

XXX

=head1 AUTHOR

Slaven Rezic <eserte@cs.tu-berlin.de>

=head1 SEE ALSO

Tk::Balloon(3).

=cut
