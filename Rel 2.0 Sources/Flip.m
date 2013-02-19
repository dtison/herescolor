#import "Flip.h"
#import "HEREutils.h"
#import "Prometer.h"


@implementation Flip


/*  Sets up the processing / undo / redo stuff  */

-  initWithDocument:  (ImageDocument *) document
{
	[super init];
	idDocument = document;
	return self;
}

/*  Somebody think of a better naming convention (that doesn't conflict with the AppKit
     or objective C runtime system) */ 

- go
{
	NXSize	imageSize;
	PBYTE	pImageData;

	/*   Because we have a self-reversible process, we can simply call our processor (with
	      possible optional parameters  (no further undo preparation necessary)  */

	[idDocument getImageSize: &imageSize];
	pImageData = [idDocument getImageData];
	[self doProcess: pImageData: &imageSize];
	[idDocument setImageData: pImageData];

	return self;

}

- undoChange
{
	NXSize	imageSize;
	PBYTE	pImageData;

 	[idDocument getImageSize: &imageSize];
	pImageData = [idDocument getImageData];
	[self doProcess: pImageData: &imageSize];
	[idDocument setImageData: pImageData];
	
	return self;
}

- redoChange
{
	NXSize	imageSize;
	PBYTE	pImageData;

 	[idDocument getImageSize: &imageSize];
	pImageData = [idDocument getImageData];
	[self doProcess: pImageData: &imageSize];
	[idDocument setImageData: pImageData];
	
	return self;
}

- (const char *) changeName
{
	return "Flip";		// This needs to match the menu
}


- doProcess: (PBYTE) data: (NXSize *) size 
{
	int	i;
	PBYTE	pDataPtr = data;
	PBYTE	pTempData;
	PBYTE	pTopPtr;
	PBYTE	pBottomPtr;
	int		nBytesPerRow;
	int		nScanWidth = (int) size -> width;	
	int		nScanHeight = (int) size -> height;	
	id		idPrometer;

	nBytesPerRow = nScanWidth * 3;	// Don't you like it this simple?

	NX_MALLOC (pTempData, BYTE, nBytesPerRow);
	if (! pTempData)
		return self;		// Error Handling  (out of memory? really?)

	pTopPtr 		= pDataPtr;
	pBottomPtr 	= pDataPtr + ((nScanHeight - 1) * nBytesPerRow);

	idPrometer = [[NXApp delegate] proMeter];
	[idPrometer start: NO];
	[idPrometer setTitle: "Flipping..."];	

	for (i = 0; i < (nScanHeight >> 1); i++)
	{
		memcpy (pTempData, pBottomPtr, nBytesPerRow);
		memcpy (pBottomPtr, pTopPtr, nBytesPerRow);
		memcpy (pTopPtr, pTempData, nBytesPerRow);

		pTopPtr += nBytesPerRow;
		pBottomPtr -= nBytesPerRow;

		if ((i % 32) == 0) 
 			[idPrometer setPercent: ((float) (i + 31) / (size -> height / 2))];

	}
	[idPrometer hide];
	
	NX_FREE (pTempData);
	return self;
}





@end