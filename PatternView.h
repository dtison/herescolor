
#ifndef PATTERNVIEW_H
#define PATTERNVIEW_H

#import <appkit/appkit.h>
#import "AppDefs.h"
#include "/LocalLibrary/HERELibrary/Include/CmsLib.h"
#include "/LocalLibrary/HERELibrary/Include/OutputProfile.h"
#import "Controller.h"					// For hiddenDirectory
#import "HEREpsw.h"


#ifndef EPSBUG
#define NXEPSImageRep NXBitmapImageRep
#endif

@interface PatternView: View
{
	NXBitmapImageRep				*cmyk320Image;                  
	NXBitmapImageRep				*gray16Image;      
	int							patternType;            
}


//- (NXBitmapImageRep *) makeBitmapImage: (int) type;
- setPatternType: (int) type;

@end
#endif