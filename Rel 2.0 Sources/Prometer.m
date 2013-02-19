#import <appkit/appkit.h>

#import "Prometer.h"

/*  This class handles the prometer-related tasks we need */

@implementation Prometer

#if 0
- init
{
	[super init];
	[olProgressPanel setBecomeKeyOnlyIfNeeded: YES];
	return self;
}
#endif

/*  This one's weird.  See Prometer.h  */

- proMeter
{
	return self;
}

/*  Eventually rename "stop:"  */

- hide
{
	/*  First see if the user has turned me off  */

	if (! [olProgressPanel isVisible])
		return self;

	[self setPercent: 0.0];
	[self setTitle: "(Inactive)"];
	[olProgressPanel display];

    	return self;
}

- start: (BOOL) flag
{

	bAbandon = NO;

	if (! olProgressPanel)
	{
	    	[NXApp loadNibSection: "Prometer.nib" owner: self withNames:NO];
		[olProgressPanel setBecomeKeyOnlyIfNeeded: YES];
	}

	/*  First see if the user has turned me off (unless client is requesting firm reset - flag=1)  */

	if (! flag)
		if (! [olProgressPanel isVisible])
			return self;
	
	[olProgressPanel orderFront: self];
	[olProgressMeter setPercent: 0.0];
    	return self;
}

/*  Returns non-zero for user-abandon  */

- (BOOL) setPercent: (float) percent;
{
	
	/*  First see if the user has turned me off  */

	if (! [olProgressPanel isVisible])
		return NO;

	#ifdef WHYRUNSLOW
	/*  Process some pending events  */

     	while (NXGetOrPeekEvent (DPSGetCurrentContext(),
       		&event,
		NX_MOUSEUPMASK | NX_MOUSEDOWNMASK,
		0.0,10, NO))
			[NXApp sendEvent: &event];

	#endif

	[olProgressMeter setPercent: percent];
	
	NXPing();

    	return (bAbandon);
}

- setTitle: (const char *) aString
{
	/*  First see if the user has turned me off  */

	if (! [olProgressPanel isVisible])
		return self;

	if (aString)
//		[olProgressPanel setTitle: aString];
		[olProgressBox setTitle: aString];
[olProgressBox display];

    	return self;
}

- setAbandon: sender
{
	bAbandon = YES;
	return self;
}

- (BOOL) abandon
{
	return (bAbandon);
}


#ifdef WHATSTHIS
/*  A derivative of this might move into the app at a later point  */

- setMenu: (id) menu to: (BOOL) flag
{
	id 	itemList = [menu itemList];
	int	nNumRows, nNumColumns;
	int	i;

	[itemList getNumRows: &nNumRows numCols: &nNumColumns];

	for (i = 0; i < nNumRows; i++)
		[[itemList cellAt: i: 0] setEnabled: flag];

	[menu update];

	return self;
}
#endif

@end
