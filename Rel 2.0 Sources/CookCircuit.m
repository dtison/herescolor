- (int) cookCircuit: (OutputProfile *) profile
{
	int			status;
	int			qualityLevel;
	BOOL		is4Color;
	ColorV 		primaries [3];
	long			refWhite;
	Flt			gamma [3];
	BOOL		isTransformActive = NO;
	BOOL		isCircuitActive = NO;

	NX_DURING

	/*  Set RCS to monitor's color space  */ 

	primaries [0] [0] = monitorSpace.redChroma_x;
	primaries [0] [1] = monitorSpace.redChroma_y;
	primaries [0] [2] = 0;
	primaries [1] [0] = monitorSpace.greenChroma_x;
	primaries [1] [1] = monitorSpace.greenChroma_y;
	primaries [1] [2] = 0;
	primaries [2] [0] = monitorSpace.blueChroma_x;
	primaries [2] [1] = monitorSpace.blueChroma_y;
	primaries [2] [2] = 0;
	gamma [0] = monitorSpace.redGamma;
	gamma [1] = monitorSpace.greenGamma;
	gamma [2] = monitorSpace.blueGamma;	
 	refWhite = (long) monitorSpace.whitePoint;

	status = CiCmsRcsSet (primaries, refWhite, CI_CT_GAMMA, gamma);
	if (status != CE_OK)
		NX_RAISE (Err_TransformError0, NULL, NULL);

 	/*  Now make the  transform  */

	CiTranCreate();
	isTransformActive = YES;

	qualityLevel = (profile -> processingQuality == MAX_QUALITY) ? 
				CI_QL_MAX - 1 : CI_QL_MAX - 2;
	
	/*  Now add the links to the transform (4 color transform)  */
	
	[colorLinks addRcHnLink: profile -> rchnRCSColors:
						[self referenceRcHnColors]:
						profile -> rchnColorsUsed:
						NUMRCHNCOLORS: CI_FDIR_NATIVE];

	is4Color = (deviceType == CMYK_4COLOR);
	if (is4Color)
	{
		[colorLinks addHnPnLink: profile: CI_FDIR_NATIVE: useRelaxedInkmodel];
		[colorLinks addPnPdLink: profile: CI_FDIR_NATIVE];
	}
	else
		[colorLinks addHnHdLink: profile: CI_FDIR_NATIVE];

	/*  Now cook into a colorcircuit  */
	/*  Note that in an OOP setup, this would be done by colorLinks object  */

	[olCancelButton setEnabled: YES];
	abandon			= NO;
	progressDone		= 0; 
	progressPortion 	= ((float) 1 / 6);

	CiCmsCallbackSet (CI_CB_PROGRESS, cmslibProgress);
 	CiCmsCallbackSet (CI_CB_ABORT, cmslibAbort);

	if (CiCircCreate (qualityLevel, CI_DIR_FORWARD) != CE_OK)
		if (abandon)
			NX_RAISE (Err_UserAbandon, NULL, NULL);
		else 
			NX_RAISE (Err_TransformError5, NULL, NULL);
	isCircuitActive = YES;

	if (CiCircWrite ("Profile.hc1") != CE_OK)
		NX_RAISE (Err_TransformError6, NULL, NULL);

	CiCircClose();
	isCircuitActive = NO;
	
	progressDone += progressPortion;

	if (CiCircCreate (qualityLevel, CI_DIR_BACKWARD) != CE_OK)
		if (abandon)
			NX_RAISE (Err_UserAbandon, NULL, NULL);
		else 
			NX_RAISE (Err_TransformError5, NULL, NULL);
	isCircuitActive = YES;

	if (CiCircWrite ("Profile.hc2") != CE_OK)
		NX_RAISE (Err_TransformError6, NULL, NULL);

	NX_RAISE (Err_NoError, NULL, NULL);
	NX_HANDLER	
	if (isCircuitActive)
		CiCircClose();
	if (isTransformActive)
		CiTranClose();
	[controller setDefaultRCS];
	/*  We don't set the percent back because profile write is still in progress... */
	[olCancelButton setEnabled: NO];
	if (NXLocalHandler.code != Err_NoError)
	{
		[olProgressView setPercent: 0];
		NX_RERAISE();
	}
	NX_ENDHANDLER

     	return CE_OK;
}

