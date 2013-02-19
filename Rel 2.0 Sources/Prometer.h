
#import <appkit/appkit.h>

@interface Prometer: Object
{
	id		olProgressPanel;
	id		olProgressMeter;
	id		olProgressBox;			// For setting the little title string
	BOOL 	bAbandon;
	id		idPrometer;
}

/* "Standards"  */


/*  "Exported" methods this class  */

- hide;
- start: (BOOL) flag;
- (BOOL) setPercent: (float) percent;
- setTitle: (const char *) aString;
- setAbandon: sender;
- (BOOL) abandon;

/*  Others / internals  */

- proMeter;		// This one is to be implemented by whomever allocs and inits this class and
				// return the ID to an instance of this class.  Weird?  Yes.


@end
