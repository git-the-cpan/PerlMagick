#!/usr/local/bin/perl
#
# Test writing TIFF images
#
# Contributed by Bob Friesenhahn <bfriesen@simple.dallas.tx.us>
#
BEGIN { $| = 1; $test=1; print "1..3\n"; }
END {print "not ok $test\n" unless $loaded;}

use Image::Magick;
$loaded=1;

require 't/subroutines.pl';

chdir 't/tiff' || die 'Cd failed';

#
# 1) Test pseudocolor image
#
print("PsuedoColor image ...\n");
testReadWrite( 'input_256.tiff',
  'output_256.tiff',
  q/quality=>54/,
  'e77f78b3bbfefe57b5981e60a6bf08c137aa527395fe7f206cd69198eb08ddd0');

#
# 2) Test truecolor image
#
++$test;
print("TrueColor image ...\n");
testReadWrite( 'input_truecolor.tiff',
  'output_truecolor.tiff',
  q/quality=>55/,
  '489aed63f0c516497a59881cd42ae99579bd962a3b5346a8820c1f47a1ebf80c' );

#
# 3) Test monochrome image
#
++$test;
print("Monochrome image ...\n");
testReadWrite(  'input_mono.tiff',
  'output_mono.tiff',
  q//,
  'c3db0a928eb365a8d4c132fccf913174f22864253e3974d89e7af6b81f57b14e' );
