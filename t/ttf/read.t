#!/usr/local/bin/perl
#
# Test read image method on TrueType font
#
# Contributed by Bob Friesenhahn <bfriesen@simple.dallas.tx.us>
#
BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use Image::Magick;
$loaded=1;

chdir 't/ttf' || die 'Cd failed';

#
# 1) Test default ImageMagick read operation on font
#

$image=Image::Magick->new;
$x=$image->ReadImage('input.ttf');
if( "$x" ) {
  print "$x\n";
  print "not ok 1\n";
} else {
  # $image->Display();
  $image->SignatureImage();
  $signature=$image->Get('signature');
  print "MD5 = $signature\n";
  if ( $signature ne 'd9925b776eb0e8e0e126d9e510710f07' ) {
    print "not ok 1\n";
  } else {
    print "ok 1\n";
  }
}
undef $image;

#
# 2) Test drawing text using font
#

print "1..2\n";
$image=Image::Magick->new;
$x=$image->Set(font=>'@input.ttf', pen=>'#0000FF', pointsize=>14);
if( "$x" ) {
  print "$x\n";
  print "not ok 2\n";
} else {
  $x=$image->ReadImage('label:The quick brown fox jumps over the lazy dog.');
  if( "$x" ) {
    print "$x\n";
    print "not ok 2\n";
  } else {
    #$image->Display();
    $image->SignatureImage();
    $signature=$image->Get('signature');
    print "MD5 = $signature\n";
    if ( $signature ne 'dc0511fee04057fdaa58c41642f1a898' ) {
      print "not ok 2\n";
    } else {
      print "ok 2\n";
    }
  }
}
undef $image;


