#!/usr/local/bin/perl
#
# Test reading PNG images
#
# Contributed by Bob Friesenhahn <bfriesen@simple.dallas.tx.us>
#
BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use Image::Magick;
$loaded=1;

chdir 't/png' || die 'Cd failed';

#
# 1) Test 256 color pseudocolor PNG
# 

$image=Image::Magick->new;
$x=$image->ReadImage('input_256.png');
if ( "$x" ) {
  print "not ok 1\n";
} else {
  $image->SignatureImage();
  $signature=$image->Get('signature');
  print "MD5 = $signature\n";
  if ( $signature ne '1a25f341ceae3ef36a1facdf4a7b4f67' ) {
    print "not ok 1\n";
  } else {
    print "ok 1\n";
  }
}
undef $image;

#
# 2) Test TrueColor PNG
# 

print "1..2\n";

$image=Image::Magick->new;
$x=$image->ReadImage('input_truecolor.png');
if( "$x" ) {
  print "not ok 2\n";
}
else {
  $image->SignatureImage();
  $signature=$image->Get('signature');
  print "MD5 = $signature\n";
  if ( $signature ne '966179f59e3782d286bc693128ee9739' ) {
    print "not ok 2\n";
  } else {
    print "ok 2\n";
  }
}
undef $image;


