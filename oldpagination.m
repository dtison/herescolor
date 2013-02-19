#if 0

- (BOOL) knowsPagesFirst: (int *) firstPageNum last: (int *) lastPageNum
{
	*firstPageNum = *lastPageNum = 1;
	return YES;
}

- (BOOL) getRect: (NXRect *) theRect forPage: (int) page
{
	if (page != 1)
		return NO;
	else
		*theRect = bounds;

	return YES;
}
#endif

