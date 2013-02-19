#import "Brighten.h"
#import "HEREutils.h"
#import "Prometer.h"
#import "MarquisView.h"		// Future TODO:  When generalize marquis' make abstract

@implementation Brighten


/*  Sets up the processing / undo / redo stuff  */

-  initWithDocument:  (ImageDocument *) document
{
	[super init];
	idDocument = document;
	nPointCount = 0;
	pPoints = NULL;
	pUndoData = NULL;
	return self;
}

/*  Somebody think of a better naming convention (that doesn't conflict with the AppKit
     or objective C runtime system) */ 

- go 
{
	NXSize	imageSize;
	PBYTE	pImageData;
	PBYTE	pSelectionData;
	id		idSelection;

	[idDocument getImageSize: &imageSize];
	pImageData = [idDocument getImageData];

	idSelection = [idDocument getCurrentSelection];
	[idSelection getBoundingBox: &selectionRect];
	pPoints = [idSelection getSelectionPoints: &nPointCount];      // Error handling

	pSelectionData = copySelection (pImageData, &imageSize, &selectionRect);
	pUndoData = copySelection (pImageData, &imageSize, &selectionRect);

	[self doProcess: pSelectionData: &selectionRect.size];
	[idDocument updateImageData: pSelectionData: pPoints: nPointCount: &selectionRect];

	NX_FREE (pSelectionData);

 	return self;
}

 
- undoChange
{
	[idDocument updateImageData: pUndoData: pPoints: nPointCount: &selectionRect];
	return self;
}

- redoChange
{
	NXSize	imageSize;
	PBYTE	pImageData;
	PBYTE	pSelectionData;

	[idDocument getImageSize: &imageSize];
	pImageData = [idDocument getImageData];
	pSelectionData = copySelection (pImageData, &imageSize, &selectionRect);
	[self doProcess: pSelectionData: &selectionRect.size];
	[idDocument updateImageData: pSelectionData: pPoints: nPointCount: &selectionRect];
	NX_FREE (pSelectionData);
	return self;
}

- (const char *) changeName
{
	return "Bogus Brighten";
}


- doProcess: (PBYTE) data: (NXSize *) selectionSize
{
	int	i, j;
	PBYTE	pDataPtr = data;
	id		idPrometer;

	idPrometer = [[NXApp delegate] proMeter];
	[idPrometer start: NO];
	[idPrometer setTitle: "Bogus Brightening..."];	

	for (i = 0; i < (int) selectionSize -> height; i++)
	{
		for (j = 0; j < (int) selectionSize -> width; j++)
		{
			*pDataPtr++ += 20;
			*pDataPtr++ +=  20;
			*pDataPtr++ += 20;
		}
		if ((i % 32) == 0) 
 			[idPrometer setPercent: ((float) (i + 31) / selectionSize -> height)];

	}

	[idPrometer hide];

	return self;
}

- free
{
	#if 0
	if (pUndoData)
		NX_FREE (pUndoData);
	if (pPoints)
		NX_FREE (pPoints);
	#endif

	[super free];
	return self;
}

@end
