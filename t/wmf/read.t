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
          'ad47b8a3356b5f65a09aa6012f745ec15f93880073377c4fc4315f5e433d1094',
          '73814b42d6626921801e44fd18c75ee80207f8f4a5521cc77a4688b39afa721f' );
++$test;
testRead( 'clock.wmf',
          'ad47b8a3356b5f65a09aa6012f745ec15f93880073377c4fc4315f5e433d1094',
          '555d14b94e78a128dc9a4862b80cfc2abbe0e9abbd003a05139262d542b15f5f' );


