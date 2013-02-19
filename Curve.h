
#import <appkit/appkit.h>
#import "AppDefs.h"

@interface Curve: Control
{
	int		nNumPoints;
	NXPoint	*pPoints;			// For lines
	NXRect	*pRectangles;		// For grab points
	float		*handlePositions;	// Float positions of handles normalized (0..1);
	NXPoint	hitPoint;			// Point (location) of mousedown
	int		nSelectedRect;		// Index of selected rectangle
	id		idGridImage;		// Holds the grid bitmap
	float		horizSectionSize;
	float		vertSectionSize;
	int		nSections;
	int		nRectSize;
	int		nRectMidpoint;
	BOOL	bIsDragged;

	/*  Some outlets for text feedback  */

	id		*Controls;
	id		olControl0;
	id		olControl1;
	id		olControl2;
	id		olControl3;
	id		olControl4;
	id		olControl5;

}

#define MIN_POINTS 		5
#define DEFAULT_HANDLE_SIZE 5
#define HANDLEOFFSET ((float) (nRectSize >> 1))

- setNumPoints: (int) numPoints;
- setHandleSize: (int) size;
- (int) selectedRect;


- doDraw;
- setupDraw;
- setPoints: (float *) positions: (int) count;
- getPoints: (float *) positions;

- setFormattedValue: (float) value forTextField: textField;


@end
