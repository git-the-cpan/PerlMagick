#!/usr/local/bin/perl
#
# Test image filter.
#
# Contributed by Bob Friesenhahn <bfriesen@simple.dallas.tx.us>
#
BEGIN { $| = 1; $test=1, print "1..43\n"; }
END {print "not ok 1\n" unless $loaded;}
use Image::Magick;
$loaded=1;

require 't/subroutines.pl';

chdir 't' || die 'Cd failed';

testFilterSignature('input.miff', 'Blur',
  q/2x1/,
  'df129e7b522f8228e96c5fbf5f64176b30bb80f77c8efd2a8ef4228719a4659f',
  '3e750155a9e797ceb9713132ad2d3673a5895f366a0446ddb819fc116f284469');

++$test;
testFilterSignature('input.miff', 'Border',
  q/10/,
  'b4956b654102b9af96956017f94c57d214110d91cb7be995e5ce19d29b0a3eba');

++$test;
testFilterSignature('input.miff', 'Channel',
  q/Red/,
  '76b07c5ff3de0530bc6fcba511f1391cef261eaf4b0f9ee1e3859c7466d017e7');

++$test;
testFilterSignature('input.miff', 'Chop',
  q/10x10!/,
  '0cee3408e6e3255317340bde1ebe026359d58ec3989ecf315df34dd52925beca');

++$test;
testFilterSignature('input.miff', 'ColorFloodfill',
  q/+25+45/,
  '9767e3a22a9cdafe39c448903aea84e68881d39b250b4be921e3f3ebec53f9ee');

++$test;
testFilterSignature('input.miff', 'Colorize',
  q/red/,
  '767b270256d40ccec025494072c070256147a7046b464327ebea6f7934b96121');

++$test;
testFilterSignature('input.miff', 'Contrast',
  q/1/,
  'd22f5aa7610c7527355e9805aac6d3e0125b8b4d62cdb7a1a4e5bf5359c83e11',
  'f780476c04c823dc288b7cda85e8cd26bb97353323978b11ff7081a96209d1f2');

++$test;
testFilterSignature('input.miff', 'Convolve',
  [1, 2, 1, 2, 4, 2, 1, 2, 1],
  '5462852779b238f2bce750a5d23addb00b4906162deda8aedf36054390ac0b50',
  'b85f70779d2048563e8950ee79b3af85219b201bfc1396a90ace5ddfd8ac62fd');

++$test;
testFilterSignature('input.miff', 'Crop',
  q/10x10!/,
  'b66e37b497d4e7275b04fc8f0d0539aeca9a73c187ae239352c7abec44ad2fe9');

++$test;
testFilterSignature('input.miff', 'Despeckle',
  q/ /,
  '9e7f20a6f5a36cbc7809c4ef7e748583fad81c6718f5af799210666b76016368',
  'd3c153d8eed545e70371f82d5398c0a9649a90eff964c42ed94074586046438d');

++$test;
testFilterSignature('input.miff', 'Edge',
  q/3/,
  '8245bada67e7be6509c02ec6f8372a8c2eb0c04bdc6221ff839ac06e770b9bf2',
  'a0106135ce0959a95d2fe8766018ba1436f97903ae4b88e23bb1e9901ae75249');

++$test;
testFilterCompare('input.miff', q/2x1/, 'reference/filter/Emboss.miff',
  'Emboss', q/2x1/,  3.4e-05, 2.5e-02);

++$test;
testFilterCompare('input.miff', q/2x1/, 'reference/filter/Equalize.miff',
  'Equalize', q/2x1/, 0, 0);

++$test;
testFilterSignature('input.miff', 'Flip',
  q/ /,
  '092fa2bb0e2c1826a7b0ac9ea42a788684230623fa56bf0c4c2c9e1d71de8bf1');

++$test;
testFilterSignature('input.miff', 'Flop',
  q/ /,
  'f847ea7cc9b78677c083df656978081827c7bfb532a4c2d5fd3eed19e8b73a3a');

++$test;
testFilterSignature('input.miff', 'Frame',
  q/10x10/,
  'b4956b654102b9af96956017f94c57d214110d91cb7be995e5ce19d29b0a3eba', 
  '0469d077e745fe177f42abe4383cd9fd6f3aba5a1fa24ba67268390f540daeff');

++$test;
testFilterSignature('input.miff', 'Gamma',
  q/2.2/,
  '500b17abf69d4c9e11e8f6a9c245a3a021ba935731f9d3d477ac07d9f4a6b197',
  '9bf0b267e68565b0a808287edbc1fcf80e7edb8786b93e7d3c31410010701a82');

++$test;
testFilterSignature('input.miff', 'Implode',
  q/0.5/,
  '96282ca286c636af2981edf8d9ee64f92a82a9260d33a911a32fd8e75b23d8a4',
  'cad303d2c70bf8f601aff456d22bcfe2ff06861a3bd5ecac61203c037ec352a5');

++$test;
testFilterSignature('input.miff', 'Magnify',
  q/ /,
  'f22df13ea461203e4b88e5ed608dc1f8905f18e3580bf934a30da8e3f03d3fb2',
  '207fe33176b222d1d1c543141fbe292ff20372a3727fd5fd576d172e9cddf95e');

++$test;
testFilterSignature('input.miff', 'MatteFloodfill',
  q/+25+45/,
  '6d18a2b8e149727c853c9f2e02f5807ca732ed15f5dbc03f45314d2fab95a631',
  '2c9e13828667822c69a403e789d1783b7d2d875527c9e22c1481e1acf66d889b');

++$test;
testFilterSignature('input.miff', 'Minify',
  q/ /,
  '41c3625cc93fd10645d0ee2a0120a87739a329dd088724611c76b5bebf49fcc5',
  '3fa7f170995524c5fbac306ef1e106455d3bb804d2093c41669f4e6e1562c5d2');

++$test;
testFilterSignature('input.miff', 'Modulate',
  q/60/,
  '17b9fcd681d677c1a5e1e673901ebd7ba8051b6296b134739584be26468fdabe',
  '7850fb3747bf7221bd9dab159c327334246d53aa83dbacad86044cee205bbcee');

++$test;
testFilterSignature('input.miff', 'Negate',
  q/False/,
  '13d2a0623ca4eefa189d9db65896ed0b3af21c7a61b3d34a1644e9fb151daef6');

++$test;
testFilterSignature('input.miff', 'Normalize',
  q/ /,
  '8a6d8fda83c8ee77506181df370579b194a129e615a5ba472be2b9f40fedf95d',
  '33a4ff4ea9bcd03fb6b5e4957cf56eea64ae9d57f4ecba705cfc56787c986a8b');

++$test;
testFilterSignature('input.miff', 'OilPaint',
  q/3/,
  'dd579fd36e04b6d22bbc9aa65ca326645ba1fbb39fa7fef67b230ec0eb5f4fd3',
  '7894d4bace6288dac627873134c906728f8004c783211bf0e31eacf46001c22e');

++$test;
testFilterSignature('input.miff', 'Opaque',
  q/#fefefd/,
  '8b19185a62241bd7b79ecf3f619711f4ebbedd73eaeca0366f05778762b6614f');

++$test;
testFilterSignature('input.miff', 'Quantize',
  q/128/,
  '2cfd3e729a57d13bef868d525d909d806df6b5ff595b6d5c88bd172f0eaef1e7',
  '8b93248e8d83be9caae3f0ff78a47bd85cc63372c18846943df0778de96a630c');

++$test;
testFilterSignature('input.miff', 'Raise',
  q/10x10/,
  'd675590ba355ff46287cbdb62076284fe9a046fff53ebcbf1456e2e03489458c',
  '36adc65e9ffa3535723f42597f8d6a95782aa19f9e7ca855a6cbdb6dd56e0f80');

++$test;
testFilterSignature('input.miff', 'Resize',
  q/50%/,
  '034a25c1de9337e993d64629478c0f7826653cf8408b95511e98da17c8b16f92',
  '9d54ceadb2dd6b36eef5cd9e3c4f2015d277f93bf2205927ba41f449915b6edf');

++$test;
testFilterSignature('input.miff', 'Roll',
  q/+10+10/,
  '7d06e76bc4dbc8a1c5908dde113fe2f89644e6b9272b67575c648e97453f1a1d');

++$test;
testFilterSignature('input.miff', 'Rotate',
  q/10/,
  '677cccb5efad4b4188825c5e5d483a643bc764d07437e55f4734769cf17b1918',
  '138c2338b6216e981f8b0a95a67d60d58d8d6e98599e2efbba79d71c4a473df3');

++$test;
testFilterSignature('input.miff', 'Sample',
  q/50%/,
  'b775c7c661bd6b2c4eab7d5c4202b67e37d38b2854dc037d000e2d5500a822e2');

++$test;
testFilterSignature('input.miff', 'Scale',
  q/50%/,
  '1e41fc85f160baa8cce4436ddf64e64e549b1e1bf941c75bc2860c6d1352022f',
  'ff2af316c85f4d38a707e974525def24ed8b9c25eaf247c960d8d923575f1add');

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/Shade.miff',
  'Shade', q/geometry=>'30x30',gray=>'true'/, 3.5e-06, 1.6e-05);

++$test;
testFilterSignature('input.miff', 'Segment',
  q/1/,
  '5e65af380f40077db2aac8ba0a058c1a4d32057d1b48bbe0ae617c557d765606',
  'a5e75fb937fcddc86a10aea2fbf9c596566c352304c3469eb257383dd5254416');

++$test;
testFilterSignature('input.miff', 'Sharpen',
  q/2x1/,
  '430e21f8a69d4421d6747f6edd43a3cd9646323a71730363fbcb712b0e7c45c3',
  'a1fd37d99a89f93f1c49268a8df0c07d2c50f34803d8b79faec3caf5557eb06b');

++$test;
testFilterSignature('input.miff', 'Shave',
  q/10x10/,
  '6f8749013dbe04020176a6e1d4a8a6783c2651fd0ef05cd9eb2dd66d38fa916f');

++$test;
testFilterSignature('input.miff', 'Shear',
  q/10x10/,
  '6a791cf363b5f6d9cf9bb80ca7ced8569733436cb96e5e3fa582819dd7ac4a35',
  'f71634c949bba1d9437512063025e0b4e3d6bc49e0f420647fd45e7428425f04');

++$test;
testFilterSignature('input.miff', 'Solarize',
  q/60/,
  '7aa9589246439e23b6a4504cae40b9e32b0e5ee34a6c3ede14ffa958d39806b0',
  '13d2a0623ca4eefa189d9db65896ed0b3af21c7a61b3d34a1644e9fb151daef6');

++$test;
testFilterSignature('input.miff', 'Swirl',
  q/60/,
  '8c793dc3c528ed3736779d43d424797a224b30bdd5efe47733a9b8d86e0ef314',
  '1719dae4583af8dcf686108bfd1ac1916ca88e31792ab80e50108fce4a91d9a4');

++$test;
testFilterSignature('input.miff', 'Threshold',
  q/50%/,
  '36c9b367b84035869df118d2fc61cbd7060d419d8626c4147955c712bcab15c0',
  '8b19185a62241bd7b79ecf3f619711f4ebbedd73eaeca0366f05778762b6614f');

++$test;
testFilterSignature('input.miff', 'Trim',
  q/0/,
  '8b19185a62241bd7b79ecf3f619711f4ebbedd73eaeca0366f05778762b6614f');

++$test;
testFilterSignature('input.miff', 'Wave',
  q/25x157/,
  'a9e97b5265e09463afa521dc9e69e3da9ff3933a11630a91baf87f867cc074bb',
  'fb03dc49241692317b5583d36ec1ef8d27dcb8f71579aa5af198b0552a05ea31');

++$test;

1;
