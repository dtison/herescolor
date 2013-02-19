
#import "MonitorCalibrator.h"

@implementation MonitorCalibrator

#define SHOW_HIDDEN_GAMMA(g) rint (((g - 0.5) * 33.333) + 0.05)

- runOrderFront: sender
{
	MonitorSpace space;

	/*  Do our initialization...  */

	[[olViewPopup itemList] selectCellAt: 0: 0];

	controller = [NXApp delegate];
	[controller monitorColorSpace: &space];

	[olRedGammaView1 setChipColor: RED];
	[olRedGammaView2 setChipColor: RED];
	[olGreenGammaView1 setChipColor: GREEN];
	[olGreenGammaView2 setChipColor: GREEN];
	[olBlueGammaView1 setChipColor: BLUE];
	[olBlueGammaView2 setChipColor: BLUE];

	[olRedGammaView2 setSolid: YES];
	[olGreenGammaView2 setSolid: YES];
	[olBlueGammaView2 setSolid: YES];

  	[olMonPrimariesRedX setFloatValue: space.redChroma_x];
   	[olMonPrimariesRedY setFloatValue: space.redChroma_y];
  	[olMonPrimariesGreenX setFloatValue: space.greenChroma_x];
   	[olMonPrimariesGreenY setFloatValue: space.greenChroma_y];
  	[olMonPrimariesBlueX setFloatValue: space.blueChroma_x];
   	[olMonPrimariesBlueY setFloatValue: space.blueChroma_y];
   	[olMonitorWhitepoint setFloatValue: space.whitePoint];

	[olRedGammaView1 setDrawGamma: 1];
	[olGreenGammaView1 setDrawGamma: 1];
	[olBlueGammaView1 setDrawGamma: 1];

	[olRedGammaSlider setFloatValue: space.redGamma];
	[olGreenGammaSlider setFloatValue: space.greenGamma];
	[olBlueGammaSlider setFloatValue: space.blueGamma];
	[olRedGammaView2 setFloatValue: space.redGamma];
	[olGreenGammaView2 setFloatValue: space.greenGamma];
	[olBlueGammaView2 setFloatValue: space.blueGamma];

 	[olRedGammaText setIntValue: SHOW_HIDDEN_GAMMA (space.redGamma)];
 	[olGreenGammaText setIntValue: SHOW_HIDDEN_GAMMA (space.greenGamma)];
 	[olBlueGammaText setIntValue: SHOW_HIDDEN_GAMMA (space.blueGamma)];

	[olEpsilonSlider setFloatValue: 2.2];
	[olEpsilonEdit setFloatValue: 2.2];
	epsilon = [controller getEpsilon];
	if (! [controller isRoot])
	{
		[olEpsilonEdit setEnabled: NO];
		[olEpsilonSlider setEnabled: NO];
	}

	if (! currentView)
		[self setGammaView: self];

	#ifdef BROWSER
	[olMonitorBrowser setDelegate: self];
	#endif

	[olMonitorCalibratorPanel orderFront: sender];
	[olMonitorCalibratorPanel setDelegate: self];

	isActive = YES;

	return self;
}

#ifdef BROWSER

#define NUM_MONITORS 4

- (int) browser: sender
 fillMatrix: matrix
inColumn: (int)column
{
	int	i;

	for (i = 0; i < NUM_MONITORS; i++)
		[matrix addRow];

	[[[[matrix cellAt: 0: 0] setStringValue: "17\" NeXT Monitor"] setLoaded: YES] setLeaf: YES];
	[[[[matrix cellAt: 1: 0] setStringValue: "21\" NeXT Monitor"] setLoaded: YES] setLeaf: YES];
	[[[[matrix cellAt: 2: 0] setStringValue: "SuperMac 19\""] setLoaded: YES] setLeaf: YES];
	[[[[matrix cellAt: 3: 0] setStringValue: "SuperMac 19\" Dual Mode"] setLoaded: YES] setLeaf: YES];
	#if 0
	[[[[matrix cellAt: 4: 0] setStringValue: "NEC Monitor"] setLoaded: YES] setLeaf: YES];
	[[[[matrix cellAt: 5: 0] setStringValue: "Compaq Monitor"] setLoaded: YES] setLeaf: YES];
	[[[[matrix cellAt: 6: 0] setStringValue: "Goldstar Monitor"] setLoaded: YES] setLeaf: YES];
	[[[[matrix cellAt: 7: 0] setStringValue: "Mag Electronics Monitor"] setLoaded: YES] setLeaf: YES];
	[[[[matrix cellAt: 8: 0] setStringValue: "SamsungMonitor"] setLoaded: YES] setLeaf: YES];
	[[[[matrix cellAt: 9: 0] setStringValue: "Samtron Monitor"] setLoaded: YES] setLeaf: YES];
	[[[[matrix cellAt: 10: 0] setStringValue: "Viewtronics 15\" Monitor"] setLoaded: YES] setLeaf: YES];
	[[[[matrix cellAt: 11: 0] setStringValue: "Viewtronics 17\"Monitor"] setLoaded: YES] setLeaf: YES];
	[[[[matrix cellAt: 12: 0] setStringValue: "Radius Monitor"] setLoaded: YES] setLeaf: YES];
	[[[[matrix cellAt: 13: 0] setStringValue: "Barco Monitor"] setLoaded: YES] setLeaf: YES];
	[[[[matrix cellAt: 14: 0] setStringValue: "Brand X Monitor"] setLoaded: YES] setLeaf: YES];
	#endif

	return NUM_MONITORS;
}
 
- (const char *) browser: sender titleOfColumn: (int) column
{
	return "Monitors";
}
#endif


- setSettingsView: sender
{
	currentView = olSettingsView;

	[olViewButton  setTitle: [[olViewButton target]  selectedItem]];

	[olMonitorCalibratorView setContentView: currentView];
	[olMonitorCalibratorPanel display];
	[olInstructionsText setStringValue: "Enter values for your monitor."];
	return self;
}

- setGammaView: sender
{
	currentView = olGammaView;

	[olViewButton  setTitle: [[olViewButton target]  selectedItem]];

	[olMonitorCalibratorView setContentView: currentView];
	[olMonitorCalibratorPanel display];
	[olInstructionsText setStringValue: "Adjust the values so the lower chip matches the upper."];

	return self;
}

- setNormalizerView: sender
{
	currentView = olNormalizerView;

	[olMonitorCalibratorView setContentView: currentView];
	[olMonitorCalibratorPanel display];
	[olInstructionsText setStringValue: "Use slider to adjust to overall brightness to your liking."];

	return self;
}

- redGammaSet: sender
{
	float redGamma = [sender floatValue];
	
	[olRedGammaText setIntValue: SHOW_HIDDEN_GAMMA (redGamma)];
	[olRedGammaView2 setFloatValue: redGamma];	
	return self;
}

- greenGammaSet: sender
{
	float greenGamma = [sender floatValue];
	
	[olGreenGammaText setIntValue: SHOW_HIDDEN_GAMMA (greenGamma)];
	[olGreenGammaView2 setFloatValue: greenGamma];	
	return self;
}

- blueGammaSet: sender
{
	float blueGamma = [sender floatValue];
	
	[olBlueGammaText setIntValue: SHOW_HIDDEN_GAMMA (blueGamma)];
	[olBlueGammaView2 setFloatValue: blueGamma];

	return self;
}

- epsilonSet: sender
{
	epsilon = [sender floatValue];
	
	PSsetglobal (1);
	PSWsetgamma (epsilon);
	PSsetglobal (0);


	if ([sender isKindOf: [TextField class]])
 		[olEpsilonSlider setFloatValue: epsilon];
	else
		[olEpsilonEdit setFloatValue: epsilon];

	return self;
}

#if 0
/*  Thing for finding best defaultTransfer  */
- setEpsilon: (float) 
{
	float	gamma = [sender floatValue];

	return self;
}
#endif

- monitorCalibratorSet: sender
{
	MonitorSpace space;
	BOOL		isError = NO;

	/*  Copy the fields to the monitor space structure and send off to controller  */

 	space.redGamma 		= [olRedGammaSlider floatValue];
 	space.greenGamma 	= [olGreenGammaSlider floatValue];
 	space.blueGamma 		= [olBlueGammaSlider floatValue];
	space.redChroma_x		= [olMonPrimariesRedX floatValue];
	space.redChroma_y		= [olMonPrimariesRedY floatValue];
	space.greenChroma_x	= [olMonPrimariesGreenX floatValue];
	space.greenChroma_y	= [olMonPrimariesGreenY floatValue];
	space.blueChroma_x	= [olMonPrimariesBlueX floatValue];
	space.blueChroma_y	= [olMonPrimariesBlueY floatValue];
	space.whitePoint		= [olMonitorWhitepoint floatValue];

	/*  Do some error checking to see some nonsense has been entered  */

	if ((space.redChroma_x + space.redChroma_y) > 1.0)
		isError = YES;
	if ((space.greenChroma_x + space.greenChroma_y) > 1.0)
		isError = YES;
	if ((space.blueChroma_x + space.blueChroma_y) > 1.0)
		isError = YES;
	if (space.whitePoint > (float) CI_CIE_MAX_TEMP ||
		space.whitePoint < (float) CI_CIE_MIN_TEMP)
			isError = YES;

	if (isError)
	{
		HEREAlert (MONITOR_SETTINGS_ERROR);
		return self;
	}

	[controller setMonitorColorSpace: &space];

	#ifdef EPSILON
	/*  Deal with the epsilon thing if we can  */
	
	if ([controller isRoot])
	{
		float	epsilon = [olEpsilonEdit floatValue];
		setDefaultTransfer (epsilon, epsilon, epsilon);
		[controller setEpsilon: epsilon];
	}
	#endif

	HEREAlert (MONITOR_CALIBRATION_SET_ACKNOWLEDGE);
	return self;
}

- windowWillClose: sender
{
	isActive = NO;		

	return self;
}

/*  For main menu support only so far  5-18-93  */

- (BOOL) isActive
{
	return isActive;
}

- setDefaults: sender
{
 	[olMonPrimariesRedX setFloatValue: 0.64];
   	[olMonPrimariesRedY setFloatValue: 0.33];
  	[olMonPrimariesGreenX setFloatValue: 0.30];
   	[olMonPrimariesGreenY setFloatValue: 0.60];
  	[olMonPrimariesBlueX setFloatValue: 0.15];
   	[olMonPrimariesBlueY setFloatValue: 0.06];
   	[olMonitorWhitepoint setFloatValue: REFWHITE];
	return self;
}
@end
