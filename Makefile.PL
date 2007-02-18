#  Copyright 1999-2005 ImageMagick Studio LLC, a non-profit organization
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

use ExtUtils::MakeMaker;
use Config;

# Compute test specification
my $delegate_tests='t/*.t';
my $delegate;
foreach $delegate (qw/ bzlib jpeg lcms mpeg png ps tiff x xfig zlib/) {
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
   'VERSION'   => '6.3.2',

   # Preprocessor defines
   'DEFINE'	=> ' -D_LARGE_FILES=1 -DHAVE_CONFIG_H',     # e.g., '-DHAVE_SOMETHING' 

   # Header search specfication and preprocessor flags
   'INC'	=> '-I../ -I.. -I/usr/include/librsvg-2 -I/usr/include/glib-2.0 -I/usr/lib64/glib-2.0/include -I/usr/include/gtk-2.0 -I/usr/include/graphviz -I/usr/include/freetype2 -I/usr/include/libxml2',

   # C pre-processor flags (e.g. -I & -D options)
   # 'CPPFLAGS'    => "$Config{'cppflags'} -I/usr/include/librsvg-2 -I/usr/include/glib-2.0 -I/usr/lib64/glib-2.0/include -I/usr/include/gtk-2.0 -I/usr/include/graphviz -I/usr/include/freetype2 -I/usr/include/libxml2",

   # C compiler flags (e.g. -O -g)
   'CCFLAGS'     => "$Config{'ccflags'} -g -O2 -Wall -W -pthread",

   # Linker flags for building an executable
   'LDFLAGS'    =>  "-L../magick/.libs -lMagick $Config{'ldflags'}",

   # Linker flags for building a dynamically loadable module
   'LDDLFLAGS'  => "-L../magick/.libs -lMagick $Config{'lddlflags'}",

   # Install PerlMagick binary into ImageMagick bin directory
   'INSTALLBIN'	=> '/usr/local/bin',

   # Library specification
   'LIBS'	=> [ '-L/home/cristy/ImageMagick/ImageMagick/magick/.libs -L/usr/lib64 -lfreetype -llcms -ltiff -lfreetype -ljpeg -lgs -lpng -lXext -lXt -lSM -lICE -lX11 -lbz2 -lrsvg-2 -lgdk_pixbuf-2.0 -lpng12 -lm -lgobject-2.0 -lgmodule-2.0 -ldl -lglib-2.0 -lxml2 -lgvc -lz -lpthread -lm -lpthread' ],

   # Perl binary name (if a Perl binary is built)
   'MAP_TARGET'	=> 'PerlMagick',

   # Let CFLAGS drive optimization flags by setting OPTIMIZE to empty
   # 'OPTIMIZE'	=> '',

   # Use same compiler as ImageMagick
   'PERLMAINCC'	=> 'g++',

   # Set Perl installation prefix to ImageMagick installation prefix
#   'PREFIX'	=> '/usr/local',

   # Include delegate directories in tests
   test		=> { TESTS	=>	$delegate_tests},

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
     $inherited =~ s:MAP_LINKCMD\s.*\s*\$\(CC\):MAP_LINKCMD   = \$(PERLMAINCC) -L/home/cristy/ImageMagick/ImageMagick/magick/.libs: ;
     $inherited;
 }

#
# Substitutions for "test" section.
#
sub MY::test {
     package MY; # so that "SUPER" works right
     my $inherited = shift->SUPER::test(@_);

     # Run tests in our environment
     $inherited =~ s:PERL_DL_NONLAZY=1:/bin/sh ../magick.sh PERL_DL_NONLAZY=1:g ;
     $inherited;
 }
