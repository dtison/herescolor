#import <appkit/appkit.h>
#import "AppDefs.h"
#import "/LocalLibrary/HERELibrary/Include/HEREutils.h"
#import "HEREpsw.h"
#import "ImageDocument.h"

@interface ImageView: View
{
	id		idImage;			// NXImage instance corresponding to image
	id		idRGBImage;		// Our NXImageRep subclass for RGB representation
	id		idCMYKImage;		// Our NXImageRep subclass for CMYK representation
	float		fCurrZoomFactor;	// When it's 1.0, images scroll faster (uses different process)
}

- setImage: (id) anImage withRGBImage: (id) anRGBImage;
- resetImage: (PBYTE) data;		
 - updateImage: (NXImage*) image: (PBYTE) data: (NXRect *) selectionRect;

- setScale: (float) factor usingZoomLevel: (float) zoomLevel; 
- drawSelf: (const NXRect *) rects: (int) rectCount;
- free;

- initFrame: (const NXRect *) frameRect;

-  rgbImage;


@end
