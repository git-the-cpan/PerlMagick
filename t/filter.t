#!/usr/local/bin/perl
#
# Test image filters.
#
# Contributed by Bob Friesenhahn <bfriesen@simple.dallas.tx.us>
#
BEGIN { $| = 1; $test=1, print "1..44\n"; }
END {print "not ok 1\n" unless $loaded;}
use Image::Magick;
$loaded=1;

require 't/subroutines.pl';

chdir 't' || die 'Cd failed';
use FileHandle;
autoflush STDOUT 1;
autoflush STDERR 1;

#$QuantumDepth=quantumDepth();
$fuzz=int($MaxRGB*0.05);

testFilterCompare('input.miff', q//, 'reference/filter/Blur.miff', 'Blur',
  q/geometry=>"0.0x1.0"/, 0.0026, 0.0056);

++$test;
testFilterCompare('input.miff',  q//, 'reference/filter/Border.miff', 'Border',
  q/geometry=>"10"/, 0, 0);

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/Channel.miff', 'Channel',
  q/channel=>"Red"/, 0, 0);

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/Chop.miff', 'Chop',
  q/geometry=>"10x10!"/, 0, 0);

++$test;
testFilterCompare('input.miff', "fuzz=>$fuzz", 'reference/filter/ColorFloodfill.miff', 'ColorFloodfill',
  q/geometry=>"+25+45"/, 0, 0);

++$test;
testFilterCompare('input.miff', "fuzz=>$fuzz", 'reference/filter/Colorize.miff', 'Colorize',
  q/fill=>"red", opacity=>"50%"/, 0.0013, 0.0020 );

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/Contrast.miff', 'Contrast',
  q/sharpen=>True/, 0.0025, 0.385);

++$test;
testFilterCompare('input.miff', q//,
 'reference/filter/Convolve.miff', 'Convolve', q/coefficients=>[1, 2, 1, 2, 4, 2, 1, 2, 1]/, 0.0026, 0.004);

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/Crop.miff', 'Crop',
  q/geometry=>"10x10!"/, 0, 0);

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/Despeckle.miff', 'Despeckle',
  q//, 0, 0);

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/Edge.miff', 'Edge',
  q/radius=>3/, 0, 0);

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/Emboss.miff', 'Emboss',
  q/geometry=>"2x1"/, 0.003, 0.27);

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/Equalize.miff', 'Equalize',
  q//, 0.001, 0.004 );

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/Flip.miff', 'Flip',
  q//, 0, 0);

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/Flop.miff', 'Flop',
  q//, 0, 0);

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/Frame.miff', 'Frame',
  q/geometry=>"10x10+2+2"/, 0.015, 0.489);

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/Gamma.miff', 'Gamma',
  q/gamma=>2.2/, 0.001, 0.004 );

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/Implode.miff', 'Implode',
  q/amount=>0.5/, 0.002, 0.004);

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/Magnify.miff', 'Magnify',
  q//, 0.019, 0.18);

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/MatteFloodfill.miff', 'MatteFloodfill',
  q/geometry=>"+25+45"/, 0, 0);

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/Minify.miff', 'Minify',
  q//, 0.053, 0.39);

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/Modulate.miff', 'Modulate',
  q/brightness=>60, saturation=>30, hue=>20/, 0.0026, 0.004);

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/MotionBlur.miff', 'MotionBlur',
  q/radius=>2,sigma=>1,angle=>30/, 1.41, 0.004);

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/Negate.miff', 'Negate',
  q/gray=>False/, 0, 0);

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/Normalize.miff', 'Normalize',
  q//, 0.001, 0.009 );

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/OilPaint.miff', 'OilPaint',
  q/radius=>3/, 0.043, 0.84);

++$test;
testFilterCompare('input.miff', "fuzz=>$fuzz", 'reference/filter/Opaque.miff', 'Opaque',
  q/color=>"#e23834", fill=>"green"/, 0, 0);

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/Quantize.miff', 'Quantize',
                  q/colors=>128/, 0.020, 0.35);

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/Raise.miff', 'Raise',
  q/geometry=>"10x10"/, 0.0011, 0.004);

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/Resize.miff', 'Resize',
  q/geometry=>"50%", filter=>"Box"/, 0.0025, 0.004);

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/Roll.miff', 'Roll',
  q/geometry=>"+10+10"/, 0, 0);

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/Rotate.miff', 'Rotate',
  q/degrees=>10,color=>"green"/, 0.24, 0.87);

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/Sample.miff', 'Sample',
  q/geometry=>"50%"/, 0, 0);

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/Scale.miff', 'Scale',
  q/geometry=>"50%"/, 0.004, 0.004);

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/Shade.miff', 'Shade',
  q/geometry=>"30x30",gray=>'true'/, 0.0162, 0.0079);

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/Sharpen.miff', 'Sharpen',
  q/geometry=>"0.0x1.0"/, 0025, 0.004);

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/Shave.miff', 'Shave',
  q/geometry=>"10x10"/, 0, 0);

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/Shear.miff', 'Shear',
  q/geometry=>'10x10',color=>'none'/, 0.094, 1.00);

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/Solarize.miff', 'Solarize',
  q/60/, 0.14, 0.83);

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/Swirl.miff', 'Swirl',
  q/degrees=>60/, 0.002, 0.004);

# Being just one pixel different spikes maximum error for the threshold
# test, so check only mean error.  This test is primarily influenced by
# the pixel intensity macro.
++$test;
testFilterCompare('input.miff', q//, 'reference/filter/Threshold.miff', 'Threshold',
  q/threshold=>"50%"/, 0.0013, 1);

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/Trim.miff', 'Trim',
  q//, 0, 0);

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/Wave.miff', 'Wave',
  q/geometry=>"25x157"/, 0.0012, 0.004);

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/Segment.miff', 'Segment',
  q/geometry=>"1.5x3.5"/, 0.0029, 0.0037);

++$test;

1;
