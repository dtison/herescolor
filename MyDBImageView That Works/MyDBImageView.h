
#import <appkit/appkit.h>
#import "AppDefs.h"
#import <dbkit/DBImageView.h>
#import "/LocalLibrary/HERELibrary/Include/HEREutils.h"

@interface MyDBImageView: DBImageView
{
	id					olOtherImage;
	NXBitmapImageRep		*bitmapImage;
	NXImage				*draggedImage;
	NXBitmapImageRep		*draggedBitmapImage;         // Bitmap rep of dragged image
	BOOL				createBitmaps;
}

- (NXBitmapImageRep *) bitmapImage;
- setCreateBitmaps: (BOOL) flag;
- (NXBitmapImageRep *) draggedBitmapImage;
- (NXImage *) draggedImage;

NXBitmapImageRep *epsToBitmap (NXImage *epsImage, NXSize *size);


@end
