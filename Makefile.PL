use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile
  (
   'NAME'	=> 'Tk::ContextHelp',
   'VERSION_FROM' => 'ContextHelp.pm', # finds $VERSION
   'LIBS'	=> [''],   # e.g., '-lm' 
   'DEFINE'	=> '',     # e.g., '-DHAVE_SOMETHING' 
   'PM'         => 
   {'ContextHelp.pm'   => '$(INST_LIBDIR)/ContextHelp.pm',
    'context_help.xbm' => '$(INST_LIBDIR)/context_help.xbm',
    'context_help_mask.xbm' => '$(INST_LIBDIR)/context_help_mask.xbm',
   },
   'INC'	=> '',     # e.g., '-I/usr/include/other' 
   'PREREQ_PM'  => {'Tk'             => 402.002,
		    'Tk::Pod'        => 0.4,
		   },
  );
