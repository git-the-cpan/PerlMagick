#!/usr/local/bin/perl
#
# Test image blobs.
#
BEGIN { $| = 1; $test=1, print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use Image::Magick;
$loaded=1;

chdir 't' || die 'Cd failed';

$image = new Image::Magick;
$image->Read( 'input.miff' );
@blob = $image->ImageToBlob();
undef $image;

$image=Image::Magick->new( magick=>'MIFF' );
$image->BlobToImage( @blob );

if ($image->Get('signature') ne 
    '975cdb03f0fa923936f1cecf7b8a49a917493393a0eb098828ab710295195584')
  { print "not ok $test\n"; }
else
  { print "ok $test\n"; }

1;
