
#import <appkit/appkit.h>
#import "AppDefs.h"

#define MINZOOMINDEX	0
#define MAXZOOMINDEX	7

@interface ImageScrollView: ScrollView
{
	id	idPopUpList;				// Contains zoom levels
	id	idPopUpListButton;		// Trigger button for above
     	float prevScaleFactor;
	int	nZoomIndex;				// Index to current zoom level
	int	zoomLevels [8];
}


/*  Instance methods */

- initFrame: (const NXRect *) theFrame;
- free;
- tile;
- (float) changeScale: sender;
- (float) changeZoom: (int) flag;

#ifdef WHAT
- scrollClip:aClipView to:(NXPoint *)aPoint;
- setDocView:aView;
- (void)fixUpRuler;
#endif

/*  First responder items  */

- zoomIn: sender;
- zoomOut: sender;
-  acceptColor: (NXColor *) color atPoint: (const NXPoint *) point;

@end
