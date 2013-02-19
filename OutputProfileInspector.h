
/*  Class definition for Output profile inspector  */

#ifndef OUTPUTPROFILEINSPECTOR_H
#define OUTPUTPROFILEINSPECTOR_H

#import <appkit/appkit.h>
#import "AppDefs.h"
#import "dbkit/DBImageView.h"
#import "/LocalLibrary/HERELibrary/Include/HEREutils.h"
#import "/LocalLibrary/HERELibrary/Include/HEREerrors.h"
#import "/LocalLibrary/HERELibrary/Include/HEREstrings.h"
#import "/LocalLibrary/HERELibrary/Include/ProgressView.h"
#import "ColorLinks.h"
#import "MyDBImageView.h"
#import "Curve.h"
#import "Spin.h"
#import "Slidey.h"
	
@interface OutputProfileInspector: Responder
{
	id	olPreviewView;
    	id	olBlackpointSpin;
    	id	olBlackpointText;
    	id	olColorMatchingView;
   	id	olColorSepView;
	id	olNotApplicableView; 
      	id	olDensitiesView;
    	id	olSetupView;
	id	olGCRCurve;
	id	olOutputProfInspPanel;
	id	olOutputProfInspView;
	id	olMeasurementsPanel; 
 	id	olTACSlidey;
    	id	olTACText;
    	id	olViewPopup;
	id	olViewPopupButton;
    	id	olVisualColor0;
    	id	olVisualColor1;
    	id	olVisualColor2;
    	id	olVisualColor3;
    	id	olVisualColor4;
    	id	olVisualColor5;
    	id	olVisualColor6;
    	id	olVisualColor7;
    	id	olVisualColor8;
    	id	olVisualColor9;
    	id	olVisualColor10;
    	id	olVisualColor11;
    	id	olVisualColor12;
    	id	olVisualColor13;
    	id	olVisualColor14;
    	id	olVisualColor15;
    	id	olVisualColor16;
    	id	olVisualColor17;
    	id	olVisualColor18;
    	id	olVisualColor19;
    	id	olVisualColor20;
    	id	olVisualColor21;
    	id	olVisualColor22;
    	id	olVisualColor23;
    	id	olVisualColor24;
    	id	olVisualColor25;
    	id	olVisualColor26;
    	id	olVisualColor27;
    	id	olVisualColor28;
    	id	olVisualColor29;
    	id	olVisualColor30;
    	id	olVisualColor31;
    	id	olVisualColor32;
    	id	olVisualColor33;
    	id	olVisualColor34;
    	id	olVisualColor35;

	/*  GCR Curve fields outlets */

	id 	olGCRText0;
	id 	olGCRText1;
	id 	olGCRText2;
	id 	olGCRText3;
	id 	olGCRText4;

	id	olPreviewImage1;
	id	olPreviewImage2;
	id	olInstallButton;
	id	olStatusLine;
	id	olStringTable;
	id	olAlternateMixes;
	id	olFullScreenPreview;
	id	olDeviceType;					// 3 color v. 4 color type
	id	olTeachMeType;				// Use spectro or do it visually
	id	olProcessingQuality;			// Draft or final
	id	olProcessingQualityMsg;
	id	olLoadTeachMe;
	id	olBlankColor;
	id	olExtendedColors;
	id	olOffscreenWindow;
	id	olOffscreenScrollView;
	id	olInkmodelFilename;			//  Last loaded Inkmodel
	id	olTeachMeFilename;			//  Last loaded TeachMe measurements
	id	olMeasurementsText1;			//  Text viewers for inkmodel or teachme
  	id	olMeasurementsText2;			//  measurements
	id	olProgressView;				//  Prometer for this UI
	id	olCancelButton;				
	id	olUseRelaxedInkmodel;			

	Text 		*measurementsText1;
	Text		*measurementsText2;

	/*  Some of the values for a profile  stored here  */

	View			*currentView;			// Which inspector view last chosen
	NXColorWell	*currentColorWell;		// Which colorwell last chosen
	NXColorWell    **visualColors;		// A pointer to our long list of visual color wells
	id		 	controller;			// Id of our controller object
	id			colorLinks;			// Id of our color links object
	OutputProfile   outputProfile;
 	char			szFilename [MAXPATHSIZE];
	BOOL		isActive;
	BOOL		abandon;			
	ColorV		altInkDensities [320];	// Matchprint (default) .Inkmodel
	int			numRcHnColors;		// Either 216, 64 or 36....
	char			teachMeType;				           //  Shadow copy
	char			deviceType;				           //  Shadow copy
	char			inkmodelFilename [MAXPATHSIZE];    //  Shadow copy
	char			teachMeFilename [MAXPATHSIZE];     //  Shadow copy
	ColorV	 	inkDensities [320];		                  //  Shadow copy
	BOOL		useRelaxedInkmodel;		           //  Shadow copy
	ColorV		measuredCIEColors [NUM_RCHNCOLORS];   //  Measured CIE colors 
	MonitorSpace	monitorSpace;
	char			previewCircuit [MAXPATHSIZE];         // Store away soft proof circuit
}

typedef struct
{
	ProgressView 	*progressView;
	id			outputProfileInspector;
	id			olOutputProfInspPanel;
	NXRect		cancelButtonFrame;
	BOOL		abandon;
}  Candela_Hack;


#define    SOFT_PROOF			 		0
#define	OUT_OF_RANGE			 	1

#define	INKMODEL_ERR_NONE			0
#define 	INKMODEL_ERR_DENSITY		1
#define 	INKMODEL_ERR_E				2
#define 	INKMODEL_ERR_D				3
#define 	INKMODEL_ERR_C				4
#define 	INKMODEL_ERR_B				5
#define 	INKMODEL_ERR_A				6

int checkInkmodel (ColorV *inkmodel, BOOL fix);

/*  Target / action methods  */

- setPreviewView: sender;
- setColorSepView: sender;
- setDensitiesView: sender;
- setColorMatchingView: sender;
- setSetupView: sender;
- blankColor: sender;
- save: sender;
- saveAs: sender;
- revertToSaved: sender;
- install: sender;
- loadInkmodel: sender;
- loadTeachMe: sender;
- colorModified: sender;
- printRcHnPattern: sender;
- printInkmodelPattern: sender;
- alternateMixesSet: sender;
- fullScreenViewSet: sender;
- processingQualitySet: sender;
- teachMeTypeSet: sender;
- deviceTypeSet: sender;
- showMeasurements: sender;
- doPreview: sender;
- doOutofRange: sender;
- relaxedInkmodelSet: sender;


/*  Methods that are "exported  */

- newProfile;
- (BOOL) openProfile: (char *) filename;
- (BOOL) isActive;		// For menu support, tells caller whether an editor panel is active or not


// OPISupport Candidates


/*  Object-specific methods  (internal)  */

- setupProfile;
- initProfile;
- (int) readProfile: (char *) filename;
- writeProfile: (char *) filename;
- doPasteboardImage: sender;
- writeCRD: (OutputProfile *) profile;
- (void) makeMatrix: (float *) matrix;



@end



#import "OPISupport.h"

#endif



