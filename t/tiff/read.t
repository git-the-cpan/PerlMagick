#!/usr/local/bin/perl
#
# Test reading TIFF images
#
# Contributed by Bob Friesenhahn <bfriesen@simple.dallas.tx.us>
#
BEGIN { $| = 1; $test=1; print "1..11\n"; }
END {print "not ok $test\n" unless $loaded;}

use Image::Magick;
$loaded=1;

require 't/subroutines.pl';

chdir 't/tiff' || die 'Cd failed';

#
# 1) Test Reading Monochrome
# 
print("Monochrome ...\n");
testRead ( 'input_mono.tiff',
  'c3db0a928eb365a8d4c132fccf913174f22864253e3974d89e7af6b81f57b14e' );

#
# 2) Test reading PseudoColor
#
++$test;
print("PseudoColor ...\n");
testRead( 'input_256.tiff',
  'e77f78b3bbfefe57b5981e60a6bf08c137aa527395fe7f206cd69198eb08ddd0' );

#
# 3) Test reading PseudoColor using contiguous planar packing
#
++$test;
print("PseudoColor contiguous planes ...\n");
testRead( 'input_256_planar_contig.tiff',
  'e77f78b3bbfefe57b5981e60a6bf08c137aa527395fe7f206cd69198eb08ddd0' );

#
# 4) Test reading PseudoColor using seperate planes
#
++$test;
print("PseudoColor seperate planes ...\n");
testRead( 'input_256_planar_separate.tiff',
  'e77f78b3bbfefe57b5981e60a6bf08c137aa527395fe7f206cd69198eb08ddd0' );

#
# 5) Test Reading TrueColor (8-bit)
# 
++$test;
print("TrueColor (8-bit) image ...\n");
testRead( 'input_truecolor.tiff',
  '489aed63f0c516497a59881cd42ae99579bd962a3b5346a8820c1f47a1ebf80c' );

#
# 6) Test Reading TrueColor (16-bit)
#
++$test;
print("TrueColor (16-bit) image ...\n");
testRead( 'input_truecolor_16.tiff',
  '3c310bd98afc8fea96d8ffb067adfb85116a969c404a8e3c7389bd9f5ba5608a',
  '36900df8fef5246db25bd747c5b944fc804efe3e9a534ad2467772a8348346a5',
  '36900df8fef5246db25bd747c5b944fc804efe3e9a534ad2467772a8348346a5');

#
# 7) Test Reading 8-bit TrueColor Tiled (32x32 tiles)
# 
++$test;
print("TrueColor (8-bit) tiled image, 32x32 tiles ...\n");
testRead( 'input_truecolor_tiled32x32.tiff',
  '489aed63f0c516497a59881cd42ae99579bd962a3b5346a8820c1f47a1ebf80c' );

#
# 8) Test Reading 8-bit TrueColor Tiled (8 rows per strip)
# 
++$test;
print("TrueColor (8-bit) stripped, image, 8 rows per strip ...\n");
testRead( 'input_truecolor_stripped.tiff',
  '489aed63f0c516497a59881cd42ae99579bd962a3b5346a8820c1f47a1ebf80c' );

#
# 9) Test Reading Grayscale 8-bit
# 
++$test;
print("Grayscale (8-bit) ...\n");
testRead( 'input_gray_8bit.tiff',
  '3aa1d0e0c053c38146de36126054eb007175e3b1fd4a92f09bed59452e991a2d');

#
# 10) Test Reading Grayscale 12-bit
# 
++$test;
print("Grayscale (12-bit) ...\n");
testRead( 'input_gray_12bit.tiff',
  'b8ee99039f7bd98146ccc48297ec04e1f86947b0299f2bc2393f881c2def3f55',
  'f969b80a2cf874de6f409d6f316ef0b10cf49dc66233b8fc2634b234dfce0ffa',
  'a585212dffa1387fc728d41ae620111babb16ed89d9e8dce3a1c1af1600f41f2');

#
# 11) Test Reading Grayscale 16-bit
# 
++$test;
print("Grayscale (16-bit) ...\n");
testRead( 'input_gray_16bit.tiff',
  '1502b4e5747ed8805fe9103f56f9c4097f60440b3a867fa6b1ae0ba81f12a90d',
  'b938c29b27bc688511df9a0d6cc9d6e65d18de1403c6d08a797318e633915ee7',
  'b938c29b27bc688511df9a0d6cc9d6e65d18de1403c6d08a797318e633915ee7' );
