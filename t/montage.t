#!/usr/local/bin/perl
#
# Test montage method.
#
# Contributed by Bob Friesenhahn <bfriesen@simple.dallas.tx.us>
#
BEGIN { $| = 1; $test=1, print "1..19\n"; }
END {print "not ok 1\n" unless $loaded;}
use Image::Magick;
$loaded=1;

require 't/subroutines.pl';

chdir 't' || die 'Cd failed';

#
# 1) Test montage defaults (except no label that requires an exact font)
#
testMontage( q//,
  q/background=>'#696e7e', label=>''/,
  '96029ea6df0445943ef4fa57e43464101c24e29421cf9c43baf3e6b228a44086');

#
# 2) Test Center gravity
#    Image should be centered in frame
#
++$test;
testMontage( q//,
  q/background=>'#696e7e', label=>'', geometry=>'90x80+5+5>', gravity=>'Center'/,
  '402be20796e94e200645091621917c550fc90675760106b2b20fc531dc88d63e');

#
# 3) Test NorthWest gravity
#    Image should be at top-left in frame
#
++$test;
testMontage( q//,
  q/background=>'#696e7e', label=>'', geometry=>'90x80+5+5>', gravity=>'NorthWest'/,
  'f7c9fb62d2b3a5087da6e3af813020d973f2b89be16772481886efbde41c09ed');

#
# 4) Test North gravity
#    Image should be at top-center of frame
#
++$test;
testMontage( q//,
  q/background=>'#696e7e', label=>'', geometry=>'90x80+5+5>', gravity=>'North'/,
  'd390c96ffe6614ff1b357623c4af2b6c4664674e94fc931c53d5b0e271d01500');

#
# 5) Test NorthEast gravity
#    Image should be at top-right of frame
#
++$test;
testMontage( q//,
  q/background=>'#696e7e', label=>'', geometry=>'90x80+5+5>', gravity=>'NorthEast'/,
  'd9a9740b3a5bcdc0692576e90e7852ed3adf8230ffa586d2c2c723f8a4c849a6');

#
# 6) Test West gravity
#    Image should be at left-center of frame
#
++$test;
testMontage( q//,
  q/background=>'#696e7e', label=>'', geometry=>'90x80+5+5>', gravity=>'West'/,
  '1f932237d5d6dd65a92d2781a0f5ec095e181916777a19d66081111d7b3cdcb2');

#
# 7) Test East gravity
#    Image should be at right-center of frame.
#
++$test;
testMontage( q//,
  q/background=>'#696e7e', label=>'', geometry=>'90x80+5+5>', gravity=>'East'/,
  'e703f28201d05bdf1c19b79e87b768f184430cae860e5359726a5d1ed49f1263');

#
# 8) Test SouthWest gravity
#    Image should be at bottom-left of frame
#
++$test;
testMontage( q//,
  q/background=>'#696e7e', label=>'', geometry=>'90x80+5+5>', gravity=>'SouthWest'/,
  '8475e28fc51dad892d7494cdc3b8bab93661ac67f3a51f2dd32880f6add8fada');

#
# 9) Test South gravity
#    Image should be at bottom of frame
#
++$test;
testMontage( q//,
  q/background=>'#696e7e', label=>'', geometry=>'90x80+5+5>', gravity=>'South'/,
  '73b214fd13d3b304dbcd4b09769bf2afffe4e82b8329702ba518054fce4eccee');

#
# 10) Test SouthEast gravity
#     Image should be at bottom-right of frame.
#
++$test;
testMontage( q//,
  q/background=>'#696e7e', label=>'', geometry=>'90x80+5+5>', gravity=>'SouthEast'/,
  '4576d046ae364a2d3818740ceb517946b314168635c340f666e4c02de6c8a553');

#
# 11) Test Framed Montage
#
# Image border color 'bordercolor' controls frame background color
# Image matte color 'mattecolor' controls frame color
# Image pen color 'pen' controls label text foreground color
++$test;
testMontage( q/bordercolor=>'blue', mattecolor=>'red'/, 
  q/background=>'#696e7e', label=>'', tile=>'4x4', geometry=>'90x80+3+3>', frame=>'8x10',
  borderwidth=>'0', gravity=>'Center', background=>'gray'/,
  '2248e3da526e0c26449f2050863761f9dac70c0a4753255565d1cf11e383bbec');

#
# 12) Test Framed Montage with drop-shadows
#
++$test;
testMontage( q/bordercolor=>'blue', mattecolor=>'red'/, 
  q/background=>'#696e7e', label=>'', tile=>'4x4', geometry=>'90x80+6+6>', frame=>'8x10',
  borderwidth=>'0', gravity=>'Center', shadow=>'True',background=>'gray'/,
  '70fc9bbd7b2dfd1d19d0818c12fb07835d1549fdefea7011287dd8c48452106a',
  '70fc9bbd7b2dfd1d19d0818c12fb07835d1549fdefea7011287dd8c48452106a',
  '70fc9bbd7b2dfd1d19d0818c12fb07835d1549fdefea7011287dd8c48452106a');

#
# 13) Test Framed Montage with drop-shadows and background texture
#
++$test;
testMontage( q/bordercolor=>'blue', mattecolor=>'red'/, 
  q/background=>'#696e7e', label=>'', tile=>'4x4', geometry=>'90x80+6+6>', frame=>'8x10',
  borderwidth=>'0', gravity=>'Center', shadow=>'True', texture=>'granite:'/,
  '4acb0473577978a62d6dfe7d795ae92b3e12cd9b133fccbb60439cf3949722c4',
  '4acb0473577978a62d6dfe7d795ae92b3e12cd9b133fccbb60439cf3949722c4',
  '4acb0473577978a62d6dfe7d795ae92b3e12cd9b133fccbb60439cf3949722c4');

#
# 14) Test Un-bordered, Un-framed Montage
#
++$test;
testMontage( q//,
  q/background=>'#696e7e', label=>'', tile=>'4x4', geometry=>'90x80+6+6>', mode=>'Unframe',
  borderwidth=>'0', gravity=>'Center', background=>'gray'/,
  '776c777029408740254405e21df83fcd4f48e16ce1a9313cb6d8971986d7f1bd');

#
# 15) Test Bordered, Un-framed Montage (mode=>'Unframe')
#
++$test;
testMontage( q/bordercolor=>'red'/, 
  q/background=>'#696e7e', label=>'', tile=>'4x4', geometry=>'90x80+6+6>', mode=>'Unframe',
  borderwidth=>'5', gravity=>'Center', background=>'gray'/,
  '32a0d75841854bd291cf7aa86ff4472f8bb2a05f7586e92d1290c8a614300870');

#
# 16) Test Bordered, Un-framed Montage (mode=>'UnFrame')
#
++$test;
testMontage( q/bordercolor=>'red'/, 
  q/label=>'', tile=>'4x4', geometry=>'90x80+6+6>', mode=>'UnFrame',
  borderwidth=>'5', gravity=>'Center', background=>'gray'/,
  '32a0d75841854bd291cf7aa86ff4472f8bb2a05f7586e92d1290c8a614300870');

#
# 17) Test Un-bordered, Un-framed Montage with 16x1 tile
#
++$test;
testMontage( q//,
  q/background=>'#696e7e', label=>'', tile=>'16x1', geometry=>'90x80+0+0>', mode=>'Unframe',
  borderwidth=>'0', gravity=>'Center', background=>'gray'/,
  '7ec524f37511b13e6456a7d04d0bb9d9a831c4a4cf174e86ac00d77e60858ba2');

#
# 18) Test concatenated thumbnail Montage (concatenated via special Concatenate mode)
#     Thumbnails should be compacted tightly together in a grid
#
++$test;
testMontage( q//,
  q/background=>'#696e7e', label=>'', tile=>'4x4', geometry=>'90x80>', mode=>'Concatenate'/,
  '97b10c3c302ba743e64f0479c4314ca966376645d1297986d31d81b2b5044158');
#
# 19) Test concatenated thumbnail Montage (concatentated by setting params to zero)
#     Thumbnails should be compacted tightly together in a grid
#
++$test;
testMontage( q//, 
  q/background=>'#696e7e', label=>'', tile=>'4x4', geometry=>'+0+0', mode=>'Unframe', shadow=>'False',
  borderwidth=>'0', background=>'gray'/,
  '97b10c3c302ba743e64f0479c4314ca966376645d1297986d31d81b2b5044158');
