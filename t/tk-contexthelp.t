# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use Tk;
use Tk::ContextHelp;
$^W = 1;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

use FindBin;
use lib ($FindBin::RealBin, "$FindBin::RealBin/..");

$top = new MainWindow;
#$ch = $top->ContextHelp;
$ch = $top->ContextHelp(-widget => 'Message',
			-width => 400, -justify => 'right',
			-podfile => 'Tk::ContextHelp',
			#-podfile => 'perl',
			-helpkey => 'F1',
		       );

#$ch->attach($top, -msg => 'No context help available for this topic');

$tl = $top->Frame->grid(-row => 0, -column => 0);

$b1 = $ch->HelpButton($tl)->pack;
#$ch->attach($b1, -msg => 'Click here to turn the context help on. Then click
#on the desired widget in the window.');

$l1 = $tl->Label(-text => 'Hello')->pack;
$ch->attach($l1, -msg => 'This is the word "Hello"');

$l2 = $tl->Label(-text => 'World')->pack;
$ch->attach($l2, -msg => 'This is the word "World"');

$tl->Button(-text => 'No context help',
	    -command => sub { warn "Ouch!\n"},
	   )->pack;

eval { require Tk::FireButton };
if (!$@) {
    $l3 = $tl->FireButton(-text => 'a fire button')->pack;
    $ch->attach($l3, -msg => 'There seem to be problems with FireButtons
not checking for an empty my_save_relief.');
}

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
		$t->Popup(-popover => 'cursor');
	    });

$f->Label(-text => 'frame')->pack;

$f2 = $top->Frame(-relief => 'raised',
		  -bd => 2)->grid(-row => 1, -column => 0);
$f2->Label(-text => 'POD sections', -fg => 'red')->pack;
$pod1 = $f2->Label(-text => 'Name',
		   -bg => '#ffc0c0')->pack(-anchor => 'w');
$pod2 = $f2->Label(-text => 'Synopsis')->pack(-anchor => 'w');
$pod3 = $f2->Label(-text => 'Description')->pack(-anchor => 'w');
$pod30 = $f2->Label(-text => 'Methods')->pack(-anchor => 'w');
$pod31 = $f2->Label(-text => '  attach')->pack(-anchor => 'w');
$pod32 = $f2->Label(-text => '  detach')->pack(-anchor => 'w');
$pod33 = $f2->Label(-text => '  activate')->pack(-anchor => 'w');
$pod34 = $f2->Label(-text => '  deactivate')->pack(-anchor => 'w');
$pod35 = $f2->Label(-text => '  HelpButton')->pack(-anchor => 'w');
$pod4 = $f2->Label(-text => 'Author')->pack(-anchor => 'w');
$pod5 = $f2->Label(-text => 'See also')->pack(-anchor => 'w');
$ch->attach($pod1, -pod => '^NAME');
$ch->attach($pod2, -pod => '^SYNOPSIS');
$ch->attach($pod3, -pod => '^DESCRIPTION');
$ch->attach($pod30, -pod => '^METHODS');
$ch->attach($pod31, -pod => '^attach');
$ch->attach($pod32, -pod => '^detach');
$ch->attach($pod33, -pod => '^activate');
$ch->attach($pod34, -pod => '^deactivate');
$ch->attach($pod35, -pod => '^HelpButton');
$ch->attach($pod4, -pod => '^AUTHOR');
$ch->attach($pod5, -pod => '^SEE ALSO');

$bn = $top->Button(-text => 'Tk::Pod pod',
		   -command => sub { $ch->configure(-podfile => 'Tk::Pod') },
		  )->grid(-row => 1, -column => 1);;
$ch->attach($bn, -msg => "Changes the active pod to Tk::Pod's pod");

$qb = $top->Button(-text => 'Quit',
		   -command => sub { exit },
		  )->grid(-row => 2, -columnspan => 2);
$ch->attach($qb, -msg => "Click here if you are tired of this demo.");

######################################################################

$top2 = new MainWindow;
$icon_frame = $top2->Frame(-relief => 'ridge',
			   -bd => 2)->pack(-fill => 'x', -expand => 1);
$main_frame = $top2->Frame->pack(-fill => 'both', -expand => 1);
$ch2 = $main_frame->ContextHelp(-podfile => 'Tk::ContextHelp');
$hb2 = $icon_frame->Button(-text => 'click here',
			   -command => [$ch2, 'activate'],
			  )->pack(-side => 'right');
$stay_active = 0;
$cb2 = $icon_frame->Checkbutton
  (-text => 'stay active',
   -variable => \$stay_active,
   -command => sub { $ch2->configure(-stayactive => $stay_active) },
  )->pack(-side => 'right');

$l20 = $main_frame->Label(-text => 'This is a test label')->pack(-expand => 1,
							   -fill => 'both');
$l21 = $main_frame->Label(-text => 'And another test label')->pack(-expand => 1,
							     -fill => 'both');

$ch2->attach($l20, -msg => 'blah blah blah');
$ch2->attach($l21, -msg => 'bla blubber foo');


$f3 = $main_frame->Frame(-relief => 'raised',
			 -bd => 2)->pack;
$f3->Label(-text => 'POD sections', -fg => 'red')->pack;
$pod1 = $f3->Label(-text => 'Name')->pack(-anchor => 'w');
$pod2 = $f3->Label(-text => 'Synopsis')->pack(-anchor => 'w');
$pod3 = $f3->Label(-text => 'Description')->pack(-anchor => 'w');
$pod30 = $f3->Label(-text => 'Methods')->pack(-anchor => 'w');
$pod31 = $f3->Label(-text => '  attach')->pack(-anchor => 'w');
$pod32 = $f3->Label(-text => '  detach')->pack(-anchor => 'w');
$pod33 = $f3->Label(-text => '  activate')->pack(-anchor => 'w');
$pod34 = $f3->Label(-text => '  deactivate')->pack(-anchor => 'w');
$pod35 = $f3->Label(-text => '  HelpButton')->pack(-anchor => 'w');
$pod4 = $f3->Label(-text => 'Author')->pack(-anchor => 'w');
$pod5 = $f3->Label(-text => 'See also')->pack(-anchor => 'w');
$ch2->attach($pod1, -pod => '^NAME');
$ch2->attach($pod2, -pod => '^SYNOPSIS');
$ch2->attach($pod3, -pod => '^DESCRIPTION');
$ch2->attach($pod30, -pod => '^METHODS');
$ch2->attach($pod31, -pod => '^attach');
$ch2->attach($pod32, -pod => '^detach');
$ch2->attach($pod33, -pod => '^activate');
$ch2->attach($pod34, -pod => '^deactivate');
$ch2->attach($pod35, -pod => '^HelpButton');
$ch2->attach($pod4, -pod => '^AUTHOR');
$ch2->attach($pod5, -pod => '^SEE ALSO');


MainLoop;
