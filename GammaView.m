
#import "GammaView.h"

@implementation GammaView

- initFrame: (const NXRect *) frameRect
{
	[super initFrame: frameRect];
	isSolid = NO;
	[self setDrawGamma: 2.2];

	[self setChipColor: RED];
	return self;
}

- drawSelf: (const NXRect *) rects: (int) rectCount
{
	float		red, green, blue, alpha;	
	NXColor	blackColor;

	PSsetgray (0);
	NXRectFill (&bounds); 
	
	blackColor = NXConvertRGBAToColor (0, 0, 0, NX_NOALPHA);

 	NXConvertColorToRGBA (drawColor, &red, &green, &blue, &alpha);
 	PSsetrgbcolor (red, green, blue);


	if (isSolid)
		NXRectFill (&bounds); 
	else
	{
		/*  We had to use NXBitmapImageRep instead of NXImage because I don't know how
			to make NXImage's out of raw bitmaps.  1/13/93  */
		
		if (! drawBitmapImage)	// Need to create the image first
			drawBitmapImage = [self createDrawImage: &bounds: drawColor];

		[drawBitmapImage draw];
	}

	PSsetgray (0);
	NXFrameRect (&bounds);


	return self;
}

- setSolid: (BOOL) flag
{
	isSolid = flag;
	return self;
}

- setGamma: sender
{
	float	value = [sender floatValue];

	[self setDrawGamma: value];
	[self display];

	return self;
}

- setFloatValue: (float) value
{
	[self setDrawGamma: value];	
	[self display];

	return self;
}



/*  Enumerated type indicating what (red, green, blue, gray?) Gamma chip to make  */

- setChipColor: (CHIPCOLOR) aColor
{
	color = aColor;
 	drawColor =  [self makeDrawColor: color: drawGamma];

	return self;
}
	
- setDrawGamma: (float) aGamma
{
	drawGamma = 1 / aGamma;
	drawColor = [self makeDrawColor: color: drawGamma];

	return self;
}
	
- (NXColor) makeDrawColor: (CHIPCOLOR) chipColor: (float) gamma
{
	NXColor 	nxColor;
	float		drawValue;

	/*  This formula backs out the 1.8 display gamma  */	

//	drawValue = pow (pow (.5, gamma), ( 1.8));
 	drawValue = pow (pow (.5, gamma), ( 1.0));
 
	switch (chipColor)
	{
		case RED:
			if (isSolid)
				nxColor = NXConvertRGBAToColor (drawValue, 0, 0, 0);
			else
				nxColor = NXConvertRGBAToColor (gamma, 0, 0, 0);
			break;

		case GREEN:
			if (isSolid)
				nxColor = NXConvertRGBAToColor (0, drawValue, 0, 0);
			else
				nxColor = NXConvertRGBAToColor (0, gamma, 0, 0);
			break;

		case BLUE:
			if (isSolid)
				nxColor = NXConvertRGBAToColor (0, 0, drawValue, 0);
			else
				nxColor = NXConvertRGBAToColor (0, 0, gamma, 0);
			break;
	}
	return nxColor;
}


/*  Returns NXBitmapImageRep created from a raw bitmap  */

- (NXBitmapImageRep *) createDrawImage: (NXRect *) rect: (NXColor) aColor
{
	NXBitmapImageRep *bitmapImage;
	PBYTE			pBitmapData;
	BYTE			bRed, bGreen, bBlue;
	float				red, green, blue, alpha;
	#ifdef 	SMALL
	int				counter = 0;
	#endif
	int				i, j;

	bitmapImage = [NXBitmapImageRep alloc]; 
	bitmapImage = [bitmapImage initData: NULL 
				pixelsWide: (int) rect -> size.width
				pixelsHigh: (int) rect -> size.height 
				bitsPerSample: 8 
				samplesPerPixel: 3
				hasAlpha: NO 
				isPlanar: NO 
				colorSpace: NX_RGBColorSpace
				bytesPerRow: 0  
				bitsPerPixel: 24];

	pBitmapData = [bitmapImage data];
	
	memset (pBitmapData, 0, (int) (rect -> size.width * rect -> size.height * 3));

	/*  Set up color stuff */

 	NXConvertColorToRGBA (aColor, &red, &green, &blue, &alpha);
	bRed 	= (BYTE) ((red * 255) + .05);
	bGreen 	= (BYTE) ((green * 255) + .05);
	bBlue 	= (BYTE) ((blue * 255) + .05);

//	#define SMALL

	for (i = 0; i < (int) rect -> size.height; i++)
	{
		#ifdef SMALL
		for (j = 0; j < (int) rect -> size.width; j++)
		{
			if (counter % 2)
			{
				*pBitmapData++ = bRed;
				*pBitmapData++ = bGreen;
				*pBitmapData++ = bBlue;
			}
			else
			{
				*pBitmapData++ = 0;
				*pBitmapData++ = 0;
				*pBitmapData++ = 0;
			}
 			counter++;
		}	
  		if (! ((int) rect -> size.width % 2))	// If width is even, tick counter once
			counter++;
		#else
		for (j = 0; j < (int) rect -> size.width; j++)
		{
			if ((i % 2) == 0)
			{
				*pBitmapData++ = bRed;
				*pBitmapData++ = bGreen;
				*pBitmapData++ = bBlue;
			}
			else
			{
				*pBitmapData++ = 0;
				*pBitmapData++ = 0;
				*pBitmapData++ = 0;
			}
		}
		#endif
 	}

	return bitmapImage;
}

- free
{
	if (drawBitmapImage)
		[drawBitmapImage free];

	[super free];
	return self;
}


@end
