#!/usr/local/bin/perl
#
# Test set/get attributes method.
#
BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use Image::Magick;
$loaded=1;
$image=Image::Magick->new;
$image->SetAttribute(compress=>'Zip', filter=>'Box', page=>'200x100+0+10');
($compress, $filter, $page)=$image->GetAttributes('compress', 'filter', 'page');
print "not " unless $compress =~ /Zip/;
print "not " unless $filter =~ /Box/;
print "not " unless $page =~ /200x100\+0\+10/;
print "ok 1\n";
