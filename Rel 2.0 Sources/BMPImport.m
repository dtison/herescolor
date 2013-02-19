
/*  BMPImport.m - Does the gruntwork for the BMPImageRep class  */

// TODO's:  (1) DiscardResource Stuff.  (2) Error codes / handling 
//			(3) Think about saves...

#import <appkit/appkit.h>
#import "Windefs.h"
#import "BMPImageRep.h"

void ReverseFileHeader (BITMAPFILEHEADER *pBitmapFileHeader);
void ReverseInfoHeader (BITMAPINFOHEADER *pbmiHeader);

int	BMPImportImage (NXStream * stream, BMPImageInfo *pBMPImageInfo)
{
	int					Return = 0;
    int                 i, j;
    WORD                wPaletteEntries;
    WORD                wDIBType;
    int                 nScanWidth;
    int                 nScanHeight;
    WORD                wBitsPerPixel;
    WORD                wSamplesPerPixel;
    WORD                wBitsPerSample;
    WORD                wHorzRes = 0;
    WORD                wVertRes = 0;
    BOOL                bIsRLE   = 0;
    BOOL                bIsWNDIB = 0;

    BITMAPFILEHEADER    BitmapFileHeader;
    BITMAPINFOHEADER    BitmapInfoHeader;
 	PBYTE				pImageData;
 	PBYTE				pDIBData;
	PBYTE				pData;
	PBYTE				pSourcePtr;
	PBYTE				pDestPtr;
	int					nSize;
	int					nBytesPerRow;
	int					nDIBBytesPerRow;
	
	NXSeek (stream, 0L, NX_FROMSTART);

    /*  Read BITMAPFILEHEADER & INFOHEADER  */

	if (NXRead (stream, &BitmapFileHeader, sizeof (BITMAPFILEHEADER)) != \
	sizeof(BITMAPFILEHEADER))
		DiscardResource (1);

	ReverseFileHeader (&BitmapFileHeader);	// Put into Motorola byte order

	if (NXRead (stream, &BitmapInfoHeader, sizeof (BITMAPINFOHEADER)) != \
	sizeof(BITMAPINFOHEADER))
		DiscardResource (1);

	ReverseInfoHeader (&BitmapInfoHeader);	// Put into Motorola byte order

    wDIBType = (WORD) 
	(BitmapInfoHeader.biSize == sizeof(BITMAPINFOHEADER) ? WNDIB : PMDIB);
	
    /*  Now for the fun part.  Let's fill in all the common/private data items
        we will need for the duration of this image's life  */

    if (wDIBType == WNDIB)
    {
        nScanWidth      = (int) BitmapInfoHeader.biWidth;
        nScanHeight     = (int) BitmapInfoHeader.biHeight;
        wBitsPerPixel   = (WORD) BitmapInfoHeader.biBitCount;
        bIsRLE          = (WORD) BitmapInfoHeader.biCompression; 
        bIsWNDIB        = (WORD) TRUE;
        wHorzRes        = (WORD) 
		(BitmapInfoHeader.biXPelsPerMeter / 39L); // Convert to DPI!
        wVertRes        = (WORD)
		 (BitmapInfoHeader.biYPelsPerMeter / 39L); // Convert to DPI!

	}
    else
    {   // Cast to COREHEADER type struct
        
        LPBITMAPCOREHEADER lpBitmapCoreHeader = 
		(LPBITMAPCOREHEADER) &BitmapInfoHeader;


        nScanWidth      = (int) lpBitmapCoreHeader -> bcWidth;
        nScanHeight     = (int) lpBitmapCoreHeader -> bcHeight;
        wBitsPerPixel   = (WORD) lpBitmapCoreHeader -> bcBitCount;
    }

    if (wBitsPerPixel == 24)
    {
        wSamplesPerPixel = 3;
        wBitsPerSample   = 8;
    }
    else
    {
        wSamplesPerPixel = 1;
        wBitsPerSample   = wBitsPerPixel;
    }

	
    /*  Finally, get the palette mess out of the way  */

    wPaletteEntries = (WORD) ((wBitsPerPixel == 24) ? ((wDIBType == WNDIB) ? (WORD)BitmapInfoHeader.biClrUsed : 0) : 1 << wBitsPerPixel);


	/*  MAY WANT TO MAKE ABOVE A FUNCTION CALL INSTEAD  */

	/*  Can we allocate the bitmap to hold the image?  */

	nSize = (nScanWidth * 3 * nScanHeight);
	NX_MALLOC (pImageData, BYTE, nSize);
	if (! pImageData)
		DiscardResource (1);

	nDIBBytesPerRow = WIDTHBYTES ((nScanWidth << 3) * 3);
	NX_MALLOC (pDIBData, BYTE, nSize);
	if (! pDIBData)
		DiscardResource (1);

	/*  Now set up BMPImageInfo structure  */ 
	
	nBytesPerRow						= (3 * nScanWidth);

	pBMPImageInfo -> pImageData 		= pImageData;
	pBMPImageInfo -> nScanWidth 		= nScanWidth;
	pBMPImageInfo -> nScanHeight 		= nScanHeight;
	pBMPImageInfo -> nBitsPerSample 	= 8;				// Always..
	pBMPImageInfo -> nSamplesPerPixel	= 3;				// Always..
	pBMPImageInfo -> bHasAlpha 		 	= NO;				// For now, always
	pBMPImageInfo -> bIsPlanar		 	= NO;				// Ditto
	pBMPImageInfo -> nScanWidth 		= nScanWidth;
	pBMPImageInfo -> nxColorSpace 		= NX_RGBColorSpace;
	pBMPImageInfo -> nBytesPerRow 		= nBytesPerRow;
	pBMPImageInfo -> nBitsPerPixel 		= 24;				// Always


	/*  Finally go read image  */

	pData = (pImageData + (nBytesPerRow * (nScanHeight - 1))); // Upside down..
	for (i = 0; i < nScanHeight; i++)
	{
		if (NXRead (stream, pDIBData, nDIBBytesPerRow) != nDIBBytesPerRow)
			DiscardResource (1);

		pSourcePtr = pDIBData;
		pDestPtr   = pData;

		/*  Reverse R and B  */
//		#if 0
		for (j = 0; j < nScanWidth; j++)
		{
			*pDestPtr 		= pSourcePtr [2];
			pDestPtr [2] 	= *pSourcePtr;
			pDestPtr [1] 	= pSourcePtr [1];	

			pSourcePtr += 3;
			pDestPtr   += 3;
		

		}
//		#endif
//		memcpy (pData, pDIBData, nBytesPerRow);		
		pData -= nBytesPerRow;
	}


	DiscardResource:
	{



	}	

	return Return;
}


void ReverseFileHeader (BITMAPFILEHEADER *pBitmapFileHeader)
{
	/*  Reverse ALL fields  */

	pBitmapFileHeader -> bfType = 
	ByteOrderWord (pBitmapFileHeader -> bfType, TRUE);

	pBitmapFileHeader -> bfSize = 
	ByteOrderLong (&pBitmapFileHeader -> bfSize, TRUE);

	pBitmapFileHeader -> bfOffBits = 
	ByteOrderLong (&pBitmapFileHeader -> bfOffBits, TRUE);

}

void ReverseInfoHeader (BITMAPINFOHEADER *pbmiHeader)
{

	/*  Reverse ALL fields  */

	pbmiHeader -> biSize = 
	ByteOrderLong (&pbmiHeader -> biSize, TRUE);
	
	pbmiHeader -> biWidth = 
	ByteOrderLong (&pbmiHeader -> biWidth, TRUE);

	pbmiHeader -> biHeight = 
	ByteOrderLong (&pbmiHeader -> biHeight, TRUE);

	pbmiHeader -> biPlanes = 
	ByteOrderWord (pbmiHeader -> biPlanes, TRUE);

	pbmiHeader -> biBitCount = 
	ByteOrderWord (pbmiHeader -> biBitCount, TRUE);
	
	pbmiHeader -> biCompression = 
	ByteOrderLong (&pbmiHeader -> biCompression, TRUE);

	pbmiHeader -> biSizeImage = 
	ByteOrderLong (&pbmiHeader -> biSizeImage, TRUE);

	pbmiHeader -> biXPelsPerMeter = 
	ByteOrderLong (&pbmiHeader -> biXPelsPerMeter, TRUE);

	pbmiHeader -> biYPelsPerMeter = 
	ByteOrderLong (&pbmiHeader -> biYPelsPerMeter, TRUE);
	
	pbmiHeader -> biClrUsed = 
	ByteOrderLong (&pbmiHeader -> biClrUsed, TRUE);

	pbmiHeader -> biClrImportant = 
	ByteOrderLong (&pbmiHeader -> biClrImportant, TRUE);

    
}


