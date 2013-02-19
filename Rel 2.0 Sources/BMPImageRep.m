#import <appkit/appkit.h>
#import "BMPImageRep.h"
#import "Windefs.h"

 
@implementation BMPImageRep

+ (const char * const *) imageUnfilteredFileTypes
{
	static const char *const types [] = {"bmp", NULL};
	return types;
}

+ (const NXAtom *) imageUnfilteredPasteboardTypes
{
	NXLogError ("bmp imageUnfilterPasteboardTypes");
	return [super imageUnfilteredPasteboardTypes];
}

+ (BOOL) canLoadFromStream: (NXStream *) aStream
{
	BOOL		Return;

	Return = TestWNDIB (aStream);
	#ifdef NOTYET
	if (! Return)
       		Return = TestPMDIB (aStream);
	#endif	

	if (Return)
		NXLogError ("Test bmp canLoadFromStream:  return TRUE");
	else
		NXLogError ("Test bmp canLoadFromStream: return FALSE");
		
	return Return;
}

BOOL TestWNDIB (NXStream *stream)
{
	BITMAPFILEHEADER  	BitmapFileHeader;    

      
	/*  Verify DIB file by reading BITMAPFILEHEADER and checking 1st WORD
        field for 'BM' signature      */

	NXSeek (stream, 0L, NX_FROMSTART);   
  
	if (NXRead (stream, &BitmapFileHeader, 
	sizeof (BITMAPFILEHEADER)) != sizeof (BITMAPFILEHEADER))
		return FALSE;
 
	if (BitmapFileHeader.bfType != 0x4D42)
  	      return FALSE;


	return TRUE;
}




#ifdef NOTYET  // STILL A TODO...
BOOL NEAR TestPMDIB (int hFile, LPSTR lpBuffer)
{
    LPBITMAPFILEHEADER  lpBitmapFileHeader;    
    LPBITMAPCOREHEADER  lpBitmapCoreHeader;

    /*  Verify DIB file by checking 1st WORD field for 'BM' signature */

    lpBitmapFileHeader = (LPBITMAPFILEHEADER)lpBuffer;

    if (SeekFile (hFile, 0L, 0) != 0)
        return (FALSE);

    if (ReadFile (hFile, (LPSTR) lpBitmapFileHeader, sizeof (BITMAPFILEHEADER)) != sizeof (BITMAPFILEHEADER))
        return (FALSE);

    if (lpBitmapFileHeader->bfType != 0x4D42)
        return (FALSE);

    lpBitmapCoreHeader = (LPBITMAPCOREHEADER)lpBuffer;
    if (ReadFile (hFile, (LPSTR) lpBitmapCoreHeader, sizeof (BITMAPCOREHEADER)) != sizeof (BITMAPCOREHEADER))
        return (FALSE);
    else
        return (lpBitmapCoreHeader -> bcSize == sizeof (BITMAPCOREHEADER) ? TRUE : FALSE);
}
#endif

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
	NXSize		aSize;	// "aSize" because of conflict w/instance vari

	[super init];

	if (BMPImportImage (stream, &bmpImageInfo) != 0)
		return self; // NEED DISCARDRESOURCE!

	#ifdef FUDGEGAMMA
	/*  Let's play "fudge the data"  */
	{
		int i, j;
		PBYTE	pSource = bmpImageInfo.pImageData;
		float		red, green, blue;

		for (i = 0; i < bmpImageInfo.nScanHeight; i++)
		{
			for (j = 0; j < bmpImageInfo.nScanWidth; j++)
			{
				red 		= (float) pSource [0];
				green 	= (float) pSource [1];
				blue 		= (float) pSource [2];

				red 		/= 255;
				green	/= 255;
				blue 		/= 255;

				red 		= pow (red, 0.45);
				green 	= pow (green, 0.45);
				blue 		= pow (blue, 0.45);
				
				red 		= (red * 255) + 0.05;
				green 	= (green * 255) + 0.05;
				blue 		= (blue * 255) + 0.05;

				*pSource++ = (BYTE) red;
				*pSource++ = (BYTE) green;
				*pSource++ = (BYTE) blue;

			}
		}
	}
	#endif
	
//	#define GRAYTEST
	#ifdef GRAYTEST

	/*  Let's play "set the data to 50% and see what happens"  */
	{
		int i, j;
		PBYTE	pSource = bmpImageInfo.pImageData;
		float		red, green, blue;

		for (i = 0; i < bmpImageInfo.nScanHeight; i++)
		{
			memset (pSource, 128, (bmpImageInfo.nScanWidth * 3));
			pSource += (bmpImageInfo.nScanWidth * 3);
		}
	}
	#endif

	idNXBitmapImageRep = [self makeImage: bmpImageInfo.pImageData];
	if (idNXBitmapImageRep == nil)
		return nil;

	
	/*  Now set our own "attributes" up  */

	[self setPixelsWide: bmpImageInfo.nScanWidth];
	[self setPixelsHigh: bmpImageInfo.nScanHeight];

	aSize.width  = (NXCoord) bmpImageInfo.nScanWidth;
	aSize.height = (NXCoord) bmpImageInfo.nScanHeight;

	[self setSize: &aSize];
	[self setNumColors: 3];

	/*  (No NX_FREE because data is NOT copied by initData: method of NXBitmapImageRep) */ 

	return self;
}


/*  Creates  a BitmapImageRep for our use.  Note that bmpImageInfo structure is persistent
    and does not need to be passed.  */

- makeImage:  (PBYTE) data
{
	id	idBitmapImageRep;

	idBitmapImageRep = [NXBitmapImageRep alloc];

	[idBitmapImageRep initData: 	data
	pixelsWide: bmpImageInfo.nScanWidth
	pixelsHigh: bmpImageInfo.nScanHeight
	bitsPerSample: bmpImageInfo.nBitsPerSample
	samplesPerPixel: bmpImageInfo.nSamplesPerPixel
	hasAlpha: bmpImageInfo.bHasAlpha 
	isPlanar: bmpImageInfo.bIsPlanar 
	colorSpace: bmpImageInfo.nxColorSpace
	bytesPerRow: bmpImageInfo.nBytesPerRow
	bitsPerPixel: bmpImageInfo.nBitsPerPixel];

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
	pDest += (int) (imageSize.height - selectionRect -> origin.y-selectionRect -> size.height) * nBytesPerRow;
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
					"Freeing up BMPImageRep ", 0, 0, 0); 

	[idNXBitmapImageRep free];


	[super free];
	return self;
}

- (int) pixelsHigh
{
	return bmpImageInfo.nScanHeight;
}
 
- (int) pixelsWide
{
	return bmpImageInfo.nScanWidth;
}

- (PBYTE) getData
{
	return [idNXBitmapImageRep data];
}

- getSize: (NXSize *) theSize
{
	theSize -> width 	= bmpImageInfo.nScanWidth;
	theSize -> height 	= bmpImageInfo.nScanHeight;
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


@end

