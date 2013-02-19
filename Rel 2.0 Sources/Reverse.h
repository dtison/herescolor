
#import "ChangeStuff.h"
#import "ImageDocument.h"
#import "HEREdefs.h"

@interface Reverse: Change
{
	id		idDocument;		// Document we are doing / undoing with...
	NXRect  	selectionRect;	// For undo/redo
	int		nPointCount;	
	NXPoint *pPoints;

}


-  initWithDocument:  (ImageDocument *) document;
- doProcess: (PBYTE) data: (NXSize *) selectionSize;
- go;

@end
