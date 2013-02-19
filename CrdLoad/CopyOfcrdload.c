
#include <stdio.h>
#include <stdlib.h>

main (int argc, char **argv)
{
	FILE		*crdFile;
	FILE		*outputFile;
	char		*buffer;
	int		index;
	int		bytesPerChunk = 1024 * 50;
	int		done = 0;
	int		bytesRead;

	fputs ("In crdload\n", stdout);

	puts ("Output file: ");
	puts (argv [2]);
	puts ("\n\n");

	buffer = malloc (bytesPerChunk);

	strcpy (buffer, argv [2]);
	outputFile = fopen (buffer, "w");

	if (outputFile)
		puts ("Got a valid outputFile\n");
	else
		puts ("Got an invalid outputFile\n");

	#if 0
	crdFile = fopen ("/me/CurrentCRD", "r");
	if (crdFile != NULL)
	{
		while (fgets (buffer, 512, crdFile) != NULL)
     			fputs (buffer, outputFile);

		fclose (crdFile);
	}
	#endif

	puts ("Copying source stream\n");

	while (! done)
	{

		char szBuffer [260];

//		puts ("Reading chunk\n");
		bytesRead = fread (buffer, 1, bytesPerChunk, stdin);

 		sprintf (szBuffer, "Read %d bytes\n", bytesRead);
		puts (szBuffer);

		if (!  bytesRead)
			done = 1;
		else
			fwrite (buffer, 1, bytesRead, outputFile);
		
	}


	puts ("Closing & Freeing\n");

	fclose (outputFile);
	free (buffer);

	puts ("Returning 1\n");
	return 1;
}