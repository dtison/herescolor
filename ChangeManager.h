
@interface ChangeManager: Responder
{
    List *_changeList;				/* done, undone and redone changes */
    Change *_lastChange;				/* the last done or redone change */
    Change *_nextChange;			/* the most recently undone change */
    Change *_changeInProgress;		/* the current change in progress */
    int _numberOfDoneChanges;		/* number of done or redone changes 
    					   recorded in the changeList */
    int _numberOfUndoneChanges;		/* undone changes in the changeList */
    int _numberOfDoneChangesAtLastClean;/* number at time clean last message */
    BOOL _someChangesForgotten;		/* YES whenever we don't remember 
    					   enough to return to a clean state */
    int _changesDisabled;		/* YES between outermost calls to
    					   disableChanges: and enableChanges:*/
}

/* Methods called directly by your code */

- init;			/* start with [super init] if overriding */
- free;			/* end with [super free] if overriding */
- (BOOL)canUndo;	/* DO NOT override */
- (BOOL)canRedo;	/* DO NOT override */
- (BOOL)isDirty;	/* DO NOT override */

- dirty:sender;		/* start with [super dirty:sender] if overriding */
- clean:sender;		/* start with [super clean:sender] if overriding */
- reset:sender;		/* start with [super reset:sender] if overriding */
- disableChanges:sender;	/* DO NOT override */
- enableChanges:sender;		/* DO NOT override */
- undoOrRedoChange:sender;	/* DO NOT override */
- undoChange:sender;		/* DO NOT override */
- redoChange:sender;		/* DO NOT override */
- (BOOL)validateCommand:sender;
			/* end with [super validateCommand:] if overriding */

/* Methods called by Change           */
/* DO NOT call these methods directly */

- changeInProgress:change;	/* DO NOT override */
- changeComplete:change;	/* DO NOT override */

/* Methods called by ChangeManager    */
/* DO NOT call these methods directly */

- changeWasDone;		/* override at will */
- changeWasUndone;		/* override at will */
- changeWasRedone;		/* override at will */

@end
