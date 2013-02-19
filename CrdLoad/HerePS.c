
#include <appkit/appkit.h>
#include <stdio.h>
#include <stdlib.h>

main (int argc, char **argv)
{
	char	*buffer;

	buffer = malloc (2048);

	sprintf (buffer, "/NextLibrary/Services/PrintFilters.service/crdload < $stdin | /NextLibrary/Services/PrintFilters.service/psprepare -o %s\n", argv [2]);

	system (buffer);

	free (buffer);

	return 1;
}