#!/usr/local/bin/perl
#
# Test read image method on JBIG image
#
# Contributed by Bob Friesenhahn <bfriesen@simple.dallas.tx.us>
#
BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use Image::Magick;
$loaded=1;

chdir 't/jbig' || die 'Cd failed';

$image=Image::Magick->new;

$x=$image->ReadImage('input.jbig');
if( "$x" ) {
  print "ReadImage failed!";
  print "not ok 1\n";
} else {
  $image->SignatureImage();
  $signature=$image->Get('signature');
  print "MD5 = $signature\n";
  if ( $signature ne '313a67b2e25301bb66c01e5517647e3d' ) {
    print "not ok 1\n";
  } else {
    print "ok 1\n";
  }
}
undef $image;
