#!/usr/local/bin/perl
use Image::Magick;

my ($adjoin, $colorspace, $images, $magick, $status);

print "Create Image::Magick object...\n";
$images = Image::Magick->new;

print "Get image attributes...\n";
($colorspace, $magick, $adjoin) =
  $images->Get("colorspace", "magick", "adjoin");
warn "$colorspace : $magick : $adjoin\n";

print "Set image attributes...\n";
$images->SetAttributes(colorspace=>"ycbcr");
($colorspace, $magick, $adjoin) =
  $images->Get("colorspace", "magick", "adjoin");
warn "$colorspace : $magick : $adjoin\n";

print "Read an image sequence...\n";
$status = $images->Read("model.gif", "smile.gif", "rose.gif");
warn "$status" if $status;
print "Images = ", 0+$status, "\ndisplay\n";
die "Quitting, fatal error" if $status <= 0;

print "Get image attributes...\n";
($colorspace, $magick, $adjoin) =
  $images->Get("colorspace", "magick", "adjoin");
warn "$colorspace : $magick : $c\n";

print "Create an image montage...\n";
$montage = $images->Montage(geometry=>'160x160+10+10>', shadow=>'true',
  label=>'%f', texture=>'granite:');
warn "$montage" unless ref($montage);

print "Write the image montage to disk...\n";
$status = $montage->Write("montage.gif");
warn "$status" if $status;

print "Display the image montage on your X server...\n";
print "Images = ", 0+$status, "\ndisplay\n";
$status = $montage->Display();
