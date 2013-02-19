#import <appkit/appkit.h>
#import "TIFImageRep.h"
#import "HEREutils.h"
   
@implementation TIFImageRep

+ (const char * const *) imageUnfilteredFileTypes
{
	static const char *const types [] = {"tif", "tiff", NULL};
	return types;
}
 
+ (const NXAtom *) imageUnfilteredPasteboardTypes
{
	NXLogError ("tif imageUnfilterPasteboardTypes");
	return [super imageUnfilteredPasteboardTypes];
}


+ (BOOL) canLoadFromStream: (NXStream *) aStream
{
	return YES;
	return [NXBitmapImageRep canLoadFromStream: aStream];
}

- initFromFile: (const char *) filename
{
	NXStream	*	stream;
	return self;

	stream = NXMapFile (filename, NX_READONLY);

	[self initFromStream: stream];
	
	NXClose (stream);

	return self;
}
 
 
//	This method needs cleanup.  
// 	(maybe use a DiscardResource approach

- initFromStream: (NXStream *) stream
{
	NXSize				aSize;	// "aSize" because of conflict w/instance vari
	NXBitmapImageRep 	*idTempBitmapImageRep;
	int					nSize;

	[super init];

	idTempBitmapImageRep = [[NXBitmapImageRep alloc] initFromStream: stream];

	/*  It seems all NeXT-saved Tiffs have alpha, so strip if necessary  */

	if ([idTempBitmapImageRep hasAlpha] && 
	[idTempBitmapImageRep samplesPerPixel] == 4)
	{
			stripAlpha ([idTempBitmapImageRep data], 
					[idTempBitmapImageRep pixelsWide],
					[idTempBitmapImageRep pixelsHigh]);
			
			tifImageInfo.nScanWidth 		= [idTempBitmapImageRep pixelsWide];
			tifImageInfo.nScanHeight 		= [idTempBitmapImageRep pixelsHigh];
			tifImageInfo.nBitsPerSample 		= 24;
			tifImageInfo.nSamplesPerPixel 	= 3;
			tifImageInfo.bHasAlpha 			= NO;
			tifImageInfo.bIsPlanar   			= NO;
			tifImageInfo.nxColorSpace  	    	= [idTempBitmapImageRep colorSpace];
			tifImageInfo.nBytesPerRow 		= tifImageInfo.nScanWidth * 3;;
			tifImageInfo.nBitsPerPixel  		= 24;
	}
	else
	{	 		
		/*  Just pass thru */

		// This file is a small disaster.  We have problems emulating NXBitmapImageRep !

		tifImageInfo.nScanWidth 		= [idTempBitmapImageRep pixelsWide];
		tifImageInfo.nScanHeight 		= [idTempBitmapImageRep pixelsHigh];
		tifImageInfo.nBitsPerSample 		= [idTempBitmapImageRep bitsPerSample];
		tifImageInfo.nSamplesPerPixel 	= [idTempBitmapImageRep samplesPerPixel];
		tifImageInfo.bHasAlpha 			= [idTempBitmapImageRep hasAlpha];
		tifImageInfo.bIsPlanar   			= [idTempBitmapImageRep isPlanar];
		tifImageInfo.nxColorSpace  	    	= [idTempBitmapImageRep colorSpace];
		tifImageInfo.nBytesPerRow 		= [idTempBitmapImageRep bytesPerRow];
		tifImageInfo.nBitsPerPixel  		= [idTempBitmapImageRep bitsPerPixel];

	}

	bOurImage = (tifImageInfo.nSamplesPerPixel == 3) ? YES : NO;

	/*  This step is a little bogus, but characteristics of NXBitmapImageRep Class
	     make it necessary.  Also, if the imported image happens to be CMYK (or
	     8 bit or something), it could be transformed about right here.  */

	/*  Duplicate image off into a separate image buffer, tifImageInfo.pImageData  */ 

	nSize = (tifImageInfo.nBytesPerRow * tifImageInfo.nScanHeight);
 	tifImageInfo.pImageData = NX_MALLOC (tifImageInfo.pImageData, BYTE, nSize);

  	memcpy (tifImageInfo.pImageData, [idTempBitmapImageRep data], nSize);

 	idNXBitmapImageRep = [self makeImage: tifImageInfo.pImageData];
	if (idNXBitmapImageRep == nil)
		return nil;

  	[idTempBitmapImageRep free];

	
	/*  Now set our own "attributes" up  */

	[self setPixelsWide: tifImageInfo.nScanWidth];
	[self setPixelsHigh: tifImageInfo.nScanHeight];

	aSize.width  = (NXCoord) tifImageInfo.nScanWidth;
	aSize.height = (NXCoord) tifImageInfo.nScanHeight;

	[self setSize: &aSize];
	[self setNumColors: 3];

	/*  (No NX_FREE because data is NOT copied by initData: method of NXBitmapImageRep) */ 

	return self;
}


/*  Creates  a BitmapImageRep for our use.  Note that tifImageInfo structure is persistent
    and does not need to be passed.  */

- makeImage:  (PBYTE) data
{
	id	idBitmapImageRep;

	idBitmapImageRep = [NXBitmapImageRep alloc];

	[idBitmapImageRep initData: 	data
	pixelsWide: tifImageInfo.nScanWidth
	pixelsHigh: tifImageInfo.nScanHeight
	bitsPerSample: tifImageInfo.nBitsPerSample
	samplesPerPixel: tifImageInfo.nSamplesPerPixel
	hasAlpha: tifImageInfo.bHasAlpha 
	isPlanar: tifImageInfo.bIsPlanar 
	colorSpace: tifImageInfo.nxColorSpace
	bytesPerRow: tifImageInfo.nBytesPerRow
	bitsPerPixel: tifImageInfo.nBitsPerPixel];

	return idBitmapImageRep;
}

/*  This thing copies fresh new tool-modified bits back into a new idNXBitmapImageRep instance     
     (Used for tool do/undo processing)  */ 

- resetImage: (PBYTE) data
{
	if (idNXBitmapImageRep)
		[idNXBitmapImageRep free];

	idNXBitmapImageRep = [self makeImage: data];

	return self;
}

/*  Ok.  Set the update region (selection) up in our NXImage.  Then make another image out of
     the selection data, lock focus on our image, and draw the selection image into ours at the
     the origin specified in rect.  After this, all should be working...  */

 - updateImage: (NXImage*) image: (PBYTE) data: (NXRect *) selectionRect
{
	int 	i;
	NXSize	imageSize;
	PBYTE	pDest;
	PBYTE	pDestPtr;
	PBYTE	pSource;
	PBYTE	pSourcePtr;
	int		nBytesPerRow;
	int		nSelectionBytesPerRow;


	/*  Now transfer data from the updated data to ours */

	[image getSize: &imageSize];


	nBytesPerRow = (int) imageSize.width * 3;
	nSelectionBytesPerRow = (int) selectionRect -> size.width * 3;

	pDest = [self getData];
	pDest += (int) (imageSize.height - selectionRect -> origin.y-selectionRect -> size.height) * 
				nBytesPerRow;

	pSource = data;

	for (i = 0; i < (int) selectionRect -> size.height; i++)
	{
		pSourcePtr = pSource;
		pDestPtr = pDest + (int) selectionRect -> origin.x * 3;

		memcpy (pDestPtr, pSourcePtr, nSelectionBytesPerRow);
		
		pSource += nSelectionBytesPerRow;
		pDest += nBytesPerRow;
	}

	[self resetImage:  [self getData]];

	return self;
}
 

/*  drawIn and drawAt both seem to be working  11-2-92  */

- (BOOL) drawIn: (const NXRect *) rect
{
	[idNXBitmapImageRep drawIn: rect];
	return YES;
}

- (BOOL) drawAt: (const NXPoint *) point
{
	[idNXBitmapImageRep drawAt: point];
	return YES;
}

- (BOOL) draw
{
	[idNXBitmapImageRep draw];
	return YES;
}

- free
{
	NXRunAlertPanel ("HERE",
					"Freeing up TIFImageRep ", 0, 0, 0); 

	[idNXBitmapImageRep free];


	[super free];
	return self;
}

- (int) pixelsHigh
{
	return tifImageInfo.nScanHeight;
}
 
- (int) pixelsWide
{
	return tifImageInfo.nScanWidth;
}

- (PBYTE) getData
{
	return [idNXBitmapImageRep data];
}

- getSize: (NXSize *) theSize
{
	theSize -> width 	= tifImageInfo.nScanWidth;
	theSize -> height 	= tifImageInfo.nScanHeight;
	return self;
}


- (BOOL) drawIn: (NXRect *) r  with: (float) rotation
{
	BOOL		error;

	error = NO;
	PSgsave ();
	PStranslate (r->origin.x, r->origin.y);			PSrotate (rotation);
	PSscale (currScale, currScale);

	/*  TODO:  May be faster to use drawIn: or drawAt:  */

	error = [idNXBitmapImageRep draw];
	PSgrestore();

	return error;
}


- (void) setScale: (float) factor
{
	currScale = factor;
}


/********************************************************************************
Compatibility w/NXBitmapImageRep stuff   
*********************************************************************************/

#ifdef DOCUMENT

THESE METHODS STILL NEED TO BE DONE!!!  2-22-93

Producing a TIFF representation of the image

- writeTIFF:
- writeTIFF:usingCompression:
- writeTIFF:usingCompression:andFactor:

Setting/checking compression types	

+ getTIFFCompressionTypes:count:
+ localizedNameForTIFFCompressionType:
 - canBeCompressedUsing:
 - getCompression:andFactor:
 - setCompression:andFactor:

Checking unpacked data handling	

+ setUnpackedImageDataAcceptable:
+ isUnpackedImageDataAcceptable

Archiving
- read:
- write:

#endif

- initFromSection:(const char *)name
{
	return [idNXBitmapImageRep initFromSection: name];
}

- (int) bitsPerPixel
{
	return [idNXBitmapImageRep bitsPerPixel];
}

- (int) samplesPerPixel
{
	return [idNXBitmapImageRep samplesPerPixel];
}


- (BOOL) isPlanar
{
	return [idNXBitmapImageRep isPlanar];
}

- (int) numPlanes
{
	return [idNXBitmapImageRep numPlanes];
}


- (int) bytesPerPlane
{
	return [idNXBitmapImageRep bytesPerPlane];
}

- (int) bytesPerRow
{
	return [idNXBitmapImageRep bytesPerRow];
}

- (NXColorSpace) colorSpace
{
	return [idNXBitmapImageRep colorSpace];
}



- (void *) data
{
	return [idNXBitmapImageRep data];
}


- getDataPlanes:(unsigned char **) thePlanes
{
	return  [idNXBitmapImageRep getDataPlanes: thePlanes];
}

- initData: (unsigned char *) data fromRect: (const NXRect *) rect
{
	return [idNXBitmapImageRep initData: data fromRect: rect];
}

- initData:(unsigned char *)data 
pixelsWide:(int)width 
pixelsHigh:(int)height 
bitsPerSample:(int)bps 
samplesPerPixel:(int)spp 
hasAlpha:(BOOL)alpha 
isPlanar:(BOOL)config 
colorSpace:(NXColorSpace)space 
bytesPerRow:(int)rowBytes 
bitsPerPixel:(int)pixelBits
{
	return [idNXBitmapImageRep initData: data
	pixelsWide: width 
	pixelsHigh: height 
	bitsPerSample: bps 
	samplesPerPixel: spp 
	hasAlpha: alpha 
	isPlanar: config 
	colorSpace: space 
	bytesPerRow: rowBytes 
	bitsPerPixel: pixelBits];
}

 

- initDataPlanes:(unsigned char **)planes 
pixelsWide:(int)width 
pixelsHigh:(int)height 
bitsPerSample:(int)bps 
samplesPerPixel:(int)spp 
hasAlpha:(BOOL)alpha 
isPlanar:(BOOL)config 
colorSpace:(NXColorSpace)space 
bytesPerRow:(int)rowBytes 
bitsPerPixel:(int)pixelBits
{
	return [idNXBitmapImageRep initDataPlanes: planes 
	pixelsWide: width 
	pixelsHigh: height 
	bitsPerSample: bps 
	samplesPerPixel: spp 
	hasAlpha: alpha 
	isPlanar: config 
	colorSpace: space 
	bytesPerRow: rowBytes 
	bitsPerPixel: pixelBits];
}
 
- copyFromZone:(NXZone *)zone
{
	return [idNXBitmapImageRep copyFromZone: zone];
}
 

+ (int)sizeImage:(const NXRect *)rect
{
	return [NXBitmapImageRep sizeImage: rect];
}

+ (int)sizeImage:(const NXRect *)rect 
pixelsWide:(int *)width 
pixelsHigh:(int *)height 
bitsPerSample:(int *)bps 
samplesPerPixel:(int *)spp 
hasAlpha:(BOOL *)alpha 
isPlanar:(BOOL *)config 
colorSpace:(NXColorSpace *)space
{
	return [NXBitmapImageRep sizeImage: rect 
		pixelsWide: width 
		pixelsHigh: height 
		bitsPerSample: bps 
		samplesPerPixel: spp 
		hasAlpha: alpha 
		isPlanar: config 
		colorSpace: space];
}


+ (List *)newListFromSection:(const char *)name
{
	return [NXBitmapImageRep newListFromSection: name];
}

+ (List *)newListFromSection:(const char *)name zone:(NXZone *)aZone
{
	return [NXBitmapImageRep newListFromSection: name zone: aZone];
}

+ (List *)newListFromFile:(const char *)filename
{
	return [NXBitmapImageRep newListFromFile: filename];
}




+ (List *)newListFromFile:(const char *)filename zone:(NXZone *)aZone
{
	return [NXBitmapImageRep newListFromFile: filename zone: aZone];
}

+ (List *)newListFromStream:(NXStream *)stream
{
	return [NXBitmapImageRep newListFromStream: stream];
}


+ (List *)newListFromStream:(NXStream *)stream zone:(NXZone *)aZone
{
	List *list;
	NXImageRep *idImageRep;
	
 	list = [[List allocFromZone: aZone] init];
	self = [TIFImageRep allocFromZone: aZone];
	idImageRep = [self initFromStream: stream];
	[list addObject: self];

	if (bOurImage)
		return list;
	else
	{
		[List free];
		NXSeek (stream, 0L, NX_FROMSTART);
		return [NXBitmapImageRep newListFromStream: stream zone: aZone];
	}
}
 

@end

