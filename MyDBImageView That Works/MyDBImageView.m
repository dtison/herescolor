
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
	NXSize	newImageSize;
	float		sizeFactor;

	/*  First save off the dragged image and the bitmap rep if image is a bitmap  */

	draggedImage = [newImage copy];
	if ([[draggedImage bestRepresentation] isKindOf: [NXBitmapImageRep class]])
	{
		if (draggedBitmapImage)
		{
			NXLogError ("MyDBImageView freeing a draggedBitmapImage");
			[draggedBitmapImage free];
		}
		draggedBitmapImage = (NXBitmapImageRep *) [draggedImage bestRepresentation];
	}
	else
		draggedBitmapImage = nil;

	/*  Then scale the image to fit in ourself  */

	[newImage setScalable: YES];
	[newImage setCacheDepthBounded: NO];

	[newImage getSize: &newImageSize];  
	if (newImageSize.width > newImageSize.height)
		sizeFactor = (frame.size.width / newImageSize.width);
	else
		sizeFactor = (frame.size.height / newImageSize.height);

	newImageSize.width 	= rint (newImageSize.width * sizeFactor);
	newImageSize.height 	= rint (newImageSize.height * sizeFactor);

	[newImage setSize: &newImageSize];


	[super setImage: newImage];
	
	if (! createBitmaps)
		return self;

	/*  Now convert that into bitmap we can get bits from  */

	imageRect.origin.x = imageRect.origin.y = 0;
	imageRect.size = newImageSize;
	[Window getFrameRect: &windowFrame
//		forContentRect: &bounds
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
	[newImage composite: NX_COPY toPoint: &bounds.origin];

	if (bitmapImage)
		[bitmapImage free];		// Free up the old one

	bitmapImage = [[NXBitmapImageRep alloc] initData: NULL fromRect: &bounds];
	
	[[imageWindow contentView] unlockFocus];

	/*  Fix a bug.  I discovered alpha flag isn't set but bps = 32.  First fix that bug  */

	if ([bitmapImage bitsPerPixel] == 32 || [bitmapImage bitsPerPixel] == 16)
		[bitmapImage setAlpha: YES];

	#ifdef NEVERNEVER
	/*  Special case.  On 16 bit board with 16 bit tiff image being dragged.  Need to forcibly
		     convert to 24 bit  */
	if ([bitmapImage bitsPerSample] == 4)
	{
		bitmapImage = convert16BitImageTo24Bit (bitmapImage, YES);
		NXLogError ("Stupid 16bit kludge");
	}
	#endif

	if (olOtherImage)
	{
		BOOL isEditable = [olOtherImage isEditable];

		[olOtherImage setEditable: YES];
		[olOtherImage setImage: nil];
		[olOtherImage setEditable: isEditable];
	}

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

- (NXBitmapImageRep *) draggedBitmapImage
{
	if (! draggedBitmapImage)	// Dragged image must have been an EPS, so here we go!
	{
		NXSize				draggedImageSize;

		[draggedImage getSize: &draggedImageSize];
		draggedBitmapImage = epsToBitmap (draggedImage, &draggedImageSize);
	}

	/*  The dragged image may have been a planar tiff.  That's bad, convert to triplets */

	if ([draggedBitmapImage isPlanar])
		NXLogError ("Dragged tiff is planar!");

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
	if (draggedBitmapImage)
		[draggedBitmapImage free];

	[super free];
	return self;
}


@end
