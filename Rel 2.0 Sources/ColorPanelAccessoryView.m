
#import "ColorPanelAccessoryView.h"
#import "CmsLib.h"
#import "Controller.h"
#import "ColorLinks.h"

@implementation ColorPanelAccessoryView


- updateMe: sender
{
	float	red, green, blue, alpha;
	NXColor	color;
	int		status;
	ColorV	sourceV;
	ColorV	destV;
	int		link, group;

	/*  Convert current color to CIE  */

	color = [window color];
	NXConvertColorToRGBA (color, &red, &green, &blue, &alpha);

	/*  This assumes CMS is open  */

	status = CiMiscQuery (CI_QT_CMS_GROUPID, &group);
	status = CiCmsGroupSet (CI_NGROUPS - 1, NULL);
	status = CiMiscQuery (CI_QT_LINK_TYPE, &link);
	if (status != CE_OK)		// CMS was closed and reopened 
		[self setupLink];
 

	sourceV [RGB_R] 	= red;
	sourceV [RGB_G] 	= green;
	sourceV [RGB_B] 	= blue;

	status = CiLinkColor (sourceV, destV, CI_DIR_BACKWARD);
	if (status != CE_OK)
		NXBeep();
	CiCmsRcsColor (CI_RCS_TO_XYZ, destV, sourceV);
	
	[[olCIEMatrix cellAt: 0: 0] setFloatValue: sourceV [0]];
	[[olCIEMatrix cellAt: 0: 1] setFloatValue: sourceV [1]];
	[[olCIEMatrix cellAt: 0: 2] setFloatValue: sourceV [2]];

	status = CiCmsGroupSet (group, NULL);
	return self;
}

- init
{
	int	status;
	int	group;

 	[self addSubview: olCIEMatrix];

	if ([window respondsTo: @selector (setAction:)])
		[window setAction: @selector (updateMe:)];

	if ([window respondsTo: @selector (setTarget:)])
		[window setTarget: self];

	/*  Now set up the CMS  */

	status = CiMiscQuery (CI_QT_CMS_GROUPID, &group);
	[self setupLink];
	status = CiCmsGroupSet (group, NULL);

	return self;
}

#import "OutputProfileInspector.h"		// TO BE REPLACED WITH A COLOR BOX include
- setupLink
{
	int 	status;
	id	controller = [NXApp delegate];
	float	redMonGamma, greenMonGamma, blueMonGamma;

	/*  Grab the system-wide monitor gammas from the dispatcher (controller)  */

	[controller monitorGammas: &redMonGamma: &greenMonGamma: &blueMonGamma];

	status = CiCmsGroupSet (CI_NGROUPS - 1, NULL);
 	status = makeMnMdLink (redMonGamma, greenMonGamma, blueMonGamma);
	return self;
}


@end
