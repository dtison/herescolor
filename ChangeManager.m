#import "ChangeStuff.h"
 

/*
 * Please refer to external reference pages for complete
 * documentation on using the ChangeManager class.
 */

/* 
 * N_LEVEL_UNDO sets the maximum number of changes that the ChangeManager
 * will keep track of. Set this to 1 to get single level undo behaviour. 
 * Set it to a really big number if you want to offer nearly infinite undo.
 * Be careful if you do this because unless you explicity reset the 
 * ChangeManager from time to time, like whenever you save a document, the
 * ChangeManager will never forget changes and will eventually chew up
 * enourmous amounts of swapfile.
 */

#define	N_LEVEL_UNDO	20
#define     SIZE_MENU_TO_FIT  

/* Localization */

#define UNDO_OPERATION NXLocalStringFromTable("Operations", "Undo", NULL, "The operation of undoing the last thing the user did.")
#define UNDO_SOMETHING_OPERATION NXLocalStringFromTable("Operations", "Undo %s", NULL, "The operation of undoing the last %s operation the user did--all the entries in the Operations and TextOperations .strings files are the %s of this or Redo.")
#define REDO_OPERATION NXLocalStringFromTable("Operations", "Redo", NULL, "The operation of redoing the last thing the user undid.")
#define REDO_SOMETHING_OPERATION NXLocalStringFromTable("Operations", "Redo %s", NULL, "The operation of redoing the last %s operation the user undid--all the entries in the Operations and TextOperations .strings files are the %s of either this or Undo.")

@interface ChangeManager(PrivateMethods)

- updateMenuCell:menuCell with:(const char *)menuText;

@end

@implementation ChangeManager
/* Methods called directly by your code */

- init
{
    [super init];

    _changeList = [[List alloc] initCount:N_LEVEL_UNDO];
    _numberOfDoneChanges = 0;
    _numberOfUndoneChanges = 0;
    _numberOfDoneChangesAtLastClean = 0;
    _someChangesForgotten = NO;
    _lastChange = nil;
    _nextChange = nil;
    _changeInProgress = nil;
    _changesDisabled = 0;
    
    return self;
}

- free
{
    [self reset:self];
    [_changeList free];
    return [super free];
}

- (BOOL)canUndo
{
    if (_lastChange == nil) {
        return NO;
    } else {
	NX_ASSERT(![_lastChange changeInProgress], "Fault in Undo system: Code 1");
	NX_ASSERT(![_lastChange disabled], "Fault in Undo system: Code 2");
	NX_ASSERT([_lastChange hasBeenDone], "Fault in Undo system: Code 3");
        return YES;
    }
}

- (BOOL)canRedo
{
    if (_nextChange == nil) {
        return NO;
    } else {
	NX_ASSERT(![_nextChange changeInProgress], "Fault in Undo system: Code 4");
	NX_ASSERT(![_nextChange disabled], "Fault in Undo system: Code 5");
	NX_ASSERT(![_nextChange hasBeenDone], "Fault in Undo system: Code 6");
        return YES;
    }
}

- (BOOL)isDirty
{
    return ((_numberOfDoneChanges != _numberOfDoneChangesAtLastClean) 
    		|| _someChangesForgotten);
}

- dirty:sender
{
    _someChangesForgotten = YES;
    return self;
}

- clean:sender
{
    _someChangesForgotten = NO;
    _numberOfDoneChangesAtLastClean = _numberOfDoneChanges;
    return self;
}

- reset:sender
{
    while(_lastChange = [_changeList removeLastObject]) {
	[_lastChange free];
    }
    _numberOfDoneChanges = 0;
    _numberOfUndoneChanges = 0;
    _numberOfDoneChangesAtLastClean = 0;
    _someChangesForgotten = NO;
    _lastChange = nil;
    _nextChange = nil;
    _changeInProgress = nil;
    _changesDisabled = 0;

    return self;
}

- disableChanges:sender
/*
 * disableChanges: and enableChanges: work as a team, incrementing and
 * decrementing the _changesDisabled count. We use a count instead of
 * a BOOL so that nested disables will work correctly -- the outermost
 * disable and enable pair are the only ones that do anything.
 */
{
    _changesDisabled++;
    return self;
}

- enableChanges:sender
/*
 * We're forgiving if we get an enableChanges: that doesn't match up
 * with any previous disableChanges: call.
 */
{
    if (_changesDisabled > 0)
        _changesDisabled--;
    return self;
}

- undoOrRedoChange:sender
{
    if ([self canUndo]) {
        [self undoChange:sender];
    } else {
	if ([self canRedo]) {
	    [self redoChange:sender];
	}
    }
    return self;
}

- undoChange:sender
{
    if ([self canUndo]) {
	[_lastChange finishChange];
	[self disableChanges:self];
	    [_lastChange undoChange];
	[self enableChanges:self];
	_nextChange = _lastChange;
	_lastChange = nil;
	_numberOfDoneChanges--;
	_numberOfUndoneChanges++;
	if (_numberOfDoneChanges > 0) {
	    _lastChange = [_changeList objectAt:(_numberOfDoneChanges - 1)];
	}
	[self changeWasUndone];
    }
    
    return self;
}

- redoChange:sender
{
    if ([self canRedo]) {
	[self disableChanges:self];
	    [_nextChange redoChange];
	[self enableChanges:self];
	_lastChange = _nextChange;
	_nextChange = nil;
	_numberOfDoneChanges++;
	_numberOfUndoneChanges--;
	if (_numberOfUndoneChanges > 0) {
	    _nextChange = [_changeList objectAt:_numberOfDoneChanges];
	}
	[self changeWasRedone];
    }
    
    return self;
}

- (BOOL)validateCommand:menuCell
/*
 * See the Draw code for a good example of how validateCommand:
 * can be used to keep the application's menu items up to date.
 */
{
    SEL action;
    BOOL canUndo, canRedo, enableMenuItem = YES;
    char menuText[256];

    action = [menuCell action];
    
    if (action == @selector(undoOrRedoChange:)) {
        enableMenuItem = NO;
	canUndo = [self canUndo];
	if (canUndo) {
	    sprintf(menuText, UNDO_SOMETHING_OPERATION, [_lastChange changeName]);
	    enableMenuItem = YES;
	} else {
	    canRedo = [self canRedo];
	    if (canRedo) {
	        sprintf(menuText, REDO_SOMETHING_OPERATION, [_nextChange changeName]);
	        enableMenuItem = YES;
	    } else {
		sprintf(menuText, UNDO_OPERATION);
	    }
	}
	[self updateMenuCell:menuCell with:menuText];
    }

    if (action == @selector(undoChange:)) {
	canUndo = [self canUndo];
	if (!canUndo) {
	    sprintf(menuText, UNDO_OPERATION);
	} else {
	    sprintf(menuText, UNDO_SOMETHING_OPERATION, [_lastChange changeName]);
	}
	[self updateMenuCell:menuCell with:menuText];
	enableMenuItem = canUndo;
    }

    if (action == @selector(redoChange:)) {
	canRedo = [self canRedo];
	if (!canRedo) {
	    sprintf(menuText, REDO_OPERATION);
	} else {
	    sprintf(menuText, REDO_SOMETHING_OPERATION, [_nextChange changeName]);
	}
	[self updateMenuCell:menuCell with:menuText];
	enableMenuItem = canRedo;
    }

    return enableMenuItem;
}

/* Methods called by Change           */
/* DO NOT call these methods directly */

- changeInProgress:change
/*
 * The changeInProgress: and changeComplete: methods are the most
 * complicated part of the undo framework. Their behaviour is documented 
 * in the external reference sheets.
 */
{
    if (_changesDisabled > 0) {
	[change disable];
	return nil;
    } 
    
    if (_changeInProgress != nil) {
	if ([_changeInProgress incorporateChange:change]) {
	    /* 
	     * The _changeInProgress will keep a pointer to this
	     * change and make use of it, but we have no further
	     * responsibility for it.
	     */
	    [change saveBeforeChange];
	    return self;
	} else {
	    /* 
	     * The _changeInProgress has no more interest in this
	     * change than we do, so we'll just disable it.
	     */
	    [change disable];
	    return nil;
	}
    } 
    
    if (_lastChange != nil) {
	if ([_lastChange subsumeChange:change]) {
	    /* 
	     * The _lastChange has subsumed this change and 
	     * may either make use of it or free it, but we
	     * have no further responsibility for it.
	     */
	    [change disable];
	    return nil;
	} else {
	    /* 
	     * The _lastChange was not able to subsume this change, 
	     * so we give the _lastChange a chance to finish and then
	     * welcome this change as the new _changeInProgress.
	     */
	    [_lastChange finishChange];
        }
    }

    /* 
     * This will be a new, independent change.
     */
    [change saveBeforeChange];
    if (![change disabled])
        _changeInProgress = change;
    return self;
}

- changeComplete:change
/*
 * The changeInProgress: and changeComplete: methods are the most
 * complicated part of the undo framework. Their behaviour is documented 
 * in the external reference sheets.
 */
{
    int i;
    
    NX_ASSERT(![change changeInProgress], "Fault in Undo system: Code 7");
    NX_ASSERT(![change disabled], "Fault in Undo system: Code 8");
    NX_ASSERT([change hasBeenDone], "Fault in Undo system: Code 9");
    if (change != _changeInProgress) {
	/* 
	 * "Toto, I don't think we're in Kansas anymore."
	 *				- Dorthy
	 * Actually, we come here whenever a change is 
	 * incorportated or subsumed by another change 
	 * and later executes its endChange method.
	 */
        [change saveAfterChange];
	return nil;
    }
    
    if (_numberOfUndoneChanges > 0) {
	NX_ASSERT(_numberOfDoneChanges != N_LEVEL_UNDO, "Fault in Undo system: Code 10");
	/* Remove and free all undone changes */
	for (i = (_numberOfDoneChanges + _numberOfUndoneChanges); i > _numberOfDoneChanges; i--) {
	    [[_changeList removeObjectAt:(i - 1)] free];
	}
	_nextChange = nil;
	_numberOfUndoneChanges = 0;
	if (_numberOfDoneChanges < _numberOfDoneChangesAtLastClean)
	    _someChangesForgotten = YES;
    }
    if (_numberOfDoneChanges == N_LEVEL_UNDO) {
	NX_ASSERT(_numberOfUndoneChanges == 0, "Fault in Undo system: Code 11");
	NX_ASSERT(_nextChange == nil, "Fault in Undo system: Code 12");
	/* 
	    * The [_changeList removeObjectAt:0] call is order N.
	    * This will be slow if N_LEVEL_UNDO is large.
	    * Ideally the _changeList should be implemented as
	    * a circular queue, or List should do removeObjectAt:
	    * in a fixed time. In many applications (including
	    * Draw) doing the redisplay associated with the undo 
	    * will take MUCH longer than even an order N call to 
	    * removeObjectAt:, so it's not too important that 
	    * this be changed.
	    */
	[[_changeList removeObjectAt:0] free];
	_numberOfDoneChanges--;
	_someChangesForgotten = YES;
    }
    [_changeList addObject:change];
    _numberOfDoneChanges++;

    _lastChange = change;
    _changeInProgress = nil;

    [change saveAfterChange];
    [self changeWasDone];

    return self;
}

/* Methods called by ChangeManager    */
/* DO NOT call these methods directly */

- changeWasDone
/*
 * To be overridden 
 */
{
    return self;
}

- changeWasUndone
/*
 * To be overridden 
 */
{
    return self;
}

- changeWasRedone
/*
 * To be overridden 
 */
{
    return self;
}

/* Private Methods    */

- updateMenuCell:menuCell with:(const char *)menuText
{
    id editMenu, cv;

    if (strcmp([menuCell title], menuText)) {
	cv = [menuCell controlView];
	editMenu = [cv window];
#ifdef SIZE_MENU_TO_FIT
	[editMenu disableDisplay];
	    [menuCell setTitle:menuText];
	    [editMenu sizeToFit];
	[editMenu reenableDisplay];
	[editMenu display];
#else
    	if (![editMenu isDisplayEnabled]) [editMenu reenableDisplay];
    	[menuCell setTitle:menuText];
#endif
    }
    return self;
}

@end
