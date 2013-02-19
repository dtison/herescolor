
#import <appkit/appkit.h>

@interface ColorPanelAccessoryView: View
{
	id		olSubview;
	id		olCIEMatrix;	

	BOOL	isInitialized;		

}
- updateMe: sender;
- setupLink;


@end
