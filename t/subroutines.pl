#
# Common subroutines to support tests
#
# Contributed by Bob Friesenhahn <bfriesen@simple.dallas.tx.us>
#

#
# Test reading a file
#
# Usage: testRead( read filename, expected md5 );
#
sub testRead {
  my( $infile, $md5 ) =  @_;
  
  $image=Image::Magick->new;
  $x=$image->ReadImage("$infile");
  if( "$x" ) {
    print "ReadImage $infile: $x";
    print "not ok $test\n";
  } else {
    $image->SignatureImage();
    $signature=$image->Get('signature');
    if ( $signature ne $md5 ) {
      print "Image: $infile, Computed: $signature, expected: $md5\n";
      print "not ok $test\n";
    } else {
      print "ok $test\n";
    }
  }
  undef $image;
}

#
# Test writing a file by first reading a source image, writing to a new image,
# reading the written image, and comparing with expected MD5.
#
# Usage: testReadWrite( read filename, write filename, write options, expected md5 );
#
# .e.g
#
# testReadWrite( 'input.jpg', 'output.jpg', q/quality=>80, interlace=>'None'/,
#                'dc0a144a0b9480cd1e93757a30f01ae3' );
#
# If the MD5 of the written image is not what is expected, the written
# image is preserved.  Otherwise, the written image is removed.
#
sub testReadWrite {
  my( $infile, $outfile, $writeoptions, $md5 ) = @_;
  
  $image=Image::Magick->new;
  $x=$image->ReadImage("$infile");
  if( "$x" ) {
    print "ReadImage $infile: $x\n";
    print "not ok $test\n";
  } else {
    # Write image to file
    my $options = 'filename=>"$outfile", ' . "$writeoptions";
    #print "Using options: $options\n";
    eval "\$x=\$image->WriteImage( $options ) ;";
    if( $@ ) {
      print "$@\n";
      print "not ok $test\n";
      exit 1;
    }
    if( "$x" ) {
      print "WriteImage $outfile: $x\n";
      print "not ok $test\n";
    } else {
      undef @$image;
      # Read image just written
      $x=$image->ReadImage("$outfile");
      if( "$x" ) {
	print "ReadImage $outfile: $x\n";
	print "not ok $test\n";
      } else {
	# Check signature
	$image->SignatureImage();
	$signature=$image->Get('signature');
	if ( $signature ne $md5 ) {
	  print " Image: $outfile, Got: $signature, expected: $md5\n";
	  print "not ok $test\n";
	} else {
	  print "ok $test\n";
	  ($file = $outfile) =~ s/.*://g;
	  unlink "$file";
	}
      }
    }
  }
  undef $image;
}

#
# Test writing a file by first reading a source image, writing to a
# new image, and reading the written image.  Depends on detecting
# reported errors by ImageMagick
#
# Usage: testReadWrite( read filename, write filename, write options);
#
# .e.g
#
# testReadWrite( 'input.jpg', 'output.jpg', q/quality=>80, interlace=>'None'/ );
#
# If the read of the written image is not what is expected, the
# written image is preserved.  Otherwise, the written image is
# removed.
#
sub testReadWriteNoVerify {
  my( $infile, $outfile, $writeoptions) = @_;
  
  $image=Image::Magick->new;
  $x=$image->ReadImage("$infile");
  if( "$x" ) {
    print "$x\n";
    print "ReadImage $infile: not ok $test\n";
  } else {
    # Write image to file
    my $options = 'filename=>"$outfile", ' . $writeoptions;
    #print "Using options: $options\n";
    eval "\$x=\$image->WriteImage( $options ) ;";
    if( $@ ) {
      print "$@";
      print "not ok $test\n";
      exit 1;
    }
    if( "$x" ) {
      print "WriteImage $outfile: $x\n";
      print "not ok $test\n";
    } else {
      undef @$image;
      # Read image just written
      $x=$image->ReadImage("$outfile");
      if( "$x" ) {
	print "ReadImage $outfile: $x\n";
	print "not ok $test\n";
      } else {
	print "ok $test\n";
	unlink $outfile;
      }
    }
  }
  undef $image;
}

1;
