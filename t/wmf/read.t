#!/usr/local/bin/perl
#
# Test reading WMF files
#
# Whenever a new test is added/removed, be sure to update the
# 1..n ouput.
#
BEGIN { $| = 1; $test=1; print "1..2\n"; }
END {print "not ok $test\n" unless $loaded;}
use Image::Magick;
$loaded=1;

require 't/subroutines.pl';

chdir 't/wmf' || die 'Cd failed';

testRead( 'wizard.wmf',
          'ebc0b5f23995f6d732600ca91378576c4a7cfbd2c21f1712b584bbf6eef03a26',
          '4358b4dba2c3213a58135b2d2271f6000371095e6d6135aa2163ab456f6cbcf3' );
++$test;
testRead( 'clock.wmf',
          'ebc0b5f23995f6d732600ca91378576c4a7cfbd2c21f1712b584bbf6eef03a26',
          'cb83d38f2b3e6ad9d3e58c01559c2535b52867dc3ce3ccc745e9e4ed79752fdd' );


