#!/usr/local/bin/perl
#
# Test reading JPEG images
#
# Contributed by Bob Friesenhahn <bfriesen@simple.dallas.tx.us>
#
BEGIN { $| = 1; print "1..1\n"; }
END {print "not \n" unless $loaded;}

use Image::Magick;
$loaded=1;

chdir 't/jpeg' || die 'Cd failed';

#
# 1) Test with non-interlaced image
#

$image=Image::Magick->new;

$x=$image->ReadImage('JPEG:input.jpg');
if( "$x" ) {
  print "$x\n";
  print "not ok 1\n";
} else {
  $x=$image->WriteImage(filename=>'JPEG:output_tmp.jpg', quality=>80, interlace=>'None');
  if( "$x" ) {
    print "$x\n";
    print "not ok 1\n";
  } else {
    system("cmp output_master.jpg output_tmp.jpg > /dev/null 2>&1") && print "not ";
    unlink('output_tmp.jpg');
    print "ok 1\n";
  }
}
undef $image;

#
# 2) Test with plane-interlaced image
#

print "1..2\n";

$image=Image::Magick->new;

$x=$image->ReadImage('JPEG:input.jpg');
if( "$x" ) {
  print "$x\n";
  print "not ok 2\n";
} else {
  $x=$image->WriteImage(filename=>'JPEG:output_plane_tmp.jpg', quality=>80, interlace=>'Plane');
  if( "$x" ) {
    print "$x\n";
    print "not ok 2\n";
  } else {
    system("cmp output_plane_master.jpg output_plane_tmp.jpg > /dev/null 2>&1") && print "not ";
    unlink('output_plane_tmp.jpg');
    print "ok 2\n";
  }
}
undef $image;


