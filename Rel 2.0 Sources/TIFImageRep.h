
#import <appkit/appkit.h>
#import "/LocalLibrary/Include/HEREutils.h"

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
}	TIFImageInfo;


 
@interface TIFImageRep: NXImageRep
{
	TIFImageInfo			tifImageInfo;
	NXBitmapImageRep 	*idNXBitmapImageRep;
	float					currScale;		// Current scale factor this image
	BOOL		bOurImage;		// We need to own this image

}

- initFromStream: (NXStream *) stream;

- (PBYTE) getData;
- makeImage:  (PBYTE) data;
- resetImage: (PBYTE) data;
 - updateImage: (NXImage*) image: (PBYTE) data: (NXRect *) selectionRect;


// This is a TEST...
- (BOOL) drawIn: (NXRect *) r  with: (float) rotation;
- (void) setScale: (float) factor;


@end
