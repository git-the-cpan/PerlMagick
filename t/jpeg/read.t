#!/usr/local/bin/perl
#
# Test read image method on non-interlaced JPEG.
#
# Contributed by Bob Friesenhahn <bfriesen@simple.dallas.tx.us>
#
BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use Image::Magick;
$loaded=1;

chdir 't/jpeg' || die 'Cd failed';


#
# 1) Test non-interlaced image read
# 

$image=Image::Magick->new;
$x=$image->ReadImage('input.jpg');
if( "$x" ) {
  print "not ok 1\n";
} else {
  $image->SignatureImage();
  $signature=$image->Get('signature');
  print "MD5 = $signature\n";
  if ( $signature ne '668413d640d284637ef3dedc13a414a5' ) {
    print "not ok 1\n";
  } else {
    print "ok 1\n";
  }
}
undef $image;

#
# 2) Test plane-interlaced image read
# 

print "1..2\n";
$image=Image::Magick->new;
$x=$image->ReadImage('input.jpg');
if( "$x" ) {
  print "not ok 2\n";
} else {
  $image->SignatureImage();
  $signature=$image->Get('signature');
  print "MD5 = $signature\n";
  if ( $signature ne '668413d640d284637ef3dedc13a414a5' ) {
    print "not ok 2\n";
  } else {
    print "ok 2\n";
  }
}
undef $image;


