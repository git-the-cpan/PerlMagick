#!/usr/local/bin/perl
use Image::Magick;

my ($q, $x);

print "Create Image::Magick object...\n";
$q = Image::Magick->new;

print "Get image attributes...\n";
my ($a, $b, $c) = $q->Get("colorspace", "magick", "adjoin");
warn "$a : $b : $c\n";

print "Set image attributes...\n";
$q->SetAttributes(colorspace=>"ycbcr");
($a, $b, $c) = $q->Get("colorspace", "magick", "adjoin");
warn "$a : $b : $c\n";

print "Read an image sequence...\n";
$x = $q->Read("girl.gif", "logo.gif", "rose.gif");
warn "$x" if $x;
print "Images = ", 0+$x, "\ndisplay\n";
die "Quitting, fatal error" if $x <= 0;

print "Get image attributes...\n";
($a, $b, $c) = $q->Get("colorspace", "magick", "adjoin");
warn "$a : $b : $c\n";

print "Create an image montage...\n";
$r = $q->Montage(frame=>'15x15+3+3',shadow=>'true',label=>'%f',
  texture=>'granite:');
warn "$r" unless ref($r);

print "Write the image montage to disk...\n";
$x = $r->Write("montage.gif");
warn "$x" if $x;

print "Display the image montage on your X server...\n";
print "Images = ", 0+$x, "\ndisplay\n";
$x = $r->Display();
