#!/usr/local/bin/perl
#
# Test write image method on JBIG image
#
# Contributed by Bob Friesenhahn <bfriesen@simple.dallas.tx.us>
#
BEGIN { $| = 1; print "1..1\n"; }
END {print "not \n" unless $loaded;}

use Image::Magick;
$loaded=1;

chdir 't/jbig' || die 'Cd failed';

$image=Image::Magick->new;
$x=$image->ReadImage('JBIG:input.jbig');
if( "$x" ) {
  print "$x\n";
  print "not ok 1\n";
} else {
  $x=$image->WriteImage(filename=>'JBIG:output_tmp.jbig');
  if( "$x" ) {
    print "$x\n";
    print "not ok 1\n";
  } else {
    system("cmp input.jbig output_tmp.jbig > /dev/null 2>&1") && print "not ";
    unlink('output_tmp.jbig');
    print "ok 1\n";
  }
}
undef $image;
