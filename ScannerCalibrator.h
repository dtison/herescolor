
#import <appkit/appkit.h>
#import "AppDefs.h"
#import "/LocalLibrary/HERELibrary/Include/HEREutils.h"
#import "Controller.h"
#import "MyDBImageView.h"
#import "ColorLinks.h"

@interface ScannerCalibrator: Responder
{
	id	olScannerCalibratorPanel;
	id	olInstructionsText;
	id	olScannedImageView;
	id	controller;
	id	colorLinks;
}

/*  Target / Action  */

- runOrderFront: sender;
- loadTestTarget: sender;

/*  Internal  */

- saveProfile: (const char *) filename;

/*  Plain old C  */

int scanalyze (NXBitmapImageRep *bitmapImage, ColorV* grayRamp, ColorV* mainColors);
void subSample (ColorV colorV, PBYTE data, int bytesPerRow, int bytesPerPixel);

@end
