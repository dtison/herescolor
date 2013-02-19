#import "OutputProfileInspector.h"
#import "Controller.h"

#import "OPIMainMethods.h"

@implementation OutputProfileInspector: Responder

/*  Some globals are necessary for every good large program... */

char			*untitledFilename = "Untitled";
Candela_Hack 	candela;
Flt			progressPortion;		
Flt			progressDone;

/*  Called when user requests a new profile  */

- newProfile
{
	NX_DURING
	[[olViewPopup itemList] selectCellAt: 0: 0];
	[self setSetupView: self];

	/*  This is by itself so docEdited will return correct values in setup  */

	[olOutputProfInspPanel setDocEdited: YES];

	[self setupProfile];
	[self initProfile];

	[self copyFieldsToProfile: &outputProfile];

	// This is how we will handle the OEM version "Save CRD..." button

	#ifdef OEM
	[olInstallButton  setEnabled: NO];
	[olInstallButton  setTransparent: YES];
	#endif

	[olOutputProfInspPanel setDelegate: self];
	[olOutputProfInspPanel makeKeyAndOrderFront: self];

	NX_HANDLER
	HERE_HANDLER
	NX_ENDHANDLER

	return self;
}

/*  This code is an imposter for an -init.. of some kind  */

- setupProfile
{
	NXRect	rect;

	controller 	= [NXApp delegate];
	colorLinks 	= [[ColorLinks alloc] init];
	visualColors 	= (NXColorWell **) &olVisualColor0;

	isActive = YES;

	[olPreviewImage1 setEditable: YES];
	[olPreviewImage1 setCreateBitmaps: YES];
	[olPreviewImage2 setEditable: NO];

 	[self processingQualitySet: olProcessingQuality];
 
	[controller monitorColorSpace: &monitorSpace];

	/*  Take care of some superfluous stuff  */

	[[olMeasurementsText1 docView] getFrame: &rect];
	measurementsText1 = [[Text alloc] initFrame: &rect];
	[measurementsText1 setVertResizable: YES];
	[measurementsText1 setEditable: NO];
	[olMeasurementsText1 setDocView: measurementsText1];

	[[olMeasurementsText2 docView] getFrame: &rect];
	measurementsText2 = [[Text alloc] initFrame: &rect];
	[measurementsText2 setVertResizable: YES];
	[measurementsText2 setEditable: NO];
	[olMeasurementsText2 setDocView: measurementsText2];

	candela.progressView 			= olProgressView;
	candela.outputProfileInspector	= self;
	candela.olOutputProfInspPanel	= olOutputProfInspPanel;
	candela.abandon				= NO;
	[olCancelButton getFrame: &candela.cancelButtonFrame];

	return self;
}		

/*  Initializes UI as if a "default-of-defaults" profile were read in   */

- initProfile
{
	float		positions [5];
	char		szBuffer [MAXPATHSIZE];
	int		i;

	NX_DURING

	/*  Allocate and init stuff.  Presumably some of these will be read from defaults database  */

	numRcHnColors = NUM_VISUAL_RCHNCOLORS;

	strcpy (szFilename, untitledFilename);
	[olOutputProfInspPanel setTitleAsFilename: szFilename];
	
	[self initColorWells: visualColors: YES];

	/*  Set up the Color sep screen  */

	positions [0] = 0.75;
	positions [1] = 0.50;
	positions [2] = 0.375;
	positions [3] = 0.25;
	positions [4] = 0.0;

 	[olGCRCurve setPoints: positions: 5];
	[olBlackpointSpin setRange: 0.0: 1.0 step: 0.01 startAt: 0.0];
	[olTACSlidey setRange: 200: 400 startAt: 300];

	/*  Read in matchprint (aka Default) inkmodel  */

	#ifndef HERESCRD
	strcpy (szBuffer, [controller inkmodelDirectory]);
	#endif
	strcat (szBuffer, "/Default.Inkmodel");
 	[self readMeasurementsFromFile: szBuffer: inkDensities: 320: NO];
	strcpy (inkmodelFilename, szBuffer);
	
	/*  Blank out the radio buttons  */

	for (i = 0; i < 3; i++)
	{
		[[olDeviceType cellAt: i: 0] setState: 0];
		[[olProcessingQuality cellAt: i: 0] setState: 0];
		[[olTeachMeType cellAt: 0: i] setState: 0];
	}

	[olAlternateMixes setState: NO];
	[[olDeviceType cellAt: CMYK_4COLOR: 0] setState: 1];
	[[olTeachMeType cellAt: 0: TEACHME_VISUAL] setState: 1];
	[[olProcessingQuality cellAt: MAX_QUALITY: 0] setState: 1];

	[olDeviceType selectCellAt: CMYK_4COLOR: 0];
	[olTeachMeType selectCellAt: 0: TEACHME_VISUAL];
	[olProcessingQuality selectCellAt: MAX_QUALITY: 0];


	/*  --- Defaults to visual profile.  (No need to initialize measuredCIEColors)  */

	teachMeType 	= TEACHME_VISUAL;
	deviceType 	= CMYK_4COLOR;

	if (teachMeType == TEACHME_VISUAL)		// For consistency only
	{ 
		[olBlankColor setEnabled: YES];
		[olExtendedColors setEnabled: YES];
		[olLoadTeachMe setEnabled: NO];
	}

	NX_HANDLER
	HERE_RERAISE();
	NX_ENDHANDLER

	return self;
}

- (BOOL) openProfile: (char *) filename
{
	/*  Basic setup, if needed  */

	if (! controller) 
		[self setupProfile];

	[olOutputProfInspPanel setDocEdited: NO];

	/*  Read the thing in and set up our values from it  */
 
	NX_DURING
	[[olViewPopup itemList] selectCellAt: 0: 0];
	[self setSetupView: self];

	[self readProfile: filename];

	if (outputProfile.tag == PROFILE_DEMO)
		HEREAlert (PROFILE_IS_DEMO); 
	[olOutputProfInspPanel setTitleAsFilename: filename];
	strcpy (szFilename, filename);

	[olOutputProfInspPanel setDelegate: self];
	[olOutputProfInspPanel makeKeyAndOrderFront: self];

	NX_HANDLER
	HERE_RERAISE();
    	NX_ENDHANDLER
	return YES;
}

- (int) readProfile: (char *) filename
{
	NXStream		*stream 		= NULL;
	NXTypedStream 	*typedStream 	= NULL;
	char				currentDirectory [MAXPATHSIZE];

	NX_DURING

	getwd (currentDirectory);
	if (chdir (filename) == -1)
		NX_RAISE (Err_FileReadError, NULL, NULL);

	stream = NXMapFile ("Profile", NX_READONLY);
	if (! stream)
		NX_RAISE (Err_FileOpenError, NULL, NULL);	
	typedStream = NXOpenTypedStream (stream, NX_READONLY);
	if (! typedStream)
		NX_RAISE (Err_FileReadError, NULL, NULL);
	readMABProfile (typedStream, &outputProfile);
	
	[self copyFieldsFromProfile: &outputProfile];

	NX_RAISE (Err_NoError, NULL, NULL);
	NX_HANDLER
	chdir (currentDirectory);
	if (typedStream)
		NXCloseTypedStream (typedStream);	//  This also gets stream closed
	HERE_RERAISE();
	NX_ENDHANDLER
	return 0;
}

- loadInkmodel: sender
{
	id 		openPanel = [OpenPanel new];
	int		status;
	int		count;
	ColorV	*densities = NULL;

	NX_DURING

 	[openPanel setTitle: "Load Ink Model"];
	[openPanel setAccessoryView: nil];
    	[openPanel setRequiredFileType:"Inkmodel"];

	NX_MALLOC (densities, ColorV, 320);
	if (! densities)
		NX_RAISE (Err_MemoryAllocationError, NULL, NULL);

	count = (deviceType == CMYK_4COLOR) ? 320 : 16;
	#ifndef HERESCRD
	status = [openPanel runModalForDirectory: 
				[controller inkmodelDirectory] 
				file: NULL];
	#endif
	if (status)
	{
 		if ([self readMeasurementsFromFile: (char *) [openPanel filename]: 
									densities: count: YES])
		{
			memcpy (inkDensities, densities, sizeof (ColorV) * 320);
			strcpy (inkmodelFilename, [openPanel filename]);
			[olOutputProfInspPanel setDocEdited: YES];
		}
	}

	NX_RAISE (Err_NoError, NULL, NULL);
	NX_HANDLER
	if (densities)
		NX_FREE (densities);
	HERE_HANDLER
	return nil;
	NX_ENDHANDLER
	return self;
}

- loadTeachMe: sender
{
	id 		openPanel = [OpenPanel new];
	int		status;

	NX_DURING

 	[openPanel setTitle: "Load CIE Model"];
	[openPanel setAccessoryView: nil];
    	[openPanel setRequiredFileType:"CIE"];

	#ifndef HERESCRD
	status = [openPanel runModalForDirectory: 
				[controller teachMeDirectory] 
				file: NULL];
	#endif

	if (status)
	{
		/*  Try to read measurements.  */

 		if ([self readMeasurementsFromFile: (char *) [openPanel filename]: 
			measuredCIEColors: numRcHnColors: YES])
		{
			[self checkCIEModel: measuredCIEColors];
			strcpy (teachMeFilename, [openPanel filename]);
			[olOutputProfInspPanel setDocEdited: YES];
		}
	}
	NX_HANDLER
	HERE_HANDLER
	return nil;
	NX_ENDHANDLER
	return self;
}

/*  Prints Calibration Target for RcHn link.  Either 36 Chips (Visual) or 216 chip target. */

-  printRcHnPattern: sender
{
	PrinterChipsView *printerChipsView 	= nil;
	NXRect		printerChipsRect;
	PrintInfo		*printInfo;
	OutputProfile *tempProfile 	= NULL;
	BOOL		isTransformActive = NO;	

	NX_DURING
	printerChipsRect.origin.x 	= 
	printerChipsRect.origin.y 	= 0.0;
 	printerChipsRect.size.width 	= 8.5 * 72;
 	printerChipsRect.size.height 	= 11.0 * 72;
 
	/*  Use PrintInfo to scale print  */

	printInfo = [NXApp printInfo];	
	[printInfo setVertPagination: NX_FITPAGINATION];
	[printInfo setHorizPagination: NX_FITPAGINATION];

	/*  If printing the RGB216, need to setup landscape orientation */

	if (teachMeType == TEACHME_INSTRUMENT)
	{
		printerChipsRect.size.width 	= 11.0 * 72;
 		printerChipsRect.size.height 	= 8.5 * 72;
		[printInfo setOrientation: NX_LANDSCAPE andAdjust: YES];
	}

	[olOffscreenWindow setDelegate: self];
	printerChipsView = [[PrinterChipsView alloc] initFrame: &printerChipsRect];
  	[olOffscreenScrollView setDocView: printerChipsView];

	/*  Now make an open transform with current settings in it  */

	NX_MALLOC (tempProfile, OutputProfile, 1);
	if (! tempProfile)
		NX_RAISE (Err_MemoryAllocationError, NULL, NULL);

	[self copyFieldsToProfile: tempProfile];

	/*  Zero out GCR, UCR & Black point settings   */

	tempProfile -> TAC = 4.0;
	tempProfile -> GCR [0] = 
	tempProfile -> GCR [1] = 
	tempProfile -> GCR [2] = 
	tempProfile -> GCR [3] = 
	tempProfile -> GCR [4] = 0.0;
	tempProfile -> blackPoint = 0.0; 

	CiTranCreate ();
	isTransformActive = YES;
	
	/*   Make a transform of only Hn->Pd or Hn->Hd */

	if (deviceType == CMYK_4COLOR)
	{
		[colorLinks addHnPnLink: tempProfile: CI_FDIR_NATIVE: useRelaxedInkmodel];
 		[colorLinks addPnPdLink: tempProfile: CI_FDIR_NATIVE];
	}
	else
	{
		[colorLinks addHnHdLink: tempProfile: CI_FDIR_NATIVE];
	}

 	[printerChipsView setColorType: deviceType];
 	[printerChipsView setTargetType: teachMeType];

	[printerChipsView printPSCode: self];

	NX_RAISE (Err_NoError, NULL, NULL);
	NX_HANDLER
	[printInfo setOrientation: NX_PORTRAIT andAdjust: YES];
	if (isTransformActive);
		CiTranClose ();
  	[olOffscreenScrollView setDocView: nil];
	if (printerChipsView)
		[printerChipsView free];
//	HERE_RERAISE();
	HERE_HANDLER
	NX_ENDHANDLER

	return self;
}


#if 0
{
	NX_DURING
	if (teachMeType == TEACHME_VISUAL)
		[self printVisualRcHnPattern];
	else
		[self printInstrumentRcHnPattern];

	NX_HANDLER
	HERE_HANDLER
	NX_ENDHANDLER
	return self;
}
#endif

- printInkmodelPattern: sender
{
	PatternView 	*patternView	= NULL;
	NXRect		patternRect;
	PrintInfo		*printInfo;

	NX_DURING

	patternRect.origin.x = 
	patternRect.origin.y = 0.0;
	patternRect.size.width 	= 8.5 * 72;
	patternRect.size.height 	= 11.0 * 72;

	/*  Use PrintInfo to scale print  */

	printInfo = [NXApp printInfo];	
	[printInfo setVertPagination: NX_FITPAGINATION];
	[printInfo setHorizPagination: NX_FITPAGINATION];

	[olOffscreenWindow setDelegate: self];
	patternView = [[PatternView alloc] initFrame: &patternRect];
 	[patternView setPatternType: deviceType];	
  	[olOffscreenScrollView setDocView: patternView];

	[patternView printPSCode: self];

	NX_RAISE (Err_NoError, NULL, NULL);
	NX_HANDLER
  	[olOffscreenScrollView setDocView: nil];
	if (patternView)
		[patternView free];
	HERE_HANDLER
	NX_ENDHANDLER

	return self;
}


- doPreview: sender
{
	[self previewProcess: SOFT_PROOF];
	return self;
}

- doOutofRange: sender
{
	[self previewProcess: OUT_OF_RANGE];
	return self;
}

- showMeasurements: sender
{
	int		numValues;
	char 	*textBuffer			= NULL;	
	char		*densitiesTextBuffer	= NULL;
	char		*densitiesText;
	int		i;
	int		bufferLen;
	ColorV	*cieColors = NULL;

	NX_DURING

	NX_MALLOC (cieColors, ColorV, numRcHnColors);
		
	/*  Grab values from interface (really only needed for visual mixes)  */

	[self copyFieldsToProfile: &outputProfile];

	/*  Do that densities text thing  */

	numValues = (deviceType == CMYK_4COLOR) ? 320 : 16;

	NX_MALLOC (textBuffer, char, MAXPATHSIZE);
	NX_MALLOC (densitiesTextBuffer, char, 10000);

	densitiesText = densitiesTextBuffer;
	for (i = 0; i < numValues; i++)
	{
		sprintf (textBuffer, "%2d - %7.3f\t%7.3f\t%7.3f\n", i + 1,
		inkDensities [i][0],
		inkDensities [i][1],
		inkDensities [i][2]);

		bufferLen = strlen (textBuffer);
		memcpy (densitiesText, textBuffer, bufferLen);
		densitiesText += bufferLen;
	}
	*densitiesText = 0;

	[[measurementsText1 window] disableDisplay];
	[measurementsText1 setText: densitiesTextBuffer];
	[measurementsText1 sizeToFit];
	[[measurementsText1 window] reenableDisplay];
	[olMeasurementsText1 display];

	numValues = numRcHnColors;

	/*  Grab the correct number set  */

	if (teachMeType == TEACHME_INSTRUMENT)
		memcpy (cieColors, measuredCIEColors, (numRcHnColors * sizeof (ColorV)));
	else
		for (i = 0; i < numValues; i++)
			CiCmsRcsColor (CI_RCS_TO_XYZ, 	outputProfile.rchnRCSColors [i], cieColors [i]);

	densitiesText = densitiesTextBuffer;
	for (i = 0; i < numValues; i++)
	{
		sprintf (textBuffer, "%2d - %7.3f\t%7.3f\t%7.3f\n", i + 1,
		cieColors [i][0],
		cieColors [i][1],
		cieColors [i][2]);

		bufferLen = strlen (textBuffer);
		memcpy (densitiesText, textBuffer, bufferLen);
		densitiesText += bufferLen;
	}
	*densitiesText = 0;

	[[measurementsText2 window] disableDisplay];
	[measurementsText2 setText: densitiesTextBuffer];
	[measurementsText2 sizeToFit];
	[[measurementsText2 window] reenableDisplay];
	[olMeasurementsText2 display];

	[olInkmodelFilename setStringValue: inkmodelFilename];
	if (teachMeType == TEACHME_INSTRUMENT)
		[olTeachMeFilename setStringValue:  teachMeFilename];
	else
		[olTeachMeFilename setStringValue: NO_FILE_LOADED_VISUAL_MIXES];
	
	/*  Now stick it up there modal  */

	[NXApp runModalFor: olMeasurementsPanel];
	[olMeasurementsPanel orderOut: self];

	NX_RAISE (Err_NoError, NULL, NULL);

	NX_HANDLER
	if (cieColors)
		NX_FREE (cieColors);
	if (densitiesTextBuffer)
		NX_FREE (densitiesTextBuffer);
	if (textBuffer)
		NX_FREE (textBuffer);
	HERE_HANDLER
	NX_ENDHANDLER
	return self;
}


- deviceTypeSet: sender
{
	char 	type;
	
	if (deviceType == CMYK_4COLOR)
	{
		type = deviceTypeFromMatrix (olDeviceType);
		if (type != CMYK_4COLOR)
			HEREAlert (CHANGE__TO_3COLOR);
		[olOutputProfInspPanel setDocEdited: YES];

	}
	else
	{
		type = deviceTypeFromMatrix (olDeviceType);
		if (type == CMYK_4COLOR)
			HEREAlert (CHANGE__TO_4COLOR);
		[olOutputProfInspPanel setDocEdited: YES];

	}
	[olUseRelaxedInkmodel setEnabled: (type == CMYK_4COLOR) ? YES : NO];
	deviceType = type; 
	
	return self;
}

- processingQualitySet: sender
{
	if ([[sender cellAt: DRAFT_QUALITY: 0] intValue] == 1)
		[olProcessingQualityMsg setTextGray: NX_DKGRAY];
	else
		[olProcessingQualityMsg setTextGray: NX_LTGRAY];

	[olOutputProfInspPanel setDocEdited: YES];

	return self;

}

- alternateMixesSet: sender
{
	int			status;

 	if ([sender state]) 
	{
		status = NXRunAlertPanel (ALTERNATE_MIXES, 
						USE_ALTERNATE_MIXES_SET, 
						CANCEL, PROCEED, NULL);
		if (status == NX_ALERTDEFAULT) 				[sender setState: 0];
	}
	else
	{
		status = NXRunAlertPanel (ALTERNATE_MIXES, 
							USE_ALTERNATE_MIXES_UNSET, 
							CANCEL, PROCEED, NULL);
		if (status == NX_ALERTDEFAULT) 				[sender setState: 1];
	}
	[olOutputProfInspPanel setDocEdited: YES];

	return self;
}

//  This may be needed for trapping errors, otherwise remove!  NO WAY!

- teachMeTypeSet: sender;
{
	int			status;
	int			i;

 	if ([[sender cellAt: 0: TEACHME_INSTRUMENT] state] && 
	teachMeType != TEACHME_INSTRUMENT)
	{
		status =NXRunAlertPanel (MEASUREMENT_OPTIONS, INSTRUMENT_BASED_SET,
							 CANCEL, PROCEED, NULL);
		if (status != NX_ALERTDEFAULT)
			[self initColorWells: visualColors:  NO];
		else
		{
			[[sender cellAt: 0: TEACHME_INSTRUMENT] setState: 0];
			[sender selectCellAt: 0: TEACHME_VISUAL];
			[[sender cellAt: 0: TEACHME_VISUAL] setState: 1];
		}
	}
 	else
 	if ([[sender cellAt: 0: TEACHME_VISUAL] state] && teachMeType != TEACHME_VISUAL)
 	{
		status = NXRunAlertPanel (MEASUREMENT_OPTIONS, 
							VISUAL_BASED_SET, CANCEL, PROCEED, NULL);
		if (status != NX_ALERTDEFAULT)
			[self initColorWells: visualColors: YES];
		else
		{
			[[sender cellAt: 0: TEACHME_INSTRUMENT] setState: 1];
			[[sender cellAt: 0: TEACHME_VISUAL] setState: 0];
			[sender selectCellAt: 0: TEACHME_INSTRUMENT];
		}
	}

	teachMeType = [[sender cellAt: 0: TEACHME_VISUAL] state] ? TEACHME_VISUAL :
				TEACHME_INSTRUMENT;

	if (teachMeType == TEACHME_INSTRUMENT)
	{
		ColorV	*rchnColors = [self referenceRcHnColors];

		/*  Need to load the default instrument measurements in case user decides to save */

		numRcHnColors = NUM_INSTRUMENT_RCHNCOLORS;
		for (i = 0; i < numRcHnColors; i++)
			CiCmsRcsColor (CI_RCS_TO_XYZ, rchnColors [i], measuredCIEColors [i]);

		strcpy (teachMeFilename, "Default measurements");
		[olAlternateMixes setState: NO];
		[olAlternateMixes setEnabled: NO];
	}
	else
	{
		numRcHnColors = NUM_VISUAL_RCHNCOLORS;
		strcpy (teachMeFilename, "No file loaded.  (Visual mixes)");
		[olAlternateMixes setEnabled: YES];
	}

	[olOutputProfInspPanel setDocEdited: YES];


	return self;
}

- fullScreenViewSet: sender
{
	BOOL isEditable;

	if ([sender state])
	{
		isEditable = [olPreviewImage2 isEditable];
		[olPreviewImage2 setEditable: YES];
		[olPreviewImage2 setImage: nil];
		[olPreviewImage2 setEditable: isEditable];
	}
	return self;
}

- relaxedInkmodelSet: sender
{
	useRelaxedInkmodel = [sender state];

	if (useRelaxedInkmodel)
		HEREAlert (RELAXED_INKMODEL_ACKNOWLEDGE);

	return self;
}

- colorModified: sender
{
	[olOutputProfInspPanel setDocEdited: YES];
	currentColorWell = sender;
	return self;
}


- saveAs: sender
{
 	id 	savePanel = [SavePanel new];
	id	Return = nil;

	[savePanel setRequiredFileType: "OutputProfile"];

	if ([savePanel runModalForDirectory:
	[controller profileDirectory] 
	file: NULL ])
	{
		strcpy (szFilename, [savePanel filename]);
		[self save: sender];
	}
	return Return;
}

- save: sender
{	
	NX_DURING 

	/*  Grab the monitor space stuff (in case it changed)  */

	[controller monitorColorSpace: &monitorSpace];
	[self writeProfile: szFilename];
	if (! [controller isDemo])
		[self install: self];

	[olOutputProfInspPanel setTitleAsFilename: szFilename];
	[olOutputProfInspPanel setDocEdited: NO];

	NX_HANDLER
	HERE_HANDLER
	NX_ENDHANDLER

	return self;
}

- close: sender
{
	[olOutputProfInspPanel performClose: sender];
	return self;
}

/*  This should be as simple as just re-opening.  */

- revertToSaved: sender
{
	[self openProfile: szFilename];

	return self;
}

- install: sender
{
	NX_DURING

	/*  Grab the monitor space stuff (in case it changed)  */

	[controller monitorColorSpace: &monitorSpace];

	if (! [controller isDemo])
	{
		[self writeCRD: &outputProfile];
		HEREAlert (CRD_INSTALLED_ACKNOWLEDGE);
	}
	else
		HEREAlert (CRD_NOT_INSTALLED_DEMO_ACKNOWLEDGE);

	NX_HANDLER
	HERE_HANDLER
	NX_ENDHANDLER
	return self;
}


- writeProfile: (char *) filename
{
	NXStream		*stream			= NULL;
	NXTypedStream	*typedStream		= NULL;
	char				currentDirectory [MAXPATHSIZE];	struct 			stat 	st;

	NX_DURING

	/*  Set up file package stuff  */

	getwd (currentDirectory);
	if (! stat (filename, &st))
		if (! st.st_mode & S_IFDIR)
		{
			#ifdef LOGERROR
			NXLogError ("Unlinking old file");
			#endif
			unlink (filename); 	// First remove old file
		}
	if (stat (filename, &st) && errno == ENOENT) 
		mkdir (filename, 0755);
	chdir (filename);

	[olStatusLine setStringValue: "Thinking..."];
	NXPing();

	/*  Fill in all the various fields for this  */

	[self copyFieldsToProfile: &outputProfile];
	[self makeTransform: &outputProfile];
	if (! [controller isDemo])
 		[self cookRenderdict: &outputProfile];


	/*  Now open stream and write profile  */

	stream = NXOpenMemory (0, 0, NX_READWRITE);
	if (! stream)
		NX_RAISE (Err_MemoryAllocationError, NULL, NULL);
 
	typedStream = NXOpenTypedStream (stream, NX_WRITEONLY);
	if (! typedStream)
		NX_RAISE (Err_FileWriteError, NULL, NULL);
	writeMABProfile (typedStream, &outputProfile);

	if (NXSaveToFile (stream, "Profile") == -1)
		NX_RAISE (Err_FileWriteError, NULL, NULL);

	NX_RAISE (Err_NoError, NULL, NULL);
	NX_HANDLER	
	[olProgressView setPercent: 0];
	[olCancelButton setEnabled: NO];
	/*  If there was some kind of error, clean up all the mess  */
	if (NXLocalHandler.code != Err_NoError)	
	{
		struct stat st;
		char	name [80];

		strcpy (name, "Profile");
		if (stat (name, &st) == 0)
			unlink (name);
		strcpy (name, "Profile.hc1");
		if (stat (name, &st) == 0)
			unlink (name);
		strcpy (name, "Profile.hc2");
		if (stat (name, &st) == 0)
			unlink (name);
	}
	chdir (currentDirectory);
	if (NXLocalHandler.code != Err_NoError)	
		rmdir (filename);
	if (stream)
		NXCloseMemory (stream, NX_FREEBUFFER);
	if (NXLocalHandler.code == Err_UserAbandon)
		[olStatusLine setStringValue: "Canceled"];
	if (NXLocalHandler.code == Err_NoError)
		[olStatusLine setStringValue: "Done"];
	else
		NX_RERAISE();
	NX_ENDHANDLER

	return self;
}

/*   Write out the CRD with an ascii version of the render table  */

- writeCRD: (OutputProfile *) profile
{
	int 			renderDictLen= 0;
	int			bufferLen = 1024 * 1024;
	char			count;
	BYTE		numSteps;
	char			szBuffer [260];
	char			*buffer		= NULL;
	char			*bufferPtr;
	const char	*string;
	NXStream	*stream		= NULL;
	BOOL		is4Color = (profile -> deviceType == CMYK_4COLOR);
	BYTE		redCount, greenCount, blueCount;
	BYTE		cyan, magenta, yellow, black;
	float			matrix [9];
	ColorV		whitepoint;
	ColorV 		primaries [3];
	long			refWhite;
	Flt			gamma [3];
	MonitorSpace 	adaptedMonitorSpace;

	NX_DURING

	numSteps = (profile -> processingQuality == MAX_QUALITY) ? 
				CRD_TABLE_SIZE : CRD_TABLE_SIZE >> 1; 

	stream = NXOpenMemory (0, 0, NX_READWRITE);
	if (! stream)
		NX_RAISE (Err_MemoryAllocationError, NULL, NULL);

	NX_MALLOC (buffer, char, bufferLen);
	if (! buffer)
		NX_RAISE (Err_MemoryAllocationError, NULL, NULL);
	
	bufferPtr = buffer;

	/*  Set RCS to whitepoint-adapted primaries and D65 whitepoint  */ 

	adaptWhitepoint (&monitorSpace, &adaptedMonitorSpace, (long) REFWHITE);

	primaries [0] [0] = adaptedMonitorSpace.redChroma_x;
	primaries [0] [1] = adaptedMonitorSpace.redChroma_y;
	primaries [0] [2] = 0;
	primaries [1] [0] = adaptedMonitorSpace.greenChroma_x;
	primaries [1] [1] = adaptedMonitorSpace.greenChroma_y;
	primaries [1] [2] = 0;
	primaries [2] [0] = adaptedMonitorSpace.blueChroma_x;
	primaries [2] [1] = adaptedMonitorSpace.blueChroma_y;
	primaries [2] [2] = 0;
	gamma [0] = gamma [1] = gamma [2] = 1.0;	
 	refWhite = (long) REFWHITE;

	#ifndef DELTA_E
	if (CiCmsRcsSet (primaries, refWhite, CI_CT_GAMMA, gamma) != CE_OK)
		NX_RAISE (Err_TransformError0, NULL, NULL);
	#else
	setupD50RCS (&monitorSpace);
	if (REFWHITE == 5000)
		NXLogError ("write crd using D50 Ref White");
 	#endif
	
	[self makeMatrix: matrix];

	/*  Get the whitepoint XYZ constants for the CRD   */

	CiMiscCalc (CI_CALC_TEMPXYZ, (ulong *) &refWhite, whitepoint);

	[controller setDefaultRCS];

	string = [olStringTable valueForStringKey: "psPart1"];
	sprintf (buffer, string, monitorSpace.redGamma, monitorSpace.greenGamma,
	monitorSpace.blueGamma, matrix [0], matrix [1], matrix [2], matrix [3], matrix [4],
	matrix [5], matrix [6], matrix [7], matrix [8], whitepoint [0], whitepoint [1], whitepoint [2]);
	strcat (buffer, "\n\n");
	if (NXWrite (stream, buffer, strlen (buffer)) != strlen (buffer))
		NX_RAISE (Err_FileWriteError, NULL, NULL);

	string = [olStringTable valueForStringKey: "psPart2"];
	sprintf (buffer, string, whitepoint [0], whitepoint [1], whitepoint [2], 
			numSteps, numSteps, numSteps);
	strcat (buffer, "\n\n");
	if (NXWrite (stream, buffer, strlen (buffer)) != strlen (buffer))
		NX_RAISE (Err_FileWriteError, NULL, NULL);

	for (redCount = 0; redCount < numSteps; redCount++)
	{
		strcpy (szBuffer, "\n<\n");
		bufferLen = strlen (szBuffer);
		memcpy (bufferPtr, szBuffer, bufferLen);
		bufferPtr += bufferLen;
		renderDictLen += bufferLen;

		count = 0;

		for (greenCount = 0; greenCount < numSteps; greenCount++)
		{
			for (blueCount = 0; blueCount < numSteps; blueCount++)
			{
				if (count == 8)
				{
					strcpy (szBuffer, "\n");
					bufferLen = strlen (szBuffer);
					memcpy (bufferPtr, szBuffer, bufferLen);
					bufferPtr += bufferLen;
					renderDictLen += bufferLen;
					count = 0;
				}

				cyan 	= profile -> renderDict [0] [blueCount] [greenCount] [redCount];
				magenta 	= profile -> renderDict [1] [blueCount] [greenCount] [redCount];
				yellow 	= profile -> renderDict [2] [blueCount] [greenCount] [redCount];
				black 	= profile -> renderDict [3] [blueCount] [greenCount] [redCount];

				if (is4Color)
				{
					sprintf (szBuffer, "%02x%02x%02x%02x", (unsigned) cyan,
					(unsigned) magenta, (unsigned) yellow, (unsigned) black);
				}
				else
				{
					sprintf (szBuffer, "%02x%02x%02x", (unsigned) cyan,
					(unsigned) magenta, (unsigned) yellow);
				}

				bufferLen = strlen (szBuffer);
				memcpy (bufferPtr, szBuffer, bufferLen);
				bufferPtr += bufferLen;
				renderDictLen += bufferLen;

				count++;
			}
		}

		strcpy (szBuffer, "\n>\n");
		bufferLen = strlen (szBuffer);
		memcpy (bufferPtr, szBuffer, bufferLen);
		bufferPtr += bufferLen;
		renderDictLen += bufferLen;

	}

	if (NXWrite (stream, buffer, renderDictLen) != renderDictLen)
		NX_RAISE (Err_FileWriteError, NULL, NULL);

	string = [olStringTable valueForStringKey: "psPart3"];

	if (profile -> deviceType == CMYK_4COLOR)
		sprintf (buffer, string, 4);
	else
		sprintf (buffer, string, 3);

 	strcat (buffer, "\n\n");
	if (NXWrite (stream, buffer, strlen (buffer)) != strlen (buffer))
		NX_RAISE (Err_FileWriteError, NULL, NULL);

	strcpy (szBuffer, "/.CurrentCRD");
	if (NXSaveToFile (stream, szBuffer) == -1)
		NX_RAISE (Err_FileWriteError, NULL, NULL);

	NX_RAISE (Err_NoError, NULL, NULL);
	NX_HANDLER
	if (stream)
		NXCloseMemory (stream, NX_FREEBUFFER);
	if (buffer)
		NX_FREE (buffer);
	HERE_RERAISE();
	NX_ENDHANDLER
	return self;
}


/*  These handle inspector views for Output Profile Inspector  */

- setPreviewView: sender
{
	currentView = olPreviewView;

	[olViewPopupButton  setTitle: [[olViewPopupButton target]  selectedItem]];

	[olOutputProfInspView setContentView: currentView];
	[olStatusLine setStringValue: "Drag and drop an image or click \"Pasteboard\""];
	[olOutputProfInspPanel display];

	return self;
}

- setColorSepView: sender
{
	if (deviceType == CMYK_4COLOR && ! useRelaxedInkmodel)
		currentView = olColorSepView;
	else		
		currentView = olNotApplicableView;

	[olViewPopupButton  setTitle: [[olViewPopupButton target]  selectedItem]];

	[olOutputProfInspView setContentView: currentView];
 	if (currentView == olColorSepView)
 		[olStatusLine setStringValue: "Adjust color separation parameters to your choosing."];
	else
 		[olStatusLine setStringValue: ""];
	[olOutputProfInspPanel display];

	return self;
}

- setDensitiesView: sender
{
	currentView = olDensitiesView;

	[olViewPopupButton  setTitle: [[olViewPopupButton target]  selectedItem]];

	[olOutputProfInspView setContentView: currentView];
	[olStatusLine setStringValue: "Load an Ink Model or print calibration target."];
	[olOutputProfInspPanel display];

	return self;
}

- setColorMatchingView: sender
{
 	currentView = olColorMatchingView;

	[olViewPopupButton  setTitle: [[olViewPopupButton target]  selectedItem]];

	[olOutputProfInspView setContentView: currentView];
	if (teachMeType == TEACHME_VISUAL)
		[olStatusLine setStringValue: "Match chips on screen to printed target."];
	else
		[olStatusLine setStringValue: "Load CIE Model or print target."];

	[olOutputProfInspPanel display];

	return self;
}

- setSetupView: sender
{
	BOOL	flag;
 
	currentView = olSetupView;

	[olViewPopupButton  setTitle: [[olViewPopupButton target]  selectedItem]];

	flag = (! [self isDocEdited]);
	[olInstallButton setEnabled: flag];

	[olOutputProfInspView setContentView: currentView];
	[olStatusLine setStringValue: "Setup profile or install it in your system."];
	[olOutputProfInspPanel display];

	return self;
}


- windowWillClose: sender
{
	int	status;

	if ([self isDocEdited])
	{
		status = NXRunAlertPanel (APPNAME, PROFILE_CONFIRM_CLOSE,
							 CLOSE, CANCEL, NULL);
		if (status != NX_ALERTDEFAULT)
			return nil;
	}
	isActive = NO;		

	return self;
}

- blankColor: sender;
{
	NXColor color = NXConvertRGBAToColor (1, 1, 1, NX_NOALPHA);

	if (currentColorWell)
		[currentColorWell setColor: color];
	return self;
}

- doPasteboardImage: sender
{
	NXImage *image;
	Pasteboard *pasteboard = [Pasteboard new];

	image = [[[NXImage alloc] initFromPasteboard: pasteboard] setCacheDepthBounded: NO];
	if (image)
		[olPreviewImage1 setImage: image];
	
	return self;
}


/*  For main menu support only so far  5-18-93  */

- (BOOL) isActive
{
	return isActive;
}


- (BOOL) validateCommand: (MenuCell *) menuCell
{
	SEL 		action = [menuCell action];

	if (action == @selector (save:)) 
		return [self isDocEdited];
	else
		if (action == @selector (revertToSaved:))
			if (strcmp (szFilename, untitledFilename) == 0) // Dont revert from untitled
				return NO;
			else
				return [self isDocEdited];

		return YES;
}

- (void) makeMatrix: (float *) matrix
{
	ColorV	destV;
	int		i;
	int		index;
	ColorV	*rchnColors = NULL;

	NX_DURING
	NX_MALLOC (rchnColors, ColorV, 3);
	if (! rchnColors)
		NX_RAISE (Err_MemoryAllocationError, NULL, NULL);

	/*  Make rchnColors red, green, blue.  First init all zero, then fill in 1.0's */

	for (i = 0; i < 3; i++)
		rchnColors [i] [0] = rchnColors [i] [1] = rchnColors [i] [2] = 0.0;

	rchnColors [0] [0] = 1.0;
	rchnColors [1] [1] = 1.0;
	rchnColors [2] [2] = 1.0;

	for (i = 0; i < 3; i++)
	{
		CiCmsRcsColor (CI_RCS_TO_XYZ, rchnColors [i], destV);

		index = 3 * i;
		matrix [index++] = destV [0];
		matrix [index++] = destV [1];
		matrix [index] 	= destV [2];
	}

	NX_RAISE (Err_NoError, NULL, NULL);
	NX_HANDLER
	if (rchnColors)
		NX_FREE (rchnColors);
	HERE_RERAISE();
	NX_ENDHANDLER
}

- stopPressed: sender
{
	abandon = YES;
	return self;
}



- free
{
	if (colorLinks)
		[colorLinks free];
//	[olPreviewImage1 setImage: nil];
//	[olPreviewImage2 setImage: nil];
	[super free];
	return self;
}




@end

