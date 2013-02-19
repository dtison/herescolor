
#import "ChangeStuff.h"
#import "ImageDocument.h"
#import "HEREdefs.h"

@interface Flip: Change
{
	id		idDocument;		// Document we are doing / undoing with...
	PBYTE	pUndoData;		// Points to original copy
	PBYTE	pRedoData;		// Points to processed copy

}

/* Methods called directly by your code */

-  initWithDocument:  (ImageDocument *) document;
- doProcess: (PBYTE) data: (NXSize *) size;
- go;

@end
