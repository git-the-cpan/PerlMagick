#!/usr/local/bin/perl
#
# Test write image method.
#
BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use Image::Magick;
$loaded=1;
$image=Image::Magick->new;
$x=$image->ReadImage('xc:black');
$x=$image->WriteImage('t/image.miff');
print "not " if "$x";
print "ok 1\n";
unlink('t/image.miff');
