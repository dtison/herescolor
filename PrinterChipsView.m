
/*  Prints the printer chips for visual matching */

#import "PrinterChipsView.h"

@implementation PrinterChipsView

- drawSelf: (const NXRect *) rects: (int) rectCount
{
	struct 	stat st;
	char		circuitName [MAXPATHSIZE];

	/*  This view is for printing only  */

	if (NXDrawingStatus != NX_PRINTING)
		return self;	

	NX_DURING

	memset (circuitName, 0, MAXPATHSIZE);

	if (! referenceColors)
		referenceColors = [[window delegate] referenceRcHnColors];


	if (targetType == TEACHME_INSTRUMENT)
	{
		int	qualityLevel;
		int	status;

		/*  Make sure image color space is straight Level 1, and is in device coordinates  */	
		DPSPrintf (DPSGetCurrentContext(), 
		"/NXCalibratedRGBColorSpace /BogusRGB [/DeviceRGB]  /ColorSpace defineresource def\n");

		/*  Now eliminate any black / transfer function stuff.    */

		PSWremoveblackgen ();

		/*  Now let's create a circuit, transform image to either device RGB or CMYK space  */

		qualityLevel =  CI_QL_MIN + 3;
		status = CiCircCreate (qualityLevel, CI_DIR_FORWARD);
		strcpy (circuitName, [[NXApp delegate] hiddenDirectory]);
		strcat (circuitName, "/Target.hc");
		status = CiCircWrite (circuitName);
		CiCircClose();	// Close because colorCorrectImage will read in, xform and close

		if (! bitmapImage)
 			bitmapImage = makeTargetBitmapImage (CI_TP_RGB216, 1536, 1024,
			 [[NXApp delegate] hiddenDirectory]);

		if (colorType == CMYK_4COLOR)
			bitmapImage = colorCorrectImage (bitmapImage, circuitName, 
										NULL, NX_CMYKColorSpace);
		else
			bitmapImage = colorCorrectImage (bitmapImage, circuitName, 
										NULL, NX_RGBColorSpace);
		[bitmapImage drawIn: rects];
	}
	else	
	{
		/*  Draw the Visual Chips  */

		if (colorType == CMYK_4COLOR)
			[self drawCMYKChips];
		else
			[self drawRGBChips];
	}

	NX_RAISE (Err_NoError, NULL, NULL);
	NX_HANDLER
	if (stat (circuitName, &st) == 0)
		unlink (circuitName);
	HERE_RERAISE();
	NX_ENDHANDLER
	return self;
}


- drawCMYKChips
{
	float boxsize 		= 60;
	float	whitespace 	= 10;
	int				i, j, index;
	ColorV 			 destV;
	
	/*  Eliminate any black / transfer function stuff.  6-17-93  */

	PSWremoveblackgen ();

	/*  Setup font and drawing  */

	PSsetgray (0);
	PSWsetfont ("Helvetica", 20);

	/*  Draw 6 basic colors   */

	PStranslate (20, 700);
	PSmoveto (0, 0);
	PSshow ("Basic Colors");
	
	PStranslate (0, -85);

	index = 0;
 	for (i = 0; i < 6; i++, index++)
	{
 		CiTranColor (referenceColors [index], destV, CI_DIR_FORWARD);

		/*  Fix PostScript bug.  If emitted value < .01, set = 0.0  to prevent ink contamination */

		for (j = 0; j < 4; j++)
			if (destV [j] < 0.01)
				destV [j] = 0.0;

		PSWdrawbox (destV [0], destV [1], destV [2], destV [3], boxsize);
		PStranslate (boxsize + whitespace, 0);
	}
	PStranslate (((boxsize + whitespace) * -6), -(boxsize + whitespace)); 


	/*  Now the 5 rows of extended colors  */

	PSsetgray (0);
	PSmoveto (0, 0);
	PSshow ("Extended Colors");

	PStranslate (0, -85);

	/* Row 1:  Half value (dark, towards black)  */

	PSsetgray (0);
	PSmoveto (-20, 35);
	PSshow ("1");

 	for (i = 0; i < 6; i++, index++)
	{
		CiTranColor (referenceColors [index], destV, CI_DIR_FORWARD);
		/*  (See PS bug note above)  */
		for (j = 0; j < 4; j++)
			if (destV [j] < 0.01)
				destV [j] = 0.0;

		PSWdrawbox (destV [0], destV [1], destV [2], destV [3], boxsize);
		PStranslate (boxsize + whitespace, 0);
	}
	PStranslate (((boxsize + whitespace) * -6), -(boxsize + whitespace)); 


	/* Row 2:  Half value (dark, towards black)  */

	PSsetgray (0);
	PSmoveto (-20, 35);
	PSshow ("2");

	for (i = 0; i < 6; i++, index++)
	{
		CiTranColor (referenceColors [index], destV, CI_DIR_FORWARD);
		/*  (See PS bug note above)  */
		for (j = 0; j < 4; j++)
			if (destV [j] < 0.01)
				destV [j] = 0.0;
		PSWdrawbox (destV [0], destV [1], destV [2], destV [3], boxsize);
		PStranslate (boxsize + whitespace, 0);
	}
	PStranslate (((boxsize + whitespace) * -6), -(boxsize + whitespace)); 


	/* Row 3:  "Other" in between primaries                 */

	PSsetgray (0);
	PSmoveto (-20, 35);
	PSshow ("3");

	for (i = 0; i < 6; i++, index++)
	{
		CiTranColor (referenceColors [index], destV, CI_DIR_FORWARD);
		/*  (See PS bug note above)  */
		for (j = 0; j < 4; j++)
			if (destV [j] < 0.01)
				destV [j] = 0.0;
		PSWdrawbox (destV [0], destV [1], destV [2], destV [3], boxsize);
		PStranslate (boxsize + whitespace, 0);
	}
	PStranslate (((boxsize + whitespace) * -6), -(boxsize + whitespace)); 


	/* Row 4:  "Other" , half value                 */

	PSsetgray (0);
	PSmoveto (-20, 35);
	PSshow ("4");

	for (i = 0; i < 6; i++, index++)
	{
		CiTranColor (referenceColors [index], destV, CI_DIR_FORWARD);
		/*  (See PS bug note above)  */
		for (j = 0; j < 4; j++)
			if (destV [j] < 0.01)
				destV [j] = 0.0;
		PSWdrawbox (destV [0], destV [1], destV [2], destV [3], boxsize);
		PStranslate (boxsize + whitespace, 0);
	}
	PStranslate (((boxsize + whitespace) * -6), -(boxsize + whitespace)); 


	/* Row 5:  "Other" , half sat                 */

	PSsetgray (0);
	PSmoveto (-20, 35);
	PSshow ("5");

	for (i = 0; i < 6; i++, index++)
	{
		CiTranColor (referenceColors [index], destV, CI_DIR_FORWARD);
		/*  (See PS bug note above)  */
		for (j = 0; j < 4; j++)
			if (destV [j] < 0.01)
				destV [j] = 0.0;
		PSWdrawbox (destV [0], destV [1], destV [2], destV [3], boxsize);
		PStranslate (boxsize + whitespace, 0);
	}
	PStranslate (((boxsize + whitespace) * -6), -(boxsize + whitespace)); 

	return self;
}

/*  I don't know whether this ought to have the < .01 set 0.0 fix the CMYK version has... */

- drawRGBChips
{
	float boxsize 		= 60;
	float	whitespace 	= 10;
	int				i, index;
	ColorV 			 destV;
	
	/*  Eliminate any black / transfer function stuff.  6-17-93  */

	PSWremoveblackgen ();

	PSsetgray (0);
	PSWsetfont ("Helvetica", 20);

	/*  Draw 6 basic colors first  */

	PStranslate (20, 700);
	PSmoveto (0, 0);
	PSshow ("Basic Colors");
	
	PStranslate (0, -85);

	index = 0;
 	for (i = 0; i < 6; i++, index++)
	{
		CiTranColor (referenceColors [index], destV, CI_DIR_FORWARD);
		PSWdrawboxrgb (destV [0], destV [1], destV [2], boxsize);
		PStranslate (boxsize + whitespace, 0);
	}
	PStranslate (((boxsize + whitespace) * -6), -(boxsize + whitespace)); 


	/*  Now the 5 rows of extended colors  */

	PSsetgray (0);
	PSmoveto (0, 0);
	PSshow ("Extended Colors");

	PStranslate (0, -85);

	/* Row 1:  Half value (dark, towards black)  */

	PSsetgray (0);
	PSmoveto (-20, 35);
	PSshow ("1");

 	for (i = 0; i < 6; i++, index++)
	{
		CiTranColor (referenceColors [index], destV, CI_DIR_FORWARD);
		PSWdrawboxrgb (destV [0], destV [1], destV [2], boxsize);
		PStranslate (boxsize + whitespace, 0);
	}
	PStranslate (((boxsize + whitespace) * -6), -(boxsize + whitespace)); 


	/* Row 2:  Half value (dark, towards black)  */

	PSsetgray (0);
	PSmoveto (-20, 35);
	PSshow ("2");

	for (i = 0; i < 6; i++, index++)
	{
		CiTranColor (referenceColors [index], destV, CI_DIR_FORWARD);
		PSWdrawboxrgb (destV [0], destV [1], destV [2],  boxsize);
		PStranslate (boxsize + whitespace, 0);
	}
	PStranslate (((boxsize + whitespace) * -6), -(boxsize + whitespace)); 


	/* Row 3:  "Other" in between primaries                 */

	PSsetgray (0);
	PSmoveto (-20, 35);
	PSshow ("3");

	for (i = 0; i < 6; i++, index++)
	{
		CiTranColor (referenceColors [index], destV, CI_DIR_FORWARD);
		PSWdrawboxrgb (destV [0], destV [1], destV [2], boxsize);
		PStranslate (boxsize + whitespace, 0);
	}
	PStranslate (((boxsize + whitespace) * -6), -(boxsize + whitespace)); 


	/* Row 4:  "Other" , half value                 */

	PSsetgray (0);
	PSmoveto (-20, 35);
	PSshow ("4");

	for (i = 0; i < 6; i++, index++)
	{
		CiTranColor (referenceColors [index], destV, CI_DIR_FORWARD);
		PSWdrawboxrgb (destV [0], destV [1], destV [2], boxsize);
		PStranslate (boxsize + whitespace, 0);
	}
	PStranslate (((boxsize + whitespace) * -6), -(boxsize + whitespace)); 


	/* Row 5:  "Other" , half sat                 */

	PSsetgray (0);
	PSmoveto (-20, 35);
	PSshow ("5");

	for (i = 0; i < 6; i++, index++)
	{
		CiTranColor (referenceColors [index], destV, CI_DIR_FORWARD);
		PSWdrawboxrgb (destV [0], destV [1], destV [2], boxsize);
		PStranslate (boxsize + whitespace, 0);
	}
	PStranslate (((boxsize + whitespace) * -6), -(boxsize + whitespace)); 

	return self;
}


- setColorType: (int) type
{
	colorType = type;
	return self;
}	

- setTargetType: (int) type
{
	targetType = type;
	return self;
}	

- free
{
	if (bitmapImage)
		[bitmapImage free];
	[super free];
	return self;
}

@end





















