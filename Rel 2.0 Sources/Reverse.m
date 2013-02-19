
#import "Reverse.h"
#import "HEREutils.h"
#import "Prometer.h"
#import "MarquisView.h"		// Future TODO:  When generalize marquis' make abstract
							// superclass include file


#import "CmsLib.h"


@implementation Reverse

/*  Sets up the change object and prepares for undo / redo stuff  */

-  initWithDocument:  (ImageDocument *) document
{
	[super init];
	idDocument = document;
	nPointCount = 0;
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

	/*   Because we have a self-reversible process, we can simply call our processor (with
	      possible optional parameters  (no further undo preparation necessary)  */


	[idDocument getImageSize: &imageSize];
	pImageData = [idDocument getImageData];

	idSelection = [idDocument getCurrentSelection];
	[idSelection getBoundingBox: &selectionRect];
	pPoints = [idSelection getSelectionPoints: &nPointCount];      // Error handling
	pSelectionData = copySelection (pImageData, &imageSize, &selectionRect);
	[self doProcess: pSelectionData:  &selectionRect.size];
	[idDocument updateImageData: pSelectionData: pPoints: nPointCount: &selectionRect];
	NX_FREE (pSelectionData);

	return self;

}

- undoChange
{
	NXSize	imageSize;
	PBYTE	pImageData;
	PBYTE	pSelectionData;

 	[idDocument getImageSize: &imageSize];
	pImageData = [idDocument getImageData];
	pSelectionData = copySelection (pImageData, &imageSize, &selectionRect);
	[self doProcess: pSelectionData:  &selectionRect.size];
	[idDocument updateImageData: pSelectionData: pPoints: nPointCount: &selectionRect];
	NX_FREE (pSelectionData);
	
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
	[self doProcess: pSelectionData:  &selectionRect.size];
	[idDocument updateImageData: pSelectionData: pPoints: nPointCount: &selectionRect];
	NX_FREE (pSelectionData);
	
	return self;
}

- (const char *) changeName
{
	return "Reverse";		// This needs to match the menu
}

- doProcess: (PBYTE) data: (NXSize *) selectionSize
{
	int		i, j;
	int		nSelectionWidth, nSelectionHeight;
	PBYTE	pDataPtr = data;
	id		idPrometer;

	nSelectionWidth = (int) selectionSize -> width;	nSelectionHeight = (int) selectionSize -> height;

	idPrometer = [[NXApp delegate] proMeter];
	[idPrometer start: NO];
	[idPrometer setTitle: "Reversing..."];

	#ifdef NEVERNEVER
	for (i = 0; i < nSelectionHeight; i++)
	{
		for (j = 0; j < nSelectionWidth; j++)
		{
			#if 1
			*pDataPtr++ = (255 - *pDataPtr);
			*pDataPtr++ = (255 - *pDataPtr);
			*pDataPtr++ = (255 - *pDataPtr);
			#else
			*pDataPtr++ = 0;
			*pDataPtr++ = 0;
			*pDataPtr++ = 0;
			#endif

		}

 		if ((i % 32) == 0) 
 			[idPrometer setPercent: ((float) (i + 31) / (float) nSelectionHeight)];
	}
	#endif

	{
		BYTE	black;
		float 	red, green, blue;
		ColorV 	sourceV, destV;
		int	status;

 		status = CiLinkRead ("/me/RcHn.link");
		if (status != 0)
		{
			HEREAlert ("Problem reading link");
			return self;
		}	 

	for (i = 0; i < nSelectionHeight; i++)
	{
		for (j = 0; j < nSelectionWidth; j++)
		{


			sourceV [0] = ((float) pDataPtr [0] / 255);
			sourceV [1] = ((float) pDataPtr [1] / 255);
			sourceV [2] = ((float) pDataPtr [2] / 255);
					
 
			status = CiLinkColor (sourceV, destV, CI_DIR_FORWARD);
			if (status != 0)
			{
				HEREAlert ("Problem linking color");
				return self;
			}

 
				

 			#define TESTRANGE
			#ifdef TESTRANGE
			if (destV [0] > 1 || destV [1] > 1 || destV [3] > 1)
			{
				pDataPtr [0] = 255;
				pDataPtr [1] = 0;
				pDataPtr [2] = 255;
				//HEREAlert ("Found one >");
				//return self;
			}
			else
				if (destV [0] < 0 || destV [1] < 0 || destV [3] < 0)
				{
					pDataPtr [0] = 255;
					pDataPtr [1] = 0;
					pDataPtr [2] = 255;
				//HEREAlert ("Found one <");
				//return self;
				}

			#else
			
			pDataPtr [0] = (BYTE) ((destV [0] * 255) + 0.05);
			pDataPtr [1] = (BYTE) ((destV [1] * 255) + 0.05);
			pDataPtr [2] = (BYTE) ((destV [2] * 255) + 0.05);

			#endif

			pDataPtr += 3;
		}

 		if ((i % 32) == 0) 
 			[idPrometer setPercent: ((float) (i + 31) / (float) nSelectionHeight)];
	}
 
	CiLinkClose ();

	}


	[idPrometer hide];

	return self;
}





@end
