

	#if 0
	Matrix *itemList;		// Temporary as long as we have a popup not artwork
	id	popupButton;

	/*  New profile, set to setup first  */

	popupButton =  NXCreatePopUpListButton (olViewPopup);
	itemList = [olViewPopup itemList];	
	[itemList selectCellAt: 2: 0];
	[popupButton setTitle: [[itemList selectedCell] title]];
	[popupButton display];
	#endif
