Introduction 

    PerlMagick, version 1.38, is an objected-oriented Perl interface to
    ImageMagick.  Use the module to read, manipulate, or write an image
    or image sequence from within a Perl script. This makes it suitable
    for Web CGI scripts. You must have ImageMagick 4.0.7 above and Perl
    version 5.002 or greater installed on your system.  Perl version
    5.004_04 or greater is required for PerlMagick to work under NT.

    See

      http://www.wizards.dupont.com/cristy/www/perl.html

    for additional information about PerlMagick.  See

      http://www.wizards.dupont.com/cristy/

    for instructions about installing ImageMagick.


Installation 

    Get the PerlMagick distribution and type the following: 

        gunzip PerlMagick-1.38.tar.gz
        tar xvf PerlMagick-1.38.tar
        cd Magick

    Next, edit Makefile.PL and change LIBS and INC to include the
    appropriate path information to the required libMagick library. You
    will also need library search paths (-L) to JPEG, PNG, TIFF,
    etc. libraries if they were included with your installed
    version of ImageMagick. If an extension library is built as a
    shared library but not installed in the system's default
    library search path, you may need to add run-path information
    (often -R or -rpath) corresponding to the equivalent library
    search path option so that the library can be located at
    run-time.

    To create and install the dymamically-loaded version of
    PerlMagick (the preferred way), execute
        
        perl Makefile.PL
        make
        make install

    To create and install a new 'perl' executable (replacing your
    existing PERL interpreter!) with PerlMagick statically linked
    (but other libraries linked statically or dynamically according
    to system linker default), execute

        perl Makefile.PL
        make perl
        make -f Makefile.aperl inst_perl
	
    or to create and install a new PERL interpreter with a
    different name than 'perl' (e.g. 'PerlMagick') and with
    PerlMagick statically linked

        perl Makefile.PL MAP_TARGET=PerlMagick
	make PerlMagick
        make -f Makefile.aperl inst_perl

    See the ExtUtils::MakeMaker(3) manual page for more information on
    building PERL extensions (like PerlMagick).

    Use nmake instead of make on an NT system.  For NT, you also need
    to copy IMagick.dll and X11.dll from the NT ImageMagick (see
    ftp://ftp.wizards.dupont.com/pub/ImageMagick/nt) distribution to a
    path library such as c:\perl\lib.

    For Unix, you typically need to be root to install the software.
    There are ways around this.  Consult the Perl manual pages for more
    information. You are now ready to utilize the PerlMagick routines
    from within your Perl scripts.

Testing PerlMagick

    After PerlMagick has been installed, you may execute
    
        make test

    to verify that PERL can load the PerlMagick extension ok.

    As a more interesting test, you may execute
    
        perl t.pl

    to verify and demonstrate a number of PerlMagick functions.
    The results of this test should look similar to:
    
        Create Image::Magick object...
        Get image attributes...
        RGB :  : 1
        Set image attributes...
        YCbCr :  : 1
        Read an image sequence...
        Images = 3
        display
        Get image attributes...
        YCbCr : GIF : 
        Create an image montage...
        Write the image montage to disk...
        Display the image montage on your X server...
        Images = 1
        display
    
    with a montage image being displayed on your X server at the
    end of the test.

Example Perl Magick Script 

    Here is an example script to get you started: 

        #!/usr/local/bin/perl
        use Image::Magick;

        $q = Image::Magick->new;
        $x = $q->Read("girl.gif", "logo.gif", "rose.gif");
        warn "$x" if $x;

        $x = $q->Crop(geom=>'100x100+100+100');
        warn "$x" if $x;

        $x = $q->Write("x.gif");
        warn "$x" if $x;

    The script reads three images, crops them, and writes a single
    image as a GIF animation sequence.

