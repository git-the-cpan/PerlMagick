#!/usr/local/bin/perl
#
# Test zoom method.
#
BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use Image::Magick;
$loaded=1;
$image=Image::Magick->new;
$x=$image->ReadImage('xc:black');
print "not ok 1\n" if "$x";
exit if "$x";
$image->Zoom('200x100!');
($width, $height)=$image->Get('width','height');
print "not " unless ($width == 200) && ($height == 100);
print "ok 1\n";
