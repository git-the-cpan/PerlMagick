#!/usr/local/bin/perl
#
# Test reading formats supported directly by ImageMagick
#
# Whenever a new test is added/removed, be sure to update the
# 1..n ouput.
#
BEGIN { $| = 1; $test=1; print "1..45\n"; }
END {print "not ok $test\n" unless $loaded;}
use Image::Magick;
$loaded=1;

require 't/subroutines.pl';

chdir 't' || die 'Cd failed';


print("AVS X image file ...\n");
testRead( 'input.avs',
  '975cdb03f0fa923936f1cecf7b8a49a917493393a0eb098828ab710295195584');

print("Microsoft Windows bitmap image file ...\n");
++$test;
testRead( 'input.bmp',
  '63f3fc759dc1f25640b5bff50ffbb826b978bc215ae4bd5382abcb45bd2f8351');

print("Microsoft Windows 24-bit bitmap image file ...\n");
++$test;
testRead( 'input.bmp24',
  '975cdb03f0fa923936f1cecf7b8a49a917493393a0eb098828ab710295195584');

print("ZSoft IBM PC multi-page Paintbrush file ...\n");
++$test;
testRead( 'input.dcx',
  '975cdb03f0fa923936f1cecf7b8a49a917493393a0eb098828ab710295195584');

print("Microsoft Windows bitmap image file ...\n");
++$test;
testRead( 'input.dib',
  '975cdb03f0fa923936f1cecf7b8a49a917493393a0eb098828ab710295195584');

print("Flexible Image Transport System ...\n");
++$test;
testRead( 'input.fits',
  '48782ed397e05a2e44984fb7e79dc3490b8eb48f9ad72da26da9eda6c613eaba' );

print("CompuServe graphics interchange format ...\n");
++$test;
testRead( 'input.gif',
  'd23fa2a0b73778b25971b6c9c0391f07596fcb1d7c4f79f304c14716c24b043d');

print("CompuServe graphics interchange format (1987) ...\n");
++$test;
testRead( 'input.gif87',
  'd23fa2a0b73778b25971b6c9c0391f07596fcb1d7c4f79f304c14716c24b043d');

print("Gradient (gradual passing from one shade to another) ...\n");
++$test;
testRead( 'gradient:red-blue',
  'd3e9e39e646147e5998a7b869185d9f8f1ad134e5fa85513d56de5d9fc19b14c',
  '82e7ef902c58e93654e79ed71521560dc765289a8ef3616445cf496cd4d11636' );

print("GRANITE (granite texture) ...\n");
++$test;
testRead( 'granite:',
  'd84df0faf2e452f4b1cfb65a3d378b3240cdda27497a3f1fde0059ed060e65c2');

print("Microsoft icon ...\n");
++$test;
testRead( 'input.ico',
  'a30cea966c108ed60af71aaf3180a4d5fe29f3ab2a66b4389e97815dfe93e1aa' );

print("Magick image file format ...\n");
++$test;
testRead( 'input.miff',
  '975cdb03f0fa923936f1cecf7b8a49a917493393a0eb098828ab710295195584');

print("MTV Raytracing image format ...\n");
++$test;
testRead( 'input.mtv',
  '975cdb03f0fa923936f1cecf7b8a49a917493393a0eb098828ab710295195584');

print("Xv's visual schnauzer format. ...\n");
++$test;
testReadCompare('input_p7.p7', 'reference/read/input_p7.miff', q//,
                0.000005, 0.00005);

print("NULL (white image) ...\n");
++$test;
testRead( 'NULL:white', '3c907c7fc6edfcf15767c67e22c25cf9f907ba8ee59811aaae79dafd7c8ff198',
  '90fe9d00c453d0fa8a023a589b601e6fca2536f6429a227835bb7b6824f7d32a');

print("NULL (black image) ...\n");
++$test;
testRead( 'NULL:black',
  'bb9f8df61474d25e71fa00722318cd387396ca1736605e1248821cc0de3d3af8');

print("NULL (DarkOrange image) ...\n");
++$test;
testRead( 'NULL:DarkOrange',
  '13e1759e5d83e22b26f0ff42dd0d1db07d936ec21a95b2655ed77e1e2a4f82ee');

print("Portable bitmap format (black and white), ASCII format ...\n");
++$test;
testRead( 'input_p1.pbm',
  'c3db0a928eb365a8d4c132fccf913174f22864253e3974d89e7af6b81f57b14e');

print("Portable bitmap format (black and white), binary format ...\n");
++$test;
testRead( 'input_p4.pbm',
  'c3db0a928eb365a8d4c132fccf913174f22864253e3974d89e7af6b81f57b14e');

print("ZSoft IBM PC Paintbrush file ...\n");
++$test;
testRead( 'input.pcx',
  '975cdb03f0fa923936f1cecf7b8a49a917493393a0eb098828ab710295195584');

print("Portable graymap format (gray scale), ASCII format ...\n");
++$test;
testRead( 'input_p2.pgm',
  'be2672b247d1d131614d2225ba6abf062c835a5b353a90c98b814832a417424c');

print("Portable graymap format (gray scale), binary format ...\n");
++$test;
testRead( 'input_p5.pgm',
  'be2672b247d1d131614d2225ba6abf062c835a5b353a90c98b814832a417424c');

print("Apple Macintosh QuickDraw/PICT file ...\n");
++$test;
testRead( 'input.pict',
  '975cdb03f0fa923936f1cecf7b8a49a917493393a0eb098828ab710295195584');

print("Alias/Wavefront RLE image format ...\n");
++$test;
testRead( 'input.rle',
  '975cdb03f0fa923936f1cecf7b8a49a917493393a0eb098828ab710295195584');

print("Portable pixmap format (color), ASCII format ...\n");
++$test;
testRead( 'input_p3.ppm',
  '975cdb03f0fa923936f1cecf7b8a49a917493393a0eb098828ab710295195584');

print("Portable pixmap format (color), binary format ...\n");
++$test;
testRead( 'input_p6.ppm',
  '975cdb03f0fa923936f1cecf7b8a49a917493393a0eb098828ab710295195584');

print("Adobe Photoshop bitmap file ...\n");
++$test;
testRead( 'input.psd',
  '975cdb03f0fa923936f1cecf7b8a49a917493393a0eb098828ab710295195584');

print("Irix RGB image file ...\n");
++$test;
testRead( 'input.sgi',
  '975cdb03f0fa923936f1cecf7b8a49a917493393a0eb098828ab710295195584');

print("SUN 1-bit Rasterfile ...\n");
++$test;
testRead( 'input.im1',
  'd2c99db9feac60999e89e6ff9e9561ebd880009e1406fe069917164fcd277ab2');

print("SUN 8-bit Rasterfile ...\n");
++$test;
testRead( 'input.im8',
  'd23fa2a0b73778b25971b6c9c0391f07596fcb1d7c4f79f304c14716c24b043d');

print("SUN TrueColor Rasterfile ...\n");
++$test;
testRead( 'sun:input.im24',
  '975cdb03f0fa923936f1cecf7b8a49a917493393a0eb098828ab710295195584');

print("Truevision Targa image file ...\n");
++$test;
testRead( 'input.tga',
  '975cdb03f0fa923936f1cecf7b8a49a917493393a0eb098828ab710295195584');

print("PSX TIM file ...\n");
++$test;
testRead( 'input.tim',
  'c0de44d598be0f20ada13725070711f21b809025b3296bb0f8cb926e0b091ee0');

print("Khoros Visualization image file ...\n");
++$test;
testRead( 'input.viff',
  '0be6b76ef0f8748db46b023a171588c2c27832e22000f44f0788f8270b6ffd5f');

print("WBMP (Wireless Bitmap (level 0) image) ...\n");
++$test;
testRead( 'input.wbmp',
  '2d30f7486d995c1cb86fea6e134e5ab71fd081aff55d107ac0db728e8b090e86');

print("X Windows system bitmap (black and white only) ...\n");
++$test;
testRead( 'input.xbm',
  '49bf0a542c68d40e95da31aae596d4fa2269adeac9bb781a7fc92bdb845a888f');

print("XC: Constant image of X server color ...\n");
++$test;
testRead( 'xc:black',
  'bb9f8df61474d25e71fa00722318cd387396ca1736605e1248821cc0de3d3af8');

print("X Windows system pixmap file (color) ...\n");
++$test;
testRead( 'input.xpm',
  'd23fa2a0b73778b25971b6c9c0391f07596fcb1d7c4f79f304c14716c24b043d');

print("X Windows system window dump file (color) ...\n");
++$test;
testRead( 'input.xwd',
  '975cdb03f0fa923936f1cecf7b8a49a917493393a0eb098828ab710295195584');

print("TILE (Tile image with a texture) ...\n");
# This is an internal generated format
# We will tile using the default image and a MIFF file
#
++$test;
testReadSized( 'TILE:input.miff',
  '140x92',
  8,
  'a961d7f88c9cf7e432545d0340edcf908b4c8f16326d6434ce22eeaaecf4cf47');


print("CMYK format ...\n");
++$test;
testReadSized( 'input_70x46.cmyk',
   '70x46',
   8,
   '3bda6f5e91f5964ee82a4ed7328bec206e715833051d921b09108707e695e8b5');

print("GRAY format ...\n");
++$test;
testReadSized( 'input_70x46.gray',
   '70x46',
   8,
   '48782ed397e05a2e44984fb7e79dc3490b8eb48f9ad72da26da9eda6c613eaba' );

print("RGB format ...\n");
++$test;
testReadSized( 'input_70x46.rgb',
   '70x46',
   8,
   '975cdb03f0fa923936f1cecf7b8a49a917493393a0eb098828ab710295195584' );

print("RGBA format ...\n");
++$test;
testReadSized( 'input_70x46.rgba',
   '70x46',
   8,
   '975cdb03f0fa923936f1cecf7b8a49a917493393a0eb098828ab710295195584' );


print("UYVY format ...\n");
++$test;
testReadSized( 'input_70x46.uyvy',
   '70x46',
   0,
   'd4d5645764026663f4004b41ec5f4b694994ee43afe54af03a7e9af45884f032',
   '1ef67135bbe2aadc1c06997566f9d84fc8600c0a4c5a01e701296530e057726f' );
