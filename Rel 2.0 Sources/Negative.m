#import "Negative.h"
#import "HEREutils.h"
#import "Prometer.h"

void SharpenLine 	      (PBYTE pDest, 
					PBYTE pPrev,
					PBYTE pCurr, 
					PBYTE pNext, 
					int nScanWidth, 
					int nBytesPerPixel, 
					int nBytesPerRow, 
					void *p);


@implementation Negative


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
//	return "Negative";
	return "Tool Y";
}

#ifdef BOGUS
- doProcess: (PBYTE) data: (NXSize *) size 
{
	int	i, j;
	PBYTE	pDataPtr = data;
	id		idPrometer;
	WORD	Red, Grn, Blu;

	idPrometer = [[NXApp delegate] proMeter];
	[idPrometer start: NO];
	[idPrometer setTitle: "Tool Y..."];

	for (i = 0; i < (int) size -> height; i++)
		for (j = 0; j < (int) size -> width; j++)
		{
			Red  = (WORD) pDataPtr[0];
			Grn 	= (WORD) pDataPtr[1];
			Blu  = (WORD) pDataPtr[2];

			if (Red < 64)
			{
				Red += 25; 
				if (Red > 255)
					Red = 255;
			}

			if (Grn < 64)
			{
				Grn += 25; 
				if (Grn > 255)
					Grn = 255;
			}

			if (Grn < 64)
			{
				Grn += 25; 
				if (Grn > 255)
					Grn = 255;
			}

			*pDataPtr++ = Red;
			*pDataPtr++ =  Grn;
			*pDataPtr++ = Blu;

			if ((i % 32) == 0) 
 				[idPrometer setPercent: ((float) (i + 31) / size -> height)];

		}

	[idPrometer hide];

	return self;
}
#endif

/*  We throw unsharp mask into Negative tool temporarily, calling it "Tool Y"  */

- doProcess: (PBYTE) data: (NXSize *) size 
{
	int		i, j;
	PBYTE	pData = data;
	PBYTE	pTemp1;
	PBYTE	pTemp2;

	PBYTE	pCurr;
	PBYTE	pPrev;
	PBYTE	pNext;

	PBYTE	pDest;
	int		nBytesPerRow;
	int		nScanWidth = (int) size -> width;	
	int		nScanHeight = (int) size -> height;	
	id		idPrometer;

	nBytesPerRow = nScanWidth * 3;	// Don't you like it this simple?

	NX_MALLOC (pCurr, BYTE, nBytesPerRow);
	if (! pCurr)
		return self;		// Error Handling  (out of memory? really?)

	NX_MALLOC (pPrev, BYTE, nBytesPerRow);
	if (! pPrev)
		return self;		// Error Handling  (out of memory? really?)

	NX_MALLOC (pNext, BYTE, nBytesPerRow);
	if (! pNext)
		return self;		// Error Handling

	NX_MALLOC (pDest, BYTE, nBytesPerRow);
	if (! pDest)
		return self;		

	memcpy (pPrev, pData, nBytesPerRow);
	pData += nBytesPerRow;
	memcpy (pCurr, pData, nBytesPerRow);
	pData += nBytesPerRow;
	memcpy (pNext, pData, nBytesPerRow);


     	for (i = 1; i < nScanHeight; i++)
    	{
   	    	SharpenLine (pDest, pPrev, pCurr, pNext, nScanWidth, 3, nBytesPerRow, NULL);

 		memcpy (pData, pDest, nBytesPerRow);
        
       	 	memcpy (pPrev, pCurr, nBytesPerRow);
		memcpy (pCurr, pNext, nBytesPerRow);

		pData += nBytesPerRow;

   		memcpy (pNext, pData, nBytesPerRow);
    
    }

    /*  Take care of writing last line  */

	return self;
}


void SharpenLine (PBYTE pDest, 
					PBYTE pPrev,
					PBYTE pCurr, 
					PBYTE pNext, 
					int nScanWidth, 
					int nBytesPerPixel, 
					int nBytesPerRow, 
					void *p)
{
    WORD i;
    int nRedVal;
    int nGrnVal;
    int nBluVal;
    int nTmp;
    int nSharpness;

    PBYTE  pPrevPtr = pPrev;
    PBYTE  pCurrPtr = pCurr;
    PBYTE  pNextPtr = pNext;

//  nSharpness = (pSharp -> Level / 10) + 1;

	nSharpness = 5;

    if (1)	
    {

        /*  Unsharp Mask.  Create a blur window, find difference, exaggerate and 
            add back    */

        for (i = 0; i < nScanWidth; i++)
        {
            nRedVal = (BYTE) *pCurrPtr;
            
            /*  Gen an average for the 8 surrounding pixels  */
            
            if (i > 0)
            {
                nTmp    = ((BYTE)*(pCurrPtr - nBytesPerPixel) + (BYTE)*(pCurrPtr + nBytesPerPixel));
                nTmp   += ((BYTE)*(pPrevPtr - nBytesPerPixel) + (BYTE)*pPrevPtr  + (BYTE)*(pPrevPtr + nBytesPerPixel));
                nTmp   += ((BYTE)*(pNextPtr - nBytesPerPixel) + (BYTE)*pNextPtr  + (BYTE)*(pNextPtr + nBytesPerPixel));
            }
            else
            {
                nTmp    = ((BYTE)*(pCurrPtr    ) + (BYTE)*(pCurrPtr + nBytesPerPixel));
                nTmp   += ((BYTE)*(pPrevPtr    ) + (BYTE)*pPrevPtr  + (BYTE)*(pPrevPtr + nBytesPerPixel));
                nTmp   += ((BYTE)*(pNextPtr    ) + (BYTE)*pNextPtr  + (BYTE)*(pNextPtr + nBytesPerPixel));
            }
            nTmp   >>= 3;
            
            nTmp   = (nRedVal - nTmp);
            if (nTmp < 0)
                nTmp -= nSharpness;
            else
                nTmp += nSharpness;
            
            nRedVal += nTmp;
            
            if (nRedVal < 0)
                nRedVal = 0;
            
            if (nRedVal > 255)
                nRedVal = 255;
            
            *pDest++ = (BYTE) nRedVal;
            
            pCurrPtr++;
            pPrevPtr++;
            pNextPtr++;
            
            if (nBytesPerPixel == 1)
                continue;
            
            nGrnVal = (BYTE) *pCurrPtr;
            if (i > 0)
            {
                nTmp    = ((BYTE)*(pCurrPtr - 3) + (BYTE)*(pCurrPtr + 3));
                nTmp   += ((BYTE)*(pPrevPtr - 3) + (BYTE)*pPrevPtr  + (BYTE)*(pPrevPtr + 3));
                nTmp   += ((BYTE)*(pNextPtr - 3) + (BYTE)*pNextPtr  + (BYTE)*(pNextPtr + 3));
            }
            else
            {
                nTmp    = ((BYTE)*(pCurrPtr    ) + (BYTE)*(pCurrPtr + 3));
                nTmp   += ((BYTE)*(pPrevPtr    ) + (BYTE)*pPrevPtr  + (BYTE)*(pPrevPtr + 3));
                nTmp   += ((BYTE)*(pNextPtr    ) + (BYTE)*pNextPtr  + (BYTE)*(pNextPtr + 3));
            }
            nTmp   >>= 3;
            
            nTmp   = (nGrnVal - nTmp);
            if (nTmp < 0)
                nTmp -= nSharpness;
            else
                nTmp += nSharpness;
            
            nGrnVal += nTmp;
            
            if (nGrnVal < 0)
                nGrnVal = 0;
            
            if (nGrnVal > 255)
                nGrnVal = 255;
            
            *pDest++ = (BYTE) nGrnVal;
            
            pCurrPtr++;
            pPrevPtr++;
            pNextPtr++;
            
            nBluVal = (BYTE) *pCurrPtr;
            if (i > 0)
            {
                nTmp    = ((BYTE)*(pCurrPtr - 3) + (BYTE)*(pCurrPtr + 3));
                nTmp   += ((BYTE)*(pPrevPtr - 3) + (BYTE)*pPrevPtr  + (BYTE)*(pPrevPtr + 3));
                nTmp   += ((BYTE)*(pNextPtr - 3) + (BYTE)*pNextPtr  + (BYTE)*(pNextPtr + 3));
            }
            else
            {
                nTmp    = ((BYTE)*(pCurrPtr    ) + (BYTE)*(pCurrPtr + 3));
                nTmp   += ((BYTE)*(pPrevPtr    ) + (BYTE)*pPrevPtr  + (BYTE)*(pPrevPtr + 3));
                nTmp   += ((BYTE)*(pNextPtr    ) + (BYTE)*pNextPtr  + (BYTE)*(pNextPtr + 3));
            }
            nTmp   >>= 3;
            
            nTmp   = (nBluVal - nTmp);
            if (nTmp < 0)
                nTmp -= nSharpness;
            else
                nTmp += nSharpness;
            
            nBluVal += nTmp;
            
            if (nBluVal < 0)
                nBluVal = 0;
            
            if (nBluVal > 255)
                nBluVal = 255;
            
            *pDest++ = (BYTE) nBluVal;
            
            pCurrPtr++;
            pPrevPtr++;
            pNextPtr++;
        }
    }
    else    // Highpass filter
    {
        int nDelta;

        for (i = 0; i < nScanWidth; i++)
        {
            nRedVal = (BYTE) *pCurrPtr;
        
            if (i > 0)
            {
                nTmp    = ((BYTE)*(pCurrPtr - nBytesPerPixel) + (BYTE)*(pCurrPtr + nBytesPerPixel));
                nTmp   += ((BYTE)*(pPrevPtr - nBytesPerPixel) + (BYTE)*pPrevPtr  + (BYTE)*(pPrevPtr + nBytesPerPixel));
                nTmp   += ((BYTE)*(pNextPtr - nBytesPerPixel) + (BYTE)*pNextPtr  + (BYTE)*(pNextPtr + nBytesPerPixel));
            }
            else
            {
                nTmp    = ((BYTE)*(pCurrPtr    ) + (BYTE)*(pCurrPtr + nBytesPerPixel));
                nTmp   += ((BYTE)*(pPrevPtr    ) + (BYTE)*pPrevPtr  + (BYTE)*(pPrevPtr + nBytesPerPixel));
                nTmp   += ((BYTE)*(pNextPtr    ) + (BYTE)*pNextPtr  + (BYTE)*(pNextPtr + nBytesPerPixel));
            }
            nDelta = (nRedVal << 3) - nTmp;

            nRedVal += ((nDelta * nSharpness) >> 4);
            if (nRedVal < 0)
                nRedVal = 0;
        
            if (nRedVal > 255)
                nRedVal = 255;
        
            *pDest++ = (BYTE) nRedVal;
        
            pCurrPtr++;
            pPrevPtr++;
            pNextPtr++;
        
            if (nBytesPerPixel == 1)
                continue;
        
            nGrnVal = (BYTE) *pCurrPtr;
        
            if (i > 0)
            {
                nTmp    = ((BYTE)*(pCurrPtr - 3) + (BYTE)*(pCurrPtr + 3));
                nTmp   += ((BYTE)*(pPrevPtr - 3) + (BYTE)*pPrevPtr  + (BYTE)*(pPrevPtr + 3));
                nTmp   += ((BYTE)*(pNextPtr - 3) + (BYTE)*pNextPtr  + (BYTE)*(pNextPtr + 3));
            }
            else
            {
                nTmp    = ((BYTE)*(pCurrPtr    ) + (BYTE)*(pCurrPtr + 3));
                nTmp   += ((BYTE)*(pPrevPtr    ) + (BYTE)*pPrevPtr  + (BYTE)*(pPrevPtr + 3));
                nTmp   += ((BYTE)*(pNextPtr    ) + (BYTE)*pNextPtr  + (BYTE)*(pNextPtr + 3));
            }
            nDelta = (nGrnVal << 3) - nTmp;
        
            nGrnVal += ((nDelta * nSharpness) >> 4);
            if (nGrnVal < 0)
                nGrnVal = 0;
        
            if (nGrnVal > 255)
                nGrnVal = 255;
        
            *pDest++ = (BYTE) nGrnVal;
        
            pCurrPtr++;
            pPrevPtr++;
            pNextPtr++;
        
            nBluVal = (BYTE) *pCurrPtr;
        
            if (i > 0)
            {
                nTmp    = ((BYTE)*(pCurrPtr - 3) + (BYTE)*(pCurrPtr + 3));
                nTmp   += ((BYTE)*(pPrevPtr - 3) + (BYTE)*pPrevPtr  + (BYTE)*(pPrevPtr + 3));
                nTmp   += ((BYTE)*(pNextPtr - 3) + (BYTE)*pNextPtr  + (BYTE)*(pNextPtr + 3));
            }
            else
            {
                nTmp    = ((BYTE)*(pCurrPtr    ) + (BYTE)*(pCurrPtr + 3));
                nTmp   += ((BYTE)*(pPrevPtr    ) + (BYTE)*pPrevPtr  + (BYTE)*(pPrevPtr + 3));
                nTmp   += ((BYTE)*(pNextPtr    ) + (BYTE)*pNextPtr  + (BYTE)*(pNextPtr + 3));
            }
            nDelta = (nBluVal << 3) - nTmp;
        
            nBluVal += ((nDelta * nSharpness) >> 4);
            if (nBluVal < 0)
                nBluVal = 0;
        
            if (nBluVal > 255)
                nBluVal = 255;
        
            *pDest++ = (BYTE) nBluVal;

            pCurrPtr++;
            pPrevPtr++;
            pNextPtr++;
        }
    }
    return;
}


@end
