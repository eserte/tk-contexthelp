# -*- perl -*-

#
# $Id: ContextHelp.pm,v 1.5 1998/02/20 21:54:25 eserte Exp $
# Author: Slaven Rezic
#
# Copyright (c) 1998 Slaven Rezic. All rights reserved.
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
$VERSION = '0.02';
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

    my $widget = delete $args->{'-widget'} || 'Label';
    $w->{'label'} = $w->$widget()->pack;
    $w->{'state'} = 'withdrawn';

    $w->ConfigSpecs
      (-installcolormap => ["PASSIVE", "installColormap", "InstallColormap", 0],
       -background      => [$w->{'label'}, "background", "Background", "#C0C080"],
       -font            => [$w->{'label'}, "font", "Font", "-*-helvetica-medium-r-normal--*-120-*-*-*-*-*-*"],
       -borderwidth     => ["SELF", "borderWidth", "BorderWidth", 1],
       -podfile         => ["METHOD", "podFile", "PodFile", $0],
       -verbose         => ["PASSIVE", "verbose", "Verbose", 1],
       -stayactive      => ["PASSIVE", "stayActive", "StayActive", 0],
       DEFAULT          => [$w->{'label'}],
      );
}

# allowed states are:
# - context:   change the cursor and wait for clicks on widgets
# - wait:      wait for the user to finish the help balloon
# - cont:      similar like context, only if -stayactive is selected
sub activate {
    my($w, $state) = @_;
    $state = 'context' unless $state;
    $w->deactivate unless $state eq 'wait' || $state eq 'cont';
    $state = 'context' if $state eq 'cont';
    my $top = $w->parent; #->toplevel;
    my $inp_only = $top->InputO
      (-width  => $top->width,
       -height => $top->height,
      )->place('-x' => 0, '-y' => 0, -relwidth => 1.0, -relheight => 1.0);
    if ($state eq 'context') {
	$inp_only->configure
	  (-cursor => ['@' . Tk->findINC('context_help.xbm'),
		       Tk->findINC('context_help_mask.xbm'),
		       'black', 'white']);
    }
    $w->{'inp_only'} = $inp_only;
    $w->{'state'} = $state;
    $inp_only->bind('<Button-1>' => [$w, '_active_state', $top, $inp_only]);
    $inp_only->bind('<Button-2>' => [$w, 'deactivate']);
    $inp_only->bind('<Button-3>' => [$w, 'deactivate']);
    $inp_only->bind('<Key>'      => [$w, 'deactivate']); # XXX InputO does not receive any Key events?!
}

sub _active_state {
    my($w, $top, $inp_only) = @_;
    if ($w->{'state'} eq 'context') {
	my $e = $inp_only->XEvent;
	my($x, $y) = ($e->x, $e->y);
	$w->deactivate;
	my($rootx, $rooty) = ($x+$top->rootx,
			      $y+$top->rooty);
	my $under = $top->containing($rootx, $rooty);

	my $raise_msg = sub {
	    my $msg = shift;
	    if ($w->cget(-installcolormap)) {
		$w->colormapwindows($top);
	    }
	    $w->{'label'}->configure(-text => $msg);
	    $w->geometry("+$rootx+$rooty");
	    $w->deiconify;
	    $w->raise;
	    $w->update;
	    $w->activate($w->cget(-stayactive) ? 'cont' : 'wait');
	};

	# test underlying widget and its parents
	while(defined $under) {
	    if (exists $w->{'msg'}{$under}) {
		$raise_msg->($w->{'msg'}{$under});
		return;
	    } elsif (exists $w->{'command'}{$under}) {
		$w->{'command'}{$under}->($under);
		$w->deactivate;
		return;
	    } elsif (exists $w->{'pod'}{$under}) {
		my $podfile = $w->cget(-podfile);
		if (Tk::Exists($w->{'podwindow'})) {
		    $w->{'podwindow'}->deiconify;
		    $w->{'podwindow'}->raise;
		} else {
		    eval { require Tk::Pod };
		    if ($@) {
			$top->bell;
			if ($w->cget(-verbose)) {
			    $raise_msg->("Warning: Can't find Tk::Pod.\n$@");
			    return;
			}
		    } else {
			$top->Busy;
			eval { $w->{'podwindow'} 
			       = $top->Pod(-file => $podfile) };
			$top->Unbusy;
			if ($@) {
			    undef $w->{'podwindow'};
			    $top->bell;
			    if ($w->cget(-verbose)) {
				$raise_msg->("Warning: Can't find POD for <$podfile>.\n$@");
				return;
			    }
			}
		    }
		}
		if ($w->{'podwindow'}) {
		    my $text;
		    # here comes the *hack*
		    # find the Text widget of the pod window
		    foreach ($w->{'podwindow'}{'SubWidget'}{'pod'}
			     ->children->{'SubWidget'}{'more'}->children) {
			if ($_->isa('Tk::Text')) {
			    $text = $_;
			    last;
			}
		    }
		    if ($text) {
			$text->tag('configure', 'search',
				   -background => 'red');
			$text->tag('remove', 'search', qw/0.0 end/);
			my $length = 0;
			# XXX exact or regex search?
			my $pos = $text->search(-count => \$length,
						-regexp,
						'--', $w->{'pod'}{$under},
						'1.0', 'end');
			if ($pos) {
			    $text->tag('add', 'search',
				       $pos, "$pos + $length char");
			    $text->see('end');
			    $text->see($pos);
			} else {
			    $top->bell;
			    if ($w->cget(-verbose)) {
				$raise_msg->("Warning: Can't find help topic <$w->{'pod'}{$under}>.");
				return;
			    }
			}
		    }
		}
		if ($w->cget(-stayactive)) {
		    $w->activate('context');
		} else {
		    $w->deactivate;
		}
		return;
	    }
	    $under = $under->parent;
	}
	$top->bell;
	if ($w->cget(-verbose)) {
	    $raise_msg->("Warning: No help available for this topic.");
	    return;
	}
    }
    $w->deactivate;
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
    $w->detach($client);
    if      (exists $args{-msg}) {
	$w->{'msg'}{$client}     = delete $args{-msg};
    } elsif (exists $args{-command}) {
	$w->{'command'}{$client} = delete $args{-command};
    } elsif (exists $args{-pod}) {
	$w->{'pod'}{$client}     = delete $args{-pod};
    }
    $client->OnDestroy([$w, 'detach', $client]);
}

sub detach {
    my($w, $client) = @_;
    delete $w->{'msg'}{$client};
    delete $w->{'command'}{$client};
    delete $w->{'pod'}{$client};
}

sub podfile {
    my($w, $file) = @_;
    if (@_ > 1 and defined $file) {
	if (Tk::Exists($w->{'podwindow'})) {
	    delete $w->{'podwindow'};
	}
	$w->{Configure}{'podfile'} = $file;
    } else {
	$w->{Configure}{'podfile'};
    }
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

  $ch->HelpButton($top)->pack;

=head1 DESCRIPTION

B<ContextHelp> provides a context-sensitive help system. By activating
the help system (either by clicking on a B<HelpButton> or calling the
B<activate> method, the cursor changes to a left pointer with a
question mark and the user may click on any widget in the window to
get a help message or jump to the corresponding pod entry.

B<ContextHelp> accepts all the options that the B<Label> widget
accepts. In addition, the following options are also recognized.

=over 4

=item B<-podfile>

Set the pod file for the B<-pod> argument of B<attach>. The default is
C<$0> (the current script).

=item B<-verbose>

Be verbose if something goes wrong. Default is true.

=item B<-widget>

Use another widget instead of the default B<Label> for displaying
messages. Another choice would be B<Message>.

=back

=head1 METHODS

The B<ContextHelp> widget supports the following non-standard methods:

=over 4

=item B<attach(>I<widget>, I<options>B<)>

Attaches the widget indicated by I<widget> to the context-sensitive
help system. The options can be:

=over 4

=item B<-msg>

The argument is the message to be shown in a popup window.

=item B<-pod>

The argument is a regular expression to jump in the corresponding pod file.

=item B<-command>

The argument is a user-defined command to be called when activating
the help system on this widget.

=back

=item B<detach(>I<widget>B<)>

Detaches the specified widget I<widget> from the help system.

=item B<activate>

Turn the help system on.

=item B<deactivate>

Turn the help system off.

=item B<HelpButton(>I<top>, I<options>B<)>

Create a help button. It is a regular B<Button> with I<-bitmap> set to
the help cursor bitmap and I<-command> set to activation of the help
system. The argument I<top> is the parent widget, I<options> are
additional options for the help button.

=back

=head1 AUTHOR

Slaven Rezic <F<eserte@cs.tu-berlin.de>>

Some code and documentation is derived from Rajappa Iyer's
B<Tk::Balloon>.

Copyright (c) 1998 Slaven Rezic. All rights reserved.
This package is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

Tk::Balloon(3), Tk::Pod(3).

=cut
