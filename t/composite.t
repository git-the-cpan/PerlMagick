#!/usr/local/bin/perl
# Copyright (C) 1994-2004 ImageMagick Studio LLC
# Copyright (C) 2003 GraphicsMagick Group
#
#
BEGIN { $| = 1; $test=1; print "1..18\n"; }
END {print "not ok $test\n" unless $loaded;}
use Image::Magick;
$loaded=1;

require 't/subroutines.pl';

chdir 't' || die 'Cd failed';

#
# Add
#
testCompositeCompare('gradient:white-black',q/size=>"100x80"/,
  'input.miff', q//, q/, gravity=>'Center', compose=>'Add'/,
  'reference/composite/Add.miff',0.15,0.79);
#
# Atop
#
++$test;
testCompositeCompare('gradient:white-black',q/size=>"100x80"/,
  'input.miff', q//, q/, gravity=>'Center', compose=>'Atop'/,
  'reference/composite/Atop.miff',0.0025,0.008);

#
# Bumpmap
#
++$test;
testCompositeCompare('gradient:white-black',q/size=>"100x80"/,
  'input.miff', q//,q/, gravity=>'Center', compose=>'Bumpmap'/,
  'reference/composite/Bumpmap.miff',0.0025,0.008);

#
# Clear
#
++$test;
testCompositeCompare('gradient:white-black',q/size=>"100x80"/,
  'input.miff', q//, q/, gravity=>'Center', compose=>'Clear'/,
  'reference/composite/Clear.miff',0.0025,0.008);

#
# Copy
#
++$test;
testCompositeCompare('gradient:white-black',q/size=>"100x80"/,
  'input.miff', q//, q/, gravity=>'Center', compose=>'Copy'/,
  'reference/composite/Copy.miff',0.0025,0.008);

#
# CopyBlue
#
++$test;
testCompositeCompare('gradient:white-black',q/size=>"100x80"/,
  'input.miff', q//, q/, gravity=>'Center', compose=>'CopyBlue'/,
  'reference/composite/CopyBlue.miff',0.0025,0.008);

#
# CopyGreen
#
++$test;
testCompositeCompare('gradient:white-black',q/size=>"100x80"/,
  'input.miff', q//, q/, gravity=>'Center', compose=>'CopyGreen'/,
  'reference/composite/CopyGreen.miff',0.0025,0.008);

#
# CopyRed
#
++$test;
testCompositeCompare('gradient:white-black',q/size=>"100x80"/,
  'input.miff', q//, q/, gravity=>'Center', compose=>'CopyRed'/,
  'reference/composite/CopyRed.miff',0.0025,0.008);

#
# CopyOpacity
#
++$test;
testCompositeCompare('gradient:white-black',q/size=>"100x80"/,
  'input.miff', q//, q/, gravity=>'Center', compose=>'CopyOpacity'/,
  'reference/composite/CopyOpacity.miff',0.0025,0.008);

#
# Difference
#
++$test;
testCompositeCompare('gradient:white-black',q/size=>"100x80"/,
  'input.miff', q//, q/, gravity=>'Center', compose=>'Difference'/,
  'reference/composite/Difference.miff',0.0025,0.008);

#
# In
#
++$test;
testCompositeCompare('gradient:white-black',q/size=>"100x80"/,
  'input.miff', q//, q/, gravity=>'Center', compose=>'In'/,
  'reference/composite/In.miff',0.0025,0.008);

#
# Minus
#
++$test;
testCompositeCompare('gradient:white-black',q/size=>"100x80"/,
  'input.miff', q//, q/, gravity=>'Center', compose=>'Minus'/,
  'reference/composite/Minus.miff',0.0025,0.008);

#
# Multiply
#
++$test;
testCompositeCompare('gradient:white-black',q/size=>"100x80"/,
  'input.miff', q//, q/, gravity=>'Center', compose=>'Multiply'/,
  'reference/composite/Multiply.miff',0.0025,0.008);

#
# Out
#
++$test;
testCompositeCompare('gradient:white-black',q/size=>"100x80"/,
  'input.miff', q//, q/, gravity=>'Center', compose=>'Out'/,
  'reference/composite/Out.miff',0.0025,0.008);

#
# Over
#
++$test;
testCompositeCompare('gradient:white-black',q/size=>"100x80"/,
  'input.miff', q//, q/, gravity=>'Center', compose=>'Over'/,
  'reference/composite/Over.miff',0.0025,0.008);

#
# Plus
#
++$test;
testCompositeCompare('gradient:white-black',q/size=>"100x80"/,
  'input.miff', q//, q/, gravity=>'Center', compose=>'Plus'/,
  'reference/composite/Plus.miff',0.0025,0.008);

#
# Subtract
#
++$test;
testCompositeCompare('gradient:white-black',q/size=>"100x80"/,
  'input.miff', q//, q/, gravity=>'Center', compose=>'Subtract'/,
  'reference/composite/Subtract.miff',0.0025,1.0);

#
# Xor
#
++$test;
testCompositeCompare('gradient:white-black',q/size=>"100x80"/,
  'input.miff', q//, q/, gravity=>'Center', compose=>'Xor'/,
  'reference/composite/Xor.miff',0.0025,0.008);

1;
