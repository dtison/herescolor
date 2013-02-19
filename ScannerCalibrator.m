

/*  Open items:

1)  Disable save:  Use saveAs:
2)  Test the arbitrary DPI thing.  It's only been test with 150 DPI scans!  
3)  UI gets messy in a couple of places.  Might take about a week to get solid  
4)  Testing of other scanners for monitor matches can take a long time  
5)  Especially unknown right now is error handling.
*/


#import "ScannerCalibrator.h"

@implementation ScannerCalibrator

- runOrderFront: sender
{
	/*  Do our initialization..  I know this is different from outputprofileinspector.. */

	if (! controller) 
	{
		controller 	= [NXApp delegate];
		colorLinks 	= [[ColorLinks alloc] init];
	}

	[olInstructionsText setStringValue:  "Drag and drop scanned image."];
	[olScannerCalibratorPanel makeKeyAndOrderFront: sender];
	[olScannerCalibratorPanel setDocEdited: NO];
	[olScannerCalibratorPanel setDelegate: self];

	return self;
}

- loadTestTarget: sender
{
	[olInstructionsText setStringValue:  "Use save to create profile."];
	return self;
}
 
- save: sender
{

	return self;
}

- saveAs: sender
{
	SavePanel	*savePanel = [SavePanel new];

	[savePanel setRequiredFileType: "InputProfile"];

	if ([savePanel runModalForDirectory:
	[controller inputProfileDirectory] 
	file: NULL ])
	{
		[self saveProfile:  [savePanel filename]];
	}
	return self;
}

- saveProfile: (const char *) filename
{
	NXBitmapImageRep *bitmapImage = nil;
	ColorV 		*grayRamp 	= NULL;
	ColorV 		*mainColors 	= NULL;
	BOOL		isTransformActive = NO;
	int			i;

	NX_DURING
	
	NX_MALLOC (grayRamp, ColorV, 12);
	if (! grayRamp)
		NX_RAISE (Err_MemoryAllocationError, NULL, NULL);
	NX_MALLOC (mainColors, ColorV, 216);
	if (! mainColors)
		NX_RAISE (Err_MemoryAllocationError, NULL, NULL);

	/*  Now grab image from Image View  */

	bitmapImage = [olScannedImageView draggedBitmapImage];	if (! bitmapImage)
		NX_RAISE (Err_InternalError, NULL, NULL);

	scanalyze (bitmapImage, grayRamp, mainColors);

	#ifdef WRITEMEASUREMENTS
	{
		char	buffer [200];
		int	i, j;
		NXStream 	*stream;
		stream = NXOpenMemory (NULL, 0, NX_READWRITE);
		for (i = 0; i < 18; i++)
			for (j = 0; j < 12; j++)
			{
				sprintf (buffer, "r%2d c%2d: %3d %3d %3d\n", i, j, 
				(int) (mainColors [(i * 12) + j] [0] * 255.05),
				(int) (mainColors [(i * 12) + j] [1] * 255.05), 
				(int) (mainColors [(i * 12) + j] [2] * 255.05));
				NXWrite (stream, buffer, strlen (buffer));			}
		NXSaveToFile (stream, "/me/scannercolors");
		NXCloseMemory (stream, NX_FREEBUFFER);
	}
	#endif

	/*  Now make links, roll into transform, cook a circuit and save. */
	
	CiTranCreate();
	isTransformActive = YES;

	[colorLinks  makeSdSnLink: grayRamp: 12];

	/*  mainColors are in SD coordinates.  Transform into SN coordinates  */

	for (i = 0; i < 216; i++)
		CiLinkColor (mainColors [i], mainColors [i], CI_DIR_FORWARD);

	CiLinkAdd();
	CiLinkClose();
	
	[colorLinks  makeSnRcLink: mainColors: 216];

	CiLinkAdd();
	CiLinkClose();

	#ifdef OLDWAY
	if (CiCircCreate (CI_QL_MAX - 2, CI_DIR_FORWARD) != CE_OK)
		NX_RAISE (Err_TransformError5, NULL, NULL);
	if (CiCircWrite (filename) != CE_OK)
		NX_RAISE (Err_TransformError6, NULL, NULL);
	CiCircClose();
	#endif

	if (CiTranWrite (filename) != CE_OK)
		NX_RAISE (Err_TransformError6, NULL, NULL);

	NX_RAISE (Err_NoError, NULL, NULL);
	NX_HANDLER
	if (isTransformActive)
		CiTranClose ();
	if (mainColors)
		NX_FREE (mainColors);
	if (grayRamp)
		NX_FREE (grayRamp);
	HERE_Error (NXLocalHandler.code);
	NX_ENDHANDLER
	return self;
}

/*  This cutesy thing takes the tiff image of our test target using a known cropping 
     arrangement and any DPI.   */

int scanalyze (NXBitmapImageRep *bitmapImage, ColorV* grayRamp, ColorV* mainColors)
{
	int	Return = 0;		//  Assume ok return
	int	scanWidth, scanHeight;
	int	bytesPerPixel;
	int	bytesPerRow;
	int	boxWidth, halfBoxWidth;
	int	i, j;
	PBYTE	imageData, dataPtr, tempPtr;
	ColorV	colorV;
	NXColorSpace	colorSpace;
	float		aspect;

	NX_DURING

	bytesPerPixel 			= [bitmapImage hasAlpha] ? 4: 3;
	bytesPerRow 			= [bitmapImage bytesPerRow];
	scanWidth 			= [bitmapImage pixelsWide];
	scanHeight 			= [bitmapImage pixelsHigh];
	colorSpace 			= [bitmapImage colorSpace];
	boxWidth				= (int) (scanWidth / (float) 12);
	halfBoxWidth			= (boxWidth >> 1);

	if (colorSpace == NX_CMYKColorSpace)
		bytesPerPixel++;

	/*  Do some error proofing queries  */

	if (scanWidth < 300 || scanHeight < 300)
		NX_RAISE (Err_ScanalyzerError2, NULL, NULL);

	if (! (colorSpace == NX_RGBColorSpace || colorSpace == NX_CMYKColorSpace))		NX_RAISE (Err_ScanalyzerError1, NULL, NULL);

	aspect = (float) scanWidth / (float) scanHeight;
	if ((.95 * aspect) >  ((float) 12 / 18))
		NX_RAISE (Err_ScanalyzerError3, NULL, NULL);
		

	/*  Ok here goes.  Superimpose a 12 X 19 grid and subsample colors  */

	imageData 	= [bitmapImage data];

	dataPtr = imageData;
	dataPtr += halfBoxWidth * bytesPerRow;
	dataPtr += halfBoxWidth * bytesPerPixel;

	tempPtr = dataPtr;
	for (i = 0; i < 12; i++)
	{
		subSample (colorV, dataPtr, bytesPerRow, bytesPerPixel);
		memcpy (grayRamp [i], colorV, sizeof (ColorV));
		dataPtr += boxWidth * bytesPerPixel;
	}	

	for (i = 0; i < 18; i++)
	{
	 	dataPtr = tempPtr;
		dataPtr += ((i + 1) * boxWidth * bytesPerRow);
		for (j = 0; j < 12; j++)
		{
			subSample (colorV, dataPtr, bytesPerRow, bytesPerPixel);
			memcpy (mainColors [(i * 12) + j], colorV, sizeof (ColorV));
			dataPtr += boxWidth * bytesPerPixel;
		}	
	}

	NX_RAISE (Err_NoError, NULL, NULL);
	NX_HANDLER
	if (NXLocalHandler.code != Err_NoError)
		NX_RERAISE ();
	NX_ENDHANDLER
	return Return;
}

void subSample (ColorV colorV, PBYTE data, int bytesPerRow, int bytesPerPixel)
{
	int	i, j;
	int	redTotal = 0;
	int   greenTotal = 0;
	int   blueTotal = 0;
	PBYTE	dataPtr;

	for (i = 0; i < 8; i++)	
	{
		dataPtr = data;
		for (j = 0; j < 8; j++)	
		{
			redTotal 		+= dataPtr [0];
			greenTotal 	+= dataPtr [1];
			blueTotal 		+= dataPtr [2];
			dataPtr 		+= bytesPerPixel;
		}
		data += bytesPerRow;
	}

	colorV [0] = (float) redTotal / 255 / 64;
	colorV [1] = (float) greenTotal / 255 / 64;
	colorV [2] = (float) blueTotal / 255 / 64;
}

@end
