#!/usr/local/bin/perl
#
# Test reading PNG images
#
# Contributed by Bob Friesenhahn <bfriesen@simple.dallas.tx.us>
#

BEGIN { $| = 1; $test=1; print "1..6\n"; }
END {print "not ok $test\n" unless $loaded;}
use Image::Magick;
$loaded=1;

require 't/subroutines.pl';

chdir 't/png' || die 'Cd failed';

#
# 1) Test Black-and-white, bit_depth=1 PNG
# 
print( "1-bit grayscale PNG ...\n" );
testRead( 'input_bw.png',
  'e4c459cc79be8a780dcfe72e01cd9352d8cb49052d9dca782013b314cba65b0b' );

#
# 2) Test Monochrome PNG
# 
++$test;
print( "8-bit grayscale PNG ...\n" );
testRead( 'input_mono.png',
  '9806baaaff93f82136ef9c5de65b81ec728c5ee2bd518b6766fa2d656d113dbc' );

#
# 3) Test 16-bit Portable Network Graphics
# 
++$test;
print( "16-bit grayscale PNG ...\n" );
testRead( 'input_16.png',
  '72fccba220406b3ea3383cf74313b0f7491f80af800506b63851cee056e5ad8e',
  'e1069360f0afcb5b4661ecae6c4a96c5bb8c3c707e0554054bd4adbb8b7fc6db' );
#
# 4) Test 256 color pseudocolor PNG
# 
++$test;
print( "8-bit indexed-color PNG ...\n" );
testRead( 'input_256.png',
  '764c39b3dd959383ede9ad0217d655ced14f6e4a649b962be71680992916528e' );

#
# 5) Test TrueColor PNG
# 
++$test;
print( "24-bit Truecolor PNG ...\n" );
testRead( 'input_truecolor.png',
  '1aa26327416ce05264f89c6a23643d84b1f2cc263a944a809807066f3ff87e36' );

#
# 6) Test Multiple-image Network Graphics
# 
++$test;
print( "MNG with 24-bit Truecolor PNGs...\n" );
testRead( 'input.mng',
  'b054bb6b19eba09f9ae531ca3e66399125d564cc056e3b5c230782f162af2a59' );

