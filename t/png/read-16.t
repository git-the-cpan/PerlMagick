#!/usr/local/bin/perl
#
# Test reading PNG images when 16bit support is enabled
#
# Contributed by Bob Friesenhahn <bfriesen@simple.dallas.tx.us>
#

BEGIN { $| = 1; $test=1; print "1..5\n"; }
END {print "not ok $test\n" unless $loaded;}
use Image::Magick;
$loaded=1;

require 't/subroutines.pl';

chdir 't/png' || die 'Cd failed';

#
# 1) Test Monochrome PNG
# 
testRead( 'input_mono.png',
  '9806baaaff93f82136ef9c5de65b81ec728c5ee2bd518b6766fa2d656d113dbc' );

#
# 2) Test 256 color pseudocolor PNG
# 
++$test;
testRead( 'input_256.png',
  '764c39b3dd959383ede9ad0217d655ced14f6e4a649b962be71680992916528e' );

#
# 3) Test TrueColor PNG
# 
++$test;
testRead( 'input_truecolor.png',
  '1aa26327416ce05264f89c6a23643d84b1f2cc263a944a809807066f3ff87e36' );

#
# 4) Test Multiple-image Network Graphics
# 
++$test;
testRead( 'input.mng',
  'b054bb6b19eba09f9ae531ca3e66399125d564cc056e3b5c230782f162af2a59' );

#
# 5) Test 16-bit Portable Network Graphics
# 
++$test;
testRead( 'input_16.png',
  '72fccba220406b3ea3383cf74313b0f7491f80af800506b63851cee056e5ad8e',
  'e1069360f0afcb5b4661ecae6c4a96c5bb8c3c707e0554054bd4adbb8b7fc6db');

