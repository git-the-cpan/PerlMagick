/* Released Feb. 17, 1997  by Kyle Shorter (magick@sympatico.org)	*/
/* Public Domain							*/

#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "XSUB.h"
#include "magick.h"
#include "perl.h"
#include <setjmp.h>
#ifdef __cplusplus
}
#endif

#define NUMBEROF(a) (sizeof a / sizeof *a)
#define ENDOF(a)    (&a[NUMBEROF(a)])
#define NULV	    ((void *)NULL)

char *IM_packname = "Image::Magick";
char *client_name = "PerlMagick";
int IM_do_warn = 0;		/* if != 0: error messages call Perl warn */

static char *complain = "Reference is not my type";

#define warning(e, s1, s2) { SetErrorStatus(e); warninghandler(s1, s2); }

static double
constant(name, arg)
    char *name;
    int arg;
{
    errno = 0;
    switch (*name)
    {
    case 'P':
	if (strEQ(name, "PluginWarning"))
	    return PluginWarning;
	break;

    case 'O':
	if (strEQ(name, "OptionError"))
	    return OptionError;
	if (strEQ(name, "OptionWarning"))
	    return OptionWarning;
	break;

    case 'X':
	if (strEQ(name, "XServerError"))
	    return XServerError;
	if (strEQ(name, "XServerWarning"))
	    return XServerWarning;
	break;

    case 'R':
	if (strEQ(name, "ResourceLimitError"))
	    return ResourceLimitError;
	break;

    case 'S':
	if (strEQ(name, "Success"))
	    return 0;
	break;

    case 'M':
	if (strEQ(name, "MissingPluginWarning"))
	    return MissingPluginWarning;
	break;

    case 'C':
	if (strEQ(name, "CorruptImageWarning"))
	    return CorruptImageWarning;
	break;

    case 'F':
	if (strEQ(name, "FileOpenWarning"))
	    return FileOpenWarning;
	break;
    }

    errno = EINVAL;
    return 0;
}

/*  The data type for the Image::Magick package.  In reality, it can either
 *  be an Image* (if its type is scalar) or AV* (if its type is array).
 */
typedef void *Image__Magick;

/*  The data type for remembering options set by the user, which basically
 *  correspond to ImageMagick's command line options.  Each AV* type of
 *  Image__Magick has a special variable created for it (see getinfo) that
 *  holds one.
 */
struct info {
    ImageInfo info;
    QuantizeInfo quant;
};

/* the different types of arguments that can be passed as arguments from Perl */
union alist {
    int t_int;
    double t_dbl;
    char *t_str;
    Image *t_img;
};

/*  The p_XXX arrays match the ImageMagick enums.  The positions must match
 *  between both.  The names are the minimum length to match, e.g., in p_noises
 *  AddNoise("laplacian")  and  AddNoise("LaplacianNoise") both work.
 */
static char *p_noises[] = {
    "Uniform", "Gaussian", "Multiplicative", "Impulse", "Laplacian", "Poisson",
0 };

static char *p_alignments[] = {
    "Undefined", "Left", "Center", "Right", 0 };

static char *p_boolean[] = {
    "False", "True", 0 };

static char *p_compressions[] = {
    "Undefined", "None", "JPEG", "LZW", "Runlength", "Zip", 0 };

static char *p_filters[] = {
    "Box", "Mitchell", "Triangle", 0 };

static char *p_gravities[] = {
    "Forget", "NorthWest", "North", "NorthEast", "West",
    "Center", "East", "SouthWest", "South", "SouthEast", "Static", 0 };

static char *p_interlaces[] = {
    "Undefined", "None", "Line", "Plane", "Partition", 0 };

static char *p_methods[] = {
    "Point", "Replace", "Floodfill", "Reset", 0 };

static char *p_modes[] = {
    "Frame", "Unframe", "Concatenate", 0 };

static char *p_previews[] = {
    "Rotate", "Shear", "Roll", "Hue", "Saturation", "Brightness", "Gamma",
    "Spiff", "Dull", "Grayscale", "Quantize", "Despeckle", "ReduceNoise",
    "AddNoise", "Sharpen", "Blur", "EdgeDetect", "Spread", "Solarize", "Shade",
    "Raise", "Segment", "Swirl", "Implode", "OilPaint", "Charcoal", 0 };

static char *p_primitives[] = {
    "Undefined", "Point", "Line", "Rectangle", "FillRectangle", "Circle",
    "FillCircle", "Polygon", "FillPolygon", "Color", "Matte", "Text", "Image",
0 };

static char *p_units[] = {
    "Undefined", "pixels / inch", "pixels / centimeter", 0 };

static char *p_composites[] = {
    "Undefined", "Over", "In", "Out", "Atop", "Xor", "Plus", "Minus", "Add",
    "Subtract", "Difference", "Bumpmap", "Replace", "MatteReplace", "Mask",
    "Blend", "Displace", 0 };

static char *p_colorspaces[] = {
    "Undefined", "RGB", "Gray", "Transparent", "OHTA", "XYZ", "YCbCr", "YCC",
    "YIQ", "YPbPr", "YUV", "CMYK", 0 };

static char *p_classes[] = {
    "Undefined", "Direct", "Pseudo", 0 };

/* types for struct routines.args.type */
#define P_STR	(char **)0	/* arg is a string */
#define P_INT	(char **)1	/* arg in an integer */
#define P_DBL	(char **)2	/* arg is a double */
#define P_IMG	(char **)3	/* arg is an image reference */

/* anything else is a pointer to an array of strings whose position in */
/* the array is returned as an integer, i.e., an enum.  */

#define ARGMAX	12

/*  The list of ImageMagick routines and their paramters currently supported
 *  by this interface (except for Read, Write and new).  I did it this way
 *  to avoid a lot of duplicated code, and to use the neato ALIASes that
 *  XS provides.  Parameter names are matched up to the name's length so
 *  that e.g. the parameter name "comment" matches "commentstuff".
 */
static struct routines {
	char *name;		/* the routine name */
	struct args {
	    char *varname;	/* the parameter's name */
	    char **type;	/* the parameter's type, P_XXX or p_xxx */
	} args[ARGMAX];
} routines[] = {
    {	"Comment", { {"comment", P_STR} } },
    {	"Label",   { {"label", P_STR} } },
    {	"AddNoise", { {"noise", p_noises} } },
    {	"Colorize", { {"color", P_STR}, {"pen", P_STR} } },
    {	"Border", { {"geom", P_STR}, {"width", P_INT}, {"height", P_INT},
					{"color", P_STR} } },
    {	"Blur", { {"factor", P_DBL} } },
    {	"Chop", { {"geom", P_STR}, {"width", P_INT}, {"height", P_INT},
					{"x", P_INT}, {"y", P_INT} } },
    {	"Crop", { {"geom", P_STR}, {"width", P_INT}, {"height", P_INT},
					{"x", P_INT}, {"y", P_INT} } },
    {	"Despeckle", },
    {	"Edge", { {"factor", P_DBL} } },
    {	"Emboss", },
    {	"Enhance", },
    {	"Flip", },
    {	"Flop", },
    {	"Frame", { {"geom", P_STR}, {"width", P_INT}, {"height", P_INT},
		 {"inner", P_INT}, {"outer", P_INT}, {"color", P_STR} } },
    {	"Implode", { {"factor", P_DBL} } },
    {	"Magnify", },
    {	"MedianFilter", },
    {	"Minify", },
    {	"OilPaint", { {"radius", P_INT} } },
    {	"ReduceNoise", },
    {	"Roll", { {"geom", P_STR}, {"x", P_INT}, {"y", P_INT} } },
    {	"Rotate", { {"degree", P_DBL}, {"crop", p_boolean},
		  {"sharpen", p_boolean} } },
    {	"Sample", { {"geom", P_STR}, {"width", P_INT}, {"height", P_INT} } },
    {	"Scale", { {"geom", P_STR}, {"width", P_INT}, {"height", P_INT} } },
    {	"Shade", { {"geom", P_STR}, {"azimuth", P_DBL},
		   {"elevat", P_DBL}, {"color", p_boolean} } },
    {	"Sharpen", { {"factor", P_DBL} } },
    {	"Shear", { {"geom", P_STR}, {"x", P_DBL}, {"y", P_DBL},
		   {"crop", p_boolean} } },
    {	"Spread", { {"amount", P_INT} } },
    {	"Swirl", { {"degree", P_DBL} } },
    {	"Zoom", { {"geom", P_STR}, {"width", P_INT}, {"height", P_INT},
		  {"filter", p_filters} } },
    {	"IsGrayImage", },
    {	"Annotate", { {"server", P_STR}, {"font", P_STR}, {"point", P_INT},
		    {"box", P_STR}, {"pen", P_STR}, {"geom", P_STR},
		    {"text", P_STR}, {"x", P_INT}, {"y", P_INT},
		    {"align", p_alignments} } },
    {	"ColorFloodfill", },
    {	"Composite", { {"compos", p_composites}, {"image", P_IMG},
		    {"x", P_INT}, {"y", P_INT} } },
    {	"Contrast", { {"sharp", p_boolean} } },
    {	"CycleColormap", { {"amount", P_INT} } },
    {	"Draw", { {"prim", p_primitives}, {"points", P_STR},
		  {"meth", p_methods}, {"pen", P_STR}, {"linew", P_INT},
		  {"server", P_STR}, } },
    {	"Equalize", },
    {	"Gamma", { {"gamma", P_STR}, {"red", P_DBL}, {"green", P_DBL},
		    {"blue", P_DBL} } },
    {	"Map", { {"image", P_IMG}, {"dither", p_boolean} } },
    {	"MatteFloodfill", },
    {	"Modulate", { {"factor", P_STR}, {"bright", P_DBL}, {"satur", P_DBL},
		    {"hue", P_DBL} } },
    {	"Negate", { {"gray", p_boolean} } },
    {	"Normalize", },
    {	"NumberColors", },
    {	"Opaque", { {"color", P_STR}, {"pen", P_STR} } },
    {	"Quantize", { {"colors", P_INT}, {"tree", P_INT}, {"dither", p_boolean},
		    {"colorsp", p_colorspaces} } },
    {	"Raise", { {"geom", P_STR}, {"width", P_INT}, {"height", P_INT},
		    {"x", P_INT}, {"y", P_INT}, {"raise", p_boolean} } },
    {	"Segment", { {"colorsp", p_colorspaces}, {"verbose", p_boolean},
		    {"clust", P_DBL}, {"smooth", P_DBL} } },
    {	"Signature", },
    {	"Solarize", { {"factor", P_DBL} } },
    {	"Sync", },
    {	"Texture", { {"file", P_STR} } },
    {	"Transform", { {"crop", P_STR}, {"geom", P_STR} } },
    {	"Transparent", { {"color", P_STR} } },
    {   "Threshold", { {"threshold", P_DBL} } },
    {   "Charcoal", { {"factor", P_DBL} } },
    {	"Trim", },
    {	"Wave", { {"geom", P_STR}, {"ampli", P_DBL}, {"wave", P_DBL} } },
};

static SV *im_er_mes;		/* Perl variable for storing messages */
static jmp_buf *im_er_jmp;	/* long jump return for FATAL errors */

/* something like a Perl-like ignore case string compare; 
 * the strings are equal if the second string runs out first.
 */
static int
strEQcase(a, b)
    const char *a, *b;
{
    char c;
    for ( ; (c = *b); a++, b++)
	if ((isUPPER(c) ? toLOWER(c) : c) != (isUPPER(*a) ? toLOWER(*a) : *a))
	    return 0;
    return 1;
}

/* look through a list of strings matching it to str and return */
/* its index in the list, or -1 for not found */
static int
LookupStr(list, str)
    const char **list, *str;
{
    const char **p;

    for (p = list; *p; p++)
	if (strEQcase(str, *p))
	    return p - list;

    return -1;
}

/*  Makes a duplicate of the given info, or if info is NULL, a new one. */
static struct info *
copy_info(info)
    struct info *info;
{
    struct info *new = (struct info *) safemalloc(sizeof (struct info));

    if (!info)
    {
	GetImageInfo(&new->info);
	GetQuantizeInfo(&new->quant);
	return new;
    }

    *new = *info;
    new->info.filename = strcpy(safemalloc(MaxTextExtent), info->info.filename);
    if (info->info.server_name)
	new->info.server_name = strdup(info->info.server_name);
    if (info->info.font)
	new->info.font = strdup(info->info.font);
    if (info->info.size)
	new->info.size = strdup(info->info.size);
    if (info->info.tile)
	new->info.tile = strdup(info->info.tile);
    if (info->info.density)
	new->info.density = strdup(info->info.density);
    if (info->info.page)
	new->info.page = strdup(info->info.page);
    if (info->info.dispose)
	new->info.dispose = strdup(info->info.dispose);
    if (info->info.delay)
	new->info.delay = strdup(info->info.delay);
    if (info->info.iterations)
	new->info.iterations = strdup(info->info.iterations);
    if (info->info.texture)
	new->info.texture = strdup(info->info.texture);
    if (info->info.undercolor)
	new->info.undercolor = strdup(info->info.undercolor);

    return new;
}

/*  Get rid of a previously created info structure. */
static void
destroy_info(info)
    struct info *info;
{
    safefree(info->info.filename);
    if (info->info.server_name)
	safefree(info->info.server_name);
    if (info->info.font)
	safefree(info->info.font);
    if (info->info.size)
	safefree(info->info.size);
    if (info->info.tile)
	safefree(info->info.tile);
    if (info->info.density)
	safefree(info->info.density);
    if (info->info.page)
	safefree(info->info.page);
    if (info->info.dispose)
	safefree(info->info.dispose);
    if (info->info.delay)
	safefree(info->info.delay);
    if (info->info.iterations)
	safefree(info->info.iterations);
    if (info->info.texture)
	safefree(info->info.texture);
    if (info->info.undercolor)
	safefree(info->info.undercolor);
    safefree((char *) info);
}

/*
 *  Replace libmagick's warning handler.  This stores the (possibly
 *  multiple) messages in a Perl variable for later returning.  If the
 *  IM_do_warn variable is set, it also calls the Perl warn routine.
 */

static void
warninghandler(message, qual)
    const char *message, *qual;
{
    char b[400];
    int magick_status;
    int en = errno;
    errno = 0;

    if (!message)
	return;

    magick_status = SetErrorStatus(0);
    sprintf(b, "Warning %d: %.128s%s%.128s%s%s%.64s%s",
		magick_status, message,
		qual? " (" : "", qual? qual : "", qual? ")" : "",
		en? " [" : "", en? strerror(en) : "", en? "]" : "");

    if (im_er_mes == NULL || IM_do_warn)	/* message buffer not set up */
    {
	warn("%s", b);
	if (im_er_mes == NULL)
	    return;
    }

    if (SvCUR(im_er_mes))	/* add \n separator between messages */
	sv_catpv(im_er_mes, "\n");
    sv_catpv(im_er_mes, b);
}

/*
 *  Replace libmagick's fatal error handler.  This stores the message
 *  in a Perl variable, and longjmp's to return the error to perl.  If
 *  the IM_do_warn variable is set, it also calls the Perl warn routine.
 *  Note that this doesn't exit but returns control to Perl; the
 *  Image::Magick handle may be left in a bad state.
 */
static void
errorhandler(message, qual)
    const char *message, *qual;
{
    char b[400];
    int magick_status;
    int en = errno;
    errno = 0;

    magick_status = SetErrorStatus(0);
    sprintf(b, "Error %d: %.128s%s%.128s%s%s%.64s%s",
		magick_status,
		(message ? message : "ERROR"),
		qual? " (" : "", qual? qual : "", qual? ")" : "",
		en? " [" : "", en? strerror(en) : "", en? "]" : "");
    if (im_er_mes == NULL || im_er_jmp == NULL || IM_do_warn)
    {
	warn("%s", b);
	if (im_er_jmp == NULL)
	    exit(magick_status % 100);
    }

    if (im_er_mes)
    {
	if (SvCUR(im_er_mes))	/* add \n separator between messages */
	    sv_catpv(im_er_mes, "\n");
	sv_catpv(im_er_mes, b);
    }

    longjmp(*im_er_jmp, magick_status);	/* tell caller to return error */
}

/*  Used mostly for the info structure members.  It sets those elements
 *  that are malloc'd strings.
 */
static void
newval(dest, src)
    char **dest, *src;
{
    char *m = malloc(strlen(src) + 1);
    if (!m)
    {
	warning(ResourceLimitWarning, "Malloc failed", NULV);
	return;
    }
    if (*dest)
	free(*dest);
    *dest = m;
    strcpy(*dest, src);
}

/*  Look up or create an info structure for the given Image__Magick
 *  reference.  If it does create a new one, the information in
 *  oldinfo is used to initialize it.
 */
static struct info *
getinfo(rref, oldinfo)
    void *rref;		/* AV* or SV* (actually only AV* should use getinfo) */
    struct info *oldinfo;
{
    SV *sv;
    char b[80];
    struct info *info;

    sprintf(b, "%s::A_%lx_Z", IM_packname, (long)rref);
    sv = perl_get_sv(b, (TRUE | 0x2));
    if (!sv)
    {
	warning(ResourceLimitWarning, "Can't create info variable", b);
	return oldinfo;
    }
    if (SvIOKp(sv) && (info = (struct info *)SvIV(sv)))
	return info;

    info = copy_info(oldinfo);
    sv_setiv(sv, (IV)info);
    return info;
}

/*  Sets the attribute named attr to the value in sval.  This can change
 *  either or both of image or info.
 */
static void
SetAttribute(info, image, attr, sval)
    struct info *info;
    Image *image;
    char *attr;
    SV *sval;
{
    /* switch on first letter of attribute.  'break' will go */
    /* to "unknown" error; use 'return' for known options */
    switch (*attr)
    {
    case 'A': case 'a':
	if (strEQcase(attr, "adjoin"))
	{
	    int sp = SvPOK(sval) ? LookupStr(p_boolean, SvPV(sval, na))
			     : SvIV(sval);
	    if (sp < 0)
	    {
	        warning(OptionWarning, "Unknown adjoin type", SvPV(sval, na));
	        return;
	    }
	    if (info)
	        info->info.adjoin = sp;
	    return;
	}
	break;
    case 'B': case 'b':
	if (strEQcase(attr, "background"))
	{
	    XColor target_color;

	    (void) XQueryColorDatabase(SvPV(sval, na), &target_color);
	    for ( ; image; image = image->next) {
		image->background_color.red = XDownScale(target_color.red);
		image->background_color.green = XDownScale(target_color.green);
		image->background_color.blue = XDownScale(target_color.blue);
	    }
	    return;
	}
	if (strEQcase(attr, "bordercolor"))
	{
	    XColor target_color;

	    (void) XQueryColorDatabase(SvPV(sval, na), &target_color);
	    for ( ; image; image = image->next) {
		image->border_color.red = XDownScale(target_color.red);
		image->border_color.green = XDownScale(target_color.green);
		image->border_color.blue = XDownScale(target_color.blue);
	    }
	    return;
	}
	break;
    case 'C': case 'c':
	if (strEQcase(attr, "colormap"))
	{
	    ColorPacket *cp;
	    int i, red, green, blue;

	    for ( ; image; image = image->next)
	    {
	        if (image->class == DirectClass)
		    continue;
		i = 0;
	        (void) sscanf(attr, "%*[^[][%d", &i);
		if (i > image->colors)
		    i %= image->colors;
		cp = image->colormap+i;
		red = cp->red;
		blue = cp->green;
		green = cp->blue;
		(void) sscanf(SvPV(sval, na), "%d,%d,%d", &red, &green,
					&blue);
		cp->red = red;
		cp->blue = green;
		cp->green = blue;
	    }
	    return;
	}
	if (strEQcase(attr, "colorsp"))
	{
	    if (info)
	    {
		int sp = SvPOK(sval) ? LookupStr(p_colorspaces, SvPV(sval, na))
				     : SvIV(sval);
		if (sp < 0)
		{
		    warning(OptionWarning, "Unknown colorspace type",
					   SvPV(sval, na));
		    return;
		}
		info->quant.colorspace = sp;
	    }
	    return;
	}
	if (strEQcase(attr, "colors"))
	{
	colors:
	    if (info && !(info->quant.number_colors = SvIV(sval)))
		info->quant.number_colors = MaxRGB+1;
	    return;
	}
	if (strEQcase(attr, "compres"))
	{
	    int com = SvPOK(sval) ? LookupStr(p_compressions, SvPV(sval, na))
				  : SvIV(sval);
	    if (com < 0)
	    {
		warning(OptionWarning, "Unknown compression type", SvPV(sval, na));
		return;
	    }
	    if (info)
		info->info.compression = com;
	    for ( ; image; image = image->next)
		image->compression = com;
	    return;
	}
	break;
    case 'D': case 'd':
	if (strEQcase(attr, "density"))
	{
	    char *p = SvPV(sval, na);
	    if (!IsGeometry(p))
	    {
		warning(OptionWarning, "bad geometry on density", p);
		return;
	    }
	    if (info)
		newval(&info->info.density, p);
	    return;
	}
	if (strEQcase(attr, "dispose"))
	{
	    if (info)
		newval(&info->info.dispose, SvPV(sval, na));
	    for (; image; image = image->next)
		image->dispose = SvIV(sval);
	    return;
	}
	if (strEQcase(attr, "delay"))
	{
	    if (info)
		newval(&info->info.delay, SvPV(sval, na));
	    for ( ; image; image = image->next)
		image->delay = SvIV(sval);
	    return;
	}
	if (strEQcase(attr, "dither"))
	{
	    if (info)
	    {
		int sp = SvPOK(sval) ? LookupStr(p_boolean, SvPV(sval, na))
				     : SvIV(sval);
		if (sp < 0)
		{
		    warning(OptionWarning, "Unknown dither type", SvPV(sval, na));
		    return;
		}
		info->info.dither = sp;
		info->quant.dither = sp;
	    }
	    return;
	}
	if (strEQcase(attr, "display"))	/* same as server */
	{
	display:
	    if (info)
		newval(&info->info.server_name, SvPV(sval, na));
	    return;
	}
	break;
    case 'E': case 'e':
	break;
    case 'F': case 'f':
	if (strEQcase(attr, "file"))
	{
	    char *p = SvPV(sval, na);
	    if (info)
		strncpy(info->info.filename, p, MaxTextExtent - 1);
	    for ( ; image; image = image->next)
		strncpy(image->filename, p, MaxTextExtent - 1);
	    return;
	}
	if (strEQcase(attr, "font"))
	{
	    if (info)
		newval(&info->info.font, SvPV(sval, na));
	    return;
	}
	if (strEQcase(attr, "format"))	/* same as magick */
	{
	format:
	    if (info)
	    {
		sprintf(info->info.filename, "%.70s:", SvPV(sval, na));
		SetImageInfo(&info->info, 0);
		if (*info->info.magick == '\0')
		    warning(OptionWarning, "Unrecognized image format",
					    info->info.filename);
	    }
	    return;
	}
	break;
    case 'G': case 'g':
	break;
    case 'H': case 'h':
	break;
    case 'I': case 'i':
	if (strEQcase(attr, "iterat"))	/* same as loop */
	{
    iterations:
	    if (info)
		newval(&info->info.iterations, SvPV(sval, na));
	    for ( ; image; image = image->next)
		image->iterations = SvIV(sval);
	    return;
	}
	if (strEQcase(attr, "interla"))
	{
	    int in = SvPOK(sval) ? LookupStr(p_interlaces, SvPV(sval, na))
				 : SvIV(sval);
	    if (in < 0)
		warning(OptionWarning, "Unknown interlace value", SvPV(sval,na))
	    else if (info)
		info->info.interlace = in;
	    return;
	}
	break;
    case 'J': case 'j':
	break;
    case 'K': case 'k':
	break;
    case 'L': case 'l':
	if (strEQcase(attr, "loop"))	/* same as iterations */
	    goto iterations;
	break;
    case 'M': case 'm':
	if (strEQcase(attr, "magick"))	/* same as format */
	    goto format;
	if (strEQcase(attr, "mattecolor"))
	{
	    XColor target_color;

	    (void) XQueryColorDatabase(SvPV(sval, na), &target_color);
	    for ( ; image; image = image->next) {
		image->matte_color.red = XDownScale(target_color.red);
		image->matte_color.green = XDownScale(target_color.green);
		image->matte_color.blue = XDownScale(target_color.blue);
	    }
	    return;
	}
	if (strEQcase(attr, "monoch"))
	{
	    int sp = SvPOK(sval) ? LookupStr(p_boolean, SvPV(sval, na))
			     : SvIV(sval);
	    if (sp < 0)
	    {
	        warning(OptionWarning, "Unknown monochrome type",
		    SvPV(sval, na));
	        return;
	    }
	    if (info)
	        info->info.monochrome = sp;
	    return;
	}
	break;
    case 'N': case 'n':
	if (strEQcase(attr, "number"))	/* same as colors */
	    goto colors;
	break;
    case 'O': case 'o':
	break;
    case 'P': case 'p':
	if (strEQcase(attr, "page"))
	{
	    char *p = PostscriptGeometry(SvPV(sval, na));
	    if (!p)
		return;
	    for ( ; image; image = image->next)
		newval(&image->page, p);
	    if (info)
		newval(&info->info.page, p);
	    free(p);
	    return;
	}
	if (strEQcase(attr, "pixel"))
	{
	    RunlengthPacket *cp;
	    int x, y, red, green, blue, index;

	    for ( ; image; image = image->next)
	    {
	        if (!UncompressImage(image))
		    continue;
		x = 0;
		y = 0;
	        (void) sscanf(attr, "%*[^[][%d,%d", &x, &y);
		if (y > image->rows)
		    y %= image->rows;
		if (x > image->columns)
		    x %= image->columns;
		cp = image->pixels+(y*image->columns+x);
		red = cp->red;
		blue = cp->green;
		green = cp->blue;
		index = cp->index;
		(void) sscanf(SvPV(sval, na), "%d,%d,%d,%d", &red, &green,
					&blue, &index);
		cp->red = red;
		cp->blue = green;
		cp->green = blue;
		cp->index = index;
	    }
	    return;
	}
	if (strEQcase(attr, "points"))
	{
	    if (info && (info->info.pointsize = SvIV(sval)) <= 0)
		info->info.pointsize = atoi(DefaultPointSize);
	    return;
	}
	break;
    case 'Q': case 'q':
	if (strEQcase(attr, "qualit"))
	{
	    if (info && (info->info.quality = SvIV(sval)) <= 0)
		info->info.quality = atoi(DefaultImageQuality);
	    return;
	}
	break;
    case 'R': case 'r':
	break;
    case 'S': case 's':
	if (strEQcase(attr, "scene"))
	{
	    for ( ; image; image = image->next)
		image->scene = SvIV(sval);
	    return;
	}
	if (strEQcase(attr, "subim"))
	{
	    if (info)
		info->info.subimage = SvIV(sval);
	    return;
	}
	if (strEQcase(attr, "subra"))
	{
	    if (info)
		info->info.subrange = SvIV(sval);
	    return;
	}
	if (strEQcase(attr, "server"))	/* same as display */
	    goto display;
	if (strEQcase(attr, "size"))
	{
	    if (info)
	    {
		char *p = SvPV(sval, na);
		if (!IsGeometry(p))
		{
		    warning(OptionWarning, "Bad geometry on size", p);
		    return;
		}
		newval(&info->info.size, p);
	    }
	    return;
	}
	break;
    case 'T': case 't':
	if (strEQcase(attr, "tile"))
	{
	    if (info)
		newval(&info->info.tile, SvPV(sval, na));
	    return;
	}
	if (strEQcase(attr, "texture"))
	{
	    if (info)
		newval(&info->info.texture, SvPV(sval, na));
	    return;
	}
	if (strEQcase(attr, "tree"))
	{
	    if (info)
		info->quant.tree_depth = SvIV(sval);
	    return;
	}
	break;
    case 'U': case 'u':
	if (strEQcase(attr, "underc"))
	{
	    if (info)
		newval(&info->info.undercolor, SvPV(sval, na));
	    return;
	}
	break;
    case 'V': case 'v':
	if (strEQcase(attr, "verbose"))
	{
	    int sp = SvPOK(sval) ? LookupStr(p_boolean, SvPV(sval, na))
			     : SvIV(sval);
	    if (sp < 0)
	    {
	        warning(OptionWarning, "Unknown verbose type", SvPV(sval, na));
	        return;
	    }
	    if (info)
	        info->info.verbose = sp;
	    return;
	}
	break;
    case 'W': case 'w':
	break;
    case 'X': case 'x':
	break;
    case 'Y': case 'y':
	break;
    case 'Z': case 'z':
	break;
    }

    /* fall through to here for unknown attributes */
    warning(OptionWarning, "Unknown attribute", attr);
}

/*  This recursive routine is called by setup_list to traverse the
 *  Image__Magick reference.  If building an svarr (see setup_list),
 *  *cur is the current position in *svarr and *last is the final
 *  entry in *svarr.
 */
static Image *
get_list(rref, svarr, cur, last)
    SV *rref;
    SV ***svarr;
    int *cur, *last;
{
    if (!rref)
	return NULL;

    switch (SvTYPE(rref))
    {
    case SVt_PVAV:	/* array of images */
	{
	    Image *prev = NULL, *head = NULL;
	    AV *av = (AV *)rref;
	    int i, n = av_len(av);

	    for (i = 0; i <= n; i++)	/* look through entire array */
	    {
		SV **rv = av_fetch(av, i, 0);
		if (rv && *rv && sv_isobject(*rv))
		{
		    Image *image = get_list(SvRV(*rv), svarr, cur, last);
		    if (!image)
			continue;
		    image->previous = prev;
		    *(prev? &prev->next : &head) = image;
		    for (prev = image; prev->next; prev = prev->next)
			;
		}
	    }
	    return head;
	}

    case SVt_PVMG:		/* blessed scalar, one image */
	{
	    Image *image = (Image *)SvIV(rref);
	    if (!image)
		return NULL;

	    image->previous = image->next = NULL;
	    if (svarr)
	    {
		if (*cur == *last)
		{
		    *last += 256;
		    if (*svarr) 
			*svarr = (SV **)saferealloc((char *) *svarr, *last * sizeof *svarr);
		    else
			*svarr = (SV **)safemalloc(*last * sizeof *svarr);
		}
		(*svarr)[*cur] = rref;
		(*svarr)[++(*cur)] = NULL;
	    }
	    return image;
	}
    }
    fprintf(stderr, "setup_list: unknown ref type %ld\n", SvTYPE(rref));
    return NULL;
}

/*  This routine returns the list of all the images linked by their
 *  image->next and image->previous link lists for use with ImageMagick.
 *  If info is non-NULL, an info structure is returned in *info.  If
 *  svarr is non-NULL, an array of SV* are returned in *svarr.  svarr
 *  is used when the images are going to be replaced with new Image* 's.
 */
static Image *
setup_list(rref, info, svarr)
    SV *rref;
    struct info **info;
    SV ***svarr;
{
    int cur = 0, last = 0;
    Image *image;

    if (svarr)
	*svarr = NULL;
    if (info)
	*info = NULL;

    image = get_list(rref, svarr, &cur, &last);

    if (info && SvTYPE(rref) == SVt_PVAV)
	*info = getinfo(rref, NULV);

    return image;
}

/* From here on is processed by XS */

MODULE = Image::Magick		PACKAGE = Image::Magick

PROTOTYPES: ENABLE

BOOT:
	SetWarningHandler(warninghandler);
	SetErrorHandler(errorhandler);

double
constant(name, arg)
	char *		name
	int		arg

void
DESTROY(ref)
	Image::Magick	ref = NO_INIT
	PPCODE:
	{
	    SV *rref;	/* rref is the SV* of ref=SvIV(rref) */

	    if (!sv_isobject(ST(0)))
		croak(complain);
	    rref = SvRV(ST(0));

	    switch (SvTYPE(rref))
	    {
	    case SVt_PVAV:	/* array (AV *)rref */
		{
		    SV *sv;
		    char b[80];
		    struct info *info;

		    sprintf(b, "#_%lx_", (long)rref);
		    if ((sv = perl_get_sv(b, FALSE)))
		    {
			if (SvREFCNT(sv) == 1 && SvIOK(sv)
				      && (info = (struct info *)SvIV(sv)))
			{
			    destroy_info(info);
			    sv_setiv(sv, 0);
			}
			SvREFCNT_dec(sv);
		    }
		    break;
		}
	    case SVt_PVMG:	/* blessed scalar = (Image *)SvIV(rref) */
		{
		    Image *image = (Image *)SvIV(rref);
		    if (image)
		    {
			image->orphan = 1;
			DestroyImage(image);
			sv_setiv(rref, 0);
		    }
		    break;
		}
	    default:
	      break;
	    }
	}

void
Animate(ref, ...)
	Image::Magick	ref = NO_INIT
	ALIAS:
	    AnimateImage	= 1
	    animate		= 2
	    animateimage	= 3
	PPCODE:
	{
	    SV *rref;	/* rref is the SV* of ref=SvIV(rref) */
	    Image *image;
	    struct info *info;
	    volatile struct info *temp = NULL;
	    XResourceInfo resource;
	    XrmDatabase resource_database;
	    Display *display;
	    char *resource_value;
	    int n;
	    jmp_buf error_jmp;
	    volatile int retval = 0;

	    im_er_mes = newSVpv("", 0);

	    if (!sv_isobject(ST(0)))
	    {
		warning(OptionWarning, complain, IM_packname);
		goto badreturn;
	    }
	    rref = SvRV(ST(0));

	    im_er_jmp = &error_jmp;
	    if ((retval = setjmp(error_jmp)))
		goto badreturn;

	    if (!(image = setup_list(rref, &info, NULV)))
	    {
		warning(OptionWarning, "No images to Display", NULV);
		goto badreturn;
	    }

	    temp = copy_info(info);
	    *temp->info.filename = '\0';

	    if (items == 2)
		SetAttribute(temp, NULL, "server", ST(1));
	    else if (items > 2)
		for (n = 2; n < items; n += 2)
		    SetAttribute(temp, NULL, SvPV(ST(n-1), na), ST(n));

	    display = XOpenDisplay(info->info.server_name);
	    if (display)
	    {
		XSetErrorHandler(XError);
		resource_database = XGetResourceDatabase(display, client_name);
		XGetResourceInfo(resource_database, client_name, &resource);
		resource.immutable = True;
		resource.delay = 60;

		(void) XAnimateImages(display, &resource, (char **) NULL, 0,
		    image);

		XCloseDisplay(display);
	    }

	badreturn:
	    if (temp)
		destroy_info(temp);
	    sv_setiv(im_er_mes, (IV)(retval ? retval : SvCUR(im_er_mes) != 0));
	    SvPOK_on(im_er_mes);
	    ST(0) = sv_2mortal(im_er_mes);
	    im_er_mes = NULL, im_er_jmp = NULL;
	    XSRETURN(1);
	}

void
Average(ref)
	Image::Magick	ref = NO_INIT
	ALIAS:
            AverageImage   = 1
            average        = 2
            averageimage   = 3
	PPCODE:
	{
	    SV *rref;	/* rref is the SV* of ref=SvIV(rref) */
	    Image *image;
	    jmp_buf error_jmp;
	    char *p;
	    struct info *info;
	    SV *sv, *rv;
	    AV *av;
	    HV *hv;
	    volatile int retval = 0;

	    im_er_mes = newSVpv("", 0);

	    if (!sv_isobject(ST(0)))
	    {
		warning(OptionWarning, complain, IM_packname);
		goto badreturn;
	    }
	    rref = SvRV(ST(0));
	    hv = SvSTASH(rref);

	    im_er_jmp = &error_jmp;
	    if (retval = setjmp(error_jmp))
		goto badreturn;

	    if (!(image = setup_list(rref, &info, NULV)))
	    {
		warning(OptionWarning, "No images to Average", NULV);
		goto badreturn;
	    }

	    image = AverageImages(image);
	    if (!image)
		goto badreturn;

	    /* create blessed Perl array for the returned image */
	    av = newAV();
	    ST(0) = sv_2mortal(sv_bless(newRV((SV *)av), hv));
	    SvREFCNT_dec(av);

	    sv = newSViv((IV)image);
	    rv = newRV(sv);
	    av_push(av, sv_bless(rv, hv));
	    SvREFCNT_dec(sv);
	    /*SvREFCNT_dec(rv);*/

	    info = getinfo(av, info);
	    sprintf(info->info.filename, "average-%.*s", MaxTextExtent - 9,
		((p = strrchr(image->filename, '/')) ? p+1 : image->filename));
	    strcpy(image->filename, info->info.filename);
	    SetImageInfo(&info->info, False);

	    SvREFCNT_dec(im_er_mes);
	    im_er_jmp = NULL;
	    XSRETURN(1);

	badreturn:
	    sv_setiv(im_er_mes, (IV)(retval ? retval : SvCUR(im_er_mes) != 0));
	    SvPOK_on(im_er_mes);	/* return messages in string context */
	    ST(0) = sv_2mortal(im_er_mes);
	    im_er_mes = NULL, im_er_jmp = NULL;
	    XSRETURN(1);
	}

void
Copy(ref)
	Image::Magick	ref = NO_INIT
	ALIAS:
            CopyImage   = 1
            copy        = 2
            copyimage   = 3
            CloneImage  = 4
            clone       = 5
            Cloneimage  = 6
	PPCODE:
	{
	    SV *rref;	/* rref is the SV* of ref=SvIV(rref) */
	    Image *im, *image;
	    jmp_buf error_jmp;
	    char *p;
	    struct info *info;
	    SV *sv, *rv;
	    AV *av;
	    HV *hv;
	    volatile int retval = 0;

	    im_er_mes = newSVpv("", 0);

	    if (!sv_isobject(ST(0)))
	    {
		warning(OptionWarning, complain, IM_packname);
		goto badreturn;
	    }
	    rref = SvRV(ST(0));
	    hv = SvSTASH(rref);

	    im_er_jmp = &error_jmp;
	    if (retval = setjmp(error_jmp))
	        goto badreturn;

	    if (!(image = setup_list(rref, &info, NULV)))
	    {
		warning(OptionWarning, "No images to Copy", NULV);
		goto badreturn;
	    }

	    /* create blessed Perl array for the returned image */
	    av = newAV();
	    ST(0) = sv_2mortal(sv_bless(newRV((SV *)av), hv));
	    SvREFCNT_dec(av);

	    for (im = image ; im; im = im->next)
	    {
		image = CloneImage(im, im->columns, im->rows, True);
		if (!image)
		    break;
		sv = newSViv((IV)image);
		rv = newRV(sv);
		av_push(av, sv_bless(rv, hv));
		SvREFCNT_dec(sv);
	    }

	    info = getinfo(av, info);
	    SvREFCNT_dec(im_er_mes);
	    im_er_jmp = NULL;
	    XSRETURN(1);

	badreturn:
	    sv_setiv(im_er_mes, (IV)(retval ? retval : SvCUR(im_er_mes) != 0));
	    SvPOK_on(im_er_mes);	/* return messages in string context */
	    ST(0) = sv_2mortal(im_er_mes);
	    im_er_mes = NULL, im_er_jmp = NULL;
	    XSRETURN(1);
	}

void
Display(ref, ...)
	Image::Magick	ref = NO_INIT
	ALIAS:
	    DisplayImage	= 1
	    display		= 2
	    displayimage	= 3
	PPCODE:
	{
	    SV *rref;	/* rref is the SV* of ref=SvIV(rref) */
	    Image *image, *im;
	    struct info *info;
	    volatile struct info *temp = NULL;
	    XResourceInfo resource;
	    XrmDatabase resource_database;
	    unsigned long state;
	    Display *display;
	    char *resource_value;
	    int n;
	    jmp_buf error_jmp;
	    volatile int retval = 0;

	    im_er_mes = newSVpv("", 0);
	    if (!sv_isobject(ST(0)))
	    {
		warning(OptionWarning, complain, IM_packname);
		goto badreturn;
	    }
	    rref = SvRV(ST(0));

	    im_er_jmp = &error_jmp;
	    if ((retval = setjmp(error_jmp)))
		goto badreturn;

	    if (!(image = setup_list(rref, &info, NULV)))
	    {
		warning(OptionWarning, "No images to Display", NULV);
		goto badreturn;
	    }

	    temp = copy_info(info);
	    *temp->info.filename = '\0';

	    if (items == 2)
		SetAttribute(temp, NULL, "server", ST(1));
	    else if (items > 2)
		for (n = 2; n < items; n += 2)
		    SetAttribute(temp, NULL, SvPV(ST(n-1), na), ST(n));

	    display = XOpenDisplay(info->info.server_name);
	    if (display)
	    {
		XSetErrorHandler(XError);
		resource_database = XGetResourceDatabase(display, client_name);
		XGetResourceInfo(resource_database, client_name, &resource);
		resource.immutable = True;

	        for (im = image ; im; im = im->next)
	        {
		    state=DefaultState;
		    (void) XDisplayImage(display, &resource, (char **) NULL, 0,
			&im, &state);
	        }

		XCloseDisplay(display);
	    }

	badreturn:
	    if (temp)
		destroy_info(temp);
	    sv_setiv(im_er_mes, (IV)retval);
	    SvPOK_on(im_er_mes);
	    ST(0) = sv_2mortal(im_er_mes);
	    im_er_mes = NULL, im_er_jmp = NULL;
	    XSRETURN(1);
	}

void
Montage(ref, ...)
	Image::Magick	ref = NO_INIT
	ALIAS:
	    MontageImage	= 1
	    montage		= 2
	    montageimage	= 3
	PPCODE:
	{
	    SV *rref;	/* rref is the SV* of ref=SvIV(rref) */
	    XResourceInfo resource;
	    XrmDatabase resource_database;
	    XMontageInfo montage;
	    Display *display;
	    int n, concatenate;
	    char *transparent_color, *resource_value, *p, *arg = NULL;
	    jmp_buf error_jmp;
	    Image *im, *image;
	    struct info *info;
	    volatile int retval = 0;
	    SV **svarr = NULL;
	    AV *av = NULL;
	    HV *hv;
	    SV *sv, *rv, *avref;

	    im_er_mes = newSVpv("", 0);

	    if (!sv_isobject(ST(0)))
	    {
		warning(OptionWarning, complain, IM_packname);
		goto badreturn;
	    }
	    rref = SvRV(ST(0));
	    hv = SvSTASH(rref);

	    av = newAV();
	    avref = sv_2mortal(sv_bless(newRV((SV *)av), hv));
	    SvREFCNT_dec(av);

	    transparent_color = montage.tile = montage.texture = NULL;

	    im_er_jmp = &error_jmp;
	    if ((retval = setjmp(error_jmp)))
		goto badreturn;

	    if (!(image = setup_list(rref, &info, &svarr)))
	    {
		warning(OptionWarning, "No images to Montage", NULV);
		goto badreturn;
	    }
	    info = getinfo(av, info);

	    /*
	      Get user defaults from X resource database.
	    */
	    XGetMontageInfo(&montage);
	    sprintf(montage.filename, "montage-%.*s", MaxTextExtent - 9,
		((p = strrchr(image->filename, '/')) ? p+1 : image->filename));

	    display = XOpenDisplay(info->info.server_name);
	    if (display)
		XSetErrorHandler(XError);
	    resource_database = XGetResourceDatabase(display, client_name);
	    XGetResourceInfo(resource_database, client_name, &resource);
	    resource.background_color = XGetResourceInstance(resource_database,
	      client_name, "background", DefaultTileBackground);
	    resource.foreground_color = XGetResourceInstance(resource_database,
	      client_name, "foreground", DefaultTileForeground);
	    resource.image_geometry = XGetResourceInstance(resource_database,
	      client_name, "imageGeometry", DefaultTileGeometry);
	    resource.matte_color = XGetResourceInstance(resource_database,
	      client_name, "mattecolor", DefaultTileMatte);
	    resource_value = XGetResourceClass(resource_database, client_name,
	      "pointsize", DefaultPointSize);
	    montage.pointsize = atoi(resource_value);
	    resource_value = XGetResourceClass(resource_database, client_name,
		"shadow", "False");
	    montage.shadow = IsTrue(resource_value);
	    montage.tile = XGetResourceClass(resource_database, client_name,
		"tile", montage.tile);
	    if (display)
		XCloseDisplay(display);

	    concatenate = 0;
	    for (n = 2; n < items; n += 2)
	    {
		arg = (char *)SvPV(ST(n-1), na);

		/* switch on first letter of attribute.  'break' will go */
		/* to "unknown" error; use 'continue' for known options */
		switch (*arg)
		{
		case 'B': case 'b':
		    if (strEQcase(arg, "background"))
		    {
			resource.background_color = SvPV(ST(n), na);
			continue;
		    }
		    if (strEQcase(arg, "bordercolor"))
		    {
			resource.border_color = SvPV(ST(n), na);
			continue;
		    }
		    if (strEQcase(arg, "borderwidth"))
		    {
			resource.border_width = SvIV(ST(n));
			continue;
		    }
		case 'C': case 'c':
                    if (strEQcase(arg, "compos"))
                    {
                        int sp = !SvPOK(ST(n)) ? SvIV(ST(n)) :
                                 LookupStr(p_composites, SvPV(ST(n), na));
                        if (sp < 0)
                        {
			    warning(OptionWarning, "Unknown composite type",
						    SvPV(ST(n), na));
                            continue;
                        }
                        montage.compose = sp;
                        continue;
                    }
		    break;
		case 'F': case 'f':
		    if (strEQcase(arg, "frame"))
		    {
			char *p = SvPV(ST(n), na);
			if (!IsGeometry(p))
			{
			    warning(OptionWarning, "bad geometry on frame", p);
			    continue;
			}
			montage.frame = p;
			if (*p == '\0')
			  montage.frame = (char *) NULL;
			continue;
		    }
		    if (strEQcase(arg, "file"))
		    {
			strncpy(montage.filename, SvPV(ST(n), na),
						  sizeof montage.filename);
			continue;
		    }
                    if (strEQcase(arg, "filter"))
                    {
                        int sp = !SvPOK(ST(n)) ? SvIV(ST(n)) :
                                 LookupStr(p_filters, SvPV(ST(n), na));
                        if (sp < 0)
                        {
			    warning(OptionWarning, "Unknown filter type",
						    SvPV(ST(n), na));
                            continue;
                        }
                        montage.filter = sp;
                        continue;
                    }
		    if (strEQcase(arg, "font"))
		    {
			resource.font = SvPV(ST(n), na);
			continue;
		    }
		    if (strEQcase(arg, "foreground"))
		    {
			resource.foreground_color = SvPV(ST(n), na);
			continue;
		    }
		    break;
		case 'G': case 'g':
		    if (strEQcase(arg, "geometry"))
		    {
			char *p = SvPV(ST(n), na);
			if (!IsGeometry(p))
			{
			    warning(OptionWarning, "bad geometry on geometry", p);
			    continue;
			}
			resource.image_geometry = p;
			if (*p == '\0')
			  resource.image_geometry = (char *) NULL;
			continue;
		    }
		    if (strEQcase(arg, "gravity"))
		    {
			int in = !SvPOK(ST(n)) ? SvIV(ST(n)) :
				  LookupStr(p_gravities, SvPV(ST(n), na));
		    	if (in < 0)
			{
			    warning(OptionWarning, "Unknown gravity type",
						    SvPV(ST(n), na));
			    return;
			}
			resource.gravity = in;
			continue;
		    }
		    break;
		case 'L': case 'l':
		    if (strEQcase(arg, "label"))
		    {
	      		for (im = image ; im; im = im->next)
	        	  LabelImage(im, SvPV(ST(n), na));
			continue;
		    }
		    break;
		case 'M': case 'm':
		    if (strEQcase(arg, "mattec"))
		    {
			resource.matte_color = SvPV(ST(n), na);
			continue;
		    }
		    if (strEQcase(arg, "mode"))
		    {
			int in = !SvPOK(ST(n)) ? SvIV(ST(n)) :
				  LookupStr(p_modes, SvPV(ST(n), na));
			switch (in)
			{
			default:
			    warning(OptionWarning, "Unknown mode value",
						    SvPV(ST(n), na));
			    break;
			case FrameMode:
			    montage.frame = DefaultTileFrame;
			    montage.shadow = True;
			    break;
			case UnframeMode:
			    montage.frame = (char *) NULL;
			    montage.shadow = False;
			    resource.border_width = 0;
			    break;
			case ConcatenateMode:
			    montage.frame = (char *) NULL;
			    montage.shadow = False;
			    resource.image_geometry = "+0+0";
			    resource.border_width = 0;
	    		    concatenate = 1;
			}
			continue;
		    }
		    break;
		case 'S': case 's':
		    if (strEQcase(arg, "shadow"))
		    {
                        int sp = !SvPOK(ST(n)) ? SvIV(ST(n)) :
                                 LookupStr(p_boolean, SvPV(ST(n), na));
                        if (sp < 0)
                        {
			    warning(OptionWarning, "Unknown shadow type",
						    SvPV(ST(n), na));
                            continue;
                        }
                        montage.shadow = sp;
		        continue;
		    }
		    break;
		case 'T': case 't':
		    if (strEQcase(arg, "texture"))
		    {
			montage.texture = SvPV(ST(n), na);
			continue;
		    }
		    if (strEQcase(arg, "tile"))
		    {
			char *p = SvPV(ST(n), na);
			if (!IsGeometry(p))
			{
			    warning(OptionWarning, "bad geometry on tile", p);
			    continue;
			}
			montage.tile = p;
			if (*p == '\0')
			  montage.tile = (char *) NULL;
			continue;
		    }
		    if (strEQcase(arg, "trans"))
		    {
			transparent_color = SvPV(ST(n), na);
			continue;
		    }
		    break;
		}
		/* fall through to here for unknown attributes */
		warning(OptionWarning, "Unknown attribute", arg);
	    }

	    image = XMontageImages(&resource, &montage, image);
	    if (!image)
		goto badreturn;

	    if (transparent_color)
		for (im = image; im; im = im->next)
		    TransparentImage(im, transparent_color);

	    strcpy(info->info.filename, montage.filename);
	    SetImageInfo(&info->info, False);

	    sv = newSViv((IV)image);
	    rv = newRV(sv);
	    av_push(av, sv_bless(rv, hv));
	    SvREFCNT_dec(sv);
	    /*SvREFCNT_dec(rv);*/

	    ST(0) = avref;
	    im_er_jmp = NULL;
	    SvREFCNT_dec(im_er_mes);	/* can't return warning messages */
	    im_er_mes = NULL;
	    XSRETURN(1);

	badreturn:
	    im_er_jmp = NULL;
	    sv_setiv(im_er_mes, (IV)(retval ? retval : SvCUR(im_er_mes) != 0));
	    SvPOK_on(im_er_mes);
	    ST(0) = sv_2mortal(im_er_mes);
	    im_er_mes = NULL, im_er_jmp = NULL;
	    XSRETURN(1);
	}

void
Read(ref, ...)
	Image::Magick	ref = NO_INIT
	ALIAS:
	    ReadImage	= 1
	    read	= 2
	    readimage	= 3
	PPCODE:
	{
	    SV *rref;	/* rref is the SV* of ref=SvIV(rref) */
	    jmp_buf error_jmp;
	    int n, ac;
	    volatile int nimg = 0;
	    char **list, **keep, **kp;
	    struct info *info;
	    Image *image;
	    AV *av;
	    HV *hv;

	    im_er_mes = newSVpv("", 0);

	    ac = (items < 2) ? 1 : items - 1;
	    list = (char **) safemalloc((ac + 1) * sizeof *list);

	    if (!sv_isobject(ST(0)))
	    {
		warning(OptionWarning, complain, IM_packname);
		goto return_it;
	    }
	    rref = SvRV(ST(0));
	    hv = SvSTASH(rref);

	    if (SvTYPE(rref) != SVt_PVAV)	/* array of images */
	    {
		warning(OptionWarning, "Can't (yet) read into a single image", NULV);
		goto return_it;
	    }

	    av = (AV *)rref;
	    info = getinfo(av, NULV);

	    if (items <= 1)
		*list = *info->info.filename ? info->info.filename : "XC:black";
	    else
		for (n = 0; n < ac; n++)
		    list[n] = (char *)SvPV(ST(n+1), na);

	    list[ac] = NULL;
	    keep = list;

	    im_er_jmp = &error_jmp;
	    if (setjmp(error_jmp))
		goto return_it;

	    ExpandFilenames(&ac, &list);

	    for (n = nimg = 0; n < ac; n++)
	    {
		strncpy(info->info.filename, list[n], MaxTextExtent - 1);

		for (image = ReadImage(&info->info); image; image = image->next)
		{
		    SV *sv = newSViv((IV)image);
		    SV *rv = newRV(sv);
		    av_push(av, sv_bless(rv, hv));
		    SvREFCNT_dec(sv);
		    /*SvREFCNT_dec(rv);*/
		    ++nimg;
		}
	    }

	    for (n = 0; n < ac; n++)	/* free memory from ExpandFilenames */
		if (list[n])
		    for (kp = keep; list[n] != *kp++; )
			if (*kp == NULL)
			{
			    free(list[n]);
			    break;
			}
	return_it:
	    safefree((char *) list);
	    sv_setiv(im_er_mes, (IV)nimg);
	    SvPOK_on(im_er_mes);	/* return messages in string context */
	    ST(0) = sv_2mortal(im_er_mes);
	    im_er_mes = NULL, im_er_jmp = NULL;
	    XSRETURN(1);
	}

void
Write(ref, ...)
	Image::Magick	ref = NO_INIT
	ALIAS:
	    WriteImage		= 1
	    write		= 2
	    writeimage		= 3
	PPCODE:
	{
	    SV *rref;	/* rref is the SV* of ref=SvIV(rref) */
	    Image *image, *im;
	    struct info *info;
	    volatile struct info *temp = NULL;
	    int n, display = ix >= 4;
	    jmp_buf error_jmp;
	    volatile int nimg = 0;
	    char fn[MaxTextExtent], magick[MaxTextExtent];
	    char format[MaxTextExtent];

	    im_er_mes = newSVpv("", 0);
	    if (!sv_isobject(ST(0)))
	    {
		warning(OptionWarning, complain, IM_packname);
		goto badreturn;
	    }
	    rref = SvRV(ST(0));

	    im_er_jmp = &error_jmp;
	    if (setjmp(error_jmp))
		goto badreturn;

	    if (!(image = setup_list(rref, &info, NULV)))
	    {
		warning(OptionWarning, "No images to Write", NULV);
		goto badreturn;
	    }

	    temp = copy_info(info);
	    *temp->info.filename = '\0';

	    if (items == 2)
		SetAttribute(temp, NULL, (display? "server" : "file"), ST(1));
	    else if (items > 2)
		for (n = 2; n < items; n += 2)
		    SetAttribute(temp, NULL, SvPV(ST(n-1), na), ST(n));

	    sprintf(format, "%s%s", display? "X:" : "",
			    *temp->info.filename ? temp->info.filename : "%s");
	    sprintf(temp->info.filename, format, image->filename);
	    SetImageInfo((void *)&temp->info, True);	/* sets adjoin */

	    for (n = 0, im = image; im; im = im->next, n++)
		im->scene = n;

	    for (im = image; im; im = im->next)
	    {
		strcpy(magick, im->magick);
		strcpy(fn, im->filename);
		sprintf(im->filename, format, fn);

		if (WriteImage((ImageInfo *) &temp->info, im))
		    ++nimg;

		strcpy(im->magick, magick);
		strcpy(im->filename, fn);

		if (temp->info.adjoin)
		    break;
	    }

	badreturn:
	    if (temp)
		destroy_info(temp);
	    sv_setiv(im_er_mes, (IV)nimg);
	    SvPOK_on(im_er_mes);
	    ST(0) = sv_2mortal(im_er_mes);
	    im_er_mes = NULL, im_er_jmp = NULL;
	    XSRETURN(1);
	}

 #
 # Mogrify: operate on an image
 #
void
Mogrify(ref, ...)
	Image::Magick	ref = NO_INIT
	ALIAS:
		Comment			=   1
		CommentImage		=   2
		Label			=   3
		LabelImage		=   4
		AddNoise		=   5
		AddNoiseImage		=   6
		Colorize		=   7
		ColorizeImage		=   8
		Border			=   9
		BorderImage		=  10
		Blur			=  11
		BlurImage		=  12
		Chop			=  13
		ChopImage		=  14
		Crop			=  15
		CropImage		=  16
		Despeckle		=  17
		DespeckleImage		=  18
		Edge			=  19
		EdgeImage		=  20
		Emboss			=  21
		EmbossImage		=  22
		Enhance			=  23
		EnhanceImage		=  24
		Flip			=  25
		FlipImage		=  26
		Flop			=  27
		FlopImage		=  28
		Frame			=  29
		FrameImage		=  30
		Implode			=  31
		ImplodeImage		=  32
		Magnify			=  33
		MagnifyImage		=  34
		MedianFilter		=  35
		MedianFilterImage	=  36
		Minify			=  37
		MinifyImage		=  38
		OilPaint		=  39
		OilPaintImage		=  40
		ReduceNoise		=  41
		ReduceNoiseImage	=  42
		Roll			=  43
		RollImage		=  44
		Rotate			=  45
		RotateImage		=  46
		Sample			=  47
		SampleImage		=  48
		Scale			=  49
		ScaleImage		=  50
		Shade			=  51
		ShadeImage		=  52
		Sharpen			=  53
		SharpenImage		=  54
		Shear			=  55
		ShearImage		=  56
		Spread			=  57
		SpreadImage		=  58
		Swirl			=  59
		SwirlImage		=  60
		Zoom			=  61
		ZoomImage		=  62
		IsGray			=  63
		IsGrayImage		=  64
		Annotate		=  65
		AnnotateImage		=  66
		ColorFloodfill		=  67
		ColorFloodfillImage	=  68
		Composite		=  69
		CompositeImage		=  70
		Contrast		=  71
		ContrastImage		=  72
		CycleColormap		=  73
		CycleColormapImage	=  74
		Draw			=  75
		DrawImage		=  76
		Equalize		=  77
		EqualizeImage		=  78
		Gamma			=  79
		GammaImage		=  80
		Map			=  81
		MapImage		=  82
		MatteFloodfill		=  83
		MatteFloodfillImage	=  84
		Modulate		=  85
		ModulateImage		=  86
		Negate			=  87
		NegateImage		=  88
		Normalize		=  89
		NormalizeImage		=  90
		NumberColors		=  91
		NumberColorsImage	=  92
		Opaque			=  93
		OpaqueImage		=  94
		Quantize		=  95
		QuantizeImage		=  96
		Raise			=  97
		RaiseImage		=  98
		Segment			=  99
		SegmentImage		= 100
		Signature		= 101
		SignatureImage		= 102
		Solarize		= 103
		SolarizeImage		= 104
		Sync			= 105
		SyncImage		= 106
		Texture			= 107
		TextureImage		= 108
		Transform		= 109
		TransformImage		= 110
		Transparent		= 111
		TransparentImage	= 112
		Threshold		= 113
		ThresholdImage		= 114
		Charcoal		= 115
		CharcoalImage		= 116
		Trim			= 117
		TrimImage		= 118
		Wave			= 119
		WaveImage		= 120
	PPCODE:
	{
	    SV *rref;	/* rref is the SV* of ref=SvIV(rref) */
	    int n, base = 2;
	    struct routines *rp;
	    union alist alist[ARGMAX];
	    char aflag[ARGMAX];
	    jmp_buf error_jmp;
	    volatile int nimg = 0;
	    int first;
	    RectangleInfo br;
	    AnnotateInfo annotate;
	    FrameInfo fr;
	    XColor xc;
	    char *arg;
	    Image *image, *next;
	    struct info *info, *local_info = NULL;
	    char b[80];
	    SV **svarr = NULL, **pv;
	    char *commands[10];

	    im_er_mes = newSVpv("", 0);
	    if (!sv_isobject(ST(0)))
	    {
		warning(OptionWarning, complain, IM_packname);
		goto return_it;
	    }
	    rref = SvRV(ST(0));

	    if (ix)	/* called as Routinename(...) */
	    {
		ix = (ix+1)/2;
		rp = &routines[ix-1];
		arg = rp->name;
	    }
	    else	/* called as Mogrify("Routinename", ...) */
	    {
		arg = (char *)SvPV(ST(1), na);
		for (rp = routines; ; rp++)
		{
		    if (rp >= ENDOF(routines))
		    {
			warning(OptionWarning, "Unknown Magick routine", arg);
			goto return_it;
		    }
		    if (strEQcase(arg, rp->name))
			break;
		}

		ix = rp - routines + 1;
		base = 3;
	    }

	    if (!(image = setup_list(rref, &info, &svarr)))
	    {
		warning(OptionWarning, "No Images to Mogrify", arg);
		goto return_it;
	    }

	    Zero(&alist, NUMBEROF(alist), union alist);
	    Zero(&aflag, NUMBEROF(aflag), char);

	    /* Look through the argument list Perl passed to us, and
	     * try to match against the routine's parameter names.
	     * The Perl list looks something like:
	     *	  i->routine(comment => "..comments..", x => 100, ...)
	     * (which is the same as:)
	     *    i->routine("comment", "..comments..", "x", 100, ...)
	     * As a special case, if only one argument then it
	     * matches the first parameter:
	     *    i->routine("..comments..")
	     */
	    for (n = base; n < items || n == items && base == items; n += 2)
	    {
		struct args *pp = rp->args;
		union alist *al;
		SV *sv;

		if (n == items)		/* single argument */
		    sv = ST(n-1);
		else
		    for (sv = ST(n), arg = (char *)SvPV(ST(n-1), na); ; pp++)
		    {
			if (pp >= ENDOF(rp->args) || pp->varname == NULL)
			    goto continue_outer_loop;
			if (strEQcase(arg, pp->varname))
			    break;
		    }
		al = &alist[pp - rp->args];

		if (pp->type == P_INT)
		    al->t_int = SvIV(sv);
		else if (pp->type == P_STR)
		    al->t_str = (char *)SvPV(sv, na);
		else if (pp->type == P_DBL)
		    al->t_dbl = SvNV(sv);
		else if (pp->type == P_IMG)
		{
		    if (!sv_isobject(sv) ||
			!(al->t_img = setup_list(SvRV(sv), NULV, NULV)))
		    {
			warning(OptionWarning, complain, IM_packname);
			goto return_it;
		    }
		}
		else if (!SvPOK(sv))   /* not a string; just get number */
		    al->t_int = SvIV(sv);
		else			    /* is a string; look up name */
		{
		    al->t_int = LookupStr(pp->type, SvPV(sv, na));
		    if (al->t_int < 0 && (al->t_int = SvIV(sv)) <= 0)
		    {
			char b[80];
			sprintf(b, "Invalid %.60s value", pp->varname);
			warning(OptionWarning, b, arg);
			goto continue_outer_loop;
		    }
		}
		++aflag[pp - rp->args];	/* indicate that parameter was given */

	continue_outer_loop: ;
	    }

	    im_er_jmp = &error_jmp;
	    if (setjmp(error_jmp))
		goto return_it;

	    first = 1;
	    for (next = image, pv = svarr; next; first = 0, next = next->next)
	    {
		image = next;

		br.width = image->columns;
		br.height = image->rows;
		br.x = br.y = 0;
		switch (ix)
		{
		default:
		    sprintf(b, "%d", (int)ix);
		    warning(OptionWarning, "Routine value out of range", b);
		    goto return_it;
		case  1:	/* Comment */
		    if (!aflag[0])
			alist[0].t_str = NULL;
		    CommentImage(image, alist[0].t_str);
		    break;
		case  2:	/* Label */
		    if (!aflag[0])
			alist[0].t_str = NULL;
		    LabelImage(image, alist[0].t_str);
		    break;
		case  3:	/* AddNoise */
		    if (!aflag[0])
			alist[0].t_int = UniformNoise;
		    image = AddNoiseImage(image, alist[0].t_int);
		    break;
		case  4:	/* Colorize */
		    if (!aflag[0])
			alist[0].t_str = NULL;
		    if (!aflag[1])
			alist[1].t_str = "black";
		    ColorizeImage(image, alist[0].t_str, alist[1].t_str);
		    break;
		case  5:	/* Border */
		    if (first)
		    {
			br.height = br.width = 6;

			if (aflag[0])
			{
			    int f = XParseGeometry(alist[0].t_str, &br.x, &br.y,
							&br.width, &br.height);
			    if (!(f & HeightValue))
				br.height = br.width;
			}

			if (aflag[1])
			    br.height = alist[1].t_int;
			if (aflag[2])
			    br.width = alist[2].t_int;
			if (aflag[3])
			    XQueryColorDatabase(alist[3].t_str, &xc);
		    }

		    if (aflag[3])
		    {
			image->border_color.red = XDownScale(xc.red);
			image->border_color.green = XDownScale(xc.green);
			image->border_color.blue = XDownScale(xc.blue);
		    }
		    image = BorderImage(image, &br);
		    break;
		case  6:	/* Blur */
		    if (!aflag[0])
			alist[0].t_dbl = 0.6;
		    image = BlurImage(image, alist[0].t_dbl);
		    break;
		case  7:	/* Chop */
		    if (aflag[0])
		    {
			int f = XParseGeometry(alist[0].t_str, &br.x, &br.y,
							&br.width, &br.height);
			if (!(f & HeightValue))
			    br.height = br.width;
		    }
		    if (aflag[1])
			br.width = alist[1].t_int;
		    if (aflag[2])
			br.height = alist[2].t_int;
		    if (aflag[3])
			br.x = alist[3].t_int;
		    if (aflag[4])
			br.y = alist[4].t_int;

		    image = ChopImage(image, &br);
		    break;
		case 59:	/* Trim */
		    ++aflag[0];
		    alist[0].t_str = "0x0";
		case  8:	/* Crop */
		    if (aflag[0])
		    {
			int f = XParseGeometry(alist[0].t_str, &br.x, &br.y,
							&br.width, &br.height);
			if (!(f & HeightValue))
			    br.height = br.width;
		    }
		    if (aflag[1])
			br.width = alist[1].t_int;
		    if (aflag[2])
			br.height = alist[2].t_int;
		    if (aflag[3])
			br.x = alist[3].t_int;
		    if (aflag[4])
			br.y = alist[4].t_int;

		    image = CropImage(image, &br);
		    break;
		case  9:	/* Despeckle */
		    image = DespeckleImage(image);
		    break;
		case 10:	/* Edge */
		    if (!aflag[0])
			alist[0].t_dbl = .5;
		    image = EdgeImage(image, alist[0].t_dbl);
		    break;
		case 11:	/* Emboss */
		    image = EmbossImage(image);
		    break;
		case 12:	/* Enhance */
		    image = EnhanceImage(image);
		    break;
		case 13:	/* Flip */
		    image = FlipImage(image);
		    break;
		case 14:	/* Flop */
		    image = FlopImage(image);
		    break;
		case 15:	/* Frame */
		    if (first)
		    {
			fr.height = fr.width = 25;
			fr.x = fr.y = 0;
			fr.inner_bevel = fr.outer_bevel = 6;
			if (aflag[0])
			{
			    int f = XParseGeometry(alist[0].t_str,
					    &fr.outer_bevel, &fr.inner_bevel,
					    &fr.width, &fr.height);
			    if (!(f & HeightValue))
				fr.height = fr.width;
			    if (!(f & XValue))
				fr.outer_bevel = (fr.width >> 2) + 1;
			    if (!(f & YValue))
				fr.inner_bevel = (fr.height >> 2) + 1;
			}
			if (aflag[1])
			    fr.width = alist[1].t_int;
			if (aflag[2])
			    fr.height = alist[2].t_int;
			if (aflag[3])
			    fr.inner_bevel = alist[3].t_int;
			if (aflag[4])
			    fr.outer_bevel = alist[4].t_int;
			fr.x = fr.width;
			fr.y = fr.height;
			if (aflag[5])
			    XQueryColorDatabase(alist[5].t_str, &xc);
		    }
		    fr.width = image->columns + (fr.x << 1);
		    fr.height = image->rows + (fr.y << 1);
		    if (aflag[5])
		    {
			image->matte_color.red = XDownScale(xc.red);
			image->matte_color.green = XDownScale(xc.green);
			image->matte_color.blue = XDownScale(xc.blue);
		    }
		    image = FrameImage(image, &fr);
		    break;
		case 16:	/* Implode */
		    if (!aflag[0])
			alist[0].t_dbl = 30.0;
		    image = ImplodeImage(image, alist[0].t_dbl);
		    break;
		case 17:	/* Magnify */
		    image = MagnifyImage(image);
		    break;
		case 18:	/* MedianFilter */
		    break;
		case 19:	/* Minify */
		    image = MinifyImage(image);
		    break;
		case 20:	/* OilPaint */
		    if (!aflag[0])
			alist[0].t_int = 3;
		    image = OilPaintImage(image, alist[0].t_int);
		    break;
		case 21:	/* ReduceNoise */
		    image = ReduceNoiseImage(image);
		    break;
		case 22:	/* Roll */
		    if (aflag[1])
		        br.x = alist[1].t_int;
		    if (aflag[2])
		        br.y = alist[2].t_int;
		    if (aflag[0])
		      (void) ParseImageGeometry(alist[0].t_str, &br.x, &br.y,
		        &br.width, &br.height);

		    image = RollImage(image, br.x, br.y);
		    break;
		case 23:	/* Rotate */
		    if (!aflag[0])
			alist[0].t_dbl = 90.0;
		    if (!aflag[1])
			alist[1].t_int = 0;
		    if (!aflag[2])
			alist[2].t_int = 1;

		    image = RotateImage(image, alist[0].t_dbl,
					alist[1].t_int, alist[2].t_int);
		    break;
		case 24:	/* Sample */
		    if (aflag[1])
		        br.width = alist[1].t_int;
		    if (aflag[2])
		        br.height = alist[2].t_int;
		    if (aflag[0])
		      (void) ParseImageGeometry(alist[0].t_str, &br.x, &br.y,
		        &br.width, &br.height);
		    image = SampleImage(image, br.width, br.height);
		    break;
		case 25:	/* Scale */
		    if (aflag[1])
		        br.width = alist[1].t_int;
		    if (aflag[2])
		        br.height = alist[2].t_int;
		    if (aflag[0])
		      (void) ParseImageGeometry(alist[0].t_str, &br.x, &br.y,
		        &br.width, &br.height);
		    image = ScaleImage(image, br.width, br.height);
		    break;
		case 26:	/* Shade */
		{
		    float azimuth, elevation;

		    azimuth = 30.0;
		    elevation = 30.0;
		    if (aflag[1])
		        azimuth = alist[1].t_dbl;
		    if (aflag[2])
		        elevation = alist[2].t_dbl;
		    if (aflag[0])
		      (void) sscanf(alist[0].t_str, "%fx%f", &azimuth,
							     &elevation);

		    image = ShadeImage(image, alist[3].t_int, azimuth,
							      elevation);
		    break;
		}
		case 27:	/* Sharpen */
		    if (!aflag[0])
			alist[0].t_dbl = 30.0;
		    image = SharpenImage(image, alist[0].t_dbl);
		    break;
		case 28:	/* Shear */
		{
		    float x_shear, y_shear;

		    x_shear = 45.0;
		    y_shear = 45.0;
		    if (aflag[1])
		        x_shear = alist[1].t_dbl;
		    if (aflag[2])
		        y_shear = alist[2].t_dbl;
		    if (aflag[0])
		      (void) sscanf(alist[0].t_str, "%fx%f", &x_shear,
							     &y_shear);

		    image = ShearImage(image, x_shear, y_shear,
						       alist[3].t_int);
		    break;
		}
		case 29:	/* Spread */
		    if (!aflag[0])
			alist[0].t_int = 3;
		    image = SpreadImage(image, alist[0].t_int);
		    break;
		case 30:	/* Swirl */
		    if (!aflag[0])
			alist[0].t_dbl = .5;
		    image = SwirlImage(image, alist[0].t_dbl);
		    break;
		case 31:	/* Zoom */
		    if (aflag[1])
		        br.width = alist[1].t_int;
		    if (aflag[2])
		        br.height = alist[2].t_int;
		    if (aflag[0])
		      (void) ParseImageGeometry(alist[0].t_str, &br.x, &br.y,
		        &br.width, &br.height);
		    if (!aflag[3])
			alist[3].t_int = 1;
		    image = ZoomImage(image, br.width, br.height,
							     alist[3].t_int);
		    break;
		case 32:	/* IsGrayImage */
		    break;
		case 33:	/* Annotate */
		    if (first)
		    {
			GetAnnotateInfo(&annotate);
			if (aflag[0])
			    annotate.server_name = alist[0].t_str;
			if (aflag[1])
			    annotate.font = alist[1].t_str;
			if (aflag[2])
			    annotate.pointsize = alist[2].t_int;
			if (aflag[3])
			    annotate.box = alist[3].t_str;
			if (aflag[4])
			    annotate.pen = alist[4].t_str;
			if (aflag[5])
			    annotate.geometry = alist[5].t_str;
			if (aflag[6])
			    annotate.text = alist[6].t_str;
			if (aflag[7] || aflag[8])
			{
			    if (!aflag[7])
			        alist[7].t_int = 0;
			    if (!aflag[8])
				alist[8].t_int = 0;
			    sprintf(b, "%+d%+d",
					alist[7].t_int, alist[8].t_int);
			    annotate.geometry = b;
			}
			if (aflag[9])
			    annotate.alignment = alist[9].t_int;
		    }
		    AnnotateImage(image, &annotate);
		    break;
		case 34:	/* ColorFloodfill */
		    break;
		case 35:	/* Composite */
		    if (!aflag[0])
			alist[0].t_int = 2;
		    if (!aflag[2])
			alist[2].t_int = 1;
		    if (!aflag[3])
			alist[3].t_int = 1;

		    if (!aflag[1])
		    {
			warning(OptionWarning, "Missing image in Composite", NULV);
			goto return_it;
		    }
		    CompositeImage(image, alist[0].t_int, alist[1].t_img,
					  alist[2].t_int, alist[3].t_int);
		    break;
		case 36:	/* Contrast */
		    if (aflag[0])
			alist[0].t_int = 1;
		    ContrastImage(image, alist[0].t_int);
		    break;
		case 37:	/* CycleColormap */
		    if (aflag[0])
			alist[0].t_int = 6;
		    CycleColormapImage(image, alist[0].t_int);
		    break;
		case 38:	/* Draw */
		    if (first)
		    {
			GetAnnotateInfo(&annotate);
			if (aflag[3])
			    annotate.pen = alist[3].t_str;
			if (aflag[4])
			    annotate.linewidth = alist[4].t_int;
			if (aflag[5])
			    annotate.server_name = alist[5].t_str;
		    }
		    n = MaxTextExtent;
		    if (aflag[1])
		        n += strlen(alist[1].t_str);
    		    if (alist[0].t_int > 0)
    		        annotate.primitive =
		          strcpy(safemalloc(n), p_primitives[alist[0].t_int]);
		    else
    		        annotate.primitive =
		          strcpy(safemalloc(n), alist[0].t_str);
		    if (aflag[1])
		    {
		        strcat(annotate.primitive, " ");
		        strcat(annotate.primitive, alist[1].t_str);
		    }
		    if (aflag[2])
		    {
		        strcat(annotate.primitive, " ");
		        strcat(annotate.primitive, p_methods[alist[2].t_int]);
		    }
		    DrawImage(image, &annotate);
		    safefree(annotate.primitive);
		    annotate.primitive = NULL;
		    break;
		case 39:	/* Equalize */
		    EqualizeImage(image);
		    break;
		case 40:	/* Gamma */
		    if (first)
		    {
			if (!aflag[1])
			    alist[1].t_dbl = 1.0;
			if (!aflag[2])
			    alist[2].t_dbl = 1.0;
			if (!aflag[3])
			    alist[3].t_dbl = 1.0;
			if (!aflag[0])
			{
			    sprintf(b, "%f/%f/%f", alist[1].t_dbl,
					alist[2].t_dbl, alist[3].t_dbl);
			    alist[0].t_str = b;
			}
		    }
		    GammaImage(image, alist[0].t_str);
		    break;
		case 41:	/* Map */
		    if (!aflag[1])
			alist[1].t_int = 1;
		    if (!aflag[0])
		    {
			warning(OptionWarning, "Missing image in Map", NULV);
			goto return_it;
		    }
		    MapImage(image, alist[0].t_img, alist[1].t_int);
		    break;
		case 42:	/* MatteFloodfill */
		    break;
		case 43:	/* Modulate */
		    if (first)
		    {
			if (!aflag[1])
			    alist[1].t_dbl = 1.0;
			if (!aflag[2])
			    alist[2].t_dbl = 1.0;
			if (!aflag[3])
			    alist[3].t_dbl = 1.0;
			sprintf(b, "%f/%f/%f", alist[1].t_dbl,
			    alist[2].t_dbl, alist[3].t_dbl);
			if (!aflag[0])
			    alist[0].t_str = b;
		    }
		    ModulateImage(image, alist[0].t_str);
		    break;
		case 44:	/* Negate */
		    if (!aflag[0])
			alist[0].t_int = 0;
		    NegateImage(image, alist[0].t_int);
		    break;
		case 45:	/* Normalize */
		    NormalizeImage(image);
		    break;
		case 46:	/* NumberColors */
		    break;
		case 47:	/* Opaque */
		    if (!aflag[0])
			alist[0].t_str = "black";
		    if (!aflag[1])
			alist[1].t_str = "black";

		    OpaqueImage(image, alist[0].t_str, alist[1].t_str);
		    break;
		case 48:	/* Quantize */
		    {
			QuantizeInfo quan;
			quan.number_colors = aflag[0] ? alist[0].t_int :
				(info? info->quant.number_colors : MaxRGB + 1);
			quan.tree_depth = aflag[1] ? alist[1].t_int :
				(info? info->quant.tree_depth : 8);
			quan.dither = aflag[2] ? alist[2].t_int :
				(info? info->quant.dither : False);
			quan.colorspace = aflag[3] ? alist[3].t_int :
				(info? info->quant.colorspace : RGBColorspace);
			QuantizeImages(&quan, image);
			goto return_it;
		    }
		case 49:	/* Raise */
		    if (first)
		    {
			br.height = br.width = 6;

			if (aflag[0])
			{
			    int f = XParseGeometry(alist[0].t_str, &br.x, &br.y,
							&br.width, &br.height);
			    if (!(f & HeightValue))
				br.height = br.width;
			}

			if (aflag[1])
			    br.width = alist[1].t_int;
			if (aflag[2])
			    br.height = alist[2].t_int;
			if (aflag[3])
			    br.x = alist[3].t_int;
			if (aflag[4])
			    br.y = alist[4].t_int;
			if (aflag[5])
			    alist[5].t_int = 1;
		    }

		    RaiseImage(image, &br, alist[5].t_int);
		    break;
		case 50:	/* Segment */
		    if (first)
		    {
			if (!aflag[0])
			    alist[0].t_int = info ? info->quant.colorspace
						  : RGBColorspace;
			if (!aflag[1])
			    alist[1].t_int = 0;
			if (!aflag[2])
			    alist[2].t_dbl = 1.0;
			if (!aflag[3])
			    alist[3].t_dbl = .5;
		    }
		    SegmentImage(image, alist[0].t_int, alist[1].t_int,
					alist[2].t_dbl, alist[3].t_dbl);
		    break;
		case 51:	/* Signature */
		    SignatureImage(image);
		    break;
		case 52:	/* Solarize */
		    if (!aflag[0])
			alist[0].t_dbl = 50.0;
		    SolarizeImage(image, alist[0].t_dbl);
		    break;
		case 53:	/* Sync */
		    break;
		case 54:	/* Texture */
		    if (!aflag[0])
			alist[0].t_str = NULL;
		    TextureImage(image, alist[0].t_str);
		    break;
		case 55:	/* Transform */
		    break;
		case 56:	/* Transparent */
		    if (!aflag[0])
			alist[0].t_str = NULL;
		    TransparentImage(image, alist[0].t_str);
		    break;
		case 57:	/* Threshold */
		    if (!aflag[0])
			alist[0].t_dbl = (MaxRGB+1)/2.0;
		    ThresholdImage(image, alist[0].t_dbl);
		    break;
		case 58:	/* Charcoal */
		    if (first)
		    {
			local_info = copy_info(info);
			if (!aflag[0])
			    alist[0].t_str = "50";
			GetQuantizeInfo(&local_info->quant);
			if (info)
			    local_info->quant.dither = info->quant.dither;
			local_info->quant.colorspace = GRAYColorspace;
			commands[0] = client_name;
			commands[1] = "-edge";
			commands[2] = alist[0].t_str;
			commands[3] = "-blur";
			commands[4] = alist[0].t_str;
			commands[5] = "-normalize";
			commands[6] = "-negate";
			commands[7] = "-grayscale";
		    }
		    QuantizeImage(&local_info->quant, image);
		    SyncImage(image);
		    MogrifyImage(&info->info, 8, commands, &image);
		    if (next != image)
			next = NULL;  /* 'cause it's been blown away */
		    break;
		case 60:	/* Wave */
		    {
			float amplitude, wavelength;

			amplitude = 10.0;
			wavelength = 10.0;
			if (aflag[1])
			    amplitude = alist[1].t_dbl;
			if (aflag[2])
			    wavelength = alist[2].t_dbl;
			if (aflag[0])
			    (void) sscanf(alist[0].t_str, "%fx%f",
						    &amplitude, &wavelength);

			image = WaveImage(image, amplitude, wavelength);
			break;
		    }
		}

		if (image)
		{
		    ++nimg;
		    if (next && next != image)
		    {
			image->next = next->next;
			next->orphan = 1;
			DestroyImage(next);
		    }
		    sv_setiv(*pv, (IV)image);
		    next = image;
		}
		if (*pv)
		    ++pv;
	    }

	    if (local_info)
		destroy_info(local_info);

	return_it:
	    if (svarr)
		safefree((char *) svarr);
	    sv_setiv(im_er_mes, (IV)nimg);
	    SvPOK_on(im_er_mes); /* return messages in string context */
	    ST(0) = sv_2mortal(im_er_mes);
	    im_er_mes = NULL, im_er_jmp = NULL;
	    XSRETURN(1);
	}

void
Set(ref, ...)
	Image::Magick	ref = NO_INIT
	ALIAS:
		SetAttributes	= 1
		SetAttribute	= 2
		set		= 3
		setattributes	= 4
		setattribute	= 5
	PPCODE:
	{
	    SV *rref;	/* rref is the SV* of ref=SvIV(rref) */
	    int n;
	    Image *image;
	    struct info *info;

	    im_er_mes = newSVpv("", 0);
	    if (!sv_isobject(ST(0)))
	    {
		warning(OptionWarning, complain, IM_packname);
		goto badreturn;
	    }
	    rref = SvRV(ST(0));

	    image = setup_list(rref, &info, NULV);

	    for (n = 2; n < items; n += 2)
		SetAttribute(info, image, SvPV(ST(n-1), na), ST(n));

	badreturn:
	    sv_setiv(im_er_mes, (IV)(SvCUR(im_er_mes) != 0));
	    SvPOK_on(im_er_mes); /* return messages in string context */

	    ST(0) = sv_2mortal(im_er_mes);
	    im_er_mes = NULL;
	    XSRETURN(1);
	}

 #  Get returns the values of the given attributes.  It takes a list of
 #  atrribute names and returns an equal length list of their corresponding
 #  values.  Unknown attributes return as undef.

void
Get(ref, ...)
	Image::Magick	ref = NO_INIT
	ALIAS:
		GetAttributes = 1
		GetAttribute  = 2
		get	      = 3
		getattributes = 4
		getattribute  = 5
	PPCODE:
	{
	    SV *rref;	/* rref is the SV* of ref=SvIV(rref) */
	    int n;
	    char *arg;	/* the attribute name */
	    IV i;
	    SV *s;
	    char b[80];
	    Image *image;
	    struct info *info;

	    if (!sv_isobject(ST(0)))
	    {
		warning(OptionWarning, complain, IM_packname);
		XSRETURN_EMPTY;
	    }
	    rref = SvRV(ST(0));

	    image = setup_list(rref, &info, NULV);
	    if (!image && !info)
	    {
		warning(OptionWarning, "Nothing to GetAttributes from", NULV);
		XSRETURN_EMPTY;
	    }
	    EXTEND(sp, items - 1);

	    for (n = 1; n < items; n++)
	    {
		arg = (char *)SvPV(ST(n), na);
		s = NULL;		/* unknown attributes return this */

		switch (*arg)
		{
		case 'A': case 'a':
		    if (strEQcase(arg, "affirm"))
		    {
			if (info)
			    s = newSViv(info->info.affirm);
		    }
		    else if (strEQcase(arg, "adjoin"))
		    {
			if (info)
			    s = newSViv(info->info.adjoin);
		    }
		    break;
		case 'B': case 'b':
		    if (strEQcase(arg, "base_column"))
		    {
			if (image)
			    s = newSViv(image->magick_columns);
		    }
		    if (strEQcase(arg, "base_filename"))
		    {
			if (image)
			    s = newSVpv(image->magick_filename, 0);
		    }
		    if (strEQcase(arg, "base_height"))
		    {
			if (image)
			    s = newSViv(image->magick_rows);
		    }
		    if (strEQcase(arg, "base_row"))
		    {
			if (image)
			    s = newSViv(image->magick_rows);
		    }
		    if (strEQcase(arg, "base_width"))
		    {
			if (image)
			    s = newSViv(image->magick_columns);
		    }
		    else if (strEQcase(arg, "border"))
		    {
			if (!image)
			    break;
			sprintf(b, "%u,%u,%u,%u",
				    image->border_color.red,
				    image->border_color.green,
				    image->border_color.blue,
				    image->border_color.index);
			s = newSVpv(b, 0);
		    }
		    else if (strEQcase(arg, "background"))
		    {
			if (!image)
			    break;
			sprintf(b, "%u,%u,%u,%u",
				    image->background_color.red,
				    image->background_color.green,
				    image->background_color.blue,
				    image->background_color.index);
			s = newSVpv(b, 0);
		    }
		    break;
		case 'C': case 'c':
		    if (strEQcase(arg, "comment"))
		    {
			if (image && image->comments)
			    s = newSVpv(image->comments, 0);
		    }
		    else if (strEQcase(arg, "class"))
		    {
			if (!image)
			    break;
#if defined(__cplusplus) || defined(c_plusplus)
			i = image->c_class;
#else
			i = image->class;
#endif
			s = newSViv(i);
			if (i >= 0 && i < NUMBEROF(p_classes) - 1)
			{
			    sv_setpv(s, p_classes[i]);
			    SvIOK_on(s);
			}
		    }
		    else if (strEQcase(arg, "compress"))
		    {
			i = info ? info->info.compression : image->compression;
			s = newSViv(i);
			if (i >= 0 && i < NUMBEROF(p_compressions) - 1)
			{
			    sv_setpv(s, p_compressions[i]);
			    SvIOK_on(s);
			}
		    }
		    else if (strEQcase(arg, "colorspace"))
		    {
			i = info ? info->quant.colorspace : RGBColorspace;
			s = newSViv(i);
			if (i >= 0 && i < NUMBEROF(p_colorspaces) - 1)
			{
			    sv_setpv(s, p_colorspaces[i]);
			    SvIOK_on(s);
			}
		    }
		    else if (strEQcase(arg, "colormap"))
		    {
			ColorPacket *cp;

			if (!image || !image->colormap)
			    break;
		        i = 0;
		        (void) sscanf(arg, "%*[^[][%d,%d", &i );
		        if (i > image->colors)
		            i %= image->colors;
			cp = image->colormap+i;
			sprintf(b, "%u,%u,%u\n", cp->red, cp->green, cp->blue);
			s = newSVpv(b, 0);
		    }
		    else if (strEQcase(arg, "color"))	/* same as number */
		    {
			if (info && info->quant.number_colors)
			    s = newSViv(info->quant.number_colors);
			else if (image)
			    s = newSViv(image->colors);
		    }
		    else if (strEQcase(arg, "column"))
		    {
			if (image)
			    s = newSViv(image->columns);
		    }
		    break;
		case 'D': case 'd':
		    if (strEQcase(arg, "density"))
		    {
			if (info && info->info.density)
			    s = newSVpv(info->info.density, 0);
		    }
		    else if (strEQcase(arg, "dispose"))
		    {
			if (info && info->info.dispose)
			    s = newSVpv(info->info.dispose, 0);
			else if (image)
			    s = newSViv(image->dispose);
		    }
		    else if (strEQcase(arg, "delay"))
		    {
			if (info && info->info.delay)
			    s = newSVpv(info->info.delay, 0);
			else if (image)
			    s = newSViv(image->delay);
		    }
		    else if (strEQcase(arg, "dither"))
		    {
			if (!info)
			    break;
			s = newSViv(info->info.dither);
			if (info->info.dither >= 0 &&
			    info->info.dither < NUMBEROF(p_boolean) - 1)
			{
			    sv_setpv(s, p_boolean[info->info.dither]);
			    SvIOK_on(s);
			}
		    }
		    else if (strEQcase(arg, "display"))	/* same as server */
		    {
			if (info && info->info.server_name)
			    s = newSVpv(info->info.server_name, 0);
		    }
		    else if (strEQcase(arg, "depth"))
		    {
			if (image)
			    s = newSViv(image->depth);
		    }
		    else if (strEQcase(arg, "directory"))
		    {
			if (image && image->directory)
			    s = newSVpv(image->directory, 0);
		    }
		    break;
		case 'E': case 'e':
		    break;
		case 'F': case 'f':
		    if (strEQcase(arg, "filesize"))
		    {
			if (image)
			    s = newSViv(image->filesize);
		    }
		    else if (strEQcase(arg, "file"))
		    {
			if (info && info->info.filename && *info->info.filename)
			    s = newSVpv(info->info.filename, 0);
			else if (image)
			    s = newSVpv(image->filename, 0);
		    }
		    else if (strEQcase(arg, "font"))
		    {
			if (info && info->info.font)
			    s = newSVpv(info->info.font, 0);
		    }
		    else if (strEQcase(arg, "format"))	/* same as magick */
		    {
			if (info && *info->info.magick)
			    s = newSVpv(info->info.magick, 0);
			else if (image)
			    s = newSVpv(image->magick, 0);
		    }
		    break;
		case 'G': case 'g':
		    if (strEQcase(arg, "gamma"))
		    {
			if (image)
			    s = newSVnv(image->gamma);
		    }
		    else if (strEQcase(arg, "geom"))
		    {
			if (image && image->geometry)
			    s = newSVpv(image->geometry, 0);
		    }
		    break;
		case 'H': case 'h':
		    if (strEQcase(arg, "height"))
		    {
			if (image)
			    s = newSViv(image->rows);
		    }
		    break;
		case 'I': case 'i':
		    if (strEQcase(arg, "iterat"))	/* same as loop */
		    {
			if (info && info->info.iterations)
			    s = newSVpv(info->info.iterations, 0);
			else if (image)
			    s = newSViv(image->iterations);
		    }
		    else if (strEQcase(arg, "interlace"))
		    {
			i = info ? info->info.interlace : image->interlace;
			s = newSViv(i);
			if (i >= 0 && i < NUMBEROF(p_interlaces) - 1)
			{
			    sv_setpv(s, p_interlaces[i]);
			    SvIOK_on(s);
			}
		    }
		    break;
		case 'J': case 'j':
		    break;
		case 'K': case 'k':
		    break;
		case 'L': case 'l':
		    if (strEQcase(arg, "label"))
		    {
			if (image && image->label)
			    s = newSVpv(image->label, 0);
		    }
		    else if (strEQcase(arg, "loop"))	/* same as iterations */
		    {
			if (info && info->info.iterations)
			    s = newSVpv(info->info.iterations, 0);
			else if (image)
			    s = newSViv(image->iterations);
		    }
		    break;
		case 'M': case 'm':
		    if (strEQcase(arg, "magick"))	/* same as format */
		    {
			if (info && *info->info.magick)
			    s = newSVpv(info->info.magick, 0);
			else if (image)
			    s = newSVpv(image->magick, 0);
		    }
		    else if (strEQcase(arg, "monoch"))
		    {
			i = info?
			    info->info.monochrome : IsMonochromeImage(image);
			s = newSViv(i);
		    }
		    else if (strEQcase(arg, "mattecolor") ||
			     strEQcase(arg, "matte_color"))
		    {
			if (!image)
			    break;
			sprintf(b, "%u,%u,%u,%u",
				    image->border_color.red,
				    image->border_color.green,
				    image->border_color.blue,
				    image->border_color.index);
			s = newSVpv(b, 0);
		    }
		    else if (strEQcase(arg, "matte"))
		    {
			if (image)
			    s = newSViv(image->matte);
		    }
		    else if (strEQcase(arg, "montage"))
		    {
			if (image && image->montage)
			    s = newSVpv(image->montage, 0);
		    }
		    else if (strEQcase(arg, "mean"))
		    {
			if (image)
			    s = newSViv(image->mean_error_per_pixel);
		    }
		    break;
		case 'N': case 'n':
		    if (strEQcase(arg, "number"))	/* same as colors */
		    {
			if (info && info->quant.number_colors)
			    s = newSViv(info->quant.number_colors);
			else if (image)
			    s = newSViv(image->colors);
		    }
		    else if (strEQcase(arg, "normalized_max") ||
			     strEQcase(arg, "normalizedmax"))
		    {
			if (image)
			    s = newSVnv(image->normalized_maximum_error);
		    }
		    else if (strEQcase(arg, "normalized_mean") ||
			     strEQcase(arg, "normalizedmean"))
		    {
			if (image)
			    s = newSVnv(image->normalized_mean_error);
		    }
		    break;
		case 'O': case 'o':
		    break;
		case 'P': case 'p':
		    if (strEQcase(arg, "packetsize") ||
			strEQcase(arg, "packet_size"))
		    {
			if (image)
			    s = newSViv(image->packet_size);
		    }
		    else if (strEQcase(arg, "packet"))
		    {
			if (image)
			    s = newSViv(image->packets);
		    }
		    else if (strEQcase(arg, "page"))
		    {
			if (info && info->info.page)
			    s = newSVpv(info->info.page, 0);
			else if (image && image->page)
			    s = newSVpv(image->page, 0);
		    }
		    else if (strEQcase(arg, "pipe"))
		    {
			if (image)
			    s = newSViv(image->pipe);
		    }
		    else if (strEQcase(arg, "pixel"))
		    {
			RunlengthPacket *cp;
			int x, y;

			if (!image || !image->pixels)
			    break;
			if (!UncompressImage(image))
			    break;
		        x = 0;
		        y = 0;
		        (void) sscanf(arg, "%*[^[][%d,%d", &x, &y);
		        if (y > image->rows)
		            y %= image->rows;
		        if (x > image->columns)
		            x %= image->columns;
			cp = image->pixels+(y*image->columns+x);
			sprintf(b, "%u,%u,%u,%u\n", cp->red, cp->green,
						    cp->blue, cp->index);
			s = newSVpv(b, 0);
		    }
		    else if (strEQcase(arg, "points"))
		    {
			if (info)
			    s = newSViv(info->info.pointsize);
		    }
		    break;
		case 'Q': case 'q':
		    if (strEQcase(arg, "quality"))
		    {
			if (info)
			    s = newSViv(info->info.quality);
		    }
		    break;
		case 'R': case 'r':
		    if (strEQcase(arg, "runlength"))
		    {
			if (image)
			    s = newSViv(image->runlength);
		    }
		    else if (strEQcase(arg, "row"))
		    {
			if (image)
			    s = newSViv(image->rows);
		    }
		    break;
		case 'S': case 's':
		    if (strEQcase(arg, "status"))
		    {
			if (image)
			    s = newSViv(image->status);
		    }
		    else if (strEQcase(arg, "subimage"))
		    {
			if (info)
			    s = newSViv(info->info.subimage);
		    }
		    else if (strEQcase(arg, "subrange"))
		    {
			if (info)
			    s = newSViv(info->info.subrange);
		    }
		    else if (strEQcase(arg, "server"))	/* same as display */
		    {
			if (info && info->info.server_name)
			    s = newSVpv(info->info.server_name, 0);
		    }
		    else if (strEQcase(arg, "size"))
		    {
			if (info && info->info.size)
			    s = newSVpv(info->info.size, 0);
		    }
		    else if (strEQcase(arg, "scene"))
		    {
			if (image)
			    s = newSViv(image->scene);
		    }
		    else if (strEQcase(arg, "sign"))
		    {
			if (image)
			    s = newSVpv(image->signature, 0);
		    }
		    break;
		case 'T': case 't':
		    if (strEQcase(arg, "temp"))
		    {
			if (image)
			    s = newSViv(image->temporary);
		    }
		    else if (strEQcase(arg, "tile"))
		    {
			if (info && info->info.tile)
			    s = newSVpv(info->info.tile, 0);
		    }
		    else if (strEQcase(arg, "texture"))
		    {
			if (info && info->info.texture)
			    s = newSVpv(info->info.texture, 0);
		    }
		    else if (strEQcase(arg, "text"))
		    {
			if (image && image->text)
			    s = newSVpv(image->text, 0);
		    }
		    else if (strEQcase(arg, "total"))
		    {
			if (image)
			    s = newSViv(image->total_colors);
		    }
		    break;
		case 'U': case 'u':
		    if (strEQcase(arg, "undercolor"))
		    {
			if (info && info->info.undercolor)
			    s = newSVpv(info->info.undercolor, 0);
		    }
		    else if (strEQcase(arg, "units"))
		    {
			if (!image)
			    break;
			s = newSViv(image->units);
			if (image->units >= 0 &&
					image->units < NUMBEROF(p_units) - 1)
			{
			    sv_setpv(s, p_units[image->units]);
			    SvIOK_on(s);
			}
		    }
		    break;
		case 'V': case 'v':
		    if (strEQcase(arg, "verbose"))
		    {
			if (info)
			    s = newSViv(info->info.verbose);
		    }
		    break;
		case 'W': case 'w':
		    if (strEQcase(arg, "width"))
		    {
			if (image)
			    s = newSViv(image->columns);
		    }
		    break;
		case 'X': case 'x':
		    if (strEQcase(arg, "x"))
		    {
			if (image)
			    s = newSVnv(image->x_resolution);
		    }
		    break;
		case 'Y': case 'y':
		    if (strEQcase(arg, "y"))
		    {
			if (image)
			    s = newSVnv(image->y_resolution);
		    }
		    break;
		case 'Z': case 'z':
		    break;
		}

		/* push return value onto stack */
		PUSHs(s? sv_2mortal(s) : &sv_undef);
	    }
	}

# Ping image

void
Ping(ref, ...)
	Image::Magick	ref = NO_INIT
	ALIAS:
	    PingImage	= 1
	    ping	= 2
	    pingimage	= 3
	PPCODE:
	{
	    SV *rref;	/* rref is the SV* of ref=SvIV(rref) */
	    int n;
	    char b[80];
	    struct info *info;
	    unsigned int columns, rows, filesize;
	    AV *av;
	    SV *s;

	    EXTEND(sp, items - 1);
	    im_er_mes = newSVpv("", 0);

	    rref = SvRV(ST(0));
	    av = (AV *)rref;
	    info = getinfo(av, NULV);
	    for (n = 1; n < items; n++)
	    {
		strcpy(info->info.filename, (char *)SvPV(ST(n), na));
		filesize=PingImage(&info->info, &columns, &rows);
		if (filesize == 0)
		    s = &sv_undef;
		else {
		    sprintf(b, "%u,%u,%u,%s", columns, rows, filesize,
		    	info->info.magick);
		    s = sv_2mortal(newSVpv(b, 0));
		}
		PUSHs(s);
	    }

	    SvREFCNT_dec(im_er_mes);    /* throw away all errors */
	    im_er_mes = NULL;
	}

# lookup a color by its name

void
QueryColor(ref, ...)
	Image::Magick	ref = NO_INIT
	ALIAS:
		querycolor = 1
	PPCODE:
	{
	    int n;
	    char *arg;	/* the color name */
	    XColor target_color;
	    char b[80];
	    SV *s;

	    EXTEND(sp, items - 1);
	    im_er_mes = newSVpv("", 0);

	    for (n = 1; n < items; n++)
	    {
		arg = (char *)SvPV(ST(n), na);

		if (!XQueryColorDatabase(arg, &target_color))
		    s = &sv_undef;
		else {
		    sprintf(b, "%u,%u,%u", XDownScale(target_color.red),
					   XDownScale(target_color.green),
					   XDownScale(target_color.blue));
		    s = sv_2mortal(newSVpv(b, 0));
		}
		PUSHs(s);
	    }

	    SvREFCNT_dec(im_er_mes);    /* throw away all errors */
	    im_er_mes = NULL;
	}
