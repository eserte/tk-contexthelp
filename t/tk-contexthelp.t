# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use Tk::ContextHelp;
use Tk;
$^W = 1;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

$top = new MainWindow;
#$ch = $top->ContextHelp;
$ch = $top->ContextHelp(-widget => 'Message',
			-width => 400, -justify => 'right',
			-podfile => 'Tk::ContextHelp');

$tl = $top->Frame->grid(-row => 0, -column => 0);

$b1 = $ch->HelpButton($tl)->pack;
$ch->attach($b1, -msg => 'Click here to turn the context help on. Then click
on the desired widget in the window.');

$l1 = $tl->Label(-text => 'Hello')->pack;
$ch->attach($l1, -msg => 'This is the word "Hello"');

$l2 = $tl->Label(-text => 'World')->pack;
$ch->attach($l2, -msg => 'This is the word "World"');

$f  = $top->Frame(-relief => 'raised',
		  -bg => 'red',
		  -bd => 2)->grid(-row => 0, -column => 1);
$ch->attach($f, -msg => 'Frame test');

$f->Label(-text => 'Labels')->pack;

$f->Label(-text => 'in')->pack;

$fl1 = $f->Label(-text => 'a')->pack;
$ch->attach($fl1, -command => sub {
		my $t = $top->Toplevel;
		$t->Label(-text => 'user-defined command')->pack;
	    });

$f->Label(-text => 'frame')->pack;

$f2 = $top->Frame(-relief => 'raised',
		  -bd => 2)->grid(-row => 1, -column => 0);
$f2->Label(-text => 'POD sections', -fg => 'red')->pack;
$pod1 = $f2->Label(-text => 'Name')->pack;
$pod2 = $f2->Label(-text => 'Synopsis')->pack;
$pod3 = $f2->Label(-text => 'Description')->pack;
$pod4 = $f2->Label(-text => 'Author')->pack;
$pod5 = $f2->Label(-text => 'See also')->pack;
$ch->attach($pod1, -pod => 'NAME');
$ch->attach($pod2, -pod => 'SYNOPSIS');
$ch->attach($pod3, -pod => 'DESCRIPTION');
$ch->attach($pod4, -pod => 'AUTHOR');
$ch->attach($pod5, -pod => 'SEE ALSO');

$bn = $top->Button(-text => 'Tk::Pod pod',
		   -command => sub { $ch->configure(-podfile => 'Tk::Pod') },
		  )->grid(-row => 1, -column => 1);;
$ch->attach($bn, -msg => "Changes the active pod to Tk::Pod's pod");

MainLoop;

__END__

# =head1 NAME

# Tk::ContextHelp - context-sensitive help with perl/Tk

# =head1 SYNOPSIS

#   use Tk::ContextHelp;

#   $ch = $top->ContextHelp;
#   $ch->attach($widget, -msg => ...);

#   $top->HelpButton->pack;

# =head1 DESCRIPTION

# XXX

# =head1 AUTHOR

# Slaven Rezic <eserte@cs.tu-berlin.de>

# =head1 SEE ALSO

# Tk::Balloon(3).

# =cut
