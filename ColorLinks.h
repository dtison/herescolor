#ifndef COLORLINKS_H
#define COLORLINKS_H

#import <appkit/appkit.h>
#import "AppDefs.h"
#include "/LocalLibrary/HERELibrary/Include/CmsLib.h"
#include "/LocalLibrary/HERELibrary/Include/OutputProfile.h"
#include "/LocalLibrary/HERELibrary/Include/MonitorSpace.h"
#import "/LocalLibrary/HERELibrary/Include/HEREerrors.h"

/*  A special class that handles color transforms and related things.  Hopefully this becomes
    the ancestor of some future OOP-NS-Objective C color libraries  */

@interface ColorLinks: Object
{

}


- (int) makeMnMdLink: (float) redMonGamma: (float) greenMonGamma: (float) blueMonGamma;
- (int) makeRcMnLink: (float) redChroma_x: (float) redChroma_y: (float) greenChroma_x:
	(float) greenChroma_y: (float) blueChroma_x: (float) blueChroma_y: (float) whitePoint;
- (int) makeSdSnLink: (ColorV *) colors: (int)  numColors;
- (int) makeSnRcLink: (ColorV *) colors: (int)  numColors;

- (int) addRcHnLink: (ColorV *) rcsColors: (ColorV *) referenceColors: (BOOL *) rchnColorsUsed
				: (int)  numColors: (int) direction;


- (int) addHnPnLink: (OutputProfile *) profile: (int) direction: (BOOL) useRelaxedInkmodel;
- (int) addPnPdLink: (OutputProfile *) profile: (int) direction;
- (int) addHnHdLink: (OutputProfile *) profile: (int) direction;

- (int) monitorColorToRCS: (ColorV) rcsColor: (NXColor) monitorColor: (MonitorSpace *) space;
- (NXColor) rcsColorToMonitor: (ColorV) rcsColor: (MonitorSpace *) space;

- (ColorV *) referenceRGB: (int) teachMeType;
- (ColorV *) altReferenceRGB;

@end
#endif
