    
#import "Controller.h"

#include <sys/types.h>
#include <sys/dir.h>

int colorEditImage (NXBitmapImageRep *bitmapImage, NXColor sourceColor, float hueTolerance, float deltaHue, float percentSat, float percentBrightness);

id idGlobalPrometer;
extern int licensed;			// In Registration.m

/*  Controller -- Delegate for our application */

@implementation Controller

#ifdef IMAGEPROCESSING
#define TOOL_SUCCESS 0

/*  Anything that changes an image (alters anything but its size or BitsPerPixel) is sent through
     here.  Tools that alter Bpp or size create new images / ImageDocument instances  */

- doChange: sender
{
	int		toolID = [[sender selectedCell] tag] - 100;
	id		idDocument;
	id		idChange;
	int		nReturn;

	idDocument = [self activeDocument];
	if (idDocument == nil)					     // Something went wrong somewhere
		return self;
		
 	idChange = [[ToolClasses [toolID] allocFromZone: [self zone]]  initWithDocument: idDocument];
	[idChange startChange];
 	nReturn = (int) [idChange go];
	[idChange endChange];
 	 
	return self;
}

- doTransform: sender
{
	HEREAlert ("Doing a transform of the image.  A new image window will be created from the present.");
	return self;
}
#endif

#if 0
- (int) openFile: (const char *) fullPath ok: (int *) flag
{
	NXLogError ("openFile");
	return 0;
}
#endif

#ifdef NOTYET
- (BOOL) appAcceptsAnotherFile: sender
{
	NXLogError ("Accepts another file");
	return YES;
}

- (int)app:sender openFile:(const char *)filename type:(const char *)aType
{
	NXLogError ("Opening...");
	return NO;
}
#endif

#if 0
- (int) app: sender openFile: (const char *) filename type: (const char *) aType
{
	const char	*pFileName;

	NXLogError ("sender openFile");

	/*  This is lifted from the code for the open: action.  Should combine later  */
	
			if (! idOutputProfileInspector)
			{
				idOutputProfileInspector = [[OutputProfileInspector alloc] init];
 		 		[NXApp loadNibSection: "OutputProfInsp.nib" owner: idOutputProfileInspector
								 withNames: NO];

			}
			pFileName = filename;
			[idOutputProfileInspector openProfile: (char *) pFileName];
			strcpy (lastProfileFilename, pFileName);   // error handling

	return 0;
}
#endif

/*  For runModal stuff.  This approach gives us at least Win-equivalent functionality  */

- ok: sender
{
	[NXApp stopModal: YES];
	return self;
}

- cancel: sender
{
	[NXApp stopModal: NO];
	return self;
}


- proMeter
{
	return idPrometer;
}

int cancel (void)
{
	return ((int) [idGlobalPrometer abandon]);
}


/*  general purpose entry point  */
 
- test: sender
{
	return self;
}

- showInfo: sender
{
	char buffer [80];
	int	majorVersion, minorVersion;

	if (! olInfoPanel)
	{
    		[NXApp loadNibSection: "Info.nib" owner: self withNames:NO];
		[olInfoPanel setBecomeKeyOnlyIfNeeded: YES];
	}

	[self getVersionInfo: &majorVersion: &minorVersion: NULL];
	sprintf (buffer, VERSION, majorVersion + ((float) minorVersion / 1000));
	[olInfoVersion setStringValue: buffer];

	[olInfoPanel setDelegate: self];		//  So we are notified when window closes
	[olInfoPanel orderFront: self];
	
	return self;
}

#ifdef PROMETER
- showPrometer: sender
{
	/*  idPrometer SHOULD already exist now  */

	[idPrometer start: YES];

    return self;
}
#endif

- open: sender
{
	char 			szFileName [MAXPATHSIZE];
	id				idOpenPanel;
	id				idImageDocument	= nil;
	char				*profileName 		= NULL;
	const char		*pFileName;	
	NXBitmapImageRep *bitmapImage = nil;
	NXStream		*stream		= NULL;
	char				profile [MAXPATHSIZE];
	
	NX_DURING

	idOpenPanel 	= [self openPanel: sender];

 	[idOpenPanel setDelegate: self];
	if (isOpeningImage)
		[self setOpenImages: self];
	else
		[self setOpenProfiles: self];

	if ([idOpenPanel runModal] == NX_CANCELTAG)
		NX_RAISE (Err_UserAbandon, NULL, NULL);

	pFileName = [idOpenPanel filename];
	if (pFileName)
	{
	 	/* If user wants open image, there's a lot to deal with.   */

		if (isOpeningImage)
		{
			if ([olSelectInputProfile state])
			{
				if  ([self isDemo])
					HEREAlert (CANT_COLOR_CORRECT_IN_DEMO);
				else
					if (isOpeningTiff)
					{			
						/*  Stick the input profiles up there modal  */
	
						if (! olInputProfilesPanel)
						{
					 		[NXApp loadNibSection: "InputProfile.nib" owner: 
							self  withNames: NO];
							[olInputProfilesBrowser setDelegate: self];
						}
				
						if (! [NXApp runModalFor: olInputProfilesPanel])
							NX_RAISE (Err_UserAbandon, NULL, NULL);

						profileName = (char *) 
						[[olInputProfilesBrowser selectedCell] stringValue];

						if (strcmp (profileName, "Uncorrected (No Profile)") == 0)
							profileName = NULL;
					}
					else
						HEREAlert (CANT_COLOR_CORRECT_EPS_IMAGES);
			}

 			idImageDocument = [ImageDocument alloc];
			if (! idImageDocument)
				NX_RAISE (Err_MemoryAllocationError, NULL, NULL);

			if (profileName)	       // Do correction (change path name to corrected..)
			{
				bitmapImage = [[NXBitmapImageRep alloc] initFromFile: pFileName];
				if (! bitmapImage)
					NX_RAISE (Err_MemoryAllocationError, NULL, NULL);
				if ([bitmapImage bitsPerSample] != 8)
				{
					HEREAlert (CANT_COLOR_CORRECT_4BIT_IMAGES );
					NX_RAISE (Err_NoError, NULL, NULL);
				}
				if ([bitmapImage colorSpace] != NX_RGBColorSpace)
					NX_RAISE (Err_ColorCorrectError1, NULL, NULL);
				if ([bitmapImage isPlanar])
					bitmapImage = planesToTriplets (bitmapImage);
				strcpy (profile, [self inputProfileDirectory]);
				strcat (profile, "/");
				strcat (profile, profileName);
				if (strlen (rcmdCircuit) == 0)
				{
					strcpy (rcmdCircuit, "./rcmdCircuit");  // TEMP
					[self cookrcmdCircuit: profile: rcmdCircuit];
				}
  //				#define TESTCOLOREDIT
				#ifdef TESTCOLOREDIT
				{
					NXColor color;

// 					color = NXConvertRGBAToColor (.13, .6, .13, 0);
// 					colorEditImage (bitmapImage, color, .10, -.17, 1.0,  1.15);

 					color = NXConvertRGBAToColor (.96, .78, .035, 0);
 					colorEditImage (bitmapImage, color, .250, .004, 1.4,  .59);
				}
				#else 
 					colorCorrectImage (bitmapImage, rcmdCircuit, olInputProfilesProgress, NX_RGBColorSpace);
				#endif
				[olInputProfilesPanel orderOut: self];
				stream = NXOpenMemory (NULL, 0, NX_READWRITE);
				if (! stream)
					NX_RAISE (Err_FileOpenError, NULL, NULL);
				if (! [bitmapImage writeTIFF: stream])
					NX_RAISE (Err_MemoryAllocationError, NULL, NULL);
				NXSeek (stream, 0L, NX_FROMSTART);
 				[idImageDocument initFromStream: stream];
				untitledDocCount++;
			}
			else
			{
				[olInputProfilesPanel orderOut: self];
				strcpy (szFileName, pFileName);
				[idImageDocument initFromFile: szFileName];
				untitledDocCount++;
				strcpy (lastImageFilename, pFileName);
			}
		}
		else
		{
			if (! idOutputProfileInspector)
			{
				idOutputProfileInspector = [[OutputProfileInspector alloc] init];
 		 		[NXApp loadNibSection: "OutputProfInsp.nib" owner: idOutputProfileInspector
								 withNames: NO];
			}

			[idOutputProfileInspector openProfile: (char *) pFileName];
			strcpy (lastProfileFilename, pFileName);   // error handling
		}
	}

	NX_RAISE (Err_NoError, NULL, NULL);
	NX_HANDLER
	if (stream)
		NXCloseMemory (stream, NX_FREEBUFFER);
	if (bitmapImage)
		[bitmapImage free];
	[olInputProfilesPanel orderOut: self];
	HERE_HANDLER
	NX_ENDHANDLER
	return self;
}

- new: sender
{
	int status;

	status = NXRunAlertPanel (APPNAME, TYPE_DOCUMENT_TO_CREATE,
						OUTPUT_PROFILE, INPUT_PROFILE, CANCEL);

	if (status == NX_ALERTOTHER)	// Cancel
		return self;

	if (status != NX_ALERTDEFAULT)	// Asked for Input Profile
	{
		if (! idScannerCalibrator)
		{
			idScannerCalibrator = [[ScannerCalibrator alloc] init];
  			[NXApp loadNibSection: "ScannerCalibrator.nib" owner: idScannerCalibrator
							 withNames: NO];
		}

		[idScannerCalibrator runOrderFront: self];
	}
	else
	{
		if (! idOutputProfileInspector)
		{
			idOutputProfileInspector = [[OutputProfileInspector alloc] init];
  			[NXApp loadNibSection: "OutputProfInsp.nib" owner: idOutputProfileInspector
							 withNames: NO];
		}

		[idOutputProfileInspector newProfile];
	}
	return self;
}

#ifdef HAVEPRINT
- print: sender;
{
	id	idWindow;
	id  idDocument;

	idWindow = [NXApp keyWindow];
	if (idWindow != nil)
	{
		idDocument = [idWindow delegate];
		if (idDocument != nil)	// TODO: Change this to test if window is image
								// window, remove this test
		    	[[idDocument view] printPSCode: self];

	}

	return self;
}
#endif

/*
Invoked from within the terminate: method immediately before the application terminates.  If this method returns nil, the application is not terminated, and control is returned to the main event loop.  If you want to allow the application to terminate, you should put your clean up code in this method and return non-nil.  */


/*  App Delegate-related methods  */

- appWillTerminate: sender
{
	int		response;
	char		szBuffer [260];

	if (idOutputProfileInspector)
		if ([idOutputProfileInspector isDocEdited])
		{
			response = NXRunAlertPanel (APPNAME, "Profile is not saved.", "Cancel", "Quit Anyway", NULL);
			if (response == NX_ALERTDEFAULT)
				return nil;
		}

	/*  Save the defaults stuff  */

	saveMonitorSpace (&monitorSpace, "HeresColor");
	sprintf (szBuffer, "%5.2f", epsilon);
	NXWriteDefault ("HeresColor", "epsilon", szBuffer);

	CiCmsClose();

	return self;
}

- appDidInit: sender
{
 	PBYTE		pDefault;
	const char	*homeDirectory;
	int			status;

	/*  Check defaults for our special setting.. */

	isSpecial = NO;
	pDefault = (PBYTE) NXGetDefaultValue ("HeresColor", "Special");
	if (pDefault)
		if (strcmp (pDefault, "In principio erat verbum") == 0)
			isSpecial = YES;

	isRoot = strncmp (NXUserName(), "root", 4) == 0 ? YES : NO;
	if (isRoot)
		NXLogError ("User is root");
	
	homeDirectory = NXHomeDirectory ();

	/*  Set up various path stuff  */
 
  	strcpy (hereDirectory, homeDirectory);
  	strcpy (hiddenDirectory, homeDirectory);
  	strcpy (profileDirectory, homeDirectory);
    	strcpy (inputProfileDirectory, homeDirectory);
	strcpy (inkmodelDirectory, homeDirectory);
    	strcpy (teachMeDirectory, homeDirectory);
	strcpy (imageDirectory, homeDirectory);
 
  	strcat (hereDirectory, "/Apps/HeresColor");
   	strcat (hiddenDirectory, "/Apps/.HeresColor");
	strcat (profileDirectory, "/Apps/HeresColor/Printers");
	strcat (inputProfileDirectory, "/Apps/HeresColor/Scanners");
	strcat (inkmodelDirectory, "/Apps/HeresColor/InkModels");
	strcat (teachMeDirectory, "/Apps/HeresColor/CIEModels");

	if (chdir (hereDirectory) != 0)
		status = mkdir (hereDirectory, 0755);

	if (chdir (profileDirectory) != 0)
		mkdir (profileDirectory, 0755);

	if (chdir (inputProfileDirectory) != 0)
		mkdir (inputProfileDirectory, 0755);

	if (chdir (inkmodelDirectory) != 0)
		mkdir (inkmodelDirectory, 0755);

	if (chdir (teachMeDirectory) != 0)
		mkdir (teachMeDirectory, 0755);

	strcpy (lastImageFilename, [self imageDirectory]);
	strcpy (lastProfileFilename, [self profileDirectory]);
	
	/*  Set up the monitor space info  */

	initDefaultMonitorSpace (&monitorSpace);
	getMonitorSpace (&monitorSpace, "HeresColor");

	pDefault = (PBYTE) NXGetDefaultValue ("HeresColor", "epsilon");
	if (! pDefault)
		epsilon = 2.2;
	else
		epsilon = (float) atof (pDefault);

	CiCmsOpen ();

	[self setDefaultRCS];


	/*  Grab the current working directory  */

	getwd (szAppDir); 

	#ifdef PROMETER
	/*  Allocate an app-public prometer instance  */

  	idPrometer= [[Prometer allocFromZone: [self zone]] init]; 
 	idGlobalPrometer= idPrometer; 
	#endif	


	/*  Setup for reading images nicely  */

//  	[NXImage registerImageRep: [BMPImageRep class]];  
	#ifdef WESPLIT
  	[NXImage registerImageRep: [TIFImageRep class]];  
	#endif

	/*  This sets up our application menu  */

	initMenu ([NXApp mainMenu]);

	/*  Set up pasteboard send/receive types ("fudging" services while we're at it)   */
 
	pbReceiveTypes [0] = NXTIFFPboardType;
	pbReceiveTypes [1] = NXPostScriptPboardType;
	pbReceiveTypes [2] = NULL;
	pbSendTypes [0]    = NXTIFFPboardType;
	pbSendTypes [1]    = NULL;
	pbSendTypes [2]    = NULL;

	[NXApp registerServicesMenuSendTypes: NULL 
	andReturnTypes: pbReceiveTypes];

	#ifdef TOOLBOX
	/*  Turn off key window status for toolbox  */

	[olToolBox setBecomeKeyOnlyIfNeeded: YES];
	#endif
	
	/*  As far as I can tell, this must be on for menus to work properly  */

	[NXApp setAutoupdate: YES];

//	[[NXColorPanel sharedInstance: YES] setAccessoryView: olColorPanelAccessoryView];
//	/*  Hokey workaround for nib loader "bug"  */
//	[olColorPanelAccessoryView init];

	untitledDocCount = 1;

	return self;
}


/*  Return the currently active document, nil if there is none  */

- activeDocument;
{
	return [findDocument (NULL) delegate];
}

- windowWillClose: sender
{
	return self;
}


- (BOOL) menuItemUpdate: (MenuCell *) menuCell
{
	SEL action;
	id responder, target;
	BOOL enable;

	target = [menuCell target];
	enable = [menuCell isEnabled];

	if (! target) 
	{
		action = [menuCell action];
		responder = [NXApp calcTargetForAction: action];

		if ([responder respondsTo: @selector (validateCommand:)]) 
	    		enable = [responder validateCommand: menuCell]; 
		else
			enable = responder ? YES : NO;
	}

	if ([menuCell isEnabled] != enable) 
	{
		[menuCell setEnabled: enable];
		return YES;
    	} 
	else 
		return NO;

}


- (BOOL) validateCommand: (MenuCell *) menuCell
{
	SEL 		action = [menuCell action];
	BOOL	bHaveHit = NO;

		if (action == @selector (paste:)) 
			return [self checkPasteboard: nil];
		else
			#if 0
			if (action == @selector (runMonitorCalibrator:)) 
				if (idOutputProfileInspector)
					return (! [idOutputProfileInspector isActive]);
				else
					return YES;
			else
				if (action == @selector (new:) || action == @selector (open:)) 
					if (idMonitorCalibrator)
						return (! [idMonitorCalibrator isActive]);
					else
						return YES;
				else
			#endif

					if (action == @selector (setupPrinters:))
						return (isRoot);

	if (bHaveHit)
		return ((BOOL) (findDocument (NULL) != nil));
	
	return YES;
}

/*  TODO:  -- Use the changeCount approach (for validateCommand only) --  
	Also - this technique will likely change if/when PostScriptPboardType is supported  */

- (BOOL) checkPasteboard: (Pasteboard *) pBoard
{
	id		idPB;
	NXAtom 	retValue;

	if (pBoard == nil)
		idPB = [Pasteboard new];
	else
		idPB = pBoard;

	retValue = [idPB findAvailableTypeFrom: pbReceiveTypes num: NUM_PB_RECEIVE_TYPES];

	return (BOOL) (retValue != NULL);
}

void initMenu (Menu *menu)
{
	int count;
	Matrix *matrix;
	MenuCell *cell;
	id matrixTarget, cellTarget;

	matrix = [menu itemList];
	matrixTarget = [matrix target];

	count = [matrix cellCount];
	while (count--)
	{ 
		cell = [matrix cellAt: count: 0];
		cellTarget = [cell target];
		if (! matrixTarget && ! cellTarget)
	    		[cell setUpdateAction: @selector (menuItemUpdate:) forMenu: menu];
		 else 
			if ([cell hasSubmenu])
	   			 initMenu (cellTarget);

	}
}
 
 /*
   Searches the window list looking for a Document with the specified name.
   Returns the window containing the document if found.
   (If name == NULL then the first document found is returned.    */

Window *findDocument (const char *name)
{
	int count;
	ImageDocument *document;
	Window *window;
	List *windowList;

	windowList = [NXApp windowList];
 	count = [windowList count];
	while (count--)
	{
		window = [windowList objectAt: count];
		document = documentInWindow (window);
		if ([document isSameAs: name]) 
			return window;
    }

    return nil;
}

/*
    Checks to see if the passed window's delegate is a DrawDocument.
    If it is, it returns that document, otherwise it returns nil.
 */

ImageDocument *documentInWindow (Window *window)
{
	id document = [window delegate];
	return [document isKindOf: [ImageDocument class]] ? document : nil;
}

- (NXAtom *) getPBSendTypes
{
	return pbSendTypes;
}

/*  We process paste in Controller because we only paste as new document now.  11-27-92  */

- paste: sender;
{
	id 			idPB = [Pasteboard new];
	NXStream	*stream = NULL;

	if (! [self checkPasteboard: nil])
	{
		HEREAlert (INTERNAL_PASTEBOARD_ERROR);
		return self;
	}

	NX_DURING
	stream = [idPB readTypeToStream: NXTIFFPboardType];
	[[ImageDocument alloc] initFromStream: stream];
	untitledDocCount++;

	NX_RAISE (Err_NoError, NULL, NULL);
	NX_HANDLER
	if (stream)
		NXCloseMemory (stream, NX_FREEBUFFER);
	if (NXLocalHandler.code > NX_APPBASE)
		HERE_Error (NXLocalHandler.code);
	else
		NX_RERAISE();
	NX_ENDHANDLER
	return self;
}

-saveAll: sender
{
	return self;
}

/*  The next two methods are for Services menu support. 11-27-92   Now need to look at
     send types and possible other receive types.  We now only support receive TIFF.  */

- validRequestorForSendType: (NXAtom) sendType andReturnType: (NXAtom) returnType
{

   	if ((sendType == NXTIFFPboardType || sendType == NULL) &&
        (returnType == NXTIFFPboardType || returnType == NULL) )
    {
                         return self;
      
    }
	return nil;
}

- readSelectionFromPasteboard: (Pasteboard *) pBoard
{
	NXStream	*stream;
		
	if (! [self checkPasteboard: pBoard])
	{
		HEREAlert (INTERNAL_PASTEBOARD_ERROR);
		return self;
	}
	
	stream = [pBoard readTypeToStream: NXTIFFPboardType];
	[[ImageDocument alloc] initFromStream: stream];
	untitledDocCount++;
	NXCloseMemory (stream, NX_FREEBUFFER);
	return self;
}

- runMonitorCalibrator: sender
{

	if (! idMonitorCalibrator)
	{
		idMonitorCalibrator = [[MonitorCalibrator alloc] init];
 		[NXApp loadNibSection: "MonitorCalibrator.nib" owner: idMonitorCalibrator
							 withNames: NO];
	}

	[idMonitorCalibrator runOrderFront: self];

	return self;
}

- (char *) hereDirectory
{
	return hereDirectory;
}

- (char *) hiddenDirectory
{
	return hiddenDirectory;
}

- (char *) profileDirectory
{
	return profileDirectory;
}

- (char *) inputProfileDirectory
{
	return inputProfileDirectory;
}

- (char *) inkmodelDirectory
{
	return inkmodelDirectory;
}

- (char *) teachMeDirectory
{
	return teachMeDirectory;
}

- (char *) imageDirectory
{
	return imageDirectory;
}

- (SavePanel *) savePanel: sender
/*  	Returns a SavePanel with the accessory view which allows the user to
	pick which type of file he wants to save.  The title of the Panel is
	set to whatever was on the menu item that brought it up (it is assumed
	that sender is the menu that has the item in it that was chosen to
	cause the action which requires the SavePanel to come up).  */
{
   	 SavePanel *savepanel = [SavePanel new];

    	if (! olSavePanelAccessoryView)
 		[NXApp loadNibSection: "SavePanelAccessory.nib"
		owner:self withNames:NO fromZone: [savepanel zone]];
 
 //   theTitle = cleanTitle([[sender selectedCell] title], title);
 //   if (theTitle) [savepanel setTitle:theTitle];
    	[savepanel setAccessoryView: olSavePanelAccessoryView];
//    [spamatrix selectCellAt:0 :0];
//    [savepanel setRequiredFileType:"draw"];

    	return savepanel;
}

- (OpenPanel *) openPanel: sender
{
 	OpenPanel *openpanel = [OpenPanel new];

    	if (! olOpenPanelAccessoryView)
 		[NXApp loadNibSection: "OpenPanelAccessory.nib"
		owner: self withNames: NO fromZone: [openpanel zone]];
 
	[openpanel setAccessoryView: olOpenPanelAccessoryView];

    	return openpanel;
}

/*  Respond to "Images" and "Profiles" Buttons on Open Panel  */

- setOpenImages: sender
{
	OpenPanel *panel = [OpenPanel new];

	[olSelectInputProfile setEnabled: YES];
 	[panel setDirectory: lastImageFilename];
 	[panel setTitle: "Open Image"];
	isOpeningImage = YES;

	return self;
}

- setOpenProfiles: sender
{
	OpenPanel *panel = [OpenPanel new];
 
  	[olSelectInputProfile setEnabled: NO];
   	[panel setDirectory: lastProfileFilename];
 	[panel setTitle: "Open Output Profile"];
	isOpeningImage = NO;

	return self;
}

- monitorColorSpace: (MonitorSpace *) space
{
	memcpy (space, &monitorSpace, sizeof (MonitorSpace));
	return self;
}

- setMonitorColorSpace: (MonitorSpace *) space
{
	memcpy (&monitorSpace, space, sizeof (MonitorSpace));
	saveMonitorSpace (&monitorSpace, "HeresColor");
	return self;
}

- (void) setDefaultRCS
{
	char 		szPath [MAXPATHSIZE];

	/*  This ought to set everything back to CCIR 709 space  */

	CiCmsClose();
	CiCmsOpen();

	strcpy (szPath, hiddenDirectory);
	strcat (szPath, "/");
	CiCmsPathSet (szPath);
}


- setupPrinters: sender
{
	doPrinters();		//  Defined in HEREutils.m
	HEREAlert (SETUP_PRINTERS_ACKNOWLEDGE);
	return self;
}


- (void) getVersionInfo: (int *) major: (int *) minor: (int *) special
{
	*major = MAJOR_VERSION;
	*minor = MINOR_VERSION;
	if (special)
		*special = isSpecial;
}

- (BOOL) isDemo
{
	return (! (BOOL) licensed);
}

- (BOOL) isRoot
{
	return (isRoot);
}

- uninstallCRD: sender
{
	struct stat st;
	char		crd [80];

	strcpy (crd, "/.CurrentCRD");	

	if (stat (crd, &st) == 0)
	{
		unlink (crd);
		HEREAlert (CRD_UNINSTALL_ACKNOWLEDGE);
	}
	else	
		HEREAlert (CRD_UNINSTALL_UNACKNOWLEDGE);

	return self;
}	

- (float) getEpsilon
{
	return epsilon;
}

- (void) setEpsilon: (float) value
{
	epsilon = value;
}

/*  Now some delegate methods for the input profile browser  */

- (int) browser: sender
 fillMatrix: matrix
inColumn: (int)column
{
	int	i;
	int	count;
	char *directory;
	struct direct **directories;
 
	directory = [self inputProfileDirectory];

	count = scandir (directory, &directories, dirSelect, NULL);

	for (i = 0; i < count - 1; i++)
		[matrix addRow];
	
 	[[[[matrix cellAt: 0: 0] setStringValue: "Uncorrected (No Profile)"] setLoaded: YES] setLeaf: YES];

	for (i = 2; i < count; i++)
	{
 		[[[[matrix cellAt: i - 1: 0] setStringValue: 
 		directories [i][0].d_name] setLoaded: YES] 
 		setLeaf: YES];
	}

 //	[matrix selectCellAt: lastInputProfile: 0];
	
	return count - 1;
}
 
int dirSelect (void) {return 1;}

- (const char *) browser: sender titleOfColumn: (int) column
{
	return "Input Profiles";
}

- free
{	
	if (strlen (rcmdCircuit))
		unlink (rcmdCircuit);
	[super free];
	return self;
}

- (void) cookrcmdCircuit: (char *) sdrcTransform: (char *) circuit
{
	id		colorLinks = nil;
	BOOL	isCircuitActive = NO;

	NX_DURING

	if (CiTranRead (sdrcTransform) != CE_OK)
		NX_RAISE (Err_TransformError6, NULL, NULL);
		
	colorLinks = [[ColorLinks alloc] init];

	[colorLinks makeRcMnLink: monitorSpace.redChroma_x: monitorSpace.redChroma_y: 
	monitorSpace.greenChroma_x: monitorSpace.greenChroma_y: monitorSpace.blueChroma_x:
	monitorSpace.blueChroma_y: monitorSpace.whitePoint];
	
	CiLinkAdd();
	CiLinkClose();

	[colorLinks makeMnMdLink: monitorSpace.redGamma: 
	monitorSpace.greenGamma: monitorSpace.blueGamma];

	CiLinkAdd();
	CiLinkClose();

	if (CiCircCreate (CI_QL_MAX - 1, CI_DIR_FORWARD) != CE_OK)
		NX_RAISE (Err_NoError, NULL, NULL);  // error handling
	isCircuitActive = YES;
	
	if (CiCircWrite (circuit) != CE_OK)
		NX_RAISE (Err_NoError, NULL, NULL);  // error handling

	NX_RAISE (Err_NoError, NULL, NULL);
	NX_HANDLER
	if (isCircuitActive)
		CiCircClose();
	if (colorLinks)
		[colorLinks free];
	CiTranClose();
	if (NXLocalHandler.code > NX_APPBASE)
		HERE_Error (NXLocalHandler.code);
	else
		NX_RERAISE();
	NX_ENDHANDLER
}


- (BOOL) panelValidateFilenames: sender
{
	const char *filename = [sender filename];
	char	*extension;

	extension = rindex (filename, '.');
	if (extension)
	{

 		if (extension [1] != 0)
			extension++; 
 		if (strncmp (extension, "tif", 3) == 0)
			isOpeningTiff = YES;
		else
			isOpeningTiff = NO;
	}
	return YES;
}

/*  Some things to think about for this.  
     - User masks region for spatial selection.
     - User picks source color
     - User picks dest color.  This creates then a formula that specifies delta hue, and percent
       delta saturation and brightness.  (Percent of remaining for sat and bright)
     - User selects an optional "tolerance range" that we use to further select colors by hue
    
     - Other variations are to look at saturation ("grayness") to further select colors

     - Or, to "colorize" grays to a user-selected hue.  */


int colorEditImage (NXBitmapImageRep *bitmapImage, NXColor sourceColor, float hueTolerance, float deltaHue, float percentSat, float percentBrightness)
{
	int 		i;
	int		j;
	int		bytesPerPixel;
	int		bytesPerRow;
	int		pixelsWide;
	int		pixelsHigh;
	PBYTE	data;
	PBYTE	tempPtr;
	float		red, green, blue;
	float		hue, saturation, brightness, alpha;
	float		sourceHue, sourceSaturation, sourceBrightness, sourceAlpha;
	NXColor	color;
	int		componentOffset;
	float		distance;

	NX_DURING

	NXConvertColorToHSBA (sourceColor, &sourceHue, &sourceSaturation, &sourceBrightness, 
	&sourceAlpha);

	hueTolerance *= hueTolerance;

	bytesPerRow 	= [bitmapImage bytesPerRow];
	pixelsWide	= [bitmapImage pixelsWide];
	pixelsHigh	= [bitmapImage pixelsHigh];

	if ([bitmapImage isPlanar])
	{
		componentOffset 	= (pixelsWide * pixelsHigh);
		bytesPerPixel 		= 1;
	}
	else
	{
		componentOffset 	= 1;
		bytesPerPixel 		= [bitmapImage hasAlpha] ?  4 : 3;
	}
	
	data = [bitmapImage data];

	for (i = 0; i < pixelsHigh; i++)
	{
		tempPtr = data;
		for (j = 0; j < pixelsWide; j++)
		{
			red 		= ((float) tempPtr [0] / 255);
			green 	= ((float) tempPtr [1] / 255);
			blue		= ((float) tempPtr [2] / 255);

			color = NXConvertRGBAToColor (red, green, blue, (float) 0);
			NXConvertColorToHSBA (color, &hue, &saturation, &brightness, &alpha);
	
			/*  First see if the color is really a candidate by way of hue similiarity */

			distance = sourceHue - hue;
			distance = distance * distance;
			
			if (distance <= hueTolerance)
			{		

				/*  Apply requested re-arrangment  */

				hue += deltaHue;
				if (hue > 1.0)
					hue -= 1.0;
				else
					if (hue < 0.0)
						hue += 1.0;

				saturation 	*= percentSat;
				brightness	*= percentBrightness;

				color = NXConvertHSBAToColor (hue, saturation, brightness, 0);
				NXConvertColorToRGBA (color, &red, &green, &blue, &alpha);

				tempPtr [0] = (BYTE) (red * 255);
				tempPtr [1] = (BYTE) (green * 255);
				tempPtr [2] = (BYTE) (blue * 255);
			}
			tempPtr += bytesPerPixel;
		}
		data += bytesPerRow;
	}

	NX_RAISE (0, NULL, NULL);
	NX_HANDLER

	NX_ENDHANDLER
	return 0;
}

- (int) untitledDocCount
{
	return untitledDocCount;
}

@end
