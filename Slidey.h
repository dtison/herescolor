
#import <appkit/appkit.h>
#import "AppDefs.h"

@interface Slidey: Control
{
	id		olControl1;
	float		slideyBegin;
	float		slideyEnd;
	float		slideyPosition;
	float		slideyRange;		// Range:  end - begin
	float 	ratio;
}

- setRatio: (float) aRatio;
- setRange: (float) begin: (float) end startAt: (float) start;


@end
