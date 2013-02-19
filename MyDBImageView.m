
#import "MyDBImageView.h"

@implementation MyDBImageView
 
- initFrame: (const NXRect *) frameRect
{
//	const char *fileType[] = {NXTIFFPboardType, NXPostScriptPboardType};

	[super initFrame: frameRect];
	[super setEditable: YES];
	createBitmaps = NO;
//	[super registerForDraggedTypes: fileType count: 2];

	return self;
}

- setImage: newImage
{
	Window *imageWindow;
	NXRect	windowFrame;
	NXRect	imageRect;
	float		sizeFactor;

	/*  A nil image passed in, by convention, will free the last dragged image and everything
	     associated with it */

	if (newImage == nil)
	{
		/*  This may need to be functionalized  (for free) */

		#ifdef DONT_KNOW_YET 
		if (draggedImage)
 			[draggedImage free];
		#endif
		if (draggedBitmapImage && ! draggedImageWasTiff)
			[draggedBitmapImage free];
		if (bitmapImage)
			[bitmapImage free];
		draggedImage 			= nil;
		draggedBitmapImage 	= nil;
		bitmapImage 			= nil;
		[super setImage: nil];

		return self;
	}

	#ifdef DONT_KNOW_YET
	if (draggedImage)
	{
		draggedImage = newImage;
		NXLogError ("MyDBImageView freeing a draggedImage");
		[draggedImage free];
	}
	#endif

	/*  Now save off the dragged image and the bitmap rep if image is a bitmap  */

	draggedImage = newImage;

	if (draggedBitmapImage && ! draggedImageWasTiff)
	{
		#ifdef LOGERROR
		NXLogError ("MyDBImageView freeing a draggedBitmapImage");
		#endif
		[draggedBitmapImage free];
		draggedBitmapImage = nil;
	}

	/*  If dragged image is Tiff, that is also the dragged bitmap image.  */

	if ([[draggedImage bestRepresentation] isKindOf: [NXBitmapImageRep class]])
	{
		draggedImageWasTiff = YES;
		draggedBitmapImage = (NXBitmapImageRep *) [draggedImage bestRepresentation];
	}
	else
	{
		draggedImageWasTiff = NO;
		draggedBitmapImage = nil;
	}
	/*  Then scale the image to fit in ourself  */

 	[draggedImage setScalable: YES];
	[draggedImage setCacheDepthBounded: NO];
	[draggedImage getSize: &draggedImageSize];  

	/*  Now prepare to fix up the size to the size of this view */

	memcpy (&viewImageSize, &draggedImageSize, sizeof (NXSize));

	if (viewImageSize.width > viewImageSize.height)
		sizeFactor = (frame.size.width / viewImageSize.width);
	else
		sizeFactor = (frame.size.height / viewImageSize.height);

	if (viewImageSize.width > bounds.size.width || 
	   viewImageSize.height > bounds.size.height)
	{
		viewImageSize.width 	= rint (viewImageSize.width * sizeFactor);
		viewImageSize.height 	= rint (viewImageSize.height * sizeFactor);
	}

	[draggedImage setSize: &viewImageSize];

	[super setImage: draggedImage];
	
	if (! createBitmaps)
		return self;

	/*  Now convert dragged image into small bitmap (the size of this view) */

	imageRect.origin.x = imageRect.origin.y = 0;
 	imageRect.size = viewImageSize;
	[Window getFrameRect: &windowFrame
 		forContentRect: &imageRect
		style: NX_PLAINSTYLE];

	imageWindow = [[Window alloc] 
			initContent: &windowFrame
			style:	NX_PLAINSTYLE		// TITLED?
			backing: NX_RETAINED
			buttonMask: 0
			defer: NO];

	if (! imageWindow)
		return self;		// error handling

	/*  Make sure it's a 24 bit offscreen Window  */

	[imageWindow setDynamicDepthLimit: NO];
	[imageWindow setDepthLimit: NX_TwentyFourBitRGBDepth];

	[[imageWindow contentView] lockFocus];
//	[newImage composite: NX_COPY toPoint: &bounds.origin];
 	[newImage composite: NX_COPY toPoint: &imageRect.origin];

	if (bitmapImage)
		[bitmapImage free];		// Free up the old one

//	bitmapImage = [[NXBitmapImageRep alloc] initData: NULL fromRect: &bounds];
 	bitmapImage = [[NXBitmapImageRep alloc] initData: NULL fromRect: &imageRect];

	[[imageWindow contentView] unlockFocus];
	[imageWindow free];

	/*  Fix a bug.  I discovered alpha flag isn't set but bps = 32.  First fix that bug  */

	if ([bitmapImage bitsPerPixel] == 32 || [bitmapImage bitsPerPixel] == 16)
		[bitmapImage setAlpha: YES];

 	#if 1
	if (olOtherImage)
	{
		BOOL isEditable = [olOtherImage isEditable];

		[olOtherImage setEditable: YES];
 		[olOtherImage setImage: nil];
		#if 0
		{
			NXImage *image;

 	//		[olOtherImage setImage: bitmapImage];

		}
		#endif
		[olOtherImage setEditable: isEditable];
	}
 	#endif
       
	return self;
}

- setCreateBitmaps: (BOOL) flag
{
	createBitmaps = flag;
	return self;
}


- (NXBitmapImageRep *) bitmapImage
{
	return bitmapImage;
}

/*   Method returns a bitmap at the res of the original dragged image.  If that was EPS, then we 
      create a 72 DPI RIP of it.  */

- (NXBitmapImageRep *) draggedBitmapImage
{
	if (! draggedBitmapImage)	// Must have been an EPS image dragged
		draggedBitmapImage = epsToBitmap (draggedImage, &draggedImageSize, NO);

	/*  The dragged image may have been a planar tiff.  That's bad, convert to triplets */

	#ifdef LOGERROR
	if ([draggedBitmapImage isPlanar])
		NXLogError ("Dragged tiff is planar!");
	#endif

	if ([draggedBitmapImage isPlanar])
		draggedBitmapImage = planesToTriplets (draggedBitmapImage);
	return draggedBitmapImage;
}

- (NXImage *) draggedImage
{
	return draggedImage;
}

- free 
{
	if (bitmapImage)
		[bitmapImage free];
	if (draggedBitmapImage && ! draggedImageWasTiff)
		[draggedBitmapImage free];

	[super free];
	return self;
}

- getDraggedImageSize: (NXSize *) size
{
	size -> width 	= draggedImageSize.width;
	size -> height 	= draggedImageSize.height;
	return self;
}

- getViewImageSize: (NXSize *) size
{
	size -> width 	= viewImageSize.width;
	size -> height 	= viewImageSize.height;
	return self;
}


@end
