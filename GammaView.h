
#import <appkit/appkit.h>
#import "AppDefs.h"
#import "/LocalLibrary/HERELibrary/Include/HEREutils.h"

typedef enum {RED, GREEN, BLUE} CHIPCOLOR;

@interface GammaView: Control
{
	CHIPCOLOR 	color;
	BOOL		isSolid;
	NXColor		drawColor;
	float			drawGamma;
	id			olText;
	id			drawBitmapImage;		// Cached image for drawing dotted chips
}

- (NXBitmapImageRep *) createDrawImage: (NXRect *) rect: (NXColor) aColor;
- (NXColor) makeDrawColor: (CHIPCOLOR) color: (float) drawGamma;

- setSolid: (BOOL) flag;
- setGamma: sender;

- setChipColor: (CHIPCOLOR) aColor;
- setDrawGamma: (float) aGamma;


@end
