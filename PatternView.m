 
/*  Draws one of the CmsLib test targets  */

/*  When do we free the bitmap ??? */

#import "PatternView.h"

@implementation PatternView	

- initFrame: (const NXRect *) frameRect
{
	[super initFrame: frameRect];
	cmyk320Image = gray16Image = nil;
	patternType = CMYK_4COLOR;
	return self;
}


- drawSelf: (const NXRect *) rects: (int) rectCount
{
	NXBitmapImageRep	*bitmapImage;

	/*  This view is for printing only  */

	if (NXDrawingStatus != NX_PRINTING)
		return self;	

	NX_DURING

	/*  Make sure image color space is straight Level 1, and is in device coordinates  */	
	DPSPrintf (DPSGetCurrentContext(), 
	"/NXCalibratedRGBColorSpace /BogusRGB [/DeviceRGB]  /ColorSpace defineresource def\n");

	/*  Now eliminate any black / transfer function stuff.    */

	PSWremoveblackgen ();

	switch (patternType)
	{
		case CMYK_4COLOR:
			if (! cmyk320Image)
				cmyk320Image = makeTargetBitmapImage (CI_TP_CMYK320, 1024, 1325,
			 	[[NXApp delegate] hiddenDirectory]);
			bitmapImage = cmyk320Image;
			break;
		
		case CMY_3COLOR:
		case RGB_3COLOR:
			if (! gray16Image)
				gray16Image = makeTargetBitmapImage (CI_TP_GRAY16, 612, 792, 				[[NXApp delegate] hiddenDirectory]);
			bitmapImage = gray16Image;
			break;
	}

	[bitmapImage drawIn: rects];

	NX_RAISE (Err_NoError, NULL, NULL);
	NX_HANDLER

	HERE_RERAISE();
	NX_ENDHANDLER
	return self;
}


- setPatternType: (int) type
{
	patternType = type;
	return self;
}	

- free
{
	if (cmyk320Image)
		[cmyk320Image free];
	if (gray16Image)
		[gray16Image free];
	[super free];
	return self;
}

@end





















