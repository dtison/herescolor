#import "ChangeStuff.h"

/*
 * Please refer to external reference pages for complete
 * documentation on using the Change class.
 */

@interface Change(PrivateMethods)

- calcTargetForAction:(SEL)theAction in:aView;

@end

@implementation Change

/* Methods called directly by your code */

- init
{
    [super init];
    _changeFlags.disabled = NO;
    _changeFlags.hasBeenDone = NO;
    _changeFlags.changeInProgress = NO;
    _changeManager = nil;
    return self;
}

- startChange
{
    return [self startChangeIn:nil];
}
 
- startChangeIn:aView
{
    _changeFlags.changeInProgress = YES;
    _changeManager = [NXApp calcTargetForAction:@selector(changeInProgress:)];

    if (_changeManager == nil && aView != nil)
        _changeManager = [self calcTargetForAction:@selector(changeInProgress:) in:aView];

    if(_changeManager != nil) {
	if ([_changeManager changeInProgress:self] && !_changeFlags.disabled)
	    return self;
	else
	    return nil;
    }

    return self;
}

- endChange
{
    if (_changeManager == nil || _changeFlags.disabled) {
	[self free];
	return nil;
    } else {
	_changeFlags.hasBeenDone = YES;
	_changeFlags.changeInProgress = NO;
	if ([_changeManager changeComplete:self])
	    return self;
	else
	    return nil;
    }
}

- changeManager
{
    return _changeManager;
}

/* Methods called by ChangeManager or by your code */

- disable
{
    _changeFlags.disabled = YES;
    return self;
}

- (BOOL)disabled
{
    return _changeFlags.disabled;
}

- (BOOL)hasBeenDone
{
    return _changeFlags.hasBeenDone;
}

- (BOOL)changeInProgress
{
    return _changeFlags.changeInProgress;
}

- (const char *)changeName
/*
 * To be overridden 
 */
{
    return "";
}

/* Methods called by ChangeManager */
/* DO NOT call directly */

- saveBeforeChange
/*
 * To be overridden 
 */
{
    return self;
}

- saveAfterChange
/*
 * To be overridden 
 */
{
    return self;
}

- undoChange
/*
 * To be overridden. End with:
 * return [super undoChange];
 */
{
    _changeFlags.hasBeenDone = NO;
    return self;
}

- redoChange
/*
 * To be overridden. End with:
 * return [super redoChange];
 */
{
    _changeFlags.hasBeenDone = YES;
    return self;
}

- (BOOL)subsumeChange:change
/*
 * To be overridden 
 */
{
    return NO;
}

- (BOOL)incorporateChange:change
/*
 * To be overridden 
 */
{
    return NO;
}

- finishChange
/*
 * To be overridden 
 */
{
    return self;
}

/* Private Methods */

- calcTargetForAction:(SEL)theAction in:aView
/*
 * This method is intended to behave exactly like the Application
 * method calcTargetForAction:, except that that method always returns
 * nil if the application is not active, where we do our best to come
 * up with a target anyway.
 */
{
    id responder, nextResponder;

    responder = [[aView window] firstResponder];
    while (![responder respondsTo:theAction]) {
        nextResponder = nil;
        if ([responder respondsTo:@selector(nextResponder)])
            nextResponder = [responder nextResponder];
	if (nextResponder == nil && [responder isKindOf:[Window class]])
	    nextResponder = [responder delegate];
	if (nextResponder == nil)
	    nextResponder = NXApp;
	if (nextResponder == nil && responder == NXApp)
	    nextResponder = [responder delegate];
	responder = nextResponder;
    }
    return responder;
}

@end
