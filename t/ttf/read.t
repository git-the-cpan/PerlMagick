#!/usr/local/bin/perl
#
# Test read image method on TrueType font
#
# Contributed by Bob Friesenhahn <bfriesen@simple.dallas.tx.us
#

BEGIN { $| = 1; $test=1; print "1..3\n"; }
END {print "not ok $test\n" unless $loaded;}
use Image::Magick;
$loaded=1;

require 't/subroutines.pl';

chdir 't/ttf' || die 'Cd failed';

#
# 1) Test default ImageMagick read operation on font
#
print("Default ImageMagick read ...\n");
testReadCompare('input.ttf', '../reference/ttf/read.miff',
                q/size=>'512x512', depth=>8/,
                5.5e-09, 3.1e-05);

#
# 2) Test drawing text using font
#
++$test;
print("Draw text using font ...\n");
testReadCompare(q!label:The quick brown fox jumps over the lazy dog.!,
                q!../reference/ttf/label.miff!,
                q!font=>'input.ttf', fill=>'#0000FF', pointsize=>14, depth=>8!,
                8.7e-08, 1.02e-05);

#
# 3) Test drawing text using annotate
#
++$test;
print("Draw text using annotate ...\n");
testFilterCompare('xc:#FFFFFF',
                  q!size=>'250x20', depth=>8!,
                  q!../reference/ttf/annotate.miff!,
                  'Annotate',
                  q!text=>'The quick brown fox jumps over the lazy dog.',
                  gravity=>'NorthWest',
                  geometry=>'+6+14',
                  font=>'input.ttf',
                  fill=>'#FF0000',
                  pointsize=>14!,
                  4.5e-07, 1.1e-05);

1;
