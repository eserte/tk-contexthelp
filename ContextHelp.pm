# -*- perl -*-

#
# $Id: ContextHelp.pm,v 1.8 1998/03/03 23:13:35 eserte Exp $
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
$VERSION = '0.04';
@ISA = qw(Tk::Toplevel);

Construct Tk::Widget 'ContextHelp';

sub Populate {
    my($w, $args) = @_;
    $w->SUPER::Populate($args);
    
    $w->overrideredirect(1);
    $w->withdraw;
    $w->bind('<Button-1>' => [ $w, '_next_action']);
    $w->bind('<Button-2>' => [ $w, 'deactivate']);
    $w->bind('<Button-3>' => [ $w, 'deactivate']);
    
    my $widget = delete $args->{'-widget'} || 'Label';
    $w->{'label'} = $w->$widget()->pack;
    $w->{'clients'} = [];
    $w->{'inp_only_clients'} = [];
    $w->{'state'} = 'withdrawn';

    my $key = delete $args->{'-helpkey'}; # XXX ConfigSpecs
    if (defined $key) {
	$w->parent->toplevel->bind('<F1>' => sub { $w->_key_help });
    }

    $w->{'inp_only'} = $w->parent->InputO(-cursor => 'watch');
    $w->{'inp_only'}->bind('<Button-1>' => [ $w, '_next_action']);
    $w->{'inp_only'}->bind('<Button-2>' => [ $w, 'deactivate']);
    $w->{'inp_only'}->bind('<Button-3>' => [ $w, 'deactivate']);
    
    $w->ConfigSpecs
      (-installcolormap => ["PASSIVE", "installColormap", "InstallColormap", 0],
       -background      => [$w->{'label'}, "background", "Background", "#C0C080"],
       -font            => [$w->{'label'}, "font", "Font", "-*-helvetica-medium-r-normal--*-120-*-*-*-*-*-*"],
       -borderwidth     => ["SELF", "borderWidth", "BorderWidth", 1],
       '-podfile'       => ["METHOD", "podFile", "PodFile", $0],
       -verbose         => ["PASSIVE", "verbose", "Verbose", 1],
       -cursor          => ["PASSIVE", "cursor", "Cursor",
			    ['@' . Tk->findINC('context_help.xbm'),
			     Tk->findINC('context_help_mask.xbm'),
			     'black', 'white']],
       -offcursor       => ["PASSIVE", "offCursor", "offCursor",
			    ['@' . Tk->findINC('context_nohelp.xbm'),
			     Tk->findINC('context_nohelp_mask.xbm'),
			     'black', 'white']],
       -stayactive      => ["PASSIVE", "stayActive", "StayActive", 0],
       -callback        => ["CALLBACK", "callback", "Callback", undef],
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
    $w->_reset if $state eq 'context';
    $state = 'context' if $state eq 'cont';
    my $cw;
    foreach $cw (@{$w->{'inp_only_clients'}}) {
	$cw->place('-x' => 0, '-y' => 0,
		   -relwidth => 1.0, -relheight => 1.0);
    }
    if ($state eq 'context') {
	$w->{'save_cursor'} = $w->parent->cget(-cursor);
	$w->parent->configure(-cursor => $w->cget(-offcursor));
	my $cursor = $w->cget(-cursor);
	foreach $cw (@{$w->{'inp_only_clients'}}) {
	    $cw->configure(-cursor => $cursor);
	    $cw->raise;
	}
    } elsif ($state eq 'wait') {
	$w->{'inp_only'}->place('-x' => 0, '-y' => 0,
				-relwidth => 1.0, -relheight => 1.0);
	$w->{'inp_only'}->raise;
    }

    $w->{'state'} = $state;
    $w->cget(-callback)->($w) if $w->cget(-callback);
}

sub _active_state {
    my($w, $inp_only) = @_;
    if ($w->{'state'} eq 'context') {
	my $parent = $inp_only->parent;
	my $e = $inp_only->XEvent;
	my($x, $y) = ($e->x, $e->y);
	$w->_reset;
	my($rootx, $rooty) = ($x+$parent->rootx,
			      $y+$parent->rooty);
	my $under = $parent->containing($rootx, $rooty);
	return $w->_show_help($under, $parent, $rootx, $rooty);
    }
    $w->deactivate;
}

sub _key_help {
    my($w) = @_;
    if ($w->{'state'} eq 'wait') {
	$w->deactivate;
    } else {
	my $parent = $w->parent;
	my $top = $parent->toplevel;
	my $e = $top->XEvent;
	my($x, $y) = ($e->x, $e->y);
	$w->_reset; # XXX
	my($rootx, $rooty) = ($x+$parent->rootx,
			      $y+$parent->rooty);
	my $under = $parent->containing($rootx, $rooty);
	$w->_show_help($under, $parent, $rootx, $rooty);
    }
}

sub _show_help {
    my($w, $under, $parent, $rootx, $rooty) = @_;
    $parent = $under->parent unless defined $parent;
    $rootx = $under->rootx + int($under->width/2);
    $rooty = $under->rooty + int($under->height/2);

    my $raise_msg = sub {
	my $msg = shift;
	if ($w->cget(-installcolormap)) {
	    $w->colormapwindows($parent);
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
	    $w->_next_action;
	    return;
	} elsif (exists $w->{'pod'}{$under} ||
		 exists $w->{'podfile'}{$under}) {
	    my $podfile = $w->{'podfile'}{$under} || $w->cget('-podfile');
	    if (Tk::Exists($w->{'podwindow'})) {
		$w->{'podwindow'}->deiconify;
		$w->{'podwindow'}->raise;
	    } else {
		eval { require Tk::Pod };
		if ($@) {
		    $parent->bell;
		    if ($w->cget(-verbose)) {
			$raise_msg->("Warning: Can't find Tk::Pod.\n$@");
			return;
		    }
		} else {
		    $parent->Busy;
		    eval { $w->{'podwindow'} 
			   = $parent->toplevel->Pod(-file => $podfile) };
		    $parent->Unbusy;
		    if ($@) {
			undef $w->{'podwindow'};
			$parent->bell;
			if ($w->cget(-verbose)) {
			    $raise_msg->("Warning: Can't find POD for <$podfile>.\n$@");
			    return;
			}
		    }
		}
	    }
	    if ($w->{'podwindow'} && $w->{'pod'}{$under}) {
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
			$parent->bell;
			if ($w->cget(-verbose)) {
			    $raise_msg->("Warning: Can't find help topic <$w->{'pod'}{$under}>.");
			    return;
			}
		    }
		}
	    }
	    $w->_next_action;
	    return;
	}
	$under = $under->parent;
    }
    $parent->bell;
    if ($w->cget(-verbose)) {
	$raise_msg->("Warning: No help available for this topic.");
	return;
    }
}

sub _next_action {
    my($w) = @_;
    if ($w->cget(-stayactive)) {
	$w->activate('context');
    } else {
	$w->deactivate;
    }
}

sub _normal_cursor {
    my($w) = @_;
    $w->parent->configure(-cursor => $w->{'save_cursor'});
}

sub _reset {
    my($w) = @_;
    $w->withdraw;
    $w->{'state'} = 'withdrawn';
    $w->{'inp_only'}->placeForget;
    $w->_normal_cursor;
    my $cw;
    foreach $cw (@{$w->{'inp_only_clients'}}) {
	if (Tk::Exists($cw)) {
	    $cw->placeForget;
	}
    }
}

sub deactivate {
    my($w) = @_;
    $w->_reset;
    $w->cget(-callback)->($w) if $w->cget(-callback);
}

sub toggle {
    my $w = shift;
    if ($w->{'state'} eq 'withdrawn') {
	$w->activate;
    } else {
	$w->deactivate;
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
    if (exists $args{'-podfile'}) {
	$w->{'podfile'}{$client}     = delete $args{'-podfile'};
    }
    push(@{$w->{'clients'}}, $client);
    my $inputo = $client->InputO(-width  => $client->width,
				 -height => $client->height,
				);
    push(@{$w->{'inp_only_clients'}}, $inputo);
    $inputo->bind('<Button-1>' => [$w, '_active_state', $inputo]);
    $inputo->bind('<Button-2>' => [$w, 'deactivate']);
    $inputo->bind('<Button-3>' => [$w, 'deactivate']);
    #$inputo->bind('<Escape>'   => [$w, 'deactivate']);
    #$inputo->bind('<Key>'      => [$w, 'deactivate']); # XXX InputO does not receive any Key events?!
    $client->OnDestroy([$w, 'detach', $client]);
}

sub detach {
    my($w, $client) = @_;
    delete $w->{'msg'}{$client};
    delete $w->{'command'}{$client};
    delete $w->{'pod'}{$client};
    my $i;
    for($i = 0; $i <= $#{$w->{'clients'}}; $i++) {
	if ($client eq $w->{'clients'}[$i]) {
	    splice @{$w->{'clients'}}, $i, 1;
	    splice @{$w->{'inp_only_clients'}}, $i, 1;
	    last;
	}
    }
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
    my $b;
    $args{-bitmap} = '@' . Tk->findINC('context_help.xbm')
      unless $args{-bitmap};
    $args{-command} = sub { $w->configure(-stayactive => 0);
			    $w->toggle;
			};
    my $change_button_state = sub {
	if ($w->{'state'} ne 'withdrawn') {
	    $b->configure(-relief => 'sunken');
	} else {
	    $b->configure(-relief => 'raised');
	}
    };
    $w->configure(-callback => $change_button_state);

    $b = $top->Button(%args);
    $b->bind('<Button-3>' => sub { $w->configure(-stayactive => 1);
				   $w->toggle;
			       });
    $b;
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

=item B<-callback>

Set a callback to be called on each state change (useful for own
HelpButton implementations).

=item B<-cursor>

Use another cursor for the help mode instead of the left pointer with
question mark.

=item B<-helpkey>

Enable use of a help key. A common choice would be "F1".

=item B<-offcursor>

Use another cursor for the help mode shown if the underlying widget is
not attached to the help system. The default is a left pointer with a
strike-through question mark.

=item B<-podfile>

Set the pod file for the B<-pod> argument of B<attach>. The default is
C<$0> (the current script).

=item B<-stayactive>

If set to true, help mode is active until set to false. So the user
may browse over all topics he like.

=item B<-verbose>

Be verbose if something goes wrong. Default is true.

=item B<-widget>

Use another widget instead of the default B<Label> for displaying
messages. Another possible choice would be B<Message>.

=back

=head1 METHODS

The B<ContextHelp> widget supports the following non-standard methods:

=over 4

=item B<attach(>I<widget>, I<option>B<)>

Attaches the widget indicated by I<widget> to the context-sensitive
help system. Option may be one of the following:

=over 4

=item B<-msg>

The argument is the message to be shown in a popup window.

=item B<-pod>

The argument is a regular expression to jump in the corresponding pod file.

=item B<-podfile>

The argument is a pod name to be used instead of the default pod file.
B<-podfile> may be used together with B<-pod> or all alone.

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

=item B<toggle>

Toggle help system on or off.

=item B<HelpButton(>I<top>, I<options>B<)>

Create a help button. It is a regular B<Button> with I<-bitmap> set to
the help cursor bitmap and I<-command> set to activation of the help
system. The argument I<top> is the parent widget, I<options> are
additional options for the help button.

The button stays pressed as the help is activated. Clicking on the
pressed button causes the end of the help mode. Clicking with
mousebutton-3 causes the help system to stay active until the user
clicks on the button over again.

=back

=head1 BUGS

The user cannot click on the border of an attached widget to raise the help
window.

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
