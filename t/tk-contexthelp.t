# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use Tk::ContextHelp;
use Tk;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

$top = new MainWindow;
#$ch = $top->ContextHelp;
$ch = $top->ContextHelp(-widget => 'Message',
			-width => 400, -justify => 'right');

$l1 = $top->Label(-text => 'Hello')->pack;
$ch->attach($l1, -msg => 'This is the word "Hello"');

$l2 = $top->Label(-text => 'World')->pack;
$ch->attach($l2, -msg => 'This is the word "World"');

$f  = $top->Frame(-relief => 'raised',
		  -bd => 2)->pack;
$ch->attach($f, -msg => 'Frame test');

$f->Label(-text => 'Labels')->pack;
$f->Label(-text => 'in')->pack;
$f->Label(-text => 'a')->pack;
$f->Label(-text => 'frame')->pack;

$b1 = $ch->HelpButton($top)->pack;
$ch->attach($b1, -msg => 'Click here to turn the context help on. Then click
on the desired widget in the window.');

MainLoop;
