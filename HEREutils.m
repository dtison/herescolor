
/*  - HEREUtils.m -
 
This file has stuff that is application-wide.    */

#import "AppDefs.h"
#import "/LocalLibrary/HERELibrary/Include/HEREutils.h"
#import <string.h>
#import <ctype.h>


int SeparateFile (PBYTE pDestPath, PBYTE pDestFileName, PBYTE pSrcFileName)
{
	int   nError = 0;
	PBYTE pTmp;

	pTmp = pSrcFileName + strlen (pSrcFileName);

    pDestFileName [0] = 0;
    pDestPath [0] = 0;

	while (*pTmp != ':' && *pTmp != '/' && pTmp > pSrcFileName)
		pTmp--;
 	

	if (*pTmp != ':' && *pTmp != '/')
	{
 		strcpy (pDestFileName, pSrcFileName);                 
   		pDestPath[0] = 0;                                         
    	return (0);
	}
 	strcpy (pDestFileName, pTmp +1);                    
	strncpy (pDestPath, pSrcFileName, (int) (pTmp - pSrcFileName) + 1);
	pDestPath [(pTmp - pSrcFileName) + 1] = 0;            
	return (nError);
}


void SetExtension (char * pFilename, char * pExtension)
{
	char 	*pExt;

	pExt = strrchr (pFilename, '.');
	if (pExt)
		*pExt = 0;

	strcat (pFilename, ".");
	strcat (pFilename, pExtension);
}

/*  Goes thru an RGB bitmap and re-arranges alpha / component so they are pre-multiplied and the R, G and B components can be interpreted conventionally.  Something to look at is the multiplications below and if they round off lower than they should, ie 254 instead of 255   */
 
void multiplyAlpha (NXBitmapImageRep *bitmapImage)
{
	int	i, j;
	int	pixelsWide, pixelsHigh;
	int	bytesPerRow;
	PBYTE	data, dataPtr;
	float 		alpha;

	if (! [bitmapImage hasAlpha])
		return;

	bytesPerRow 	= [bitmapImage bytesPerRow];
	pixelsWide	= [bitmapImage pixelsWide];
	pixelsHigh	= [bitmapImage pixelsHigh];
	data			= [bitmapImage data];

	for (i = 0; i < pixelsHigh; i++)
	{
		dataPtr = data;
		for (j = 0; j < pixelsWide; j++)
		{
			alpha = (float) dataPtr [3] / 255;

			dataPtr [0] = 255 - (BYTE) (alpha * (float) (255 - (int) dataPtr [0]));
			dataPtr [1] = 255 - (BYTE) (alpha * (float) (255 - (int) dataPtr [1]));
			dataPtr [2] = 255 - (BYTE) (alpha * (float) (255 - (int) dataPtr [2]));
			dataPtr [3] = 255;
			dataPtr += 4;		// R, G, B & Alpha = 4
		}
		data += bytesPerRow;
	}
	return;
}


#ifdef NOTYET
PBYTE copySelection (PBYTE data, NXSize *imageSize, NXRect *selectionRect)
{
	int		nSelectionBytesPerRow;
	int		nSelectionSize;

	int		i;
	int		nTop, nLeft, nBottom, nRight;
	int		nSelectionWidth, nSelectionHeight;
	int		nBytesPerRow;
	PBYTE	pDataPtr = data;
	PBYTE	pDataPtr2;
	PBYTE	pDest;
	PBYTE	pDestPtr;
	

	nSelectionBytesPerRow = (int) selectionRect -> size.width * 3;
	nSelectionSize = nSelectionBytesPerRow * (int) selectionRect -> size.height;

	NX_MALLOC (pDest, BYTE, nSelectionSize);
	if (! pDest)
		return NULL;		// Error handling

	pDestPtr = pDest;

	/*  First translate Postscript bounds (selection) rect  */

	nBottom  = (int) (imageSize -> height - selectionRect -> origin.y - 1);
	nTop	= nBottom - (int) selectionRect -> size.height + 1;

	nLeft  	= (int) (selectionRect -> origin.x);
	nRight  	= nLeft + (int) selectionRect -> size.width - 1;

	nSelectionWidth  = nRight - nLeft + 1;
	nSelectionHeight = nBottom - nTop + 1;

	/*  Then adjust pointer(s) forward if necessary  */

	nBytesPerRow = (int) imageSize -> width * 3;
	pDataPtr += (nBytesPerRow * nTop);

	for (i = 0; i < nSelectionHeight; i++)
	{		
		/*  Adjust source for X  */

		pDataPtr2 = pDataPtr +  (nLeft * 3);

		memcpy (pDestPtr, pDataPtr2, nSelectionBytesPerRow); 
		
		/*  Advance past this line  */

		pDataPtr += nBytesPerRow;
		pDestPtr += nSelectionBytesPerRow;
 	}

	return pDest;
}
#endif


int doPrinters (void)
{
	char		*buffer;
	char		*tempPtr;
	int		bytesPerChunk = 1024 * 50;
	FILE		*printerFile;
	char		*printerName;
	char		command [128];
	char		printerPath [80];

	buffer = malloc (bytesPerChunk);

	getwd (buffer);


 	strcpy (printerPath, "/777_printers");
	strcpy (command, "niutil -list . /printers > ");
	strcat (command, printerPath);

	system (command);

	printerFile = fopen (printerPath, "r");
	if (! printerFile)
	{
		return (1);
	}

	while (! feof (printerFile))
	{
		fgets (buffer, 128, printerFile);
		printerName = buffer;
		while (! isalpha (*printerName) && *printerName != 0)
			printerName++;
		tempPtr = printerName;
		while (! isspace (*tempPtr) && *tempPtr != 0)
			tempPtr++;

		*tempPtr = 0;		// Terminate it nicely

		strcpy (command, "niutil -createprop . /printers/");
		strcat (command, printerName);
		strcat (command, "/Admin InitFiles /.CurrentCRD");
		system (command);
	}

	fclose (printerFile);
	free (buffer);
	unlink (printerPath);

	return 0;
}


int setDefaultTransfer (float red, float green, float blue)
{
	char		*buffer;
	int		bytesPerChunk = 1024 * 50;
	char		command [260];

	buffer = malloc (bytesPerChunk);

	strcpy (command, "niutil -createprop . /localconfig/screens/MegaPixel defaultTransfer ");
	sprintf (buffer, "\"{1 %3.2f div exp} {1 %3.2f div exp} {1 %3.2f div exp} {}\"", red, green, blue);
	strcat (command, buffer);
	system (command);

	free (buffer);

	return 0;
}

/*  This is a good example of a generalized bitmapImage transformer.  This version enhanced to do CMYK or RGB output  */

NXBitmapImageRep *colorCorrectImage (NXBitmapImageRep *bitmapImage, 
const char *circuit, id progress, NXColorSpace destSpace)
{
	int 		i;
	int		bytesPerPixel;
	int		bytesPerRow;
	int		destBytesPerRow;
	int		pixelsWide;
	int		pixelsHigh;
	PBYTE	data, destData;
	uchar 	*ip [3];
	uchar 	*op [4];
	int		iStep;
	int		oStep;
	int		componentOffset;
	BOOL	isCircuitActive = NO;
	NXBitmapImageRep *newImage = nil;
	NXBitmapImageRep *returnImage = nil;

	NX_DURING
	
	bytesPerRow 	= [bitmapImage bytesPerRow];
	pixelsWide	= [bitmapImage pixelsWide];
	pixelsHigh	= [bitmapImage pixelsHigh];

	if (destSpace == NX_CMYKColorSpace)
	{
		NXSize imageSize;

		[bitmapImage getSize: &imageSize];

		/*  Now allocate a new bitmap image  */

		newImage = [[NXBitmapImageRep alloc] initData: NULL
					pixelsWide: 		pixelsWide
					pixelsHigh:		pixelsHigh
					bitsPerSample:	8
					samplesPerPixel:	4
					hasAlpha:		NO
					isPlanar:			NO
					colorSpace:		NX_CMYKColorSpace
 					bytesPerRow:		0
					bitsPerPixel:		32];

		if (! newImage)
			NX_RAISE (Err_MemoryAllocationError, NULL, NULL);

		[newImage setSize: &imageSize];
		destBytesPerRow = [newImage bytesPerRow];
		destData = [newImage data];
	}

	if ([bitmapImage isPlanar])
	{
		componentOffset 	= [bitmapImage bytesPerPlane];
		bytesPerPixel 		= 1;
	}
	else
	{
		componentOffset 	= 1;
		bytesPerPixel 		= [bitmapImage hasAlpha] ? 4 : 3; 
	}

	if (CiCircRead ((char *) circuit) != CE_OK)
		NX_RAISE (Err_TransformError6, NULL, NULL);
	isCircuitActive = YES;
	
	data = [bitmapImage data];
	iStep = bytesPerPixel;
	oStep = (destSpace == NX_CMYKColorSpace) ? 4 : bytesPerPixel;

	for (i = 0; i < pixelsHigh; i++)
	{
		ip [RGB_R] = data;
		ip [RGB_G] = data + componentOffset;
		ip [RGB_B] = data + (componentOffset << 1);

		if (destSpace == NX_CMYKColorSpace)
		{
			op [CMYK_C] = destData;
			op [CMYK_M] = destData + 1;
			op [CMYK_Y] = destData + 2;
			op [CMYK_K] = destData + 3;
		}
		else
		{
			op [RGB_R] = ip [RGB_R];
			op [RGB_G] = ip [RGB_G];
			op [RGB_B] = ip [RGB_B];
		}

 		CiCircColor (pixelsWide, ip, iStep, op, oStep);

		data += bytesPerRow;
	
		if (destSpace == NX_CMYKColorSpace)
			destData += destBytesPerRow;

		if (progress)
			if ((i % 16) == 0)
				[progress setPercent: ((float) i + 1) / pixelsHigh];
	}

	/*   Set return image.  Also, discard old bitmap if we did transform to CMYK space  */

	if (destSpace == NX_CMYKColorSpace)
	{
		returnImage = newImage;
	 	if (bitmapImage)
 			[bitmapImage free];
	}
	else
		returnImage = bitmapImage;

	NX_RAISE (Err_NoError, NULL, NULL);
	NX_HANDLER
	if (progress)
		[progress setPercent: 0];
	if (isCircuitActive)
		CiCircClose ();
	HERE_RERAISE();
	NX_ENDHANDLER
	return returnImage;
}

/*  This code's intended to rasterize EPS files.  Turns out it will also re-res tiffs as well */

NXBitmapImageRep *epsToBitmap (NXImage *epsImage, NXSize *size, BOOL isDemo)
{
	NXRect				contentRect;
	NXRect				frameRect;
	NXBitmapImageRep 	*bitmapImage 	= nil;
	Window				*window 		= nil;
	NXImageRep			*imageRep;

	NX_DURING

	/*  What about if the thing is > 16000 pixels wide or high ?  */

	contentRect.origin.x = 
	contentRect.origin.y = 0;
	contentRect.size.width 	= size -> width;
	contentRect.size.height 	= size -> height;

	[Window getFrameRect: &frameRect
	forContentRect: &contentRect
	style: NX_PLAINSTYLE];

	window = [[Window alloc] initContent: &contentRect
	style: NX_PLAINSTYLE
	backing: NX_BUFFERED
	buttonMask: NO
	defer: NO];

	if (! window)
		NX_RAISE (Err_MemoryAllocationError, NULL, NULL);

	[window setDynamicDepthLimit: NO];
	[window setDepthLimit: NX_TwentyFourBitRGBDepth];

 	[epsImage setScalable: YES];
	imageRep = [epsImage bestRepresentation];

	[[window contentView] lockFocus];
	[epsImage drawRepresentation: imageRep
	inRect: &contentRect];

	if (isDemo)
	{
		/*  Put a red strip down   */

		PSsetlinewidth (contentRect.size.width / 500);
		PSsetrgbcolor (1, 0, 0);
		PSmoveto (0, 0);
		PSrlineto (size -> width - 1, size -> height - 1);
		PSstroke();
	}

	bitmapImage = [[NXBitmapImageRep alloc]  
	initData: NULL fromRect: &contentRect];
	if (! bitmapImage)
		NX_RAISE (Err_MemoryAllocationError, NULL, NULL);

	/*  Fix a bug.  I discovered alpha flag isn't set but bps = 32 or 16.  First fix that bug  */

	if ([bitmapImage bitsPerPixel] == 32 || [bitmapImage bitsPerPixel] == 16)
		[bitmapImage setAlpha: YES];

	NX_RAISE (Err_NoError, NULL, NULL);
	NX_HANDLER
	if (window)
		[window free];
	HERE_RERAISE();
	NX_ENDHANDLER
	return bitmapImage;
}


NXBitmapImageRep *planesToTriplets (NXBitmapImageRep *bitmapImage)
{
	NXBitmapImageRep 	*newImage	= nil;
	int					pixelsWide, pixelsHigh;
	int					sourceBytesPerRow;
	int					destBytesPerRow;
	int					i, j;
	PBYTE				destData;
	PBYTE				destPtr;
	PBYTE				redPlane,	greenPlane, bluePlane, alphaPlane;
	PBYTE				redPlanePtr, greenPlanePtr, bluePlanePtr, alphaPlanePtr;
	BOOL				sourceHasAlpha;
	PBYTE				planes [5];
	NXSize				imageSize;

	NX_DURING

	pixelsWide 			= [bitmapImage pixelsWide];
	pixelsHigh 			= [bitmapImage pixelsHigh];
	sourceHasAlpha 		= [bitmapImage hasAlpha];
	sourceBytesPerRow 	= [bitmapImage bytesPerRow];

	[bitmapImage getSize: &imageSize];

	/*  Now allocate a new bitmap image  */

	newImage = [[NXBitmapImageRep alloc] initData: NULL
				pixelsWide: 		pixelsWide
				pixelsHigh:		pixelsHigh
				bitsPerSample:	8
				samplesPerPixel:	sourceHasAlpha ? 4 : 3
				hasAlpha:		sourceHasAlpha
				isPlanar:			NO
				colorSpace:		NX_RGBColorSpace
 				bytesPerRow:		0
				bitsPerPixel:		sourceHasAlpha ? 32 : 24];

	if (! newImage)
		NX_RAISE (Err_MemoryAllocationError, NULL, NULL);

	[newImage setSize: &imageSize];

	destBytesPerRow = [newImage bytesPerRow];

	/*  Then just reformat the data  */

	destData 		= [newImage data];
	memset (destData, 0, (pixelsHigh * destBytesPerRow));

	[bitmapImage getDataPlanes: planes];

	redPlane		= planes [0];
	greenPlane	= planes [1];
	bluePlane		= planes [2];

	for (i = 0; i < pixelsHigh; i++)
	{	
		redPlanePtr		= redPlane;
		greenPlanePtr		= greenPlane;
		bluePlanePtr		= bluePlane;
		if (sourceHasAlpha)
			alphaPlanePtr	= alphaPlane;

		destPtr = destData;

		for (j = 0; j < pixelsWide; j++)
		{
			*destPtr++ = *redPlanePtr++;
 			*destPtr++ = *greenPlanePtr++;
  			*destPtr++ = *bluePlanePtr ++;

			if (sourceHasAlpha)
				*destPtr++ = *alphaPlanePtr++;
	
		}
		redPlane		+= sourceBytesPerRow;
		greenPlane	+= sourceBytesPerRow;
		bluePlane		+= sourceBytesPerRow;
 		destData		+= destBytesPerRow;
	}

	NX_RAISE (Err_NoError, NULL, NULL);
	NX_HANDLER
 	if (bitmapImage)
 		[bitmapImage free];
	HERE_RERAISE();
	NX_ENDHANDLER
 	return newImage;
}

/*  Retrieves the monitor color space from the defaults database.   */

int getMonitorSpace (MonitorSpace *space, char *appString)
{
	int			Return = NO;
 	PBYTE		pDefault;
	float			value;

	NXUpdateDefaults();

	pDefault = (PBYTE) NXGetDefaultValue (appString, "redMonitorValue");
	if (pDefault)
	{
		value = (float) atof (pDefault);
		if (value < 0.05)
			value = 2.2;
		space -> redGamma = value;
		Return = YES;
	}
	pDefault = (PBYTE) NXGetDefaultValue (appString, "greenMonitorValue");
	if (pDefault)
	{
		value = (float) atof (pDefault);
		if (value < 0.05)
			value = 2.2;
		space -> greenGamma = value;
		Return = YES;
	}
	pDefault = (PBYTE) NXGetDefaultValue (appString, "blueMonitorValue");
	if (pDefault)
	{
		value = (float) atof (pDefault);
		if (value < 0.05)
			value = 2.2;
		space -> blueGamma = value;
		Return = YES;
	}

	pDefault = (PBYTE) NXGetDefaultValue (appString, "redChroma_x");
	if (pDefault)
	{
		space -> redChroma_x = (float) atof (pDefault);
		Return = YES;
	}
	pDefault = (PBYTE) NXGetDefaultValue (appString, "redChroma_y");
	if (pDefault)
	{
		space -> redChroma_y = (float) atof (pDefault);
		Return = YES;
	}

	pDefault = (PBYTE) NXGetDefaultValue (appString, "greenChroma_x");
	if (pDefault)
	{
		space -> greenChroma_x = (float) atof (pDefault);
		Return = YES;
	}

	pDefault = (PBYTE) NXGetDefaultValue (appString, "greenChroma_y");
	if (pDefault)
	{
		space -> greenChroma_y = (float) atof (pDefault);
		Return = YES;
	}

	pDefault = (PBYTE) NXGetDefaultValue (appString, "blueChroma_x");
	if (pDefault)
	{
		space -> blueChroma_x = (float) atof (pDefault);
		Return = YES;
	}

	pDefault = (PBYTE) NXGetDefaultValue (appString, "blueChroma_y");
	if (pDefault)
	{
		space -> blueChroma_y = (float) atof (pDefault);
		Return = YES;
	}

	pDefault = (PBYTE) NXGetDefaultValue (appString, "whitePoint");
	if (pDefault)
	{
		space -> whitePoint = (float) atof (pDefault);
		Return = YES;
	}
	return Return;

}

/*  Saves off the monitor color space into the defaults database.   */

void saveMonitorSpace (MonitorSpace *space, char *appString)
{
	char 	szBuffer [260];

	sprintf (szBuffer, "%5.2f", space -> redGamma);
	NXWriteDefault (appString, "redMonitorValue", szBuffer);
	sprintf (szBuffer, "%5.2f", space -> greenGamma);
	NXWriteDefault (appString, "greenMonitorValue", szBuffer);
	sprintf (szBuffer, "%5.2f", space -> blueGamma);
	NXWriteDefault (appString, "blueMonitorValue", szBuffer);

	sprintf (szBuffer, "%5.2f", space -> redChroma_x);
	NXWriteDefault (appString, "redChroma_x", szBuffer);
	sprintf (szBuffer, "%5.2f", space -> redChroma_y);
	NXWriteDefault (appString, "redChroma_y", szBuffer);

	sprintf (szBuffer, "%5.2f", space -> greenChroma_x);
	NXWriteDefault (appString, "greenChroma_x", szBuffer);
	sprintf (szBuffer, "%5.2f", space -> greenChroma_y);
	NXWriteDefault (appString, "greenChroma_y", szBuffer);

	sprintf (szBuffer, "%5.2f", space -> blueChroma_x);
	NXWriteDefault (appString, "blueChroma_x", szBuffer);
	sprintf (szBuffer, "%5.2f", space -> blueChroma_y);
	NXWriteDefault (appString, "blueChroma_y", szBuffer);

	sprintf (szBuffer, "%5.2f", space -> whitePoint);
	NXWriteDefault (appString, "whitePoint", szBuffer);
}


void initDefaultMonitorSpace (MonitorSpace *space)
{
	space -> redGamma 		= 2.2;
	space -> greenGamma 		= 2.2;
	space -> blueGamma 		= 2.2;
	space -> redChroma_x 		= 0.64;
	space -> redChroma_y 		= 0.33;
	space -> greenChroma_x 	= 0.30;
	space -> greenChroma_y 	= 0.60;
	space -> blueChroma_x 		= 0.15;
	space -> blueChroma_y 		= 0.06;
 	space -> whitePoint 		= (float) REFWHITE;
}

void writeMABProfile (NXTypedStream *typedStream, OutputProfile *profile)
{
	int	i;

	NXWriteType (typedStream, "c", &profile -> majorVersion);
	NXWriteType (typedStream, "c", &profile -> minorVersion);
	NXWriteType (typedStream, "s", &profile -> length);
	NXWriteType (typedStream, "c", &profile -> tag);
	NXWriteType (typedStream, "c", &profile -> filler);
     	NXWriteArray (typedStream, "f", 5, profile -> GCR);
	NXWriteType (typedStream, "f", &profile -> blackPoint);
	NXWriteType (typedStream, "f", &profile -> TAC);
	for (i = 0; i < NUM_RCHNCOLORS; i++)
 	    	NXWriteArray (typedStream, "f", 4, &profile -> rchnRCSColors [i]);
	for (i = 0; i < NUM_RCHNCOLORS; i++)
		NXWriteType (typedStream, "c", &profile -> rchnColorsUsed [i]);
	for (i = 0; i < 320; i++)
 	    	NXWriteArray (typedStream, "f", 4, &profile -> inkDensities [i]);
     	NXWriteArray (typedStream, "c", (20 * 20 * 20 * 4), profile -> renderDict);
	NXWriteType (typedStream, "c", &profile -> useAlternateMixes);
	NXWriteType (typedStream, "c", &profile -> useRelaxedInkmodel);
	NXWriteType (typedStream, "c", &profile -> deviceType);
	NXWriteType (typedStream, "c", &profile -> teachMeType);
	NXWriteType (typedStream, "c", &profile -> processingQuality);
     	NXWriteArray (typedStream, "c", MAXPATHSIZE, profile -> inkmodelFilename);
     	NXWriteArray (typedStream, "c", MAXPATHSIZE, profile -> teachMeFilename);
	NXWriteType (typedStream, "l", &profile -> inkmodelLoadTime);
	NXWriteType (typedStream, "l", &profile -> teachMeLoadTime);
     	NXWriteArray (typedStream, "c", sizeof (profile -> fillerSpace), profile -> fillerSpace);
}	

void readMABProfile (NXTypedStream *typedStream, OutputProfile *profile)
{
	int	i;

	NX_DURING

	NXReadType (typedStream, "c", &profile -> majorVersion);
	NXReadType (typedStream, "c", &profile -> minorVersion);
	NXReadType (typedStream, "s", &profile -> length);
	NXReadType (typedStream, "c", &profile -> tag);
	NXReadType (typedStream, "c", &profile -> filler);
     	NXReadArray (typedStream, "f", 5, profile -> GCR);
	NXReadType (typedStream, "f", &profile -> blackPoint);
	NXReadType (typedStream, "f", &profile -> TAC);
	for (i = 0; i < NUM_RCHNCOLORS; i++)
 	    	NXReadArray (typedStream, "f", 4, &profile -> rchnRCSColors [i]);
	for (i = 0; i < NUM_RCHNCOLORS; i++)
		NXReadType (typedStream, "c", &profile -> rchnColorsUsed [i]);
	for (i = 0; i < 320; i++)
 	    	NXReadArray (typedStream, "f", 4, &profile -> inkDensities [i]);
     	NXReadArray (typedStream, "c", (20 * 20 * 20 * 4), profile -> renderDict);
	NXReadType (typedStream, "c", &profile -> useAlternateMixes);
	NXReadType (typedStream, "c", &profile -> useRelaxedInkmodel);
	NXReadType (typedStream, "c", &profile -> deviceType);
	NXReadType (typedStream, "c", &profile -> teachMeType);
	NXReadType (typedStream, "c", &profile -> processingQuality);
     	NXReadArray (typedStream, "c", MAXPATHSIZE, profile -> inkmodelFilename);
     	NXReadArray (typedStream, "c", MAXPATHSIZE, profile -> teachMeFilename);
	NXReadType (typedStream, "l", &profile -> inkmodelLoadTime);
	NXReadType (typedStream, "l", &profile -> teachMeLoadTime);
     	NXReadArray (typedStream, "c", sizeof (profile -> fillerSpace), profile -> fillerSpace);

	NX_HANDLER
	HERE_RERAISE();
	NX_ENDHANDLER
		
}

/*  Adapts x y chromaticities in sourceSpace to x' y' in destSpace according
 to specified whitePoints  (Turn x y into x'y')   */

void adaptWhitepoint (MonitorSpace *sourceSpace, MonitorSpace *destSpace, long destWhitepoint) 
{
	ColorV sourceV, destV;
	long	sourceWhitepoint = (long) sourceSpace -> whitePoint;

	ColorV 		primaries [3];
	long			refWhite;
	Flt			gamma [3];

	#ifdef OLDWAY
	/*  Red  */

	sourceV [0] = sourceSpace -> redChroma_x;
	sourceV [1] = sourceSpace -> redChroma_y;
	sourceV [2] = 1.0;
	CiCmsRcsColor (CI_XYY_TO_RCS, sourceV, destV);
	CiCmsRcsColor (CI_RCS_TO_XYZ, destV, sourceV);
	Ci_MapRefWhite (sourceV, sourceWhitepoint, destV, destWhitepoint);	CiCmsRcsColor (CI_XYZ_TO_RCS, destV, sourceV);
	CiCmsRcsColor (CI_RCS_TO_XYY, sourceV, destV);
	destSpace -> redChroma_x = destV [0];
	destSpace -> redChroma_y = destV [1];

	/*  Green  */

	sourceV [0] = sourceSpace -> greenChroma_x;
	sourceV [1] = sourceSpace -> greenChroma_y;
	sourceV [2] = 1.0;
	CiCmsRcsColor (CI_XYY_TO_RCS, sourceV, destV);
	CiCmsRcsColor (CI_RCS_TO_XYZ, destV, sourceV);
	Ci_MapRefWhite (sourceV, sourceWhitepoint, destV, destWhitepoint);
	CiCmsRcsColor (CI_XYZ_TO_RCS, destV, sourceV);
	CiCmsRcsColor (CI_RCS_TO_XYY, sourceV, destV);
	destSpace -> greenChroma_x = destV [0];
	destSpace -> greenChroma_y = destV [1];

	/*  Blue  */

	sourceV [0] = sourceSpace -> blueChroma_x;
	sourceV [1] = sourceSpace -> blueChroma_y;
	sourceV [2] = 1.0;
 	CiCmsRcsColor (CI_XYY_TO_RCS, sourceV, destV);
	CiCmsRcsColor (CI_RCS_TO_XYZ, destV, sourceV);
	Ci_MapRefWhite (sourceV, sourceWhitepoint, destV, destWhitepoint);
	CiCmsRcsColor (CI_XYZ_TO_RCS, destV, sourceV);
	CiCmsRcsColor (CI_RCS_TO_XYY, sourceV, destV);
	destSpace -> blueChroma_x = destV [0];
	destSpace -> blueChroma_y = destV [1];
	#endif

	primaries [0] [0] = sourceSpace -> redChroma_x;
	primaries [0] [1] = sourceSpace -> redChroma_y;
	primaries [0] [2] = 0;
	primaries [1] [0] = sourceSpace -> greenChroma_x;
	primaries [1] [1] = sourceSpace -> greenChroma_y;
	primaries [1] [2] = 0;
	primaries [2] [0] = sourceSpace -> blueChroma_x;
	primaries [2] [1] = sourceSpace -> blueChroma_y;
	primaries [2] [2] = 0;
	gamma [0] = gamma [1] = gamma [2] = 1.0;	
 	refWhite = sourceWhitepoint;

	if (CiCmsRcsSet (primaries, refWhite, CI_CT_GAMMA, gamma) != CE_OK)
		NX_RAISE (Err_TransformError0, NULL, NULL);

	/*  Red  */

	sourceV [0] = 1.0;
	sourceV [1] = 0.0;
	sourceV [2] = 0.0;
	CiCmsRcsColor (CI_RCS_TO_XYZ, sourceV, destV);
	memcpy (sourceV, destV, sizeof (ColorV));
	Ci_MapRefWhite (sourceV, sourceWhitepoint, destV, destWhitepoint);	CiCmsRcsColor (CI_XYZ_TO_RCS, destV, sourceV);
	CiCmsRcsColor (CI_RCS_TO_XYY, sourceV, destV);
	destSpace -> redChroma_x = destV [0];
	destSpace -> redChroma_y = destV [1];


	/*  Green  */

	sourceV [0] = 0.0;
	sourceV [1] = 1.0;
	sourceV [2] = 0.0;
	CiCmsRcsColor (CI_RCS_TO_XYZ, sourceV, destV);
	memcpy (sourceV, destV, sizeof (ColorV));
	Ci_MapRefWhite (sourceV, sourceWhitepoint, destV, destWhitepoint);	CiCmsRcsColor (CI_XYZ_TO_RCS, destV, sourceV);
	CiCmsRcsColor (CI_RCS_TO_XYY, sourceV, destV);
	destSpace -> greenChroma_x = destV [0];
	destSpace -> greenChroma_y = destV [1];

	/*  Blue  */

	sourceV [0] = 0.0;
	sourceV [1] = 0.0;
	sourceV [2] = 1.0;
	CiCmsRcsColor (CI_RCS_TO_XYZ, sourceV, destV);
	memcpy (sourceV, destV, sizeof (ColorV));
	Ci_MapRefWhite (sourceV, sourceWhitepoint, destV, destWhitepoint);
	#if 0
	{
		char szBuffer [90];
		sprintf (szBuffer, "sourceV: %5.3f\t%5.3f\t%5.3f", sourceV [0], sourceV [1], sourceV [2]);
		NXLogError (szBuffer);
		sprintf (szBuffer, "destV: %5.3f\t%5.3f\t%5.3f", destV [0], destV [1], destV [2]);
		NXLogError (szBuffer);
	}
	#endif

	CiCmsRcsColor (CI_XYZ_TO_RCS, destV, sourceV);
	CiCmsRcsColor (CI_RCS_TO_XYY, sourceV, destV);
	destSpace -> blueChroma_x = destV [0];
	destSpace -> blueChroma_y = destV [1];

	/*  This ought to set everything back to CCIR 709 space  */

	CiCmsClose();
	CiCmsOpen();

	// For debugging / testing, return self  

//	memcpy (destSpace, sourceSpace, sizeof (MonitorSpace));

/*
	set rcs to x y of monitor and 9800 of monitor gamma 1.0

	Begin loop	
		RCS to XYZ (1 0 0, then 010, etc

		Map refwhite (that XYZ, 9800, dest XYZ, 6500)
		
		XYZ to RCS
	
		RCS to XYY  (this is the x' y')
	End Loop
	*/

 
}

NXBitmapImageRep *makeTargetBitmapImage (int type, int width, int height, char *directory)
{
 	NXBitmapImageRep 	*bitmapImage = nil;
	char					szFilename [260];
	int					status;
	FormatSpecs			specs;
	struct stat st;

	NX_DURING
	memset (&specs, 0, sizeof (specs));
	specs.format 		= CI_RL_TIFF;
	specs.res 		= 72;
	specs.options[0] 	= CI_TIFF_ILEAVE;

	strcpy (szFilename, directory);
	strcat (szFilename, "/Target.tiff");

	status = CiMiscPatternMake (type, width, height, szFilename, &specs);
	if (status != CE_OK)
		NX_RAISE (Err_FileWriteError, NULL, NULL);	
	bitmapImage = [[NXBitmapImageRep alloc] initFromFile: szFilename];
	if (! bitmapImage)
		NX_RAISE (Err_MemoryAllocationError, NULL, NULL);

	NX_RAISE (Err_NoError, NULL, NULL);
	NX_HANDLER
	if (stat (szFilename, &st) == 0)
		unlink (szFilename);
	HERE_RERAISE();
	NX_ENDHANDLER
	return bitmapImage;
}

/*  Makes a temporary file with a full path.  Caller is responsible for freeing up the memory  */

char *makeTempFile (char *template)
{
	char *path;

	NX_MALLOC (path, char, MAXPATHSIZE);

//	getwd (path);
//	if (strlen (path) > 1)
//		strcat (path, "/");

	strcpy (path, "/tmp/");
 	strcat (path, template);
	mktemp (path);
	return path;
}


