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
  'd3531ca6dab5b7ab38acec3cdeb6a1fc99848acabeefc3a31df88435f138e869');

#
# 2) Test Center gravity
#    Image should be centered in frame
#
++$test;
testMontage( q//,
  q/background=>'#696e7e', label=>'', geometry=>'90x80+5+5>', gravity=>'Center'/,
  '63e4b50df578614ad97b4d95795d133707750ec4c902db17455ff8e16c9e7063');

#
# 3) Test NorthWest gravity
#    Image should be at top-left in frame
#
++$test;
testMontage( q//,
  q/background=>'#696e7e', label=>'', geometry=>'90x80+5+5>', gravity=>'NorthWest'/,
  'd5c5d1155ede009ac777903b5ab3d92eb4baabd082a3a822d9afc95b383c77aa');

#
# 4) Test North gravity
#    Image should be at top-center of frame
#
++$test;
testMontage( q//,
  q/background=>'#696e7e', label=>'', geometry=>'90x80+5+5>', gravity=>'North'/,
  '9ed698ad0f8e9067199e9d894b216873d9a9644e5a42c920ef89f4d204b630f2');

#
# 5) Test NorthEast gravity
#    Image should be at top-right of frame
#
++$test;
testMontage( q//,
  q/background=>'#696e7e', label=>'', geometry=>'90x80+5+5>', gravity=>'NorthEast'/,
  '462d55ff2c0489e1a7cb020c46c58e146f023115db789396d823946372b73320');

#
# 6) Test West gravity
#    Image should be at left-center of frame
#
++$test;
testMontage( q//,
  q/background=>'#696e7e', label=>'', geometry=>'90x80+5+5>', gravity=>'West'/,
  'a134863bdd89d23d52de42643793f0cd8d2aacb1c2c5e116a87d847f04a1d652');

#
# 7) Test East gravity
#    Image should be at right-center of frame.
#
++$test;
testMontage( q//,
  q/background=>'#696e7e', label=>'', geometry=>'90x80+5+5>', gravity=>'East'/,
  'f6219930e1dcaf09f40f3ee601c9d6fed0cbb0316d020ee7194ee2a4edcc12f2');

#
# 8) Test SouthWest gravity
#    Image should be at bottom-left of frame
#
++$test;
testMontage( q//,
  q/background=>'#696e7e', label=>'', geometry=>'90x80+5+5>', gravity=>'SouthWest'/,
  'f33b7f58fd751b720cc604b71a1d7ffe7708ea53f22d48d7fcd3abdb0bddfc43');

#
# 9) Test South gravity
#    Image should be at bottom of frame
#
++$test;
testMontage( q//,
  q/background=>'#696e7e', label=>'', geometry=>'90x80+5+5>', gravity=>'South'/,
  'a4d682d74b632027d477c5ee68142486cfcf65c1cecf0cf4e2fa09caf352cbd6');

#
# 10) Test SouthEast gravity
#     Image should be at bottom-right of frame.
#
++$test;
testMontage( q//,
  q/background=>'#696e7e', label=>'', geometry=>'90x80+5+5>', gravity=>'SouthEast'/,
  'ba93266a375117346710d979b6b2be179c396a07aee695d2f40c9b86514eb76c');

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
  '152f522b60372648ed967044e13ec97e0da73da7100a0f2d468bea528d5da16b',
  'b8f575e35a0730873e88f4b6b289e517d4e2f1b76a6916cab9626fe268fefff7',
  'a4498fd44d835d5313d5a00e93036356deed0773f78d06427b9c257dd7f2aabd');

#
# 12) Test Framed Montage with drop-shadows
#
++$test;
testMontage( q/bordercolor=>'blue', mattecolor=>'red'/, 
  q/background=>'#696e7e', label=>'', tile=>'4x4', geometry=>'90x80+6+6>', frame=>'8x10',
  borderwidth=>'0', gravity=>'Center', shadow=>'True',background=>'gray'/,
  '51b40775409703d6a3cd48c3e123cf95240552f949b4bd5fc7c34e865fde8271',
  'a686625ee84345193f2a5cb4a16e49bf8b9ea44a842b7484b2a34e5e646eb010',
  '8b29af4ff28ddeb5f96a3693fcb526ef3c29303aa410f3b5cd76e304f540bac3');

#
# 13) Test Framed Montage with drop-shadows and background texture
#
++$test;
testMontage( q/bordercolor=>'blue', mattecolor=>'red'/, 
  q/background=>'#696e7e', label=>'', tile=>'4x4', geometry=>'90x80+6+6>', frame=>'8x10',
  borderwidth=>'0', gravity=>'Center', shadow=>'True', texture=>'granite:'/,
  '5ef61c52e79e32f9113b7bfdf6c26d6a19585b5ecfc16fedd0b44ad08cb9a0fd',
  '12972173aef9e114f4f011cf16b6a279ab93ba3469bf6460f8ede896e402d881',
  '1cd3c7340b6711e54e6ac6b27d6f081d1ca11ee5bd90ea6e74ae449ebd8f1134');

#
# 14) Test Un-bordered, Un-framed Montage
#
++$test;
testMontage( q//,
  q/background=>'#696e7e', label=>'', tile=>'4x4', geometry=>'90x80+6+6>', mode=>'Unframe',
  borderwidth=>'0', gravity=>'Center', background=>'gray'/,
  '407e153c5a2348f7860c9d70f3b9951b020e338f3cd86845f79334fb875c5196');

#
# 15) Test Bordered, Un-framed Montage (mode=>'Unframe')
#
++$test;
testMontage( q/bordercolor=>'red'/, 
  q/background=>'#696e7e', label=>'', tile=>'4x4', geometry=>'90x80+6+6>', mode=>'Unframe',
  borderwidth=>'5', gravity=>'Center', background=>'gray'/,
  '380f416d496c68516b54e02ecf44d1c232f8b47427528db176eef3bd046bc2b8');

#
# 16) Test Bordered, Un-framed Montage (mode=>'UnFrame')
#
++$test;
testMontage( q/bordercolor=>'red'/, 
  q/label=>'', tile=>'4x4', geometry=>'90x80+6+6>', mode=>'UnFrame',
  borderwidth=>'5', gravity=>'Center', background=>'gray'/,
  '380f416d496c68516b54e02ecf44d1c232f8b47427528db176eef3bd046bc2b8');

#
# 17) Test Un-bordered, Un-framed Montage with 16x1 tile
#
++$test;
testMontage( q//,
  q/background=>'#696e7e', label=>'', tile=>'16x1', geometry=>'90x80+0+0>', mode=>'Unframe',
  borderwidth=>'0', gravity=>'Center', background=>'gray'/,
  'f384e3db0dd52e7420239be24e25c1cf438b6d08550a5a55137838bf329a0433');

#
# 18) Test concatenated thumbnail Montage (concatenated via special Concatenate mode)
#     Thumbnails should be compacted tightly together in a grid
#
++$test;
testMontage( q//,
  q/background=>'#696e7e', label=>'', tile=>'4x4', geometry=>'90x80>', mode=>'Concatenate'/,
  '06db877ef6a9842d12f4f604940d23622826884333c32f169ce795af10d7a2ea');
#
# 19) Test concatenated thumbnail Montage (concatentated by setting params to zero)
#     Thumbnails should be compacted tightly together in a grid
#
++$test;
testMontage( q//, 
  q/background=>'#696e7e', label=>'', tile=>'4x4', geometry=>'+0+0', mode=>'Unframe', shadow=>'False',
  borderwidth=>'0', background=>'gray'/,
  '06db877ef6a9842d12f4f604940d23622826884333c32f169ce795af10d7a2ea');
