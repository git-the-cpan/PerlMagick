#!/usr/local/bin/perl
#
# Test writing MPEG images
#
# Contributed by Bob Friesenhahn <bfriesen@simple.dallas.tx.us>
#
BEGIN { $| = 1; $test=1; print "1..1\n"; }
END {print "not ok $test\n" unless $loaded;}

use Image::Magick;
$loaded=1;

require 't/subroutines.pl';

chdir 't/mpeg' || die 'Cd failed';

#
# 1) Test creating an mpeg
#    This only verifies the first frame as per ImageMagick default
#
#    To do anything else would require a change to testReadWrite
#
testReadWrite( 'input.gif', 'output.mpeg', '',
	       '5c8a39a6e0847439b9842c7b291b5fe9' );

