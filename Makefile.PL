# Makefile written by Bob Friesenhahn.

use ExtUtils::MakeMaker;
use Config;

# Compute test specification
my $delegate_tests='t/*.t';
my $delegate;
foreach $delegate (qw/ bzlib jng jpeg png ps tiff ttf x xfig zlib/) {
  if( -d "t/$delegate" ) {
    $delegate_tests .= " t/$delegate/*.t";
  }
}

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile
  (
   # Module description
   'ABSTRACT'	=> 'ImageMagick PERL Extension',

   # Perl module name is Image::Magick
   'NAME'	=> 'Image::Magick',

   # Module author
   'AUTHOR'    => 'ImageMagick Studio LLC',

   # Module version
   'VERSION'   => '6.1.7',

   # Preprocessor defines
   'DEFINE'	=> ' -D_FILE_OFFSET_BITS=64 -DHAVE_CONFIG_H',     # e.g., '-DHAVE_SOMETHING' 

   # Header search specfication and preprocessor flags
   'INC'	=> '-I../ -I.. -I/usr/include/freetype2 -I/usr/X11R6/include -I/usr/X11R6/include/X11 -I/usr/include/libxml2',

   # C pre-processor flags (e.g. -I & -D options)
   # 'CPPFLAGS'    => "$Config{'cppflags'} -I/usr/include/freetype2 -I/usr/X11R6/include -I/usr/X11R6/include/X11 -I/usr/include/libxml2",

   # C compiler flags (e.g. -O -g)
   'CCFLAGS'     => "$Config{'ccflags'} -g -O2 -Wall -pthread",

   # Linker flags for building an executable
   'LDFLAGS'    =>  "-L/usr/local/lib $Config{'ldflags'}",

   # Linker flags for building a dynamically loadable module
   'LDDLFLAGS'  => "-L/usr/local/lib $Config{'lddlflags'}",

   # Install PerlMagick binary into ImageMagick bin directory
   'INSTALLBIN'	=> '/usr/local/bin',

   # Library specification
   'LIBS'	=> ['-L/usr/local/lib -L../magick/.libs -lMagick -L/usr/X11R6/lib -lfreetype -lz -L/usr/lib -ltiff -lfreetype -ljpeg -lpng -ldpstk -ldps -lXext -lXt -lSM -lICE -lX11 -lbz2 -lxml2 -lz -lpthread -lm -lpthread'],

   # Perl binary name (if a Perl binary is built)
   'MAP_TARGET'	=> 'PerlMagick',

   # Let CFLAGS drive optimization flags by setting OPTIMIZE to empty
   # 'OPTIMIZE'	=> '',

   # Use same compiler as ImageMagick
   'PERLMAINCC'	=> '',

   # Set Perl installation prefix to ImageMagick
#   'PREFIX'	=> '/usr/local',

   # Include delegate directories in tests
   test		=> { TESTS	=>	$delegate_tests},

   ($Config{'archname'} =~ /-object$/i ? ('CAPI' => 'TRUE') : ()),
);

#
# Stinky ExtUtils::MM_Unix likes to append its own library path to $(CC),
# prior to any user-specified library path so that an installed library is
# used rather than the library just built.  This substitution function
# tries to insert our library path first. Also, use the same compiler used
# to build perlmain.c to link so that a C++ compiler may be used if
# necessary.
#
sub MY::makeaperl {
     package MY; # so that "SUPER" works right
     my $inherited = shift->SUPER::makeaperl(@_);

     $inherited =~ s:MAP_LINKCMD\s.*\s*\$\(CC\):MAP_LINKCMD   = \$(PERLMAINCC) -L/usr/local/lib: ;
     $inherited;
 }

sub MY::test {
     package MY; # so that "SUPER" works right
     my $inherited = shift->SUPER::test(@_);
                                                                                
     # Run tests in our environment
     $inherited =~ s:PERL_DL_NONLAZY=1:/bin/sh ../magick.sh PERL_DL_NONLAZY=1:g ;     $inherited;
 }
