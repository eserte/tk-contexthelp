use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile
  (
   'NAME'	=> 'Tk::ContextHelp',
   'VERSION_FROM' => 'ContextHelp.pm', # finds $VERSION
   'PM'         => 
   {'ContextHelp.pm'   => '$(INST_LIBDIR)/ContextHelp.pm',
    'context_help.xbm' => '$(INST_LIBDIR)/context_help.xbm',
    'context_help_mask.xbm' => '$(INST_LIBDIR)/context_help_mask.xbm',
    'context_nohelp.xbm' => '$(INST_LIBDIR)/context_nohelp.xbm',
    'context_nohelp_mask.xbm' => '$(INST_LIBDIR)/context_nohelp_mask.xbm',
   },
   'PREREQ_PM'  => {'Tk'             => 402.002,
		    #'Tk::Pod'        => 0.4, # optional
		   },
  );
