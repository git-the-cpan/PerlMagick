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
  'e9cecf5d790f04ccd3a8d461ac06c3a500e18226d1f831610064cdd26973e460',
  'b560f1a7e493397c35acce69c8a17cf892ac61e03392f1fc9cf79076c81aa959');

++$test;
testFilterSignature('input.miff', 'Border',
  q/10/,
  '769b46c86a82faf496c5403938793692d2f07148c8377b76ac427b33cef72c70');

++$test;
testFilterSignature('input.miff', 'Channel',
  q/Red/,
  '6e821008e56c8a3ef2d31f02824454f665849866f61c52efcb98c4afd445af37');

++$test;
testFilterSignature('input.miff', 'Chop',
  q/10x10!/,
  'f28460390db5662e57ef9c11febe18f8031c8201b935b11754f4c83c64003c82');

++$test;
testFilterSignature('input.miff', 'ColorFloodfill',
  q/+25+45/,
  '64acc706a6704551f9c6b910c2327203f4ded229d78e5d1ac16a942803f90c34');

++$test;
testFilterSignature('input.miff', 'Colorize',
  q/red/,
  'f719dd6d84d4df94a6211d395323830bd67d022c2fb989b2ad2f30d851c5a87a');

++$test;
testFilterSignature('input.miff', 'Contrast',
  q/1/,
  '98ad158502284a92419d5fd5bd0654076ae3ee80cf698fd9755257a7c6595375',
  '7e97f79c95f43de8278519fd3f6785bed9f80bbd081726111038de20bd5caa40');

++$test;
testFilterSignature('input.miff', 'Convolve',
  [1, 2, 1, 2, 4, 2, 1, 2, 1],
  '09341bface4308b96a46e4b497cd1d18c1d75e7d296cce80544cf53af0bdc7b6',
  '15fd04f8c8346d83064d6efc41c08f01c73123ec7e18088b8376bbf4a009454c');

++$test;
testFilterSignature('input.miff', 'Crop',
  q/10x10!/,
  '2154755757d51e9f84e5483217fa49fb5e25b735d48380e1e76604218c8fa101');

++$test;
testFilterSignature('input.miff', 'Despeckle',
  q/ /,
  '9e7f20a6f5a36cbc7809c4ef7e748583fad81c6718f5af799210666b76016368',
  '0df0523ec0ffb8ab984887f77956ed50de925f044d97504160f975a3c034da86');

++$test;
testFilterSignature('input.miff', 'Edge',
  q/3/,
  '8245bada67e7be6509c02ec6f8372a8c2eb0c04bdc6221ff839ac06e770b9bf2',
  '1f18c469b21fca81f50358bbf91f22173ce9e9838ca569d00f353a1c1198c3de');

++$test;
testFilterCompare('input.miff', q/2x1/, 'reference/filter/Emboss.miff',
  'Emboss', q/2x1/,  3.4e-05, 2.5e-02);

++$test;
testFilterCompare('input.miff', q/2x1/, 'reference/filter/Equalize.miff',
  'Equalize', q/2x1/, 0, 0);

++$test;
testFilterSignature('input.miff', 'Flip',
  q/ /,
  '1c301fb17bcd1592d90caaa9e0b60c25a2b422ea97b0bf77396f781bb3b376f1');

++$test;
testFilterSignature('input.miff', 'Flop',
  q/ /,
  'b89521fb5408d216bddbb4317c859e3609bf78ae42e22962b272a01747f702ec');

++$test;
testFilterSignature('input.miff', 'Frame',
  q/10x10/,
  '769b46c86a82faf496c5403938793692d2f07148c8377b76ac427b33cef72c70', 
  '769b46c86a82faf496c5403938793692d2f07148c8377b76ac427b33cef72c70');

++$test;
testFilterSignature('input.miff', 'Gamma',
  q/2.2/,
  '9523deca0972bd1cedd471b7bdd981c2439e24dcb4a457fa94c45079a4c3ad00',
  '7fe5e738b0dcc290794d72ac9bf8b824f2080282f1e9b1d997006bbf89bcde2d');

++$test;
testFilterSignature('input.miff', 'Implode',
  q/0.5/,
  'ad053e3fbfb1a6a1e979447ab6d4e5082b02cb2a92a28d80c2de152ce4c3298f',
  '19c1733a8e84deb886f4270be61abf1a2c2cc252090b7f095c985b01fa2cae4d');

++$test;
testFilterSignature('input.miff', 'Magnify',
  q/ /,
  'e3b79f59864d8aa44a3c6dabe12ef5694bfbd4db290a2fcb5934af05e7f09e69',
  '1152c1047468b90072abc356d687d1650d26349bd66e33065e97ec91137523ee');

++$test;
testFilterSignature('input.miff', 'MatteFloodfill',
  q/+25+45/,
  '6d18a2b8e149727c853c9f2e02f5807ca732ed15f5dbc03f45314d2fab95a631',
  'dc317b328877f26f337365504f1268787c8f50c473acfeb4ecc3dbdca7972e3b');

++$test;
testFilterSignature('input.miff', 'Minify',
  q/ /,
  '705b0c856e7a9e8ad78c98f51b6a286ef4d7e921ca4ab9002c6216e21709f019',
  'a2a7f50f53ac254fdf73a53dc17077396a2a1ba9886211457dec3a3b1158018a');

++$test;
testFilterSignature('input.miff', 'Modulate',
  q/60/,
  'fe42ac48cb042a2d4652a90dba273cd9cea0bfb93f7c121807335c59798cf6eb',
  '82c929d21a65c6a13b66df29ec588d2b99b8c57f399be5b2bc51d260ceeff9b3');

++$test;
testFilterSignature('input.miff', 'Negate',
  q/False/,
  '2cd6516a4ecd5f050bb8795e0a9a66022e58466dcc63cf750eb046fdc970a99c');

++$test;
testFilterSignature('input.miff', 'Normalize',
  q/ /,
  '59ccdd29e73c479ddee1741881dfebf345cdf26064b39f165b465cba1f2d0ace',
  '7b9990dd9df135f5d1f3cc125d8cb44473e210d49e9743ccb44a8329494ae3e3');

++$test;
testFilterSignature('input.miff', 'OilPaint',
  q/3/,
  '2be3be2ba8b966434c63e31984baa47f140fa5123ffb3295872893da2fe86f05',
  'bd137bd899039591888e630fa1e6a3b45f51f0c0bb0ab5f89e5d18b47c870ffb');

++$test;
testFilterSignature('input.miff', 'Opaque',
  q/#fefefd/,
  '975cdb03f0fa923936f1cecf7b8a49a917493393a0eb098828ab710295195584');

++$test;
testFilterSignature('input.miff', 'Quantize',
  q/128/,
  '1e4f1ac8c76cf5db19560b5548494c4a652b7f079536fd083b3ae19044d316de',
  '18168d874bf0cbe9794743ca383cb4b6e9d45427c1a9dd1b694ecf6f8db9acaf');

++$test;
testFilterSignature('input.miff', 'Raise',
  q/10x10/,
  '77c6c8c200555a5865da69fbcb102d12f91a3ebd91a86fc183a71abef65dfc1a',
  '683ac4627d90baba583f8f7a5ae816e56d6b20eba84f55703a63a1ba15d6a598');

++$test;
testFilterSignature('input.miff', 'Resize',
  q/50%/,
  '1d0f0cd799212d26032c6d7353106451276547c1dc3817a956ba82a18b90edd2',
  '88cb0e9626473edcf6c576aff1faf3bc7b59604dca8562c77ac73fa8a6dd9568');

++$test;
testFilterSignature('input.miff', 'Roll',
  q/+10+10/,
  '4ee58490311d60671ffdb5dffd0c21f2efeefdad24b4d61e292cb7356da87686');

++$test;
testFilterSignature('input.miff', 'Rotate',
  q/10/,
  'de3690a6f74fc6f53b1074b16936dfe01f24227c650accbb9c8c03d2e02ed27e',
  'c47a26270444c5e5ce6bfe3b657c998fdd32eac93ea12b9e881aabeb7035bc78');

++$test;
testFilterSignature('input.miff', 'Sample',
  q/50%/,
  '1b15c7c4e9423ba59cb7caf10d9c59baaf78dbf96cafac27b0772c4cda7a902f');

++$test;
testFilterSignature('input.miff', 'Scale',
  q/50%/,
  '851c132effa0ee93f5b6df15d496bec9f9fdaa856f92ab9eba068b7bec9354b1',
  'd3e6a447aa70a5a39e33eb993dff61c5b19a3e042042286a5a3d37ea373cf2b8');

++$test;
testFilterCompare('input.miff', q//, 'reference/filter/Shade.miff',
  'Shade', q/geometry=>'30x30',gray=>'true'/, 3.5e-06, 1.6e-05);

++$test;
testFilterSignature('input.miff', 'Segment',
  q/1/,
  'bddb8e4907cb6dd82acf3dc3ff21ae7637ecf8cb78055dfd14724350d4d60add',
  'f79caa1f92bab5a60971439e91086d79df1e45c4423f1bc0ecd088faa6d2de9f');

++$test;
testFilterSignature('input.miff', 'Sharpen',
  q/2x1/,
  '9fc9c24be16f95a37be45b411a8a93f98689880a99360f59a735eee9940aabac',
  '6dc698dba60e7aa6d8efcf2de1369fc3baf0318de97bb6a5b8f9d2f476a14412');

++$test;
testFilterSignature('input.miff', 'Shave',
  q/10x10/,
  '7b0a93662ef5b07c9e5960ab91e282b8bbf8d45ec0fae866af1d8297220fa5f5');

++$test;
testFilterSignature('input.miff', 'Shear',
  q/10x10/,
  '93356f008df00d5af991c6f085db5bf7e0fc9de65a08e40cb73649679cf318ca',
  '43ccbf2895bdbf575a107d8f295622e1346ce570e24f6981ecbe402e9bea2663');

++$test;
testFilterSignature('input.miff', 'Solarize',
  q/60/,
  '98584c85133cd8d0724cb56f671378558644fd743a3fc89e6f3585c028f136e9',
  '2cd6516a4ecd5f050bb8795e0a9a66022e58466dcc63cf750eb046fdc970a99c');

++$test;
testFilterSignature('input.miff', 'Swirl',
  q/60/,
  '45218bae110e7f2182f6c3f8d06f93f9a7f0a798490216fe38d70ff857e91d30',
  'fa25a00e0b4f9b9f92bf2b77168c21720b64a49c76b515719e67708233abf447');

++$test;
testFilterSignature('input.miff', 'Threshold',
  q/50%/,
  '36c9b367b84035869df118d2fc61cbd7060d419d8626c4147955c712bcab15c0',
  'cd305da077a111f18e3e5e228d7b76e896bc76841fb2c5e77fe8d5be539b0cfc');

++$test;
testFilterSignature('input.miff', 'Trim',
  q/0/,
  '975cdb03f0fa923936f1cecf7b8a49a917493393a0eb098828ab710295195584');

++$test;
testFilterSignature('input.miff', 'Wave',
  q/25x157/,
  'd824a429079004c6df3fe3833bae6b0752ca481a4d3cdf14003a55f054faa233',
  'dc1efbacbcf3c7e897157b736671427d154d74555919d4439a798459c4003f9f');

++$test;

1;
