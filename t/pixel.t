#!/usr/local/bin/perl
#
# Test set pixel method.
#
BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use Image::Magick;
$loaded=1;
$image=Image::Magick->new;
$x=$image->ReadImage('xc:black');
print "not ok 1\n" if "$x";
exit if "$x";
$image->SetAttributes('pixel[200,100]'=>'128,192,255');
$pixel=$image->GetAttributes('pixel[200,100]');
print "not " unless $pixel =~ /128,192,255,0/;
print "ok 1\n";
