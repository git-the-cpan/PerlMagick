#!/usr/bin/perl
#
# You can grab and set pixels in PerlMagick, using methods like this.
#
use strict;
use Image::Magick;

# read image
my $im=Image::Magick->new();
$im->Read('logo:');

# get a single pixel
my $skin=$im->Get('pixel[400,200]');
print "Skin Color = ", $skin, "\n";

# Or set a single pixel
$im->Set('pixel[1,1]'=>'0,0,0,0');
$im->Set('pixel[2,1]'=>$skin);
$im->Set('pixel[3,1]'=>'green');
$im->Set('pixel[4,1]'=>'rgb(255,0,255)');

# crop, scale, display the four changed pixels
$im->Crop(geometry=>'6x3+0+0');
$im->Set(page=>'0x0+0+0');
$im->Scale('1000%');

# Output the changed pixels
$im->Write('win:');
$im->Write('pixel_get_set.gif');

