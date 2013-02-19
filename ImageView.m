#import <appkit/appkit.h>
#import "ImageView.h"


@implementation ImageView

- initFrame: (const NXRect *) frameRect
{	
	[super initFrame: frameRect];
	fCurrZoomFactor = 1.0;
	return self;
}

- setImage: (id) anImage withRGBImage: (id) anRGBImage
{
	idImage = anImage;
	idRGBImage = anRGBImage;
//	[idRGBImage setScale: 1.0];

	return self;
}

- setScale: (float) factor usingZoomLevel: (float) zoomLevel; 
{
    	NXSize	aSize;
 	 
    	aSize.width = NX_WIDTH (&bounds) * factor;
    	aSize.height = NX_HEIGHT (&bounds) * factor;
    	[self sizeTo: aSize.width: aSize.height];
	
	fCurrZoomFactor = zoomLevel;
//	[idRGBImage setScale: zoomLevel];

  	 /*  Show the new image */

   	 [self display];
    
    	return self;
}



- drawSelf: (const NXRect *) rects: (int) rectCount
{
	if (NXDrawingStatus == NX_PRINTING)
	{
		if (! [[window delegate] level2])
		{
			/*  Make sure image color space uses Level 1 color  */	
			DPSPrintf (DPSGetCurrentContext(), 
	"/NXCalibratedRGBColorSpace /BogusRGB [/DeviceRGB]  /ColorSpace defineresource def\n");
			DPSPrintf (DPSGetCurrentContext(), 
	"/nxsetrgbcolor {/DeviceRGB setcolorspace setcolor} bind def\n");

			/*  Now eliminate any black / transfer function stuff.    */

			PSWremoveblackgen ();
		}
	}

//#define ZOOMPRINT
#ifdef ZOOMPRINT
		if (fCurrZoomFactor != 1.0 && NXDrawingStatus == NX_PRINTING)  
		{
			id		idTempImage;
			NXSize 	imageSize;

			if (! idCMYKImage)
			{
				idCMYKImage = [[CMYKImageRep alloc]
							 initFromBitmapImage: 
							(NXBitmapImageRep *) [idImage bestRepresentation]];
			}

			[idImage getSize: &imageSize];

			#if 0
			idTempImage = [[NXImage alloc] initSize: &imageSize];
			[idTempImage useRepresentation: (NXImageRep *) idCMYKImage];
	
			[idTempImage composite: NX_COPY 
		 		fromRect: rects
		 		toPoint: &rects -> origin];

			#endif

			{	
				PSgsave ();
				PSscale (fCurrZoomFactor, fCurrZoomFactor);
				[idCMYKImage  draw];
				PSgrestore();
				return self;
			}


		}

#endif


//	if (fCurrZoomFactor != 1.0 && NXDrawingStatus != NX_PRINTING) // Really need to zoom image
	if (1)
	{	
		PSgsave ();
		PSscale (fCurrZoomFactor, fCurrZoomFactor);
		[idRGBImage  draw];
		PSgrestore();
		return self;
	}
	else
	#ifdef WESPLIT
		if (NXDrawingStatus == NX_PRINTING)	//  Prepare a CMYK "representation" of the image  
		{
			id		idTempImage;
			NXSize 	imageSize;

			if (! idCMYKImage)
			{
				idCMYKImage = [[CMYKImageRep alloc]
							 initFromBitmapImage: 
							(NXBitmapImageRep *) [idImage bestRepresentation]];
			}

			[idImage getSize: &imageSize];

			idTempImage = [[NXImage alloc] initSize: &imageSize];
			[idTempImage useRepresentation: (NXImageRep *) idCMYKImage];
	
			[idTempImage composite: NX_COPY 
		 		fromRect: rects
		 		toPoint: &rects -> origin];


		}
		else
		#endif	
	if (idImage)
		[idImage composite: NX_COPY 
		 fromRect: rects
		 toPoint: &rects -> origin];
	
	return self;
}

- free
{
	if (idImage)
		[idImage free];

	[super free];
	return self;
}

-  rgbImage
{
	return idRGBImage;
}

/*  
(Tentative way of editing image data.)
TODO:  Figure out way of managing user selections, marquis' etc. etc.  
ANS:  Probably use NXRect-based strategy, along with some PS clipping path maneuverings
*/

- resetImage: (PBYTE) data		
{
	[idRGBImage resetImage: data];

	/*  (CMYK image, other representations as appropriate.  For now free up.)  */

	if (idCMYKImage)
	{
		[idCMYKImage free];
		idCMYKImage = nil;
	}

	return self;
}

 - updateImage: (NXImage*) image: (PBYTE) data: (NXRect *) selectionRect
{
 	[idRGBImage updateImage: image: data: selectionRect];

	/*  (CMYK image, other representations as appropriate.  For now free up.)  */

	if (idCMYKImage)
	{
		[idCMYKImage free];
		idCMYKImage = nil;
	}

	return self;
}


@end
