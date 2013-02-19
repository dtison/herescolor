#import <appkit/appkit.h>

#import "ImageDocument.h"
#import "Controller.h"

@implementation ImageDocument
 
#define MIN_WINDOW_WIDTH 50.0
#define MIN_WINDOW_HEIGHT 75.0
#define SCROLLVIEW_BORDER NX_NOBORDER

#define WINDOW_MASK (NX_MOUSEUPMASK|NX_MOUSEDRAGGEDMASK|NX_FLAGSCHANGEDMASK)

/*  Initialized a newly created document from what is in the passed filename.  */
 
- initFromFile: (const char *) filename
{
 	/*  Error handling (this whole file)  */

	[self initStuff];		// A shared routine for two very similar initFrom's

	if (! filename || ! strlen (filename))	
		return self;

	NX_DURING

	/*  First save file / path stuff  */

	strcpy (szImageFilename, filename);
	SeparateFile (szImageDirectory, szImageName, szImageFilename);

	/*  Then get image file open  */

	idImage = [[[NXImage alloc] init] setCacheDepthBounded: NO];
	[idImage loadFromFile: szImageFilename];	/// TRY a lazy load here sometime. . .
	if (idImage == nil)
		NX_RAISE (Err_NoError, NULL, NULL);

	[self initDocumentWith: idImage];
	NX_RAISE (Err_NoError, NULL, NULL);
	NX_HANDLER
	if (NXLocalHandler.code != Err_NoError)
		HERE_Error (NXLocalHandler.code);
	NX_ENDHANDLER
	return self;
}

- initFromStream: (NXStream *) stream
{
	NX_DURING

	[self initStuff];		// A shared routine for two very similar initFrom's

	/*  First save file / path stuff  */

	/*  (Have to put image counter in controller)  */

	sprintf (szImageFilename, "./Untitled-%d", [controller untitledDocCount]);
	SeparateFile (szImageDirectory, szImageName, szImageFilename);

	/*  Then get image file open  */

	idImage = [[[NXImage alloc] init] setCacheDepthBounded: NO];
	[idImage loadFromStream: stream];	/// TRY a lazy load here sometime. . .

	[self initDocumentWith: idImage];		// Error handling

	NX_RAISE (Err_NoError, NULL, NULL);
	NX_HANDLER

	NX_ENDHANDLER
	return self;
}

- initStuff
{
	[super init];

   	if (! olSavePanelAccessoryView)
 		[NXApp loadNibSection: "SavePanelAccessory.nib"
		owner:self withNames:NO fromZone: [self zone]];

 	if (! olPrintPanelAccessoryView)
 		[NXApp loadNibSection: "PrintPanelAccessory.nib"
		owner:self withNames:NO fromZone: [self zone]];

	[olJpegLevelSlider setEnabled: NO];
	[olJpegLevelEdit setEnabled: NO];
	compression = NX_TIFF_COMPRESSION_NONE;

	controller = [NXApp delegate];

	return self;
}

//#define MARQUIS

- initDocumentWith: (NXImage *) image
{
	NXRect 	viewFrame;
	NXSize 	aSize;
	id		idScrollView;
 
	NX_DURING

	/*  Check these when trouble arises  */

	[image setCacheDepthBounded: NO];		
 	[image setDataRetained: YES];
	[image setScalable: YES];
//	[image useCacheWithDepth: NX_TwentyFourBitRGBDepth];
	[image setUnique: NO];

	/*  Create an ImageView instance the size of the image  */

	[image getSize:  &aSize];
	 	
	viewFrame.origin.x 	= 
	viewFrame.origin.y 	= 0.0;
	viewFrame.size 	= aSize;

	idImageView = [[ImageView alloc] initFrame: &viewFrame];
	[idImageView setImage: image withRGBImage: [image bestRepresentation]];

			
	
	idWindow = [self createWindow: &viewFrame];
	/*  Create an ImageScrollView instance for this window */

	[[idWindow contentView] getBounds: &viewFrame];
	idScrollView = [[ImageScrollView alloc] initFrame: &viewFrame];

    	[[idWindow setContentView: idScrollView] free];

	[idScrollView setDocView: idImageView]; 
  	[idScrollView setVertScrollerRequired: YES];
	[idScrollView setHorizScrollerRequired: YES];

		
	/*  Somehow, somewhere, lets figure out a nice formula for finding these values.
	    I haven't been able to get these reliably (the 19.0's) 11/92  */

	[idWindow sizeWindow: viewFrame.size.width + 19.0
	 : viewFrame.size.height + 19.0];

	[idWindow addToEventMask:WINDOW_MASK];
 	[idWindow makeFirstResponder: idImageView];

	#ifdef MARQUIS

	/*  Try out our Marquis view  */

	idMarquisView = [[MarquisView alloc] initFrame: &viewFrame];
	[idImageView addSubview: idMarquisView];


	/*  Cursor for marquis only.  These will vary depending on tool selected  */
				
	[idScrollView setDocCursor: NXIBeam];

	#endif


	[idWindow setDelegate: self];
	[idWindow setTitleAsFilename: szImageFilename];
	[idWindow makeKeyAndOrderFront: idWindow];
	[idWindow display];

	fCurrZoomFactor = 1.0;
	
	NX_RAISE (Err_NoError, NULL, NULL);
	NX_HANDLER


	NX_ENDHANDLER
	return self;
}

- (Window *) createWindow: (NXRect *) frame
{
	id window;
	NXSize 		screenSize;

	/* Shrink the window down if necessary  */

	[NXApp getScreenSize: &screenSize];
	if (frame -> size.width > screenSize.width / 2.0) 
	    frame -> size.width = floor (screenSize.width / 2.0);
	
	if (frame -> size.height > screenSize.height - 20.0) 
	    frame -> size.height = screenSize.height - 20.0;
	
	
	frame -> origin.x = screenSize.width - 85.0 - 
	frame -> size.width;
	
	frame -> origin.y = floor ((screenSize.height - 
	frame -> size.height) / 2.0);
    
	
    	window = [[Window alloc] initContent: frame
				style:NX_RESIZEBARSTYLE
		        backing:  NX_BUFFERED
		     	buttonMask: NX_CLOSEBUTTONMASK | NX_MINIATURIZEBUTTONMASK
			  	defer: YES];


	return window;
}


- (BOOL) isSameAs: (const char *) filename
{
	if (! filename)
		return YES;
	else
		return (strcmp (szImageFilename, filename) == 0);
}

- (const char *) filename
{
 	return szImageFilename;
}

#ifdef NOTYET
- (const char *)directory
{
    return directory;
}

- (const char *)name
{
    return name;
}
#endif


- windowWillMiniaturize: (Window *) sender toMiniwindow: counterpart
{
	char title [MAXPATHLEN+1];
	NXSize	size;

	strcpy (title, szImageName);
	[counterpart setTitle: title];

	if (! idMiniImage)	// Mini image hasn't been created yet; make it
	{
		NXRect content;
		NXRect frame;

		idMiniImage = [idImage copy];

		[counterpart getFrame: &frame];
		[Window getContentRect:  &content
		forFrameRect: &frame
		style: [counterpart style]];
		
		size = content.size;		
		[idMiniImage setSize: &size];
 	}
	
	[idWindow setMiniwindowImage: idMiniImage];
	return self;
}

/*  Returns id of active image for this document  */

- (id) image 
{
	return idImage;
}
 
/*  Returns pointer to RGB image data  */

- (PBYTE) getImageData
{
	return (PBYTE)  [[idImageView rgbImage] getData];
}

- getImageSize: (NXSize *) size
{
	[idImage getSize: size];
	return self;
}

- setImageData: (PBYTE) data
{
	[idImageView resetImage: data];

	/*  Minor kludge:  Try to trigger an NXImage re-compositing  */

	[idImage recache];
	[idMiniImage recache];
	[idImageView display];

	return self;
}
 
- updateImageData: (PBYTE) data: (NXPoint *) points: (int) count: (NXRect *) selectionRect
{	
	int 	i;
	id	idTempImage;
	NXPoint	*point;

	/*  First create a temporary image with the processed data  */

	idTempImage = [NXBitmapImageRep alloc];

	[idTempImage initData: 	data
	pixelsWide: (int) selectionRect -> size.width
	pixelsHigh: (int) selectionRect -> size.height
	bitsPerSample: 8
	samplesPerPixel: 3
	hasAlpha: NO 
	isPlanar: NO 
	colorSpace: NX_RGBColorSpace
	bytesPerRow: (int) selectionRect -> size.width * 3
	bitsPerPixel: 24];

	/*  Lock focus into our image,  draw the processed image into it  */

	[idImage lockFocus];

	PSgsave();

	point = &points [0];
 
   	PSnewpath();

	PSmoveto (point -> x, point -> y);	

	for (i = 1; i < count; i++)
	{
		point = &points [i];
		PSlineto (point -> x, point -> y);	
	}
	
 	PSclosepath();
	PSclip();

	[idTempImage drawAt: &selectionRect -> origin];

	{
		int	size, pixelsWide, pixelsHigh, bps, spp, config, mask;
		PBYTE	pBitmap;

		NXSizeBitmap (selectionRect, 
					&size, 
					&pixelsWide, 
					&pixelsHigh, 
					&bps, 
					&spp, 
					&config, 
					&mask);

		NX_MALLOC (pBitmap, BYTE,  size);

		NXReadBitmap (selectionRect, 
					pixelsWide, 
					pixelsHigh, 
					bps, 
					spp, 
					config, 
					mask, 
					pBitmap, 
					NULL, NULL, NULL, NULL);

		#if 0
		stripAlpha (pBitmap, pixelsWide, pixelsHigh);
		#endif

		/*  Now (finally!) update image  */

		[idImageView updateImage: idImage: pBitmap: (NXRect *) selectionRect];

	#if 0	

	idTempImage = [NXBitmapImageRep alloc];

	[idTempImage initData: 	pBitmap
	pixelsWide: pixelsWide
	pixelsHigh: pixelsHigh
	bitsPerSample: bps
	samplesPerPixel: spp
	hasAlpha: YES 
	isPlanar: NO 
	colorSpace: NX_RGBColorSpace
	bytesPerRow: (int) selectionRect -> size.width * 4
	bitsPerPixel: bps];
	#endif



		NX_FREE (pBitmap);
	}

	PSgrestore();
	[idImage unlockFocus];

	#if 0
	{
		[[idWindow contentView] lockFocus];

		[idTempImage draw];
		[idWindow flushWindow];

	}
	#endif

	[idTempImage free];

	/*  Minor kludge:  Try to trigger an NXImage re-compositing  */

 //	[idImage recache];		// Maybe when select a new image, or new tool?
 	[idMiniImage recache];
 	[idImageView display];

	return self;
}


/*  Change manager items.  Put in the stuff for modified document / file not saved here  */ 

- changeWasDone
{
    	[super changeWasDone];
	[idWindow setDocEdited: YES];
	return self;
}

- changeWasUndone
{
    	[super changeWasUndone];
	return self;
}

- changeWasRedone
{
    	[super changeWasRedone];
	return self;
}

- clean: sender
{
    	[super clean:sender];
    	[idWindow setDocEdited: NO];
    	return self;
}

- dirty: sender
{
    	[super dirty:sender];
	[idWindow setDocEdited: YES];
    	return self;
}


- (BOOL) validateCommand: (MenuCell *) menuCell
{
	SEL 		action = [menuCell action];
	BOOL	bHaveHit = NO;

 	if (action == @selector (print:)) 
 		return YES;
	else
		if (action == @selector (save:)) 
			bHaveHit = YES;
		else
			if (action == @selector (saveAs:)) 
				return YES;
			else
				if (action == @selector (revertToSaved:)) 
					bHaveHit = YES;
				else
					if (action == @selector (close:)) 
						return YES;
					else
	if (action == @selector (copy:)) 
		return YES;
	else
		if (action == @selector (print:)) 
			return NO;

	if (bHaveHit)
		return [idWindow isDocEdited];

    	return [super validateCommand: menuCell];
}

/*  Portions of this will change when multiple export formats are supported  */

- saveAs: sender
{
	NXStream *nxStream;
 	id		savePanel = [SavePanel new];
	PBYTE	pFilename;
	char		szSaveName [MAXPATHSIZE];
	float		factor;

	NX_DURING
 
     	[savePanel setAccessoryView: olSavePanelAccessoryView];

	strcpy (szSaveName, szImageName);
	SetExtension (szSaveName, "tiff");

	[savePanel setRequiredFileType: "tiff"]; 	// For now..
	if ([savePanel runModalForDirectory: 
	szImageDirectory file: 
	szSaveName] == NX_CANCELTAG)
		NX_VALRETURN (self);	

	pFilename = (PBYTE) [savePanel filename];		if (pFilename)
		if (strlen (pFilename) > 0)
		{
			nxStream = NXOpenMemory (NULL, 0, NX_WRITEONLY); 
			if (! nxStream)
				NX_RAISE (Err_MemoryAllocationError, NULL, NULL);

			factor = [olJpegLevelEdit floatValue];
			if (factor > 255 || factor < 1)
				factor = 10;

			if (! [idImage writeTIFF: nxStream 
			allRepresentations: NO
			usingCompression: compression
			andFactor: factor])
				NX_RAISE (Err_MemoryAllocationError, NULL, NULL);
		
			if (NXSaveToFile (nxStream, pFilename) == -1)
 				NX_RAISE (Err_FileWriteError, NULL, NULL);
		}

	NX_RAISE (Err_NoError, NULL, NULL);
	NX_HANDLER
	if (nxStream)
		NXCloseMemory (nxStream, NX_FREEBUFFER);
	if (NXLocalHandler.code != Err_NoError)
		HERE_Error (NXLocalHandler.code);
	NX_ENDHANDLER
	return self;
}


- save: sender
{
//	HEREAlert ("Save not enabled yet");
	return self;
}

- revertToSaved: sender
{
//	HEREAlert ("Revert to Save not enabled yet");
	return self;
}

- close: sender
{
    	[idWindow performClose: self];
	return self;
}


/*  TODO's.  Think about moving to another file as in Draw  */

/*  Send this document off to the Pasteboard in NXTIFFPboard format  */
/*  Question:  What about the case of the document holds an EPS file?  And re-RIPing */

- copy: sender;
{
	id			Return = nil;
	id 			idPB = [Pasteboard new];
	NXStream	*stream = NULL;

	NX_DURING

	/*  First declare types (ours could be both TIFF and PS if we figure out how)  */

	[idPB declareTypes: [controller getPBSendTypes] num: 1 owner: self];

	/*  Then begin to write out the types you declared  */

	stream = 	NXOpenMemory (NULL, 0, NX_READWRITE); 

	/*  (For now, we're taking a very high-level approach, using NXImage to write the stream 
	     In the future, it may be the RGB image or the CMYK image or some other image 
	     representated in the various views for this window.) */

	if (! [idImage writeTIFF: stream 
		allRepresentations: NO
		usingCompression: NX_TIFF_COMPRESSION_NONE
		andFactor: 0])
		NX_RAISE (Err_MemoryAllocationError, NULL, NULL);

 	NXSeek (stream, 0L, NX_FROMSTART);
 	Return = [idPB writeType: NXTIFFPboardType fromStream: stream];

	NX_RAISE (Err_NoError, NULL, NULL);

	NX_HANDLER
	if (stream)
		NXCloseMemory (stream, NX_FREEBUFFER);
	if (NXLocalHandler.code != Err_NoError)
		HERE_Error (NXLocalHandler.code);
	NX_ENDHANDLER
	return self;
}


/*  Returns currently active selection bounding box.  (Entire image if no selection) OBSOLETE */

- getSelectionRect: (NXRect *) aRect
{
	[idMarquisView getBoundingBox: aRect];
	return self;
}

/*  Returns current marquisview (for now) or related object that defines the current selection  */

- getCurrentSelection
{
	/*  For now, just give 'em the MarquisView that exports needed methods  */

	return idMarquisView;
}

/*  Zoom support goodies  */

- setCurrentZoomFactor: (float) currZoomFactor
{
	NXRect viewFrame;

	fCurrZoomFactor = currZoomFactor;
	
	/*  Another temporary kludge until worked out  12-10-92  */

	[idImageView display];

	[[idWindow contentView] getBounds: &viewFrame];
	[idMarquisView sizeTo: viewFrame.size.width * 
	fCurrZoomFactor: viewFrame.size.height * fCurrZoomFactor];

	return self;
}
- (float) getCurrentZoomFactor
{
	return fCurrZoomFactor;
}

- noCompressionSet: sender
{
	[olJpegLevelSlider setEnabled: NO];
	[olJpegLevelEdit setEnabled: NO];
	compression = NX_TIFF_COMPRESSION_NONE;
	return self;
}
- lzwCompressionSet: sender
{
	[olJpegLevelSlider setEnabled: NO];
	[olJpegLevelEdit setEnabled: NO];
	compression = NX_TIFF_COMPRESSION_LZW;
	return self;
}
- jpegCompressionSet: sender
{
	[olJpegLevelSlider setEnabled: YES];
	[olJpegLevelEdit setEnabled: YES];
	compression = NX_TIFF_COMPRESSION_JPEG;
	return self;
}

- print: sender;
{
	int	status;
	PrintPanel *printPanel = [PrintPanel new];
	PrintInfo *printInfo;	

	[printPanel setAccessoryView: olPrintPanelAccessoryView];
//	status = [printPanel runModal];
//	[printPanel orderOut: self];
//	if (! status)
//		return self;

	/*  Use PrintInfo to scale print  */

	printInfo = [NXApp printInfo];	
	[printInfo setVertPagination: NX_FITPAGINATION];
	[printInfo setHorizPagination: NX_FITPAGINATION];

	[idImageView printPSCode: self];
	[printPanel setAccessoryView: nil];

	return self;
}

#if 0
- (BOOL)shouldRunPrintPanel:aView;
{
	return NO;
}
#endif 

- (BOOL) level2
{
	return [olEnableLevel2Color state];
}

@end

