#import "OPISupport.h"

/*  Some globals are necessary for every good large program... */

extern	char			*untitledFilename;
extern	Candela_Hack 	candela;
extern	Flt			progressPortion;		
extern	Flt			progressDone;

@implementation OutputProfileInspector (SupportMethods)

/*  Reads measurements from filename into buffer (make sure buffer is big enough!)  */

- (int) readMeasurementsFromFile: (char *) filename: (ColorV *) colors: (int) count: (BOOL) report
{
	int			Return 		= YES;
	NXStream	*stream		= NULL;
 	char			*textBuffer	= NULL;
	char			*buffer 		= NULL;
	int			status 		= INKMODEL_ERR_NONE;
	int			fileSize;
	int			i;
	int			response;
	BOOL		attemptToFix 	= NO;
	BOOL		useAnyway	= NO;

	NX_DURING

	stream = 	NXMapFile (filename, NX_READONLY);
	if (! stream)
		NX_RAISE (Err_FileOpenError, NULL, NULL);	
	NXSeek (stream, 0L, NX_FROMEND);
	fileSize =  NXTell (stream);

 	NX_MALLOC (textBuffer, char, fileSize);	
	if (! textBuffer)
		NX_RAISE (Err_MemoryAllocationError, NULL, NULL);

	NX_MALLOC (buffer, char, 2048);
	if (! buffer)
		NX_RAISE (Err_MemoryAllocationError, NULL, NULL);

	NXSeek (stream, 0L, NX_FROMSTART);
 	if (NXRead (stream, textBuffer, fileSize) != fileSize)
		NX_RAISE (Err_FileReadError, NULL, NULL);

	if (stream)
		NXClose (stream);
	stream = NULL;		

	/*  First go thru and fix up possible CR/LF problems  */

	for (i = 0; i < (fileSize - 1); i++)
		if (textBuffer [i] == 0x0D || textBuffer [i] == 0x0A)
		{
			textBuffer [i] = 0x0A;
			if (textBuffer [i + 1] == 0x0A)
				textBuffer [i + 1] = 32;
		}

	/*  Now attempt to reformat text into floats  */

	stream = NXOpenMemory (NULL, 0, NX_READWRITE);
	if (! stream)
		NX_RAISE (Err_FileOpenError, NULL, NULL);
	if (NXWrite (stream, textBuffer, fileSize) != fileSize)
 		NX_RAISE (Err_FileWriteError, NULL, NULL);

	NXSeek (stream, 0L, NX_FROMSTART);

	for (i = 0; i < count; i++)
	{
 		colors [i][0] = colors [i][1] = colors [i][2] = 0;    // Initialize
		NXScanf (stream, "%f %f %f\n", &colors [i][0], &colors [i][1], &colors [i][2]);
	}


	/*  Look for some bad readings.  This is a bit messed because of last-minute adding
	     fo CMYK 320 Inkmodel checking / fixing stuff                                             */

	if (count == 16)
		for (i = 0; i < count; i++)
		{
			if (colors [i][0] <= 0 || colors [i][1] <= 0 || colors [i][2] <= 0)
				status = INKMODEL_ERR_DENSITY;
			else
				if (colors [i][0] > 4.0 || colors [i][1] > 4.0 || colors [i][2] > 4.0)
					status = INKMODEL_ERR_DENSITY;
		}
	else	
	if (count == 320)	           		
		status = checkInkmodel (colors, NO); 

	if (report)
	{
		switch (status)
		{
			case INKMODEL_ERR_DENSITY:
				response = NXRunAlertPanel ("Ink Model Problem", "Illegal density measurements were detected.  Density measurements must be between 0.0 and 4.0.  This Ink Model can not be loaded.", "Cancel Load", NULL, NULL);
				Return = NO;
				break;

			/*  These errors mean we really want them to calibrate as 3 color  */

			case  INKMODEL_ERR_A:
			case  INKMODEL_ERR_B:
			sprintf (buffer, "This Ink Model can not be used reliably to make a 4 Color profile. This is because it has extremely unpredictable response patterns.  You can attempt to fix it, but it is strongly recommended you calibrate the device as 3 Color.  Or, if that is not feasible, you may enable relaxed CMYK processing in this panel to adjust for this problem.");

				response = NXRunAlertPanel ("Ink Model Problem", buffer, "Attempt To Fix", 				"Cancel Load", NULL);
				
				if (response == NX_ALERTDEFAULT)
					attemptToFix = YES;
				else
					Return = NO;
			break;

			/*  These errors are worth noting but should not be a show stopper  */

			case  INKMODEL_ERR_C:
			case  INKMODEL_ERR_D:
			case  INKMODEL_ERR_E:
			sprintf (buffer, "This Ink Model may produce an unreliable 4 Color profile. This is because it has some unpredictable response patterns.  You can attempt to fix it, or use it unchanged.  Enabling relaxed CMYK processing in this panel will also attempt to compensate for the problem.  If undesirable results occur, consider calibrating the device as 3 Color.");

				response = NXRunAlertPanel ("Ink Model Problem", buffer, "Attempt To Fix", 
				"Use Unchanged", "Cancel Load", NULL);
				
				if (response == NX_ALERTDEFAULT)
					attemptToFix = YES;
				else
					if (response == NX_ALERTALTERNATE)
						useAnyway = YES;	
					else
						Return = NO;
			break;

			default:	
			sprintf (buffer, "Read %s.", filename);
			[olStatusLine setStringValue: buffer];
			break;
		}
	}

	if (! Return)
		[olStatusLine setStringValue: "Ink Model not loaded."];

	if (attemptToFix)	
	{
		status = checkInkmodel (colors, YES); 
		[olStatusLine setStringValue: "Ink Model loaded after attempt to fix."];
	}

	if (useAnyway)	
	{
		[olStatusLine setStringValue: "Loaded Ink Model anyway without fixing it."];
	}

	NX_RAISE (Err_NoError, NULL, NULL);	// Do this to get allocations cleaned up
	NX_HANDLER
	if (textBuffer)
	 	NX_FREE (textBuffer);
	if (buffer)
		NX_FREE (buffer);
	if (stream)
		NXCloseMemory (stream, NX_FREEBUFFER);
	HERE_RERAISE();
	NX_ENDHANDLER
	return Return;
}

- previewProcess: (int) process
{
	NXBitmapImageRep 		*sourceImage;
	NXBitmapImageRep			*newImage 	= nil;
	NXImage					*newNXImage 	= nil;
	NXSize					newImageSize;
	PBYTE					pData, pDataPtr;
	int						status;
	OutputProfile				*tempProfile;
	uchar 					*ip [3];
	uchar 					*op [4];
	int						iStep;	
	int						oStep = 3;
	int						pixelsWide;
	int						pixelsHigh;
	BOOL					bOutofRange;
	BOOL					isCircuitActive = NO;
	BOOL					isTransformActive = NO;
	int						i,j;
	ColorV					sourceV, destV;
	ColorV 					primaries [3];
	long						refWhite;
	Flt						gamma [3];
	NXRect					cancelButtonFrame;
	MonitorSpace				adaptedMonitorSpace;

	NX_DURING

	/*  Grab the monitor space stuff (in case it changed)  */

	[controller monitorColorSpace: &monitorSpace];

	#ifdef NO_ADAPTATION
	/*  Set RCS to whitepoint-adapted primaries and D65 whitepoint  */ 

	adaptWhitepoint (&monitorSpace, &adaptedMonitorSpace, (long) REFWHITE);
	#endif

	/*  Set RCS to monitor's primaries and D65 whitepoint  */ 

	memcpy (&adaptedMonitorSpace, &monitorSpace, sizeof (MonitorSpace));

	primaries [0] [0] = adaptedMonitorSpace.redChroma_x;
	primaries [0] [1] = adaptedMonitorSpace.redChroma_y;
	primaries [0] [2] = 0;
	primaries [1] [0] = adaptedMonitorSpace.greenChroma_x;
	primaries [1] [1] = adaptedMonitorSpace.greenChroma_y;
	primaries [1] [2] = 0;
	primaries [2] [0] = adaptedMonitorSpace.blueChroma_x;
	primaries [2] [1] = adaptedMonitorSpace.blueChroma_y;
	primaries [2] [2] = 0;
	gamma [0] = monitorSpace.redGamma;
	gamma [1] = monitorSpace.greenGamma;
	gamma [2] = monitorSpace.blueGamma;	
 	refWhite = (long) REFWHITE;

	#ifndef DELTA_E
	if (CiCmsRcsSet (primaries, refWhite, CI_CT_GAMMA, gamma) != CE_OK)
 		NX_RAISE (Err_TransformError0, NULL, NULL);
	#else
	setupD50RCS (&monitorSpace);
	if (REFWHITE == 5000)
		NXLogError ("soft proof using D50 Ref White");
 	#endif

	if (REFWHITE == 5000)
		NXLogError ("Using D50 Ref White");

	CiTranCreate ();	
	isTransformActive = YES;

	/*  Set olPreviewImage2 to be print preview of Image1  */

	if ([olFullScreenPreview state])
		sourceImage 	= [olPreviewImage1 draggedBitmapImage];
	else
		sourceImage 	= [olPreviewImage1 bitmapImage];

	if (! sourceImage)
		NX_RAISE (Err_InternalError, NULL, NULL);

	iStep = [sourceImage hasAlpha] ? 4: 3;

	#define COPYIMAGE

	#ifdef COPYIMAGE
	newImage = [[NXBitmapImageRep alloc] initData:  NULL
			pixelsWide: [sourceImage pixelsWide]
			pixelsHigh: [sourceImage pixelsHigh] 
			bitsPerSample: [sourceImage bitsPerSample] 
			samplesPerPixel: [sourceImage samplesPerPixel] 
			hasAlpha: [sourceImage hasAlpha] 
			isPlanar: [sourceImage isPlanar] 
			colorSpace: [sourceImage colorSpace] 
			bytesPerRow: [sourceImage bytesPerRow] 
			bitsPerPixel: [sourceImage bitsPerPixel]];

	if (! newImage)
		NX_RAISE (Err_MemoryAllocationError, NULL, NULL);

	memcpy ([newImage data], [sourceImage data], [sourceImage bytesPerRow] *
			[sourceImage pixelsHigh]);

 	[sourceImage getSize: &newImageSize];
	[newImage setSize: &newImageSize];
	#else
	newImage = sourceImage;
	#endif

	pixelsWide 	= [newImage pixelsWide];
	pixelsHigh	= [newImage pixelsHigh];
	
	/*  Now set up color transform stuff  */

	NX_MALLOC (tempProfile, OutputProfile, 1);
	if (! tempProfile)
		NX_RAISE (Err_MemoryAllocationError, NULL, NULL);

	[self copyFieldsToProfile: tempProfile];
 
	pData 	= [newImage data];
	pDataPtr 	= pData;

	/*  Either case, we think about it a little bit  */

	[olStatusLine setStringValue: "Thinking..."];
	NXPing();

	if (process == SOFT_PROOF) 
	{
		[colorLinks addRcHnLink: tempProfile -> rchnRCSColors:
							[self referenceRcHnColors]:
							tempProfile -> rchnColorsUsed:
							numRcHnColors: CI_FDIR_NATIVE];
 
 		if (deviceType == CMYK_4COLOR)
 			[colorLinks addHnPnLink: tempProfile: CI_FDIR_NATIVE: useRelaxedInkmodel];
 // 			[colorLinks addHnHdLink: tempProfile: CI_FDIR_NATIVE];
		else
			[colorLinks addHnHdLink: tempProfile: CI_FDIR_NATIVE];
		
		if (deviceType == CMYK_4COLOR)
 			[colorLinks addHnPnLink: tempProfile: CI_FDIR_INVERSE: useRelaxedInkmodel];
// 			[colorLinks addHnHdLink: tempProfile: CI_FDIR_INVERSE];
		else
			[colorLinks addHnHdLink: tempProfile: CI_FDIR_INVERSE];

		[colorLinks addRcHnLink: tempProfile -> rchnRCSColors:
							[self referenceRcHnColors]:
							tempProfile -> rchnColorsUsed:
							numRcHnColors: CI_FDIR_INVERSE];
 
		status = CiCircCreate (CI_QL_MIN + 2, CI_DIR_FORWARD);
		if (status != CE_OK)
			NX_RAISE (Err_TransformError5, NULL, NULL);
		isCircuitActive = YES;

		/*  These are duplicated separately because of quirkiness w/canceling circuits */

		[olCancelButton setEnabled: YES];
		[olCancelButton getFrame: &cancelButtonFrame];
		abandon = NO;

		[olStatusLine setStringValue: "Processing..."];
		NXPing();

		for (i = 0; i < pixelsHigh; i++)
		{
			if ((i % 4) == 0)
			{ 
				[olProgressView setPercent: (float) (i + 1) / (float) pixelsHigh];
				[self pollMessages: olOutputProfInspPanel: &cancelButtonFrame];
				if (abandon)
					NX_RAISE (Err_UserAbandon, NULL, NULL);

			}
		 	ip [RGB_R] = pDataPtr;
			ip [RGB_G] = pDataPtr + 1;
			ip [RGB_B] = pDataPtr + 2;

 			op [RGB_R] = pDataPtr;
			op [RGB_G] = pDataPtr + 1;
			op [RGB_B] = pDataPtr + 2;

			oStep = iStep;
		  	status = CiCircColor ((int) pixelsWide, ip, iStep, op, oStep);
			pDataPtr += [sourceImage bytesPerRow];
		}		
  		CiCircClose ();		
		isCircuitActive = NO;
	}
	else		
	{			 
		[colorLinks addRcHnLink: tempProfile -> rchnRCSColors:
							[self referenceRcHnColors]:
							tempProfile -> rchnColorsUsed:
							numRcHnColors: CI_FDIR_NATIVE];
 
		/*  These are duplicated separately because of quirkiness w/canceling circuits */

		[olCancelButton setEnabled: YES];
		[olCancelButton getFrame: &cancelButtonFrame];
		abandon = NO;

		[olStatusLine setStringValue: "Processing..."];
		NXPing();

		for (i = 0; i < pixelsHigh; i++)
		{
 			if ((i % 4) == 0)
			{
				[olProgressView setPercent: (float) (i + 1)  / (float) pixelsHigh];
				[self pollMessages: olOutputProfInspPanel: &cancelButtonFrame];
				if (abandon)
					NX_RAISE (Err_UserAbandon, NULL, NULL);
			}

			pDataPtr 		= pData;
			for (j = 0; j < pixelsWide; j++)
			{
				bOutofRange = NO;
		
				sourceV [0] = (float) pDataPtr [0] / 255;
				sourceV [1] = (float) pDataPtr [1] / 255;
				sourceV [2] = (float) pDataPtr [2] / 255;
				if (CiTranColor (sourceV, destV, CI_DIR_FORWARD) != CE_OK)
					NX_RAISE (Err_TransformError7, NULL, NULL);
		
				if (destV [0] > 1 || destV [1] > 1 || destV [2] > 1)
					bOutofRange = YES;
				else
					if (destV [0] < 0 || destV [1] < 0 || destV [2] < 0)						bOutofRange = YES;

				if (bOutofRange)
				{
					pDataPtr [0] = 255;
					pDataPtr [1] = 255;
					pDataPtr [2] = 0;
				}
				pDataPtr += iStep;
			}
			pData += [newImage bytesPerRow];
		}
	}

	if (! [olFullScreenPreview state])
	{
		NXImage *oldImage;
	
		/*  This is a different track than if full screen is requested.  All the noodling with
		     freeing and initializing below is really req'd to get it all to work  */

		newNXImage = [[NXImage alloc] initSize: &newImageSize];
		[newNXImage useRepresentation: newImage];

		#if 1
		oldImage = [olPreviewImage2 image];
		if (oldImage)
			[oldImage free];
		#endif

		#if 0	
		/*  This should free everything  */

		[olPreviewImage2 setImage: nil];
		#endif

		/*  Now put the small view sized bitmap in it  */
	
		[olPreviewImage2 setImage: newNXImage];
		[newNXImage removeRepresentation: newImage];    //  Frees newImage
		newImage = nil;                                                   //  For NX_HANDLER
	}
	else
	{
		NXStream *stream;
		int     	msgDelivered;
		int		fileOpened; 
		id      	speaker 	= [[Speaker alloc] init]; 		port_t  	port 		= NXPortFromName ("Preview", NULL); 
		char		filename [MAXPATHSIZE];

		if (port == PORT_NULL)
			NX_RAISE (Err_InternalError, NULL, NULL);

		[speaker setSendPort: port]; 

		/*  Many errors below!  error handling  */

		if (process == SOFT_PROOF) 
		{
			strcpy (filename, [controller hereDirectory]);
			strcat (filename, "/Original.tiff");
	    		stream = NXOpenMemory (NULL, 0, NX_READWRITE);
			if (! stream)
				NX_RAISE (Err_FileOpenError, NULL, NULL);
			if (! [sourceImage writeTIFF: stream usingCompression: 
				NX_TIFF_COMPRESSION_NONE])
				NX_RAISE (Err_MemoryAllocationError, NULL, NULL);
			if (NXSaveToFile (stream, filename) == -1)
				NX_RAISE (Err_FileWriteError, NULL, NULL);
			NXCloseMemory (stream, NX_FREEBUFFER);
			msgDelivered = [speaker openFile: filename ok: &fileOpened]; 
			unlink (filename);

			strcpy (filename, [controller hereDirectory]);
			strcat (filename, "/Simulated-Output.tiff");
	    		stream = NXOpenMemory (NULL, 0, NX_READWRITE);
			if (! stream)
				NX_RAISE (Err_FileOpenError, NULL, NULL);
			if (! [newImage writeTIFF: stream usingCompression: 
				NX_TIFF_COMPRESSION_NONE])
				NX_RAISE (Err_MemoryAllocationError, NULL, NULL);
			if (NXSaveToFile (stream, filename) == -1)
				NX_RAISE (Err_FileWriteError, NULL, NULL);
			NXCloseMemory (stream, NX_FREEBUFFER);
			msgDelivered = [speaker openFile: filename ok: &fileOpened]; 
			unlink (filename);
		}
		else
		{
			strcpy (filename, [controller hereDirectory]);
			strcat (filename, "/OutOfRange.tiff");
	    		stream = NXOpenMemory (NULL, 0, NX_READWRITE);
			if (! stream)
				NX_RAISE (Err_FileOpenError, NULL, NULL);
			if (! [newImage writeTIFF: stream usingCompression: 
				NX_TIFF_COMPRESSION_NONE])
				NX_RAISE (Err_MemoryAllocationError, NULL, NULL);
			if (NXSaveToFile (stream, filename) == -1)
				NX_RAISE (Err_FileWriteError, NULL, NULL);
			NXCloseMemory (stream, NX_FREEBUFFER);
			msgDelivered = [speaker openFile: filename ok: &fileOpened]; 
			unlink (filename);
		}
   		[speaker free];    
		port_deallocate (task_self(), port); 
	}

	NX_RAISE (Err_NoError, NULL, NULL);
	NX_HANDLER
	if (isCircuitActive)
		CiCircClose(); 
	if (isTransformActive)
		CiTranClose ();
	[controller setDefaultRCS];
	[olProgressView setPercent: 0];
	[olCancelButton setEnabled: NO];
 	if (newImage)
 		[newImage free]; 
//	if (newNXImage)
//		[newNXImage free];				                     
	if (NXLocalHandler.code == Err_UserAbandon)
		[olStatusLine setStringValue: "Canceled"];
	if (NXLocalHandler.code == Err_NoError)
		[olStatusLine setStringValue: "Done"];
	else
		NX_RERAISE();
	NX_ENDHANDLER

	return self;
}
- (void) initColorWells: (NXColorWell **) colors: (BOOL) enabled
{
	NXColor color = NXConvertRGBAToColor (1, 1, 1, NX_NOALPHA);
	int	i;

	if (! enabled)
	{
		for (i = 0; i < NUM_VISUAL_RCHNCOLORS; i++)
		{
			[colors [i] setColor: color];
			[colors [i] setEnabled: NO];
		}
		[olBlankColor setEnabled: NO];
		[olExtendedColors setEnabled: NO];
		[olLoadTeachMe setEnabled: YES];
	}
	else
	{	
		for (i = 0; i < 6; i++)
			[colors [i] setEnabled: YES];

		[colors [0] setColor: NXConvertRGBAToColor (1, 0, 0, NX_NOALPHA)];
		[colors [1] setColor: NXConvertRGBAToColor (0, 1, 0, NX_NOALPHA)];
		[colors [2] setColor: NXConvertRGBAToColor (0, 0, 1, NX_NOALPHA)];
		[colors [3] setColor: NXConvertRGBAToColor (0, 1, 1, NX_NOALPHA)];
		[colors [4] setColor: NXConvertRGBAToColor (1, 0, 1, NX_NOALPHA)];
		[colors [5] setColor: NXConvertRGBAToColor (1, 1, 0, NX_NOALPHA)];

		for (i = 6; i < NUM_VISUAL_RCHNCOLORS; i++)
		{
			[colors [i] setColor: color];
			[colors [i] setEnabled: YES];
		}
		
		[olBlankColor setEnabled: YES];
		[olExtendedColors setEnabled: YES];
		[olLoadTeachMe setEnabled: NO];
	}
}


- (void) pollMessages: (id) panel: (NXRect *) frame
{
	int			eventMask;
	NXEvent		*event;
	
	eventMask = [panel eventMask];
	do 
	{
		event = [NXApp getNextEvent: eventMask waitFor: 0.01
		threshold:NX_BASETHRESHOLD];

		if (event)
			if (NXMouseInRect (&event -> location, frame, NO))
				[NXApp sendEvent: event];

	} while (event != NULL);
}

- (BOOL) abandon
{
	return abandon;
}

- copyFieldsToProfile: (OutputProfile *) profile
{
 	int		 	i;
	NXColor		monitorColor;
	NXColor		whiteColor;

	/*  Grab the monitor space stuff (in case it changed)  */

	[controller monitorColorSpace: &monitorSpace];

	/*  And blank everything just to be safe  */

	memset (profile, 0, sizeof (OutputProfile));

	/*   Now transfer all the various fields from the inspector to memory  */

	[olGCRCurve getPoints: profile -> GCR];
	profile -> blackPoint	= [olBlackpointText floatValue];
	profile -> TAC 			= [olTACText floatValue] / 100;

	/*  Grab interface colors and convert to RCS colors  */

	whiteColor = NXConvertRGBAToColor (1, 1, 1, NX_NOALPHA);

	if (teachMeType == TEACHME_VISUAL)	// Visual domain
		for (i = 0; i < numRcHnColors; i++)
		{
			monitorColor = [visualColors [i] color];
 			if (NXEqualColor (monitorColor, whiteColor))
				profile -> rchnColorsUsed [i] = NO;
			else
			{
				[colorLinks monitorColorToRCS: profile -> rchnRCSColors [i]: monitorColor: 										    &monitorSpace];
				profile -> rchnColorsUsed [i] = YES;
			}
		}
	else	// Convert from CIE Chromaticities to RCS space
	{
		for (i = 0; i < numRcHnColors; i++)
		{
			CiCmsRcsColor (CI_XYZ_TO_RCS, measuredCIEColors [i], 
							profile -> rchnRCSColors [i]);
			profile -> rchnColorsUsed [i] = YES;
		}
	}

	/*  Get the alt mixes and device type stuff */

	profile -> useAlternateMixes 	= [olAlternateMixes state];	profile -> deviceType 		= deviceType;
	profile -> teachMeType 		= ([[olTeachMeType cellAt: 0: TEACHME_VISUAL] intValue] == 1)
								? TEACHME_VISUAL : TEACHME_INSTRUMENT;
	profile -> processingQuality	= ([[olProcessingQuality cellAt: MAX_QUALITY: 0] intValue] == 1)
								? MAX_QUALITY : DRAFT_QUALITY;

	memcpy (profile -> inkDensities, inkDensities, (320 * sizeof (ColorV)));
	
	strcpy (profile -> inkmodelFilename, inkmodelFilename);
	strcpy (profile -> teachMeFilename, teachMeFilename);
	
	profile -> useRelaxedInkmodel = useRelaxedInkmodel;


	/*  Do the version / type stuff.  This could be put elsewhere, it's unrelated to all above  */
	{
		int	majorVersion, minorVersion, isSpecial;

		[controller getVersionInfo: &majorVersion: &minorVersion: &isSpecial];
		profile -> majorVersion = (char) majorVersion;
		profile -> minorVersion = (char) minorVersion;

		if (! [controller isDemo])
			if (isSpecial)
				profile -> tag = PROFILE_SPECIAL;
			else
				profile -> tag = PROFILE_NORMAL;
		else
			profile -> tag = PROFILE_DEMO;
	}
	return self; 
}

- copyFieldsFromProfile: (OutputProfile *) profile
{
	int	 		i;	
	NXColor		monitorColor;

	/*  Grab the monitor space stuff (in case it changed)  */

	[controller monitorColorSpace: &monitorSpace];

	/*  Now take care of the shadow copies of everything  */

	teachMeType 			= profile -> teachMeType;
	deviceType 			= profile -> deviceType;
 	useRelaxedInkmodel	= profile -> useRelaxedInkmodel;

	memcpy (inkDensities, profile -> inkDensities, (320 * sizeof (ColorV)));
	strcpy (inkmodelFilename, profile -> inkmodelFilename);
	strcpy (teachMeFilename, profile -> teachMeFilename);

	/*   Now transfer all the various fields from memory to the inspector  */

	[olGCRCurve setPoints: profile -> GCR: 5];
	[olBlackpointSpin setRange: 0.0: 1.0 step: 0.01 startAt: profile -> blackPoint];
	[olTACSlidey setRange: 200: 400 startAt: profile -> TAC * 100];

	/*  Convert RCS stored values back to CIE chromaticities  */

	if (teachMeType == TEACHME_INSTRUMENT)
	{
		numRcHnColors = NUM_INSTRUMENT_RCHNCOLORS;
		for (i = 0; i < numRcHnColors; i++)
			CiCmsRcsColor (CI_RCS_TO_XYZ, profile -> rchnRCSColors [i], 
										measuredCIEColors [i]);
		[self initColorWells: visualColors: NO];
	}
	else
	{
		numRcHnColors = NUM_VISUAL_RCHNCOLORS;

		/*  Take RCS colors, convert to monitor colors and set it into interface  */
		/*  Hopefully, we don't encounter colors that are out of monitor range right??? */

		[self initColorWells: visualColors: YES];
		for (i = 0; i < numRcHnColors; i++)
		{
			if (profile -> rchnColorsUsed [i])
				monitorColor = [colorLinks rcsColorToMonitor: profile -> rchnRCSColors [i]: 							  &monitorSpace];
			else
				monitorColor = NXConvertRGBAToColor (1, 1, 1, NX_NOALPHA);

			[visualColors [i] setColor: monitorColor];
		}
	}


	[olAlternateMixes setState: profile -> useAlternateMixes];

	/*  Blank out the radio buttons  */

	for (i = 0; i < 3; i++)
	{
		[[olDeviceType cellAt: i: 0] setState: 0];
		[[olProcessingQuality cellAt: i: 0] setState: 0];
		[[olTeachMeType cellAt: 0: i] setState: 0];
	}

	[[olDeviceType cellAt: profile -> deviceType: 0] setState: 1];
	[[olProcessingQuality cellAt: profile -> processingQuality: 0] setState: 1];
	[[olTeachMeType cellAt: 0: profile -> teachMeType] setState: 1];

	[olDeviceType selectCellAt: profile -> deviceType: 0];
	[olProcessingQuality selectCellAt: profile -> processingQuality: 0];
	[olTeachMeType selectCellAt: 0: profile -> teachMeType];

	return self;
}

- (ColorV *) referenceRcHnColors
{
	if ([olAlternateMixes state])
		return [colorLinks altReferenceRGB];
	else
		return [colorLinks referenceRGB: teachMeType];
}


/*  Saves the current set of links into a transform file.  Assumes CCIR 709 reference space  */

- (int) makeTransform: (OutputProfile *) profile
{
	BOOL		is4Color;

	NX_DURING

	#ifdef DELTA_E
	setupD50RCS (&monitorSpace);
	if (REFWHITE == 5000)
		NXLogError ("makeTransform Using D50 Ref White");
	#endif

 	/*  Keep the transform stuff at outermost level because of error-handling conditions */

	CiTranCreate();
	 	
	/*  Now add the links to the transform (3 or 4 color transforms) */
	
	[colorLinks addRcHnLink: profile -> rchnRCSColors:
						[self referenceRcHnColors]:
						profile -> rchnColorsUsed:
						numRcHnColors: CI_FDIR_NATIVE];
	
	is4Color = (deviceType == CMYK_4COLOR);
	if (is4Color)
	{
		[colorLinks addHnPnLink: profile: CI_FDIR_NATIVE: useRelaxedInkmodel];
		[colorLinks addPnPdLink: profile: CI_FDIR_NATIVE];
	}
	else
		[colorLinks addHnHdLink: profile: CI_FDIR_NATIVE];
	
	/*  Save the transform  */

	if (CiTranWrite ("Profile.hc1") != CE_OK)
		NX_RAISE (Err_TransformError6, NULL, NULL);
		
	NX_RAISE (Err_NoError, NULL, NULL);
	NX_HANDLER
	CiTranClose();
	HERE_RERAISE();
	NX_ENDHANDLER
		
     	return CE_OK;
}


/*  This guy also assumes CMS is OPEN...  */

- (int) cookRenderdict: (OutputProfile *) profile
{
	int			status;	
	BOOL		is4Color;
	float 		ir, ig, ib;
	BYTE		redCount, greenCount, blueCount;
	ColorV		sourceV, destV;
	float			redRange, greenRange, blueRange;
	float			redStep, greenStep, blueStep;
	BYTE		cyan, magenta, yellow, black;
	BYTE		numSteps;
	NXRect		cancelButtonFrame;

	NX_DURING

	#ifdef DELTA_E
	setupD50RCS (&monitorSpace);
	if (REFWHITE == 5000)
		NXLogError ("cookRenderdict Using D50 Ref White");
	#endif


 	/*  Keep the transform stuff at outermost level because of error-handling conditions */

	CiTranCreate();

	/*  First look at quality requested, and convert to a number of steps  */

	numSteps = (profile -> processingQuality == MAX_QUALITY) ? 
				CRD_TABLE_SIZE : CRD_TABLE_SIZE >> 1;  
 	numSteps--;	
	 	

	/*  Now add the links to the transform (3 or 4 color transforms) */
	
	[colorLinks addRcHnLink: profile -> rchnRCSColors:
						[self referenceRcHnColors]:
						profile -> rchnColorsUsed:
						numRcHnColors: CI_FDIR_NATIVE];
	
	is4Color = (deviceType == CMYK_4COLOR);
	if (is4Color)
	{
		[colorLinks addHnPnLink: profile: CI_FDIR_NATIVE: useRelaxedInkmodel];
		[colorLinks addPnPdLink: profile: CI_FDIR_NATIVE];
	}
	else
		[colorLinks addHnHdLink: profile: CI_FDIR_NATIVE];
	
	/*  Cook a Rendering dict into memory  */

	redRange 	= (1.125 - (-0.375));
	greenRange 	= (1 - (-0.125));
	blueRange 	= (1 - (-0.25));
 
	redStep 		= redRange / numSteps;
	greenStep 	= greenRange / numSteps;
	blueStep 		= blueRange / numSteps;

	[olCancelButton setEnabled: YES];
	[olCancelButton getFrame: &cancelButtonFrame];
	abandon = NO;

//	progressDone 		+= progressPortion;
//	progressPortion	= (float) 2 / 3;
 	progressPortion	= (float) 1.0;

	[olStatusLine setStringValue: "Saving...  Click Stop to Cancel"];
	NXPing();

	redCount = 0;
 	for (ir = -0.375; ir <= 1.125 + 0.05; ir += redStep)
	{
		[olProgressView setPercent: 
 		progressDone + (((ir + 0.375) / redRange) * progressPortion)];

		[self pollMessages: olOutputProfInspPanel: &cancelButtonFrame];
		if (abandon)
			NX_RAISE (Err_UserAbandon, NULL, NULL);

		greenCount = 0;			
		for (ig = -0.125; ig <= 1.0 + 0.05; ig += greenStep)
		{
			blueCount = 0;

			for (ib = -0.25; ib <= 1.0 + 0.05; ib += blueStep)
			{
				sourceV [0] = ir;
				sourceV [1] = ig;
				sourceV [2] = ib;
					
				status = CiTranColor (sourceV, destV, CI_DIR_FORWARD);
				if (status != CE_OK)
 					NX_RAISE (Err_TransformError7, NULL, NULL);

				/*  This is an idiot bug-fix for bubbly jet printer driver   */

				if (profile -> processingQuality == DRAFT_QUALITY)
					if (destV [0] < 0.025 && destV [1] < 0.025 && destV [2] < 0.025)
						destV [0] = destV [1] = destV [2] = 0.0;

				cyan 	= (BYTE) (destV [0] * 255);
				magenta 	= (BYTE) (destV [1] * 255);
				yellow 	= (BYTE) (destV [2] * 255);
				black 	= (BYTE) (destV [3] * 255);

				profile -> renderDict [0] [blueCount] [greenCount] [redCount] = cyan;
				profile -> renderDict [1] [blueCount] [greenCount] [redCount] = magenta;
				profile -> renderDict [2] [blueCount] [greenCount] [redCount] = yellow;
				profile -> renderDict [3] [blueCount] [greenCount] [redCount] = black;

				blueCount++;
 			}
			greenCount++;
		}
		redCount++;
	}

	NX_RAISE (Err_NoError, NULL, NULL);
	NX_HANDLER
	CiTranClose();
//	[olProgressView setPercent: 0];	>> Moved to HANDLER of WriteProfile
//	[olCancelButton setEnabled: NO];
	HERE_RERAISE();
	NX_ENDHANDLER
		
     	return CE_OK;
}

- (BOOL) isDocEdited
{
	if (! olOutputProfInspPanel)
	{
		NXLogError ("No panel, returning docedited = NO");
		return NO;
	}
	else
		return [olOutputProfInspPanel isDocEdited];
}



char deviceTypeFromMatrix (Matrix *matrix)
{
	int 		i;
	char		Return = 0;

	for (i = 0; i < 3; i++)
		if ([[matrix cellAt: i: 0] intValue])
			Return = (char) i;

	return Return;
}

void cmslibProgress (Flt done)
{
	[candela.progressView setPercent: progressDone + (done * progressPortion)];
	[candela.outputProfileInspector pollMessages: 
	candela.olOutputProfInspPanel: &candela.cancelButtonFrame];
	if ([candela.outputProfileInspector abandon])
		candela.abandon = YES;
}

BOOL cmslibAbort (void)
{
	BOOL Return = candela.abandon;
	candela.abandon = NO;
	return Return;
}

- (void) checkCIEModel: (ColorV *) colors
{
	int i;
	int	j;
	BOOL	decimalMoved = YES;

	for (i = 0; i < numRcHnColors;  i++)
	{
		for (j = 0; j < 3; j++)
			if (colors [i] [j] > 5.0)
				decimalMoved = NO;
	}
	
	/*  If it's not been moved, move it  */

	if (! decimalMoved)
		for (i = 0; i < numRcHnColors;  i++)
			for (j = 0; j < 3; j++)
				colors [i] [j] = colors [i] [j] / 100.0;

}


void setupD50RCS (MonitorSpace *space)
{
	ColorV 					primaries [3];
	long						refWhite;

	/*  Set RCS to CCIR 709 primaries and D50 whitepoint  */ 

	primaries [0] [0] = space -> redChroma_x;
	primaries [0] [1] = space -> redChroma_y;
	primaries [0] [2] = 0;
	primaries [1] [0] = space -> greenChroma_x;
	primaries [1] [1] = space -> greenChroma_y;
	primaries [1] [2] = 0;
	primaries [2] [0] = space -> blueChroma_x;
	primaries [2] [1] = space -> blueChroma_y;
	primaries [2] [2] = 0;
 	refWhite = (long) REFWHITE;
 	if (CiCmsRcsSet (primaries, refWhite, CI_CT_709, NULL) != CE_OK)
		HEREAlert ("error setting up D50 RCS");
}




@end

