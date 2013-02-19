
#include <appkit/appkit.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

main (int argc, char **argv)
{
	FILE		*file1, *file2;
	char		*buffer;
	int		index;
	int		bytesPerChunk = 1024 * 50;
	int		done = 0;
	int		bytesRead;
	char 	szBuffer [260];
	const char	*homeDirectory;
	int		status;
	float		v1, v2, v3, v4, v5, v6;
	int		count = 0;

	buffer = malloc (bytesPerChunk);

	printf ("%s\n", argv [1]);
	printf ("%s\n", argv [2]);


	file1 = fopen (argv[1], "r");
	file2 = fopen (argv[2], "r");

	done	 = 0;
	while (! feof (file1))
	{
	  	fscanf (file1, "%f %f %f\n", &v1, &v2, &v3);
		fscanf (file2, "%f %f %f\n", &v4, &v5, &v6);

		v1 = (v4 - v1);
		if (v1 < 0)
			v1 *= -1;

		v2 = (v5 - v2);
		if (v2 < 0)
			v2 *= -1;

		v3 = (v6 - v3);
		if (v3 < 0)
			v3 *= -1;


		printf ("Line: %d \t%+5.3f \t%+5.3f \t%+5.3f", count,  v1,   v2,  v3);
		if ((v1 > .01) || (v2 > .01) || (v3 > .01))
			printf ("***");

		printf ("\n");
		

		if (! status)
			done = YES;

		count++;

	}

	if (file1)
		fclose (file1);

	if (file2)	
		fclose (file2);

	return 1;
}