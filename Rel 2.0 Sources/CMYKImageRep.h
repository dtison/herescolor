#import <appkit/appkit.h>
#import "HEREdefs.h"

/*  Structures, typedefs, defines etc. for this class  */

typedef struct
{
	PBYTE		pImageData;
	int			nScanWidth;
	int			nScanHeight;
	int			nBitsPerSample;
	int			nSamplesPerPixel;
	BOOL		bHasAlpha; 
	BOOL		bIsPlanar;
	NXColorSpace nxColorSpace; 
    	int 			nBytesPerRow; 
	int			nBitsPerPixel;
}	CMYKImageInfo;



 
@interface CMYKImageRep: NXImageRep
{
	CMYKImageInfo	cmykImageInfo;
	id				idNXBitmapImageRep;		// Bitmap img for re-use		
}

+ (const char *const *) imageUnfilteredFileTypes;
+ (BOOL) canLoadFromStream: (NXStream *) aStream;
- (BOOL) drawIn: (const NXRect *) rect;
- (BOOL) drawAt: (const NXPoint *) point;
- getSize: (NXSize *) theSize;


- initFromBitmapImage: (NXBitmapImageRep *) bitmapImage;
- (PBYTE) getData;


/*  Support C functions for this class.  
	(May be found in other source files)		*/




@end
