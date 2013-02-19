
@interface Change: Object
{
	struct 
	{
		unsigned int disabled: 1;	/* YES if disable message receieved */
		unsigned int hasBeenDone: 1;	/* YES if done or redone */
		unsigned int changeInProgress: 1; /* YES after startChange 
									 but before endChange */
		unsigned int padding: 29;
	}  _changeFlags;
	id _changeManager;		/* Actually a (ChangeManager *). This should 
  							be changed in 3.0 when we can use @class. */
}

/* Methods called directly by your code */

- init;				/*  Start with [super init] if overriding */
- startChange;			/* DO NOT override */
- startChangeIn:aView;	/* DO NOT override */
- endChange;			/* DO NOT override */
- changeManager;		/* DO NOT override */

/* Methods called by ChangeManager or by your code */

- disable;					/* DO NOT override */
- (BOOL)disabled;			/* DO NOT override */
- (BOOL)hasBeenDone;		/* DO NOT override */
- (BOOL)changeInProgress;	/* DO NOT override */
- (const char *)changeName;	/* override at will */

/* Methods called by ChangeManager */
/* DO NOT call directly */

- saveBeforeChange;		/* override at will */
- saveAfterChange;			/* override at will */
- undoChange;				/* end with [super undoChange] if overriding */
- redoChange;				/* end with [super redoChange] if overriding */
- (BOOL)subsumeChange:change;		/* override at will */
- (BOOL)incorporateChange:change;	/* override at will */
- finishChange;			/* override at will */

@end
