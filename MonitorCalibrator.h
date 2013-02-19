
#import <appkit/appkit.h>
#import "AppDefs.h"
#import "/LocalLibrary/HERELibrary/Include/MonitorSpace.h"
#import "/LocalLibrary/HERELibrary/Include/HEREstrings.h"
#import "GammaView.h"	
#import "Controller.h"
#import "HEREpsw.h"

@interface MonitorCalibrator:Responder
{
	id	olBlueGammaSlider;
	id	olBlueGammaView1;
	id	olBlueGammaView2;
	id	olBlueGammaText;
	id	olEpsilonEdit;
	id	olEpsilonSlider;
	id	olGammaView;
	id	olGreenGammaSlider;
 	id	olGreenGammaView1;
    	id	olGreenGammaView2;
	id	olGreenGammaText;
	id	olMonitorBrowser;
	id	olMonitorCalibratorPanel;
	id	olMonitorCalibratorView;
	id	olMonitorWhitepoint;
	id	olMonPrimariesBlueX;
	id	olMonPrimariesBlueY;
	id	olMonPrimariesGreenX;
	id	olMonPrimariesGreenY;
	id	olMonPrimariesRedX;
	id	olMonPrimariesRedY;
	id	olNormalizerView;
	id	olRedGammaSlider;
	id	olRedGammaView1;
	id	olRedGammaView2;
	id	olRedGammaText;
	id	olSettingsView;
	id	olViewPopup;
	id	olViewButton;
	id	olInstructionsText;
	
	View 	*currentView;
	BOOL	isActive;
	
	/*  Get these from  app dispatcher (delegate)  */

	id		controller;
	float		epsilon;
}


- runOrderFront: sender;
- setSettingsView: sender;
- setGammaView: sender;
- setNormalizerView: sender;
- redGammaSet: sender;
- greenGammaSet: sender;
- blueGammaSet: sender;
- epsilonSet: sender;
- monitorCalibratorSet: sender;
- (BOOL) isActive;		// For menu support, tells caller whether an editor panel is active or not

@end
