int addRcHnLink (ColorV *rcsColors,
				BOOL *rchnColorsUsed,
				float redMonGamma, 
				float greenMonGamma, 
				float blueMonGamma,
				int	numColors)

{
	int		status;
	RcHnPars *RcHn;
	float	red, green, blue, alpha;	
	ColorV	 sourceV, destV;
	int		i;
	int		numPairs;
	NXColor	monitorColor, whiteColor;
	ColorV	colorV;

	NX_MALLOC (RcHn, RcHnPars, 1);

	RcHn -> set.nPairs = numColors;
	NX_MALLOC (RcHn -> set.pairs, ColorPair, RcHn -> set.nPairs);
	memset (RcHn -> set.pairs, 0, (RcHn -> set.nPairs * sizeof (ColorPair)));
	
	/*  For each color picked color, normalize then run thru MnMd backwards to put in RC */

	whiteColor = NXConvertRGBAToColor (1, 1, 1, NX_NOALPHA);
	numPairs = 0;

	for (i = 0; i < numColors; i++)
	{
		/*  First see if this is a color we should include  */

///		monitorColor = visualCalibrateColors [i];
	
//		if (! NXEqualColor (visualColor, whiteColor))
		{
			/*  Set reference color  */

			memcpy (colorV, referenceRGB [i], sizeof (ColorV));
			RcHn -> set.pairs [numPairs].reference [RGB_R] = colorV [RGB_R];
			RcHn -> set.pairs [numPairs].reference [RGB_G] = colorV [RGB_G];
			RcHn -> set.pairs [numPairs].reference [RGB_B] = colorV [RGB_B];

			NXConvertColorToRGBA (visualColor, &red, &green, &blue, &alpha);

			sourceV [0]	= red;
			sourceV [1]	= green;
			sourceV [2]	= blue;
 
 			RcHn -> set.pairs [numPairs].response [RGB_R] = destV [0];
 			RcHn -> set.pairs [numPairs].response [RGB_G] = destV [1];
 			RcHn -> set.pairs [numPairs].response [RGB_B] = destV [2];

			numPairs++;
		}
	}

	/*  Fix up actual number of pairs and close monitor link  */

	RcHn -> set.nPairs = numPairs;
	CiLinkClose();	// Close down the MnMd link

	{
		char szBuffer [80];
		sprintf (szBuffer, "Included %d pairs", numPairs);
		NXLogError(szBuffer);
	}

// 	#define LOOKATOURLINK
	#ifdef LOOKATOURLINK	
	{
		char szBuffer [260];

		NXLogError ("Our Link Pairs:");

	for (i = 0; i < numPairs; i++)
	{
		sprintf (szBuffer, "ref: %7.3f %7.3f %7.3f",
		RcHn -> set.pairs [i].reference [RGB_R],
		RcHn -> set.pairs [i].reference [RGB_G],
		RcHn -> set.pairs [i].reference [RGB_B]);
		NXLogError (szBuffer);

		sprintf (szBuffer, "res: %7.3f %7.3f %7.3f",
		RcHn -> set.pairs [i].response [RGB_R],
		RcHn -> set.pairs [i].response [RGB_G],
		RcHn -> set.pairs [i].response [RGB_B]);
		NXLogError (szBuffer);
			
	}
	
	strcpy (szBuffer, "\n\n\n");
	NXLogError (szBuffer);

	}
	#endif

// Note:  RcHnForNeXT2.link is bad,  NeXT3 works fine w/ 2 fewer pairs.

//   	status = CiLinkRead ("/me/RcHn.link");
 //   	status = CiLinkRead ("/me/RcHnForNeXT3.link");


   	status  = CiLinkCreate (CI_LT_RCHN, RcHn);
	if (status  != CE_OK)
	{
		char		szBuffer [80];
		sprintf (szBuffer, "Problem making rchn link.  Status:  %d",status);
 		HEREAlert (szBuffer);
	}

 	CiLinkAdd();
// 	CiLinkWrite ("/me/RcHn.link");
	CiLinkClose();
	NX_FREE (RcHn -> set.pairs);
	NX_FREE (RcHn);

// 	#define __TEST__
	#ifdef __TEST__
	{
		char szBuffer [260];

	   	status = CiLinkRead ("/me/RcHn.link");
		CiMiscQuery (CI_QT_LINK_PARS, &RcHn);

		NXLogError ("Query /me/RcHn:");
	
		for (i = 0; i < RcHn -> set.nPairs; i++)
		{
			sprintf (szBuffer, "ref: %7.3f %7.3f %7.3f",
			RcHn -> set.pairs [i].reference [RGB_R],
			RcHn -> set.pairs [i].reference [RGB_G],
			RcHn -> set.pairs [i].reference [RGB_B]);
			NXLogError (szBuffer);

			sprintf (szBuffer, "res: %7.3f %7.3f %7.3f",
			RcHn -> set.pairs [i].response [RGB_R],
			RcHn -> set.pairs [i].response [RGB_G],
			RcHn -> set.pairs [i].response [RGB_B]);
			NXLogError (szBuffer);

			
		}  
		strcpy (szBuffer, "\n\n\n");
		NXLogError (szBuffer);
		CiLinkParsFree (RcHn); 
		CiLinkClose();

	   	status = CiLinkRead ("/me/RcHnForNeXT3.link");
		CiMiscQuery (CI_QT_LINK_PARS, &RcHn);

		NXLogError ("Query /me/RcHnForNeXT3:");


		for (i = 0; i < RcHn -> set.nPairs; i++)
		{
			sprintf (szBuffer, "ref: %7.3f %7.3f %7.3f",
			RcHn -> set.pairs [i].reference [RGB_R],
			RcHn -> set.pairs [i].reference [RGB_G],
			RcHn -> set.pairs [i].reference [RGB_B]);
			NXLogError (szBuffer);

			sprintf (szBuffer, "res: %7.3f %7.3f %7.3f",
			RcHn -> set.pairs [i].response [RGB_R],
			RcHn -> set.pairs [i].response [RGB_G],
			RcHn -> set.pairs [i].response [RGB_B]);
			NXLogError (szBuffer);

		}

		strcpy (szBuffer, "\n\n\n");
		NXLogError (szBuffer);
		CiLinkParsFree (RcHn); 
		CiLinkClose();
 
	}
	#endif


	
	return status;
}
