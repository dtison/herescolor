#import <appkit/appkit.h>
#include "/LocalLibrary/HERELibrary/Include/CmsLib.h"
#import "/LocalLibrary/HERELibrary/Include/HEREutils.h"
#import "OutputProfileInspector.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void	writeIM (char *name, float im[320][3]);

/* macros */

#define	LERP(a,b,c)		(((b) - (a)) * (c) + (a))

/* function prototypes */

static int	Check4 (int c, int d1, int d2, int d3, int d4, int fix, float im[320][3], int *nErr);
static int		Fix4(float **ptr, int fix);
static char	*Fix2(int fix);

int checkInkmodel (ColorV *inkmodel, BOOL fix)
{
	float	im[320][3];	/* to hold ink model density measurements */

	int	status = 0;
	int	i, j;
	float	value;
	int	redError, greenError, blueError, grayError, highestError;
	int	nErr;

	/*  First put the inkmodel into native form  */

	for (i = 0; i < 320; i++)
	{
		for (j = 0; j < 3; j++)
		{
			value = inkmodel [i] [j];
			if (value < 0.0 || value > 5.0)
				status = INKMODEL_ERR_DENSITY;
			else 
				im [i] [j] = value;
		}
	}

 	nErr = 0;
	redError 		= Check4 (0, 1, 4, 0, 0, YES, im, &nErr);
	greenError 	= Check4 (1, 4, 1, 12, 0, YES, im, &nErr);
	blueError		= Check4 (2, 16, 1, 0, 48, YES, im, &nErr);
	grayError		= Check4 (3, 64, 1, 0, 0, YES, im, &nErr);	
	highestError = MAX (redError, (MAX (greenError, (MAX (blueError, grayError)))));

	/*  Then, if applicable, put the native form into inkmodel */

	if (fix)
	for (i = 0; i < 320; i++)
	{
		for (j = 0; j < 3; j++)
			inkmodel [i] [j] = im [i] [j];
	}

//	writeIM ("/me/inkmodel", im);

	return highestError;
}


static int Check4 (int c, int d1, int d2, int d3, int d4, int fix, float im[320][3], int *nErr)
{
	float den[16], *ptr[16], f;
	int i, j, k, m, q, s;
	int	status;
	int	highestError = INKMODEL_ERR_NONE;

	for (i = 0, m = 0; i < 4; i++, m += d4) {
		for (j = 0; j < 4; j++, m += d3) {
			for (k = 0; k < 4; k++, m += d2) {
				for (s = 0, q = m; s < 4; s++, q += d1) {
					if (c != 3) {
						den[s] = im[q][c];
						ptr[s] = &im[q][c];
					} else {
						den[s] = (im[q][0] + im[q][1] + im[q][2]) / 3.0;
						ptr[s] = NULL;
					}
				}
				if ((den[0] > den[1]) ||
				    (den[1] > den[2]) ||
				    (den[2] > den[3]))
				 {
					#if 0
					fprintf(stdout, "%s density error with patches %3d, %3d, %3d and %3d, %s\n", ctbl[c], m+1, m+d1+1, m+d1+d1+1, m+d1+d1+d1+1, Fix4(ptr, fix));
					#endif
					/*  Check for highest error...  */
					status = Fix4 (ptr, fix);
					if (status > highestError)
						highestError = status;
					(*nErr)++;
				}
			}
		}
	}
/*
 *	Check stepwedge along bottom.
 */
 	m = 256 + c * 16;
	for (s = 0; s < 16; s++) {
		den[s] = (c == 3) ? (im[m+s][0] + im[m+s][1] + im[m+s][2]) / 3.0 : im[m+s][c];
		if (s != 0) {
			if (den[s] <= den[s-1]) 
			{
				#if 0
				fprintf(stdout, "%s density error with patches %3d and %3d, %s\n", ctbl[c], m+s, m+s+1, Fix2(fix));
				#endif
				Fix2(fix);
				(*nErr)++;
			}
		}
	}
	if (fix == TRUE) {
		do {	/* sort the stepwedge densities */
			j = 0;
			for (s = 1; s < 16; s++) {	/* bubble sort */
				if (c != 3) {	/* C, M or Y stepwedge */
					if (im[m+s][c] < im[m+s-1][c]) {
						f = im[m+s][c];	/* swap primary channel only */
						im[m+s][c] = im[m+s-1][c];
						im[m+s-1][c] = f;
						j++;
					}
				} else {	/* K stepwedge */
					if ((im[m+s][0] + im[m+s][1] + im[m+s][2]) <
					    (im[m+s-1][0] + im[m+s-1][1] + im[m+s-1][2])) {
						for (k = 0; k < 3; k++) {
							f = im[m+s][k];	/* swap all three channels */
							im[m+s][k] = im[m+s-1][k];
							im[m+s-1][k] = f;
						}
						j++;
					}
				}
			}
		} while (j != 0);
	}
	return (highestError);
}


static int Fix4(float **ptr, int fix)
{
	float t1, t2, t3;
	int	Return = INKMODEL_ERR_NONE;

	static char fixed[] = {"  (fixed X)"};

	if (! fix || ptr [0] == NULL)
		return Return;

/*
 *	There are 23 possible orders for the densities in ptr[], not counting
 *	the one good monotonic case.  We will classify them and handle each
 *	classification type differently.  We will go from most pathological to
 *	least pathological.  Fix type A is major, fix type E is minor.
 */
	if (*ptr[0] >= *ptr[3]) {
		t1 = *ptr[0];
		t2 = *ptr[3];
		*ptr[0] = t2;
		*ptr[1] = LERP(t2, t1, 1.0/3.0);
		*ptr[2] = LERP(t2, t1, 2.0/3.0);
		*ptr[3] = t1;
		Return = INKMODEL_ERR_A;

/*
 *	That fixed 12 of the cases.  There are 11 left.
 */
 	} else if (((*ptr[1] > *ptr[3]) && (*ptr[2] > *ptr[3])) ||
		   ((*ptr[1] < *ptr[0]) && (*ptr[2] < *ptr[0])) ||
		   ((*ptr[1] > *ptr[3]) && (*ptr[2] < *ptr[0])) ||
		   ((*ptr[1] < *ptr[0]) && (*ptr[2] > *ptr[3]))) {
		t1 = *ptr[0];
		t2 = *ptr[3];
		*ptr[1] = LERP(t1, t2, 1.0/3.0);
		*ptr[2] = LERP(t1, t2, 2.0/3.0);
		Return = INKMODEL_ERR_B;

/*
 *	That fixed 6 more.  There are 5 left.
 */
 	} else if (((*ptr[2] < *ptr[0]) && (*ptr[0] < *ptr[1]) && (*ptr[1] < *ptr[3])) ||
		   ((*ptr[0] < *ptr[1]) && (*ptr[1] < *ptr[3]) && (*ptr[3] < *ptr[2]))) {
		*ptr[2] = LERP(*ptr[1], *ptr[3], 0.5);
		Return = INKMODEL_ERR_C;

/*
 *	That fixed 2 more.  There are 3 left.
 */
 	} else if (((*ptr[0] < *ptr[2]) && (*ptr[2] < *ptr[3]) && (*ptr[3] < *ptr[1])) ||
		   ((*ptr[1] < *ptr[0]) && (*ptr[0] < *ptr[2]) && (*ptr[2] < *ptr[3]))) {
		*ptr[1] = LERP(*ptr[0], *ptr[2], 0.5);
		Return = INKMODEL_ERR_D;

/*
 *	That fixed 2 more.  There is one left.
 */
	} else {
		t1 = LERP(*ptr[1], *ptr[2], 0.5);
		t2 = LERP(*ptr[1], *ptr[3], 0.5);
		t3 = LERP(*ptr[0], *ptr[2], 0.5);
		*ptr[1] = LERP(t1, t3, 0.5);
		*ptr[2] = LERP(t1, t2, 0.5);
		Return = INKMODEL_ERR_E;

	}
	return (Return);
}


static char *
Fix2(int fix)
{
//	static char fixed[] =		{"            (fixed)"};
//	static char notFixed[] =	{"            (not fixed)"};


//	if (fix == FALSE)
//		return(notFixed);
//	return(fixed);
	return NULL;
}


/*   Writes out what's in the im  */

void	writeIM (char *name, float im[320][3])
{
	int	i;
	NXStream *stream;
	char	szBuffer [260];
			
	stream = NXOpenMemory (NULL, 0, NX_READWRITE);
		
	for (i = 0; i < 320; i++)
	{
		sprintf (szBuffer, "%5.3f  %5.3f  %5.3f\n", im [i][0], im [i][1], im [i][2]);
		NXWrite (stream, szBuffer, strlen (szBuffer));
	}
	
	NXSaveToFile (stream, name);
	NXCloseMemory (stream, NX_FREEBUFFER);
}
