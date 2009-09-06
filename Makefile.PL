#  Copyright 1999-2009 ImageMagick Studio LLC, a non-profit organization
#  dedicated to making software imaging solutions freely available.
#
#  You may not use this file except in compliance with the License.  You may
#  obtain a copy of the License at
#
#    http://www.imagemagick.org/script/license.php
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
#  Exercise all regression tests:
#  
#    make test
#
#  Exersise one regression test:
#
#    make TEST_VERBOSE=1 TEST_FILES=t/filter.t test
#

use ExtUtils::MakeMaker;
use Config;

# Compute test specification
my $delegate_tests='t/*.t';
my $delegate;
foreach $delegate (qw/bzlib jng jpeg png ps ttf zlib/) {
  if ( -d "t/$delegate" ) {
    if ($delegate =~ /x11/) {
      if ( defined $ENV{'DISPLAY'} ) {
        $delegate_tests .= " t/$delegate/*.t";
      }
      next;
    }
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
   'AUTHOR' => 'ImageMagick Studio LLC',

   # Module version
   'VERSION' => '6.5.5',

   # Preprocessor defines
   'DEFINE'	=> ' -D_LARGE_FILES=1 -DHAVE_CONFIG_H',     # e.g., '-DHAVE_SOMETHING' 
   # Header search specfication and preprocessor flags
   'INC'	=> '-I/usr/local/include/ImageMagick -I/usr/local/include -I/usr/include/ImageMagick',

   # Linker flags for building an executable
   'LDFLAGS' =>  "-L/usr/local/lib -lMagickCore -lMagickWand $Config{'ldflags'}",

   # Linker flags for building a dynamically loadable module
   'LDDLFLAGS' => "-L/usr/local/lib -lMagickCore -lMagickWand $Config{'lddlflags'}",

   # Install PerlMagick binary into ImageMagick bin directory
   'INSTALLBIN'	=> '/usr/local/bin',

   # Library specification
   'LIBS' => [ '-L/usr/local/lib -lMagickCore -lMagickWand -lm' ],

   # Perl binary name (if a Perl binary is built)
   'MAP_TARGET'	=> 'PerlMagick',

   # Include delegate directories in tests
   test	=> { TESTS	=>	$delegate_tests},

   ($Config{'archname'} =~ /-object$/i ? ('CAPI' => 'TRUE') : ()),
);


#
# Substitutions for "makeaperl" section.
#
sub MY::makeaperl {
     package MY; # so that "SUPER" works right
     my $inherited = shift->SUPER::makeaperl(@_);

     # Stinky ExtUtils::MM_Unix likes to append its own library path to $(CC),
     # prior to any user-specified library path so that an installed library is
     # used rather than the library just built.  This substitution function
     # tries to insert our library path first. Also, use the same compiler used
     # to build perlmain.c to link so that a C++ compiler may be used if
     # necessary.
     $inherited =~ s:MAP_LINKCMD\s.*\s*\$\(CC\):MAP_LINKCMD   = \$(PERLMAINCC) -L/usr/local/lib: ;
     $inherited;
 }
