use ExtUtils::MakeMaker;

WriteMakefile(
	      NAME         => 'tidyview',
	      ABSTRACT     => "Preview the effects of perltidy's plethora of options",
	      AUTHOR       => "Leif Eriksen <tidyview@tidyview.sourceforge.net>",
	      VERSION_FROM => 'lib/VERSION.pm',
	      PREREQ_PM    => {
			       'Tk'            => '800.025',
			       'Log::Log4perl' => '1.0',
			       'version'       => 0, # used to detect old Tk's and use different widgets where required
			      },
	      test         => {'TESTS' => join(' ', qw(lib/PerlTidy/t/*.t lib/TidyView/t/*.t))},
	      EXE_FILES    => [ "bin/tidyview.pl", "bin/log.conf" ],
	      );
