
#import <appkit/appkit.h>
#import "NetInfo.h"
#import "/LocalLibrary/Include/HEREutils.h"

int	result;
void *resultPtr = (void *) &result;
void	*handle;
ni_status status;
char szBuffer [80];
ni_namelist n1;
struct sockaddr_in sockAddr;



@implementation NetInfo

- test
{
	ni_status status;
	ni_entrylist entries;
	ni_idlist list;

	status = [self setConnection: "/"];

	NI_INIT (&n1);
	status = ni_listprops (domainHandle, &rootDirectory, &n1);
	if (status != NI_OK)		
		HEREAlert ("Got a bad return status on listprops");

	status = ni_children (domainHandle, &rootDirectory, &list);

		#if 0
		NI_INIT (&sockAddr);
		handle = ni_connect (&sockAddr, (ni_name) ".");
 		if (handle == NULL)		
 			HEREAlert ("Got a bad return status on open");
	
		#if 0
		status = ni_open (handle, "/", &resultPtr);
		if (status != NI_OK)		
			HEREAlert ("Got a bad return status on open");
		#endif

	niID.nii_object
struct ni_id {
	u_long nii_object;
	u_long nii_instance;
};


		NI_INIT (&n1);
		status = ni_listprops (handle, (ni_id *) ".", &n1);
		if (status != NI_OK)		
			HEREAlert ("Got a bad return status on listprops");


	sprintf (szBuffer, "Length: %u  Zero: %s", n1.ni_namelist_len, (char *) n1.ni_namelist_val);
		HEREAlert (szBuffer);
#if 0		
typedef struct {
	u_int ni_namelist_len;
	ni_name *ni_namelist_val;
} ni_namelist;
#endif



	#endif

	return self;
}
