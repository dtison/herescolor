/*
	ImageScrollView.m - Subclass that manages our scrolling views...

*/

#import <appkit/appkit.h>

#import "ImageScrollView.h"
#import "ImageView.h"
#import "ImageDocument.h"

@implementation ImageScrollView

-  acceptColor: (NXColor *) color atPoint: (const NXPoint *) point
{
	[window setBackgroundColor: *color];
	[window display];
	return self;
}


- initFrame: (const NXRect *) theFrame
{
	Matrix *itemList;

	#ifdef USERULERS
    	NXRect	rulerViewRect = {{0.0, 0.0}, {NX_WIDTH(theFrame), 20.0}};
   	#endif
 
   	 [super initFrame: theFrame];
    
	#ifdef USERULERS
  	/*  Create a rulerView */
    	rulerView = [[RulerView alloc] initFrame:&rulerViewRect];
    
  	/*  Make a clipView to hold it (we'll adjust its size & position in tile) */
   
 	rulerClipView = [[ClipView alloc] initFrame: &rulerViewRect];
    	[self addSubview:rulerClipView];
    	[rulerClipView setDocView:rulerView];
	#endif

	/*  Put the popup zoom thing on our scrollview  */
	
	idPopUpList = [[PopUpList alloc] init];
	[idPopUpList changeButtonTitle: YES];
	[[idPopUpList addItem: "25%"] setTag: 0];
	[[idPopUpList addItem: "50%"] setTag: 1];
	[[idPopUpList addItem: "75%"] setTag: 2];
	[[idPopUpList addItem: "100%"] setTag: 3];
	[[idPopUpList addItem: "125%"] setTag: 4];
	[[idPopUpList addItem: "150%"] setTag: 5];
	[[idPopUpList addItem: "200%"] setTag: 6];
	[[idPopUpList addItem: "400%"] setTag: 7];

	idPopUpListButton =  NXCreatePopUpListButton (idPopUpList);

	/*  Select 100%  */

	nZoomIndex = 3;						// 3 is index of 100% today 11/12/92
	itemList = [idPopUpList itemList];	
	[itemList selectCellAt: nZoomIndex: 0];
	[idPopUpListButton setTitle: [[itemList selectedCell] title]];

	[self addSubview: idPopUpListButton];

	[idPopUpList setTarget: self];	
	[idPopUpList setAction: @selector (changeScale:)];
 
	zoomLevels [0] = 25;
	zoomLevels [1] = 50;
	zoomLevels [2] = 75;
	zoomLevels [3] = 100;
	zoomLevels [4] = 125;
	zoomLevels [5] = 150;
	zoomLevels [6] = 200;
	zoomLevels [7] = 400;

 
	/*  Save the previous (current)  scale factor */

    	prevScaleFactor = 1.0;
    
    	return self;
}

- sizeTo: (NXCoord) width: (NXCoord) height
{
	[super sizeTo: width: height];
	return self;
}


- free
{
	#ifdef USERULERS
    	[rulerView free];
    	[rulerClipView free];
	#endif

	[idPopUpListButton free];
	[idPopUpList free];

    	return [super free];
}

- (float) changeScale: sender
{
    	float scaleFactor;

	scaleFactor = zoomLevels [[[sender selectedCell] tag]] / 100.0;   // Slick, huh?

    	if (scaleFactor != prevScaleFactor) 
	{
		nZoomIndex = [sender selectedRow];
		[window disableDisplay];
		[[self docView] setScale: (scaleFactor / prevScaleFactor) usingZoomLevel: scaleFactor];
		#ifdef USERULERS
		[rulerView scale:scaleFactor / prevScaleFactor :1.0];
		[self fixUpRuler];
		#else
	       [self tile];
		#endif
		[window reenableDisplay];
		[self display];
		prevScaleFactor = scaleFactor;
    	}
    
	[[window delegate] setCurrentZoomFactor: scaleFactor];

   	 return scaleFactor;
}

#ifdef USERULERS
- (void) fixUpRuler
{
    NXRect docViewBounds, rulerViewBounds;
    [window disableDisplay];
    [[self docView] getBounds:&docViewBounds];
    [rulerView getBounds:&rulerViewBounds];
    [rulerView sizeTo:NX_WIDTH(&docViewBounds) :NX_HEIGHT(&rulerViewBounds)];
    [self tile];
    [window reenableDisplay];
    [self display];
}
#endif

#ifdef USERULERS
- setDocView:aView
{
    id retVal = [super setDocView:aView];
    [self fixUpRuler];
    return retVal;
}
#endif

- resizeSubviews:(const NXSize *)oldSize
{
	[super resizeSubviews: oldSize];
	return self;
}

- tile

/*    Tile gets called whenever the scrollView changes size.  Its job is to resize
  	all of the scrollView's "tiled" views (scrollers, contentView and any other
       views we might want to place in the scrollView's bounds).  */
 
{
	NXRect scrollerRect;
	NXRect buttonRect;

  	/* Resize and arrange the scrollers and contentView as usual */ 

    	[super tile];
 
  	/*  Make sure the popup list and stub view are subviews of us */
    	if ([idPopUpListButton superview] != self) 
		[self addSubview: idPopUpListButton];
   
#ifdef USERULERS
  /* cut a slice from the contentView to make room for the rulerView */
    [contentView getFrame:&contentViewRect];
    [rulerView getFrame:&rulerRect];
    NXDivideRect(&contentViewRect, &rulerClipRect, NX_HEIGHT(&rulerRect), 1);
    [rulerClipView setFrame:&rulerClipRect];
    [contentView setFrame:&contentViewRect];
    
	#endif

	
  	/*  Now make the hScroller smaller and stick the popupList next to it */

    	[hScroller getFrame:&scrollerRect];
    	NXDivideRect(&scrollerRect, &buttonRect, 60.0, 2);
    	[hScroller setFrame:&scrollerRect];
	[idPopUpListButton setFrame:&buttonRect];
    

    return self;
}

#ifdef WHAT
- scrollClip:aClipView to:(NXPoint *)aPoint
{
    NXPoint	colOrigin;
    NXRect	colBounds;
    
  /* don't do anything if it's not the contentView */
    if (aClipView != contentView) {
	return self;
    }
    
  /* turn off drawing (to the screen) */
    [window disableFlushWindow];
    
  /* scroll the contentView to the new origin */
    [aClipView rawScroll:aPoint];
    
  /* compute new origin for the rulerView (don't let it scroll vertically) */
    [rulerClipView getBounds:&colBounds];
    colOrigin.x = aPoint->x;
    colOrigin.y = colBounds.origin.y;
    
  /* scroll the ruler view to that point */
    [rulerClipView rawScroll:&colOrigin];
    
  /* send results to screen */
    [[window reenableFlushWindow] flushWindow];
    
    return self;
}
#endif

- zoomIn: sender; 
{
	float	currZoomFactor;

	/*  YES means zoom in  */

	currZoomFactor = [self changeZoom: YES];
	[[window delegate] setCurrentZoomFactor: currZoomFactor];
	return self;
}

- zoomOut: sender;
{
	float	currZoomFactor;

	/* NO means zoom out  */

	currZoomFactor = [self changeZoom: NO];
	[[window delegate] setCurrentZoomFactor: currZoomFactor];

	return self;
}



- (float) changeZoom: (int) flag
{
	Matrix *itemList;
	float		Return;

	if (flag)
		if (nZoomIndex < MAXZOOMINDEX)
			nZoomIndex++;
		else
			NXBeep();
	else
		if (nZoomIndex > MINZOOMINDEX)
			nZoomIndex--;
		else
			NXBeep();
		
	/*  Now make popuplist reflect the new zoom level, then redisplay  */

	itemList = [idPopUpList itemList];	
	[itemList selectCellAt: nZoomIndex: 0];
	[idPopUpListButton setTitle: [[itemList selectedCell] title]];

	Return = [self changeScale: itemList];
	[self display];

	return Return;
}
@end
