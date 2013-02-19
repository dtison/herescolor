
#ifndef PRINTERCHIPSVIEW_H
#define PRINTERCHIPSVIEW_H
#import <appkit/appkit.h>
#import "AppDefs.h"
#include "/LocalLibrary/HERELibrary/Include/CmsLib.h"
#include "/LocalLibrary/HERELibrary/Include/OutputProfile.h"
#include "OutputProfileInspector.h"	// For [controller rchnColors] decl only
#import "HEREpsw.h"


@interface PrinterChipsView: View
{
	/*  Reference constants for printer chips  */

	ColorV 				*referenceColors;
	char					colorType;		// CMYK (4 Color) or CMY (3 Color)
	char					targetType; 
	NXBitmapImageRep 	*bitmapImage;
}

- drawCMYKChips;
- drawRGBChips;
- setColorType: (int) type;
- setTargetType: (int) type;

@end
#endif