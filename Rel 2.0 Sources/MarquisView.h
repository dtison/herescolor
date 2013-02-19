#import <appkit/appkit.h>

@interface MarquisView: View
{
	/*  Stuff for marquis and selected region  */	 

	NXPoint	*pCurrentPoints;
	int		nTotalPoints;
	int		nAvailablePoints;		// # Points left in above buffer
	float		fPattern [4];
	int		nOffset;
	DPSTimedEntry currTimedEntry;
}


- drawSelf: (const NXRect *) rects: (int) rectCount;
- initFrame: (const NXRect *) frameRect;
- getBoundingBox: (NXRect *) aRect;
- (NXPoint *) getSelectionPoints: (int *) count;
- crawl;





@end
