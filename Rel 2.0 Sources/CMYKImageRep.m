#import <appkit/appkit.h>
#import "CMYKImageRep.h"
#import "HEREutils.h"
#import "HEREdefs.h"
#import "Controller.h"

// TODO's:  (1) Find out if the idNXBitmapImageRep instance we create
//				requires the bitmap data, or does it copy that data? 

@implementation CMYKImageRep

+ (const char * const *) imageUnfilteredFileTypes
{
	static const char *const types[2] = {"cmyk", NULL};
	return types;
}


+ (BOOL) canLoadFromStream: (NXStream *) aStream
{
	return YES;
}

 
- initFromBitmapImage: (NXBitmapImageRep *) bitmapImage
{
	PBYTE	pSourceData;
	PBYTE	pDestData;

	int		nScanWidth;
	int		nScanHeight;
	int		nCMYKBytesPerRow;
	int		nDestImageSize;

	
	/*  First get the data from the source image  */

	pSourceData = [bitmapImage getData];

	nScanWidth  = [bitmapImage pixelsWide];
	nScanHeight = [bitmapImage pixelsHigh];

	nCMYKBytesPerRow = (nScanWidth << 2);	// Multiply by 4
	nDestImageSize	 = (nScanHeight * nCMYKBytesPerRow);

	pDestData = NX_MALLOC (pDestData, BYTE, nDestImageSize);
	if (! pDestData)	// ERROR HANDLING
		return self;

	RGBToCMYK (pDestData, pSourceData, nScanWidth, nScanHeight, 
	(char *) [[NXApp delegate] currentCircuit]);

	idNXBitmapImageRep = [NXBitmapImageRep alloc];
	[idNXBitmapImageRep initData: 	pDestData
	pixelsWide: nScanWidth
	pixelsHigh: nScanHeight
	bitsPerSample: 8
	samplesPerPixel: 4
	hasAlpha: NO  
	isPlanar: NO 
	colorSpace: NX_CMYKColorSpace
	bytesPerRow: nCMYKBytesPerRow
	bitsPerPixel: 32];

	#if 0
	{
		NXSize size;

		[self setPixelsWide: nScanWidth];
		[self setPixelsHigh: nScanHeight];
	
		size.width = (NXCoord) nScanWidth;
		size.height = (NXCoord) nScanHeight;

		[self setSize: &size];
		[self setBitsPerSample: 8];
		[self setNumColors: 4];
	}
	#endif

	cmykImageInfo.nScanWidth = nScanWidth;
	cmykImageInfo.nScanHeight = nScanHeight;

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
					"Bye Bye CMYK image! ", 0, 0, 0); 

	if (idNXBitmapImageRep) 
		[idNXBitmapImageRep free];

	[super free];
	return self;
}

- getSize: (NXSize *) theSize
{

	theSize -> width 	= cmykImageInfo.nScanWidth;
	theSize -> height 	= cmykImageInfo.nScanHeight;
	return self;
}

- (PBYTE) getData
{
	return cmykImageInfo.pImageData;
}

- (int) numColors
{
	return 4;
}

- (BOOL) hasAlpha
{
	return FALSE;
}

- (int) pixelsHigh
{
	return cmykImageInfo.nScanHeight;
}

- (int) pixelsWide
{
	return cmykImageInfo.nScanWidth;
}

- (int) bitsPerSample
{
	return 8;
}

- (BOOL) isOpaque
{
	return YES;
}
@end

