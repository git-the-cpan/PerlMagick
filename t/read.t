#!/usr/local/bin/perl
#
# Test read image method.
#
BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use Image::Magick;
$loaded=1;
$image=Image::Magick->new;
$x=$image->ReadImage('xc:black');
print "not " if "$x";
print "ok 1\n";
