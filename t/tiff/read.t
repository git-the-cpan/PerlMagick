#!/usr/local/bin/perl
#
# Test reading TIFF images
#
# Contributed by Bob Friesenhahn <bfriesen@simple.dallas.tx.us>
#
BEGIN { $| = 1; $test=1; print "1..16\n"; }
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
  '1eb1f91d284e0b19af6610a8e3884a87178353a850287b63a0dabe8570a83e3f' );

#
# 2) Test reading PseudoColor (16 color)
#
++$test;
print("PseudoColor (16 color)...\n");
testRead( 'input_16.tiff',
  'eff9f8087197689c717ee4678bc242d2973c569c20dd29bc23631f5f0d0cb058' );

#
# 3) Test reading PseudoColor (16 color + matte channel)
#
++$test;
print("PseudoColor (16 color + matte channel)...\n");
testRead( 'input_16_matte.tiff',
  '37d9cfa7d8d2b5a4224eafe0ace10a4481b9566fb0ba0f29acef95dafd87eabe',
  '37d9cfa7d8d2b5a4224eafe0ace10a4481b9566fb0ba0f29acef95dafd87eabe',
  'cd4048d89248cf0a6630a9de0d924a2b047ee6bfd58c07723ed55c5564d174cd' );

#
# 4) Test reading PseudoColor (256 color)
#
++$test;
print("PseudoColor (256 color) ...\n");
testRead( 'input_256.tiff',
  'af0e4541c30c01c9f3527a87e5ea06912ade17dea3d3295028b87b856ec21558' );

#
# 5) Test reading PseudoColor (256 color + matte channel)
#
++$test;
print("PseudoColor (256 color + matte channel) ...\n");
testRead( 'input_256_matte.tiff',
	'01f9d29ebea733fb815dcccfa1fb769cf223d60d8bfbce47b8329d119587de15' );

#
# 6) Test reading PseudoColor using contiguous planar packing
#
++$test;
print("PseudoColor (256 color) contiguous planes ...\n");
testRead( 'input_256_planar_contig.tiff',
  'af0e4541c30c01c9f3527a87e5ea06912ade17dea3d3295028b87b856ec21558' );

#
# 7) Test reading PseudoColor using seperate planes
#
++$test;
print("PseudoColor (256 color) seperate planes ...\n");
testRead( 'input_256_planar_separate.tiff',
  'af0e4541c30c01c9f3527a87e5ea06912ade17dea3d3295028b87b856ec21558' );

#
# 8) Test Reading TrueColor (8-bit)
# 
++$test;
print("TrueColor (8-bit) image ...\n");
testRead( 'input_truecolor.tiff',
  '6452b611f3bf10ebe0f4809b6e27570931bc982d6c3993e28ab3d27527b182fa' );

#
# 9) Test Reading TrueColor (16-bit)
#
++$test;
print("TrueColor (16-bit) image ...\n");
testRead( 'input_truecolor_16.tiff',
  'efabb2e1a99ad20078f699bc190a1fc02555dbb45513696532283a9757aba692',
  '0272ad07d7e84c8635fd3aa7c1748bbcd6ce6f27047e34fb24bc4c93cc1dba13' );

#
# 10) Test Reading 8-bit TrueColor Tiled (32x32 tiles)
# 
++$test;
print("TrueColor (8-bit) tiled image, 32x32 tiles ...\n");
testRead( 'input_truecolor_tiled32x32.tiff',
  '6452b611f3bf10ebe0f4809b6e27570931bc982d6c3993e28ab3d27527b182fa' );

#
# 11) Test Reading 8-bit TrueColor Tiled (8 rows per strip)
# 
++$test;
print("TrueColor (8-bit) stripped, image, 8 rows per strip ...\n");
testRead( 'input_truecolor_stripped.tiff',
  '6452b611f3bf10ebe0f4809b6e27570931bc982d6c3993e28ab3d27527b182fa' );

#
# 12) Test Reading Grayscale 4-bit
#
++$test;
print("Grayscale (4-bit) ...\n");
testRead( 'input_gray_4bit.tiff',
  'a23eabe8f0c6aa3ae4e7ef2e6a86d37befe8d8cc83ad3ede010eca25275ba478');

#
# 13) Test Reading Grayscale 8-bit
# 
++$test;
print("Grayscale (8-bit) ...\n");
testRead( 'input_gray_8bit.tiff',
  'a3880cab9837b975d6f62116811a28578cef871c4879403a105e3d946160a078');

#
# 14) Test Reading Grayscale 8-bit + matte
# 
++$test;
print("Grayscale (8-bit + matte) ...\n");
testRead( 'input_gray_8bit_matte.tiff',
	'1d09012a9334266bc64255cfc8305a89afba602a93e29bec0c793851f8bb01e7',
	'9928d426c46dc85062cef24eb913167b6e0cd93e0f597bc34a49c455c5e7dec2',
  '9f6fb67cbee16f46e18ffc3b38b54c81fd6bbbd44b1be91ca23cfb665586df6e' );

#
# 15) Test Reading Grayscale 12-bit
# 
++$test;
print("Grayscale (12-bit) ...\n");
testRead( 'input_gray_12bit.tiff',
  'ca02793076b8845454d3cc4d949bda5bc49fe16d063e310331f86318ed644ba7',
  'c71e330246d102f8b18abc00052c5c4ee66353f740b1035059483d916054ecb3',
  'c71e330246d102f8b18abc00052c5c4ee66353f740b1035059483d916054ecb3');

#
# 16) Test Reading Grayscale 16-bit
# 
++$test;
print("Grayscale (16-bit) ...\n");
testRead( 'input_gray_16bit.tiff',
  '77d523ddb8e58c0a0a4e0e891bc65212035e4c3b1a8c6d29b2093e0e331143a5',
  '7dfb9a0e1217d546b6f2fde1d5261f1fc0c817fc5f00edf72fc10edc41e03143');
