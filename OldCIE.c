		#ifdef __NEVER__
		{
			ColorV sourceV, destV;

			/*  Red:  .3105 .1743 .0705  */

			sourceV [0] = .3105;
			sourceV [1] = .1743;
			sourceV [2] = .0705;

			CiCmsRcsColor (CI_XYZ_TO_RCS, sourceV, destV);

			RcHn -> set.pairs [0].response [RGB_R] = destV [0];
			RcHn -> set.pairs [0].response [RGB_G] = destV [1];
			RcHn -> set.pairs [0].response [RGB_B] = destV [2];

			/*  Green:  .0864 .1631 .1203  */

			sourceV [0] = .0864;
			sourceV [1] = .1631;
			sourceV [2] = .1203;

			CiCmsRcsColor (CI_XYZ_TO_RCS, sourceV, destV);

			RcHn -> set.pairs [1].response [RGB_R] = destV [0];
			RcHn -> set.pairs [1].response [RGB_G] = destV [1];
			RcHn -> set.pairs [1].response [RGB_B] = destV [2];

			/*  Blue:  .0708 .0483 .2139  */

			sourceV [0] = .0708;
			sourceV [1] = .0483;
			sourceV [2] = .2139;

			CiCmsRcsColor (CI_XYZ_TO_RCS, sourceV, destV);

			RcHn -> set.pairs [2].response [RGB_R] = destV [0];
			RcHn -> set.pairs [2].response [RGB_G] = destV [1];
			RcHn -> set.pairs [2].response [RGB_B] = destV [2];


			/*  Cyan:  .1817  .2445  .6895  */

			sourceV [0] = .1817;
			sourceV [1] = .2445;
			sourceV [2] = .6895;

			CiCmsRcsColor (CI_XYZ_TO_RCS, sourceV, destV);

			RcHn -> set.pairs [3].response [RGB_R] = destV [0];
			RcHn -> set.pairs [3].response [RGB_G] = destV [1];
			RcHn -> set.pairs [3].response [RGB_B] = destV [2];

			/*  Magenta:  .3461 .1808 .2165  */

			sourceV [0] = .3461;
			sourceV [1] = .1808;
			sourceV [2] = .2165;

			CiCmsRcsColor (CI_XYZ_TO_RCS, sourceV, destV);

			RcHn -> set.pairs [4].response [RGB_R] = destV [0];
			RcHn -> set.pairs [4].response [RGB_G] = destV [1];
			RcHn -> set.pairs [4].response [RGB_B] = destV [2];

			/*  Yellow:  .6690 .6941 .1245  */

			sourceV [0] = .6690;
			sourceV [1] = .6941;
			sourceV [2] = .1245;

			CiCmsRcsColor (CI_XYZ_TO_RCS, sourceV, destV);

			RcHn -> set.pairs [5].response [RGB_R] = destV [0];
			RcHn -> set.pairs [5].response [RGB_G] = destV [1];
			RcHn -> set.pairs [5].response [RGB_B] = destV [2];

		}
		#endif		 
