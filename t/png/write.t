#!/usr/local/bin/perl
#
# Test writing PNG images
#
# Contributed by Bob Friesenhahn <bfriesen@simple.dallas.tx.us>
#
BEGIN { $| = 1; print "1..1\n"; }
END {print "not \n" unless $loaded;}

use Image::Magick;
$loaded=1;

chdir 't/png' || die 'Cd failed';

#
# 1) Test pseudocolor image
#

$image=Image::Magick->new;
$x=$image->ReadImage('PNG:input_256.png');
if( "$x" ) {
  print "$x\n";
  print "not ok 1\n";
} else {
  $x=$image->WriteImage(filename=>'PNG:output_256_tmp.png', quality=>54);
  if( "$x" ) {
    print "$x\n";
    print "not ok 1\n";
  } else {
    system("cmp output_256_master.png output_256_tmp.png > /dev/null 2>&1") && print "not ";
    unlink('output_256_tmp.png');
    print "ok 1\n";
  }
}
undef $image;

#
# 2) Test truecolor image
#

print "1..2\n";
$image=Image::Magick->new;
$x=$image->ReadImage('PNG:input_truecolor.png');
if( "$x" ) {
  print "$x\n";
  print "not ok 2\n";
} else {
  $x=$image->WriteImage(filename=>'PNG:output_truecolor_tmp.png', quality=>55);
  if( "$x" ) {
    print "$x\n";
    print "not ok 2\n";
  } else {
    system("cmp output_truecolor_master.png output_truecolor_tmp.png > /dev/null 2>&1") && print "not ";
    unlink('output_truecolor_tmp.png');
    print "ok 2\n";
  }
}




