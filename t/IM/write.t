#!/usr/local/bin/perl
#
# Test reading formats supported directly by ImageMagick
#
# (Any formats depending on external programs need to be moved elsewhere)
#
# Currently supported tests are for formats that ImageMagick
# knows how to both read and write.
#
# Whenever a new test is added/removed, be sure to update the
# 1..n ouput.

BEGIN { $| = 1; $test=1; print "1..26\n"; }
END {print "not ok $test\n" unless $loaded;}
use Image::Magick;
$loaded=1;

require 't/subroutines.pl';

chdir 't/IM' || die 'Cd failed';

#
# 1) AVS X image file
#
testReadWrite( 'AVS:input.avs',
               'AVS:output.avs',
               q//,
               '93bd185340123477f0a0e6622392a5b4' );
#
# 2) Joint Bi-level Image experts Group file interchange format
#
++$test;
testReadWrite( 'BIE:input.bie',
               'BIE:output.bie',
               q//,
               '1a8d5855273e27302856c727934c9f9a' );

#
# 3) Microsoft Windows bitmap image file
#
++$test;
testReadWrite( 'BMP:input.bmp',
               'BMP:output.bmp',
               q//,
               '25c550da420eeb782f57dd88c689e819' );

#
# 4) Microsoft Windows 24-bit bitmap image file
#
++$test;
testReadWrite( 'BMP24:input.bmp24',
               'BMP24:output.bmp24',
               q//,
               '3a17784c61a87a98f8e25f1977b9d363' );

#
# 5) ZSoft IBM PC multi-page Paintbrush file
#
++$test;
testReadWrite( 'DCX:input.dcx',
               'DCX:output.dcx',
               q//,
               '25c550da420eeb782f57dd88c689e819' );

#
# 6) Flexible Image Transport System
#
++$test;
testReadWrite( 'FITS:input.fits',
               'FITS:output.fits',
               q//,
               '21e7890c853c980821f28d233386f872' );

#
# 7) CompuServe graphics interchange format
#
++$test;
testReadWrite( 'GIF:input.gif',
               'GIF:output.gif',
               q//,
               '25c550da420eeb782f57dd88c689e819' );

#
# 8) CompuServe graphics interchange format (1987)
#
++$test;
testReadWrite( 'GIF87:input.gif87',
               'GIF87:output.gif87',
               q//,
               '25c550da420eeb782f57dd88c689e819' );

#
# 9) Magick image file format
#
++$test;
testReadWrite( 'MIFF:input.miff',
               'MIFF:output.miff',
               q//,
               '25c550da420eeb782f57dd88c689e819' );

#
# 10) MTV Raytracing image format
#
++$test;
testReadWrite( 'MTV:input.mtv',
               'MTV:output.mtv',
               q//,
               '3a17784c61a87a98f8e25f1977b9d363' );

#
# 11) Xv's visual schnauzer format.
#
++$test;
testReadWrite( 'P7:input.p7',
               'P7:output.p7',
               q//,
               '30240a853c82002347c8a12e38e9f394' );

#
# 12) Portable bitmap format (black and white)
#
++$test;
testReadWrite( 'PBM:input.pbm',
               'PBM:output.pbm',
               q//,
               '1a8d5855273e27302856c727934c9f9a' );

#
# 13) ZSoft IBM PC Paintbrush file
#
++$test;
testReadWrite( 'PCX:input.pcx',
               'PCX:output.pcx',
               q//,
               '25c550da420eeb782f57dd88c689e819' );

#
# 14) Portable graymap format (gray scale)
#
++$test;
testReadWrite( 'PGM:input.pgm',
               'PGM:output.pgm',
               q//,
               '60c799dcec989ad147468a24f76ddb5f' );

#
# 15) Apple Macintosh QuickDraw/PICT file
#
++$test;
testReadWrite( 'PICT:input.pict',
               'PICT:output.pict',
               q//,
               'a166b7ae4fdb91cf89f612761f22317e' );

#
# 16) Portable pixmap format (color)
#
++$test;
testReadWrite( 'PPM:input.ppm',
               'PPM:output.ppm',
               q//,
               'd5fdeba9d1e28db7c07f1485d0d64697' );

#
# 17) Adobe Photoshop bitmap file
#
++$test;
testReadWrite( 'PSD:input.psd',
               'PSD:output.psd',
               q//,
               '25c550da420eeb782f57dd88c689e819' );

#
# 18) Radiance image file
#
++$test;
testReadWrite( 'RAD:input.rad',
               'MIFF:output.rad',
               q//,
               '695965272ca7aa04c75852185cc3df30' );

#
# 19) Irix RGB image file
#
++$test;
testReadWrite( 'SGI:input.sgi',
               'SGI:output.sgi',
               q//,
               'a05c5863b2d073046329b0b71d5e85e9' );

#
# 20) SUN 1-bit Rasterfile
#
++$test;
testReadWrite( 'SUN:input.im1',
               'SUN:output.im1',
               q//,
               '5ee57461fb1810e09ed6ddc6ffb11c7d' );

#
# 21) SUN 8-bit Rasterfile
#
++$test;
testReadWrite( 'SUN:input.im8',
               'SUN:output.im8',
               q//,
               '25c550da420eeb782f57dd88c689e819' );

#
# 22) SUN True-Color Rasterfile
#
++$test;
testReadWrite( 'SUN:input.im24',
               'SUN:output.im24',
               q//,
               '5cb2c2f3d73b57302059da592506be22' );

#
# 23) Truevision Targa image file
#
++$test;
testReadWrite( 'TGA:input.tga',
               'TGA:output.tga',
               q//,
               '25c550da420eeb782f57dd88c689e819' );

#
# 24) X Windows system bitmap (black and white only)
#
++$test;
testReadWrite( 'XBM:input.xbm',
               'XBM:output.xbm',
               q//,
               '1a8d5855273e27302856c727934c9f9a' );

#
# 25) X Windows system pixmap file (color)
#
++$test;
testReadWrite( 'XPM:input.xpm',
               'XPM:output.xpm',
               q//,
               '2f1ab12288938e48c54b0d237c3c58d1' );

#
# 26) X Windows system window dump file (color)
#
++$test;
testReadWrite( 'XWD:input.xwd',
               'XWD:output.xwd',
               q//,
               '25c550da420eeb782f57dd88c689e819' );

1;
