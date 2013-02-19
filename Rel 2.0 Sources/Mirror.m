#import "Mirror.h"
#import "HEREutils.h"
#import "Prometer.h"

@implementation Mirror


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
	int		Return = 0;
	int		nSize;
	NXSize	imageSize;
	PBYTE	pImageData;
	
	if (! olSetupPanel)
   		[NXApp loadNibSection: "Changes.nib" owner: self withNames:NO];

	[olSetupPanel orderFront: self];
	Return =  [NXApp runModalFor: olSetupPanel];
	[olSetupPanel orderOut: self];
	
	if (! Return)
		return self;

 	[idDocument getImageSize: &imageSize];
	pUndoData = [idDocument getImageData];

	nSize = (int) imageSize.width * (int) imageSize.height * 3;

	pImageData  = NX_MALLOC (pImageData, BYTE, nSize);
	memcpy (pImageData, pUndoData, nSize);
	pRedoData    = pImageData;

	[self doProcess: pImageData: &imageSize];

	[idDocument setImageData: pImageData];

 	return self;
}

- cancel: sender;
{
	[NXApp stopModal];
	return self;
}

- apply: sender;
{
	[NXApp stopModal];
	return self;
}

- undoChange
{
	[idDocument setImageData: pUndoData];
	return self;
}

- redoChange
{
	[idDocument setImageData: pRedoData];
	return self;
}

- (const char *) changeName
{
//	return "Mirror";
	return "Tool X";

}



- doProcess: (PBYTE) data: (NXSize *) size 
{
	int	i, j;
	PBYTE	pDataPtr = data;
	WORD	Red, Grn, Blu;
	id		idPrometer;
	int		nInterval;	

	idPrometer = [[NXApp delegate] proMeter];
	[idPrometer start: NO];
	[idPrometer setTitle: "Tool X..."];

	nInterval = (int) size -> height / 5;

	for (i = 0; i < (int) size -> height; i++)
		for (j = 0; j < (int) size -> width; j++)
		{
			Red  = (WORD) pDataPtr[0];
			Grn 	= (WORD) pDataPtr[1];
			Blu  = (WORD) pDataPtr[2];

			if (Red > 192)
			{
				Red += 25; 
				if (Red > 255)
					Red = 255;
			}

			if (Grn > 192)
			{
				Grn += 25; 
				if (Grn > 255)
					Grn = 255;
			}

			if (Grn > 192)
			{
				Grn += 25; 
				if (Grn > 255)
					Grn = 255;
			}

			*pDataPtr++ = Red;
			*pDataPtr++ =  Grn;
			*pDataPtr++ = Blu;

			if ((i % nInterval) == 0) 
 				[idPrometer setPercent: ((float) (i + (nInterval - 1)) / size -> height)];

		}

	[idPrometer hide];

	return self;
}

@end
