#ifndef CONTROLLER_H
#define CONTROLLER_H
#import <appkit/appkit.h>
#import "AppDefs.h"
#import "/LocalLibrary/HERELibrary/Include/HEREutils.h"
#import "/LocalLibrary/HERELibrary/Include/HEREerrors.h"
#import "/LocalLibrary/HERELibrary/Include/HEREstrings.h"
#import "ImageDocument.h"
#import "OutputProfileInspector.h"
#import "ScannerCalibrator.h"
#import "MonitorCalibrator.h"
#import "ColorLinks.h"

@interface Controller: Object
{
	/*  Some objects we presently reference from controller  */

	id 		olInfoPanel;
	id		olInfoVersion;
	id 		olPreferencesPanel;
	id		olOpenPanelAccessoryView;
	id		olSavePanelAccessoryView;
	id		olColorPanelAccessoryView;
	id		olSelectInputProfile;
	id		olInputProfilesPanel;
	id		olInputProfilesBrowser;
	id		olInputProfilesProgress;

	/*  Some objects for calibration  */

	id		idOutputProfileInspector;
	id		idScannerCalibrator;
	id		idMonitorCalibrator;

	char		szAppDir [MAXPATHSIZE];		// Directory app started in
	id		idPrometer;					// App-wide prometer object
	NXAtom 	pbReceiveTypes [3]; 
	NXAtom	pbSendTypes [3]; 

	char	hereDirectory [MAXPATHSIZE];  
	char	hiddenDirectory [MAXPATHSIZE];  
	char profileDirectory [MAXPATHSIZE];
	char inputProfileDirectory [MAXPATHSIZE];
	char inkmodelDirectory [MAXPATHSIZE];
	char teachMeDirectory [MAXPATHSIZE];
	char imageDirectory [MAXPATHSIZE];

	char	lastImageFilename [MAXPATHSIZE];
	char	lastProfileFilename [MAXPATHSIZE];
	
	char	rcmdCircuit [MAXPATHSIZE];
		
	BOOL	isOpeningImage;
	BOOL	isOpeningTiff;
	BOOL	isRoot;
	BOOL	isSpecial;		// Our special setting so we can make profiles HC-Lite can't read
	MonitorSpace monitorSpace;
	float		epsilon;
	int		untitledDocCount;
}

#define 	NUM_PB_RECEIVE_TYPES 	2
#define	MAJOR_VERSION			1
#define	MINOR_VERSION			3


//- showInfoPanel: sender;  // (1st Responder instead)

- (OpenPanel *) openPanel: sender;
- (SavePanel *) savePanel: sender;
- setOpenImages: sender;
- setOpenProfiles: sender;

- activeDocument;
- (BOOL) menuItemUpdate: (MenuCell *) menuCell;
- (BOOL) validateCommand: (MenuCell *) menuCell;
- (BOOL) checkPasteboard: (Pasteboard *) pBoard;
- (NXAtom *) getPBSendTypes;

- (char *) hereDirectory;
- (char *) hiddenDirectory;
- (char *) profileDirectory;
- (char *) inputProfileDirectory;
- (char *) inkmodelDirectory;
- (char *) teachMeDirectory;
- (char *) imageDirectory;

- monitorColorSpace: (MonitorSpace *) space;
- setMonitorColorSpace: (MonitorSpace *) space;
- (void) setDefaultRCS;
- (void) getVersionInfo: (int *) major: (int *) minor: (int *) special;
- (BOOL) isDemo;
- (BOOL) isRoot;
- (float) getEpsilon;
- (void) setEpsilon: (float) value;
- (void) cookrcmdCircuit: (char *) sdrcTransform: (char *) circuit;
- (int) untitledDocCount;


/*  Plain old C functions  */

void TimerProc (DPSTimedEntry timedEntry, double timeNow, void *data);
void initMenu (Menu *menu);
Window *findDocument (const char *name);
ImageDocument *documentInWindow (Window *window);

void progress (float done);
int   cancel (void);
int dirSelect (void);


@end
#endif
