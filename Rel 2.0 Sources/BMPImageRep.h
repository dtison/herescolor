
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
}	BMPImageInfo;


#define WIDTHBYTES(i)    ((((i) + 31) / 32) * 4)
#define WNDIB           1             /* Windows 3.0 DIB        */
#define PMDIB           2             /* PM DIB                 */

 
@interface BMPImageRep: NXImageRep
{
	BMPImageInfo			bmpImageInfo;
	NXBitmapImageRep 	*idNXBitmapImageRep;
	float					currScale;		// Current scale factor this image
		
}

- initFromStream: (NXStream *) stream;

- (PBYTE) getData;
- makeImage:  (PBYTE) data;
- resetImage: (PBYTE) data;
 - updateImage: (NXImage*) image: (PBYTE) data: (NXRect *) selectionRect;


// This is a TEST...
- (BOOL) drawIn: (NXRect *) r  with: (float) rotation;
- (void) setScale: (float) factor;


/*  Support C functions for this class.  
	(May be found in other source files)		*/

BOOL TestWNDIB (NXStream *stream);

// BMPImportImage.c:

int	BMPImportImage (NXStream * stream, BMPImageInfo *pBMPImageInfo);

// ByteOrder.c:

WORD ByteOrderWord (WORD wValue, BOOL bReverse);
LONGWORD ByteOrderLong (LONGWORD *dwValue, BOOL bReverse);


@end
