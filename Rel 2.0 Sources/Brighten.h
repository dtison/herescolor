
#import "ChangeStuff.h"
#import "HEREdefs.h"
#import "ImageDocument.h"

@interface Brighten: Change
{
	id		idDocument;		// Document we are doing / undoing with...
	NXRect  	selectionRect;		// For undo/redo
	int		nPointCount;	
	NXPoint *pPoints;
	PBYTE	pUndoData;		// Points to original copy
}

/* Methods called directly by your code */

-  initWithDocument:  (ImageDocument *) document;
- doProcess: (PBYTE) data: (NXSize *) selectionSize;
- go;

@end
