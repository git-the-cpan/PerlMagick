#!/usr/local/bin/perl
#
# Test writing PNG images when 16bit support is enabled
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
# 1) Test pseudocolor image
#
testReadWrite( 'input_256.png',
  'output_256.png',
  q/quality=>54/,
  '764c39b3dd959383ede9ad0217d655ced14f6e4a649b962be71680992916528e' );

#
# 2) Test truecolor image
#
++$test;
testReadWrite( 'input_truecolor.png',
  'output_truecolor.png',
  q/quality=>55/,
  '1aa26327416ce05264f89c6a23643d84b1f2cc263a944a809807066f3ff87e36' );

#
# 3) Test monochrome image
#
++$test;
testReadWrite( 'input_mono.png',
  'output_mono.png', '',
  '9806baaaff93f82136ef9c5de65b81ec728c5ee2bd518b6766fa2d656d113dbc' );

#
# 4) Test Multiple-image Network Graphics
#
++$test;
testReadWrite( 'input.mng',
  'output.mng',
  q/quality=>55/,
  'b054bb6b19eba09f9ae531ca3e66399125d564cc056e3b5c230782f162af2a59' );

#
# 5) Test 16-bit Portable Network Graphics
# 
++$test;
testReadWrite( 'input_16.png',
  'output_16.png',
  q/quality=>55/,
  '72fccba220406b3ea3383cf74313b0f7491f80af800506b63851cee056e5ad8e',
  'e1069360f0afcb5b4661ecae6c4a96c5bb8c3c707e0554054bd4adbb8b7fc6db');


