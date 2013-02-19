
#include <appkit/appkit.h>
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
	char 	szBuffer [260];
	const char	*homeDirectory;

	buffer = malloc (bytesPerChunk);

//	strcpy (buffer, argv [2]);
//	outputFile = fopen (buffer, "w");
	outputFile = stdout;

	strcpy (szBuffer, "/.CurrentCRD");

	crdFile = fopen (szBuffer, "r");
	done	 = 0;
	while (! done)
	{
		bytesRead = fread (buffer, 1, bytesPerChunk, crdFile);

		if (!  bytesRead)
			done = 1;
		else
			fwrite (buffer, 1, bytesRead, outputFile);
		
	}


	done	 = 0;
	while (! done)
	{
		bytesRead = fread (buffer, 1, bytesPerChunk, stdin);	
		if (!  bytesRead)
			done = 1;
		else
			fwrite (buffer, 1, bytesRead, outputFile);
		
	}

//	fclose (outputFile);
	free (buffer);

	return 1;
}