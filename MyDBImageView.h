
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
	BOOL				draggedImageWasTiff;
	NXSize				draggedImageSize;               // Records actual size of dragged im.
	NXSize				viewImageSize;                    //  Size of above scaled to fit view.
}

- (NXBitmapImageRep *) bitmapImage;
- setCreateBitmaps: (BOOL) flag;
- (NXBitmapImageRep *) draggedBitmapImage;
- (NXImage *) draggedImage;

- getDraggedImageSize: (NXSize *) size;
- getViewImageSize: (NXSize *) size;


@end
