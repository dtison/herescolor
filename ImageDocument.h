#ifndef IMAGEDOCUMENT_H
#define IMAGEDOCUMENT_H
#import "AppDefs.h"
#import "/LocalLibrary/HERELibrary/Include/HEREutils.h"
#import "ChangeStuff.h"
#import "ImageView.h"
#import "ImageScrollView.h"

@interface ImageDocument: ChangeManager
{
	id		idWindow;
	id		idImageView;
	id		idMarquisView;	// (Free-form) marquis
	id		idImage;			// NXImage object in this document
	id		idMiniImage;		// NXImage object for (icon) miniwindow
	char		szImageFilename [MAXPATHSIZE];
	char		szImageName [MAXPATHSIZE];
	char 	szImageDirectory [MAXPATHSIZE];
	float		fCurrZoomFactor;
	int		compression;

	/*  Save panel accessory view items  */

	id		olSavePanelAccessoryView;
	id		olJpegLevelSlider;
	id		olJpegLevelEdit;

	/*  For print panel accessory view  */

	id		olPrintPanelAccessoryView;
	id		olEnableLevel2Color;

	id		controller;
}


- initFromFile: (const char *) filename;
- initFromStream: (NXStream *) stream;
- initStuff;
- initDocumentWith: (NXImage *) image;

- (BOOL)isSameAs: (const char *) filename;
- (const char *) filename;
 
- saveAs: sender;

- (Window *) createWindow: (NXRect *) frame;

- windowWillMiniaturize: (Window *) sender toMiniwindow: counterpart;

- (PBYTE) getImageData;
- getImageSize: (NXSize *) size;
- setImageData: (PBYTE) data;
- getSelectionRect: (NXRect *) aRect;
- updateImageData: (PBYTE) data: (NXPoint *) points: (int) count: (NXRect *) selectionRect;
- getCurrentSelection;
- (float) getCurrentZoomFactor;
- setCurrentZoomFactor: (float) currZoomFactor;


- noCompressionSet: sender;
- lzwCompressionSet: sender;
- jpegCompressionSet: sender;

- (BOOL) level2;

/*  First Responder (menu) items  */



@end
#endif
