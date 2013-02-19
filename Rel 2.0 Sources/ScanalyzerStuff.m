#ifdef JUNK
float colorDistance (ColorV colorV, ColorV targetV) 
{
	float red, green, blue;
	float	distance;	

	red 		= colorV [0] - targetV [0];
	green 	= colorV [1] - targetV [1];
	blue 		= colorV [2] - targetV [2];

	red 		*= red;
	green 	*= green;
	blue 		*= blue;

	distance = red + green + blue;
	distance = sqrt (distance);

	return distance;

}

/*  For now bytesPerPixel assumed to be 1  */

int findEdges (PBYTE data, int nScanWidth, int nScanHeight, int bytesPerPixel) 
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
	id		idPrometer;

	nBytesPerRow = nScanWidth * bytesPerPixel;

	NX_MALLOC (pCurr, BYTE, nBytesPerRow);
	if (! pCurr)
		return 1;		// Error Handling  (out of memory? really?)

	NX_MALLOC (pPrev, BYTE, nBytesPerRow);
	if (! pPrev)
		return 1;		// Error Handling  (out of memory? really?)

	NX_MALLOC (pNext, BYTE, nBytesPerRow);
	if (! pNext)
		return 1;		// Error Handling

	NX_MALLOC (pDest, BYTE, nBytesPerRow);
	if (! pDest)
		return 1;		

	memcpy (pPrev, pData, nBytesPerRow);
	pData += nBytesPerRow;
	memcpy (pCurr, pData, nBytesPerRow);
	pData += nBytesPerRow;
	memcpy (pNext, pData, nBytesPerRow);

	/*  Fudge the first line  (a REAL image processing fn should not do this)  */

	pData = data;
	memset (pData, 255, nBytesPerRow);
	pData += nBytesPerRow;


 	for (i = 1; i < nScanHeight; i++)
    	{
   	    	edgeLine (pDest, pPrev, pCurr, pNext, nScanWidth, 
				bytesPerPixel, nBytesPerRow, NULL);

 		memcpy (pData, pDest, nBytesPerRow);
        
       	 	memcpy (pPrev, pCurr, nBytesPerRow);
		memcpy (pCurr, pNext, nBytesPerRow);

		pData += nBytesPerRow;

   		memcpy (pNext, pData, nBytesPerRow);
    
    	}

	NX_FREE (pCurr);
	NX_FREE (pPrev);
	NX_FREE (pNext);
	NX_FREE (pDest);

	return 0;
}


void edgeLine (PBYTE pDest, 
			PBYTE pPrev,
			PBYTE pCurr, 
			PBYTE pNext, 
			int nScanWidth, 
			int nBytesPerPixel, 
			int nBytesPerRow, 
			void *p)
{
	WORD    i;
	int     nRedVal;
//	int     nGrnVal;
//	int     nBluVal;
	int     nTmp;
	int     nTmp1;
	int     nTmp2;
	int     nOldVal;
	PBYTE   pPrevPtr  = pPrev;
	PBYTE   pCurrPtr  = pCurr;
	PBYTE   pNextPtr  = pNext;
	int     nThreshold = 25;

	for (i = 0; i < nScanWidth; i++)
	{
            nOldVal = nRedVal = (BYTE) *pCurrPtr;
    
            nTmp1   = nRedVal - (int) (BYTE)*(pCurrPtr + nBytesPerPixel);       // "x + 1"
            if (nTmp1 < 0)
                nTmp1 *= -1;
    
            nTmp2   = nRedVal - (int) (BYTE)*pNextPtr;             // " y + 1"
            if (nTmp2 < 0)
                nTmp2 *= -1;
    
            nTmp = (nTmp1 + nTmp2);
    
            if (nTmp > nThreshold)
                nRedVal = 0;
            else
                nRedVal = 255;
    
            *pDest++ = (BYTE) nRedVal;
    
            pCurrPtr++;
            pPrevPtr++;
            pNextPtr++;
    
            if (nBytesPerPixel == 1)
                continue;
               
        }

    return;
}


/*  For now bytesPerPixel assumed to be 1  */

int medianFilter (PBYTE data, int nScanWidth, int nScanHeight, int bytesPerPixel) 
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
	id		idPrometer;

	nBytesPerRow = nScanWidth * bytesPerPixel;

	NX_MALLOC (pCurr, BYTE, nBytesPerRow);
	if (! pCurr)
		return 1;		// Error Handling  (out of memory? really?)

	NX_MALLOC (pPrev, BYTE, nBytesPerRow);
	if (! pPrev)
		return 1;		// Error Handling  (out of memory? really?)

	NX_MALLOC (pNext, BYTE, nBytesPerRow);
	if (! pNext)
		return 1;		// Error Handling

	NX_MALLOC (pDest, BYTE, nBytesPerRow);
	if (! pDest)
		return 1;		

	memcpy (pPrev, pData, nBytesPerRow);
	pData += nBytesPerRow;
	memcpy (pCurr, pData, nBytesPerRow);
	pData += nBytesPerRow;
	memcpy (pNext, pData, nBytesPerRow);


 	for (i = 1; i < nScanHeight; i++)
    	{
   	    	edgeLine (pDest, pPrev, pCurr, pNext, nScanWidth, 
				bytesPerPixel, nBytesPerRow, NULL);

 		memcpy (pData, pDest, nBytesPerRow);
        
       	 	memcpy (pPrev, pCurr, nBytesPerRow);
		memcpy (pCurr, pNext, nBytesPerRow);

		pData += nBytesPerRow;

   		memcpy (pNext, pData, nBytesPerRow);
    
    	}

	NX_FREE (pCurr);
	NX_FREE (pPrev);
	NX_FREE (pNext);
	NX_FREE (pDest);

	return 0;
}


void medianLine (PBYTE pDest, 
			PBYTE pPrev,
			PBYTE pCurr, 
			PBYTE pNext, 
			int nScanWidth, 
			int nBytesPerPixel, 
			int nBytesPerRow, 
			void *p)
{
    	int 	i;
    	int 	nTmp, nTmp2;
    	int     nVals [9];

    	PBYTE  pPrevPtr = pPrev;
	PBYTE  pCurrPtr = pCurr;
	PBYTE  pNextPtr = pNext;
   
//	int nLevel = (BYTE) (100 - pSmooth -> Level + 1);

        for (i = 0; i < nScanWidth; i++)
        {
            if (i > 0)
            {
                nVals [0] = (BYTE) *(pCurrPtr - nBytesPerPixel);
                nVals [1] = (BYTE) *(pCurrPtr + nBytesPerPixel);
                nVals [2] = (BYTE) *(pPrevPtr - nBytesPerPixel);
                nVals [3] = (BYTE) *pPrevPtr;
                nVals [4] = (BYTE) *(pPrevPtr + nBytesPerPixel);
                nVals [5] = (BYTE) *(pNextPtr - nBytesPerPixel);
                nVals [6] = (BYTE) *pNextPtr;
                nVals [7] = (BYTE) *(pNextPtr + nBytesPerPixel);
                nVals [8] = (BYTE) *pCurrPtr;
            }
            else
            {
                nVals [0] = (BYTE) *(pCurrPtr                 );
                nVals [1] = (BYTE) *(pCurrPtr + nBytesPerPixel);
                nVals [2] = (BYTE) *(pPrevPtr                 );
                nVals [3] = (BYTE) *pPrevPtr;
                nVals [4] = (BYTE) *(pPrevPtr + nBytesPerPixel);
                nVals [5] = (BYTE) *(pNextPtr                 );
                nVals [6] = (BYTE) *pNextPtr;
                nVals [7] = (BYTE) *(pNextPtr + nBytesPerPixel);
                nVals [8] = (BYTE) *pCurrPtr;
            }

	 nTmp = (BYTE) nVals [8];
    
		{
                int i, j;
                int v;

                for (i = 1; i < 9; i++)
                {
                
                    v = nVals [i];
                    j = i;
                
                    while (nVals [j - 1] > v && j > 0)
                    {
                
                        nVals [j] = nVals [j - 1];
                        j--;
                
                    }
                    nVals [j] = v;
                }

            }

            nTmp2 = nTmp - nVals [4];        // Difference between pixel and median
            if (nTmp2 < 0)
                nTmp2 *= -1;


 //           if (nTmp2 > nLevel)
                nTmp = (BYTE) nVals [4];

            *pDest++ = (BYTE) nTmp;
    
            pCurrPtr++;
            pPrevPtr++;
            pNextPtr++;
    
        
      
        }

	
}

#endif

