# Generated automatically from Makefile.PL.in by configure.
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Image::Magick',
    'VERSION_FROM' => 'Magick.pm', # finds $VERSION
    'LIBS'	=> ['-L/usr/openwin/lib -L/usr/local/lib -lMagick -lX11 -lXext -ljbig -ljpeg -lmpeg -lpng -ltiff -lttf -lz -lm'],
    'DEFINE'	=> '',     # e.g., '-DHAVE_SOMETHING' 
    'INC'	=> '-I/usr/openwin/include -I/usr/openwin/include/X11 -I/usr/local/include/magick',
);
