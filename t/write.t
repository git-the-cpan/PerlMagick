#!/usr/local/bin/perl
#
# Test writing formats supported directly by ImageMagick
#
# Currently supported tests are for formats that ImageMagick
# knows how to both read and write.
#
# Whenever a new test is added/removed, be sure to update the
# 1..n ouput.

BEGIN { $| = 1; $test=1; print "1..34\n"; }
END {print "not ok $test\n" unless $loaded;}
use Image::Magick;
$loaded=1;

require 't/subroutines.pl';

chdir 't' || die 'Cd failed';

print("AVS X image file ...\n");
testReadWrite( 'AVS:input.avs',
  'AVS:output.avs',
  q//,
  '975cdb03f0fa923936f1cecf7b8a49a917493393a0eb098828ab710295195584');

print("Microsoft Windows bitmap image file ...\n");
++$test;
testReadWrite( 'BMP:input.bmp',
  'BMP:output.bmp',
  q//,
  '63f3fc759dc1f25640b5bff50ffbb826b978bc215ae4bd5382abcb45bd2f8351');

print("Microsoft Windows 24-bit bitmap image file ...\n");
++$test;
testReadWrite( 'BMP:input.bmp24',
  'BMP:output.bmp24',
  q//,
  '975cdb03f0fa923936f1cecf7b8a49a917493393a0eb098828ab710295195584');


print("ZSoft IBM PC multi-page Paintbrush file ...\n");
++$test;
testReadWrite( 'DCX:input.dcx',
  'DCX:output.dcx',
  q//,
  '975cdb03f0fa923936f1cecf7b8a49a917493393a0eb098828ab710295195584');

print("Microsoft Windows 3.X DIB file ...\n");
++$test;
testReadWrite( 'DIB:input.dib',
  'DIB:output.dib',
  q//,
  '975cdb03f0fa923936f1cecf7b8a49a917493393a0eb098828ab710295195584');

print("Flexible Image Transport System ...\n");
++$test;
testReadWrite( 'FITS:input.fits',
  'FITS:output.fits',
  q//,
  '48782ed397e05a2e44984fb7e79dc3490b8eb48f9ad72da26da9eda6c613eaba' );

print("CompuServe graphics interchange format ...\n");
++$test;
testReadWrite( 'GIF:input.gif',
  'GIF:output.gif',
  q//,
  'd23fa2a0b73778b25971b6c9c0391f07596fcb1d7c4f79f304c14716c24b043d');

print("CompuServe graphics interchange format (1987) ...\n");
++$test;
testReadWrite( 'GIF87:input.gif87',
  'GIF87:output.gif87',
  q//,
  'd23fa2a0b73778b25971b6c9c0391f07596fcb1d7c4f79f304c14716c24b043d');

print("Magick image file format ...\n");
++$test;
testReadWrite( 'MIFF:input.miff',
  'MIFF:output.miff',
  q//,
  '975cdb03f0fa923936f1cecf7b8a49a917493393a0eb098828ab710295195584');

print("MTV Raytracing image format ...\n");
++$test;
testReadWrite( 'MTV:input.mtv',
  'MTV:output.mtv',
  q//,
  '975cdb03f0fa923936f1cecf7b8a49a917493393a0eb098828ab710295195584');

print("Xv's visual schnauzer format ...\n");
++$test;
testReadWriteCompare( 'input.miff', 'P7:output_p7.p7', 'reference/write/output_p7.miff',
                      q/depth=>8/, q/dither=>0, depth=>8/, 0.000005, 0.00011);

print("Portable bitmap format (black and white), ASCII format ...\n");
++$test;
testReadWrite( 'PBM:input_p1.pbm',
  'PBM:output_p1.pbm',
  q/compression=>'None'/,
  'c3db0a928eb365a8d4c132fccf913174f22864253e3974d89e7af6b81f57b14e');

print("Portable bitmap format (black and white), binary format ...\n");
++$test;
testReadWrite( 'PBM:input_p4.pbm',
  'PBM:output_p4.pbm',
  q//,
  'c3db0a928eb365a8d4c132fccf913174f22864253e3974d89e7af6b81f57b14e');

print("ZSoft IBM PC Paintbrush file ...\n");
++$test;
testReadWrite( 'PCX:input.pcx',
  'PCX:output.pcx',
  q//,
  '975cdb03f0fa923936f1cecf7b8a49a917493393a0eb098828ab710295195584');

print("Portable graymap format (gray scale), ASCII format ...\n");
++$test;
testReadWrite( 'PGM:input_p2.pgm',
  'PGM:output_p2.pgm',
  q/compression=>'None'/,
  'be2672b247d1d131614d2225ba6abf062c835a5b353a90c98b814832a417424c');

print("Apple Macintosh QuickDraw/PICT file ...\n");
++$test;
testReadWrite( 'PICT:input.pict',
  'PICT:output.pict',
  q//,
  '975cdb03f0fa923936f1cecf7b8a49a917493393a0eb098828ab710295195584');

print("Portable pixmap format (color), ASCII format ...\n");
++$test;
testReadWrite( 'PPM:input_p3.ppm',
  'PPM:output_p3.ppm',
  q/compression=>'None'/,
  '975cdb03f0fa923936f1cecf7b8a49a917493393a0eb098828ab710295195584');

print("Portable graymap format (gray scale), binary format ...\n");
++$test;
testReadWrite( 'PGM:input_p5.pgm',
  'PGM:output_p5.pgm',
  q//,
  'be2672b247d1d131614d2225ba6abf062c835a5b353a90c98b814832a417424c');

print("Portable pixmap format (color), binary format ...\n");
++$test;
testReadWrite( 'PPM:input_p6.ppm',
  'PPM:output_p6.ppm',
  q//,
  '975cdb03f0fa923936f1cecf7b8a49a917493393a0eb098828ab710295195584');

print("Adobe Photoshop bitmap file ...\n");
++$test;
testReadWrite( 'PSD:input.psd',
  'PSD:output.psd',
  q//,
  '975cdb03f0fa923936f1cecf7b8a49a917493393a0eb098828ab710295195584' );

print("Irix RGB image file ...\n");
++$test;
testReadWrite( 'SGI:input.sgi',
  'SGI:output.sgi',
  q//,
  '975cdb03f0fa923936f1cecf7b8a49a917493393a0eb098828ab710295195584');

print("SUN 1-bit Rasterfile ...\n");
++$test;
testReadWrite( 'SUN:input.im1',
  'SUN:output.im1',
  q//,
  'd2c99db9feac60999e89e6ff9e9561ebd880009e1406fe069917164fcd277ab2');

print("SUN 8-bit Rasterfile ...\n");
++$test;
testReadWrite( 'SUN:input.im8',
  'SUN:output.im8',
  q//,
  'd23fa2a0b73778b25971b6c9c0391f07596fcb1d7c4f79f304c14716c24b043d');

print("SUN True-Color Rasterfile ...\n");
++$test;
testReadWrite( 'SUN:input.im24',
  'SUN:output.im24',
  q//,
  '975cdb03f0fa923936f1cecf7b8a49a917493393a0eb098828ab710295195584');

print("Truevision Targa image file ...\n");
++$test;
testReadWrite( 'TGA:input.tga',
  'TGA:output.tga',
  q//,
  '975cdb03f0fa923936f1cecf7b8a49a917493393a0eb098828ab710295195584');

print("Khoros Visualization image file ...\n");
++$test;
testReadWrite( 'VIFF:input.viff',
  'VIFF:output.viff',
  q//,
  '0be6b76ef0f8748db46b023a171588c2c27832e22000f44f0788f8270b6ffd5f');

print("WBMP (Wireless Bitmap (level 0) image) ...\n");
++$test;
testReadWrite( 'WBMP:input.wbmp',
  'WBMP:output.wbmp',
  q//,
  '2d30f7486d995c1cb86fea6e134e5ab71fd081aff55d107ac0db728e8b090e86');

print("X Windows system bitmap (black and white only) ...\n");
++$test;
testReadWrite( 'XBM:input.xbm',
  'XBM:output.xbm',
  q//,
  '49bf0a542c68d40e95da31aae596d4fa2269adeac9bb781a7fc92bdb845a888f');

print("X Windows system pixmap file (color) ...\n");
++$test;
testReadWrite( 'XPM:input.xpm',
  'XPM:output.xpm',
  q//,
  'd23fa2a0b73778b25971b6c9c0391f07596fcb1d7c4f79f304c14716c24b043d');


print("X Windows system window dump file (color) ...\n");
++$test;
testReadWrite( 'XWD:input.xwd',
  'XWD:output.xwd',
  q//,
  '975cdb03f0fa923936f1cecf7b8a49a917493393a0eb098828ab710295195584');

print("CMYK format ...\n");
++$test;
testReadWriteSized( 'CMYK:input_70x46.cmyk',
  'CMYK:output_70x46.cmyk',
  '70x46',
  8,
  q//,
  '397a9f8411f7bb065f4b6e56731734ddad8ea1a7d4c488745545e17dbe575903',
  '834b8d4cbc3a2dd8e57a3e7d3e7e56b536a58525e74c1462b16499c944cb9f54' );

print("GRAY format ...\n");
++$test;
testReadWriteSized( 'GRAY:input_70x46.gray',
  'GRAY:output_70x46.gray',
  '70x46',
  8,
  q//,
  '48782ed397e05a2e44984fb7e79dc3490b8eb48f9ad72da26da9eda6c613eaba' );

print("RGB format ...\n");
++$test;
testReadWriteSized( 'RGB:input_70x46.rgb',
  'RGB:output_70x46.rgb',
  '70x46',
  8,
  q//,
  '975cdb03f0fa923936f1cecf7b8a49a917493393a0eb098828ab710295195584' );


print("RGBA format ...\n");
++$test;
testReadWriteSized( 'RGBA:input_70x46.rgba',
  'RGBA:output_70x46.rgba',
  '70x46',
  8,
  q//,
  '975cdb03f0fa923936f1cecf7b8a49a917493393a0eb098828ab710295195584' );

1;
