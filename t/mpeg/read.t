#!/usr/local/bin/perl
#
# Test reading MPEG images
#
# Contributed by Bob Friesenhahn <bfriesen@simple.dallas.tx.us>
#

BEGIN { $| = 1; $test=1; print "1..4\n"; }
END {print "not ok $test\n" unless $loaded;}
use Image::Magick;
$loaded=1;

require 't/subroutines.pl';

chdir 't/mpeg' || die 'Cd failed';

#
# 1) Read first MPEG frame
#
testRead( 'input.mpeg[0]', '5c8a39a6e0847439b9842c7b291b5fe9' );

#
# 2) Read second MPEG frame
#
++$test;
testRead( 'input.mpeg[1]', '4262fcadb28a71a0fa7b675027193526' );

#
# 3) Read third MPEG frame
#
++$test;
testRead( 'input.mpeg[2]', '869fdb5ffd7386161074b7aaf4d79cff' );

#
# 4) Read last MPEG frame
#
++$test;
testRead( 'input.mpeg[3]', '869fdb5ffd7386161074b7aaf4d79cff' );

