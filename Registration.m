/* 
* You may ship a program which uses the des.o compiled module outside of the
 * United States to any type T or type V country as long as you do not provide
 * cryptographic services to the user in your program and you clearly
 * declare "commodity control number 5D11A" on your export declaration.
 */


 
#import <appkit/appkit.h>

#import "Registration.h"

#import <netdb.h>
#import <pwd.h>
//#import <appkit/NXCType.h>

/*  Registration Stuff  */

#define	PRODUCT_PASSWORD 	"7710-952A-ZX49-1148"
#define	PRODUCT_UDP_PORT	1409	 
#define	PRODUCT_CODE		10
//#import "./Registration.m"


/* Network Registration Stuff
 *
 * "embedded" is our embedded registration string, for stamped binaries.
 * It contains our current network token.
 * Is is decrypted when we are running.
 */


struct	registration_string embedded = 
{
SERIAL_GUARD_1,SERIAL_GUARD_2,
0,					/* ctime */
0,					/* mtime */
0,					/* checksum */
0,0,0,0,0,0,0,0,0,0,			/* ls */

0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,			/* name */
SERIAL_GUARD_1,SERIAL_GUARD_2	
};


#define	REG		"SingleUserRegistration" 
#define	ANNOUNCEMENT_FREQUENCY 60.0 * 10	/* how often to announce ourselves */

/* Static variables */

static	port_name_t	myMachPort;
static	int		send_sock;		/* the talking socket */
static	int		recv_sock;		/* receiving socket */
static	int		recv_fd;		/* receiving fd */
static	mutex_t		randomt;		/* mutex for random number genreator */
static	long		otherHosts[1024]; 	/* other hosts running with our license */
static	int		numOtherHosts;
static	DPSTimedEntry	announcementTE;
static	DPSTimedEntry	expiredTE;
		int		licensed;	/* are we licensed? */
static	id		registrationPanel;
static	id 		licensePanel;
static	long		start_time;
static	char		username[10];
static	char		person[64];
static	long		session_number;

/* for probing on licensing */
static	int		probes_found;
static	unsigned char	probing_num[3];	/* number we are probing */
static	char		probed_person[9];
static	char		probed_username[64];
static	char		probed_host[64];


#import "RegSupport.m"

/****************************************************************
 MACH MESSAGE FUNCTIONS
 ****************************************************************/


/* structure for mach messaging */
typedef struct {
	msg_header_t 	h;
	msg_type_t   	t1;
	int		command;
	msg_type_t   	t2;
	const char 	*data;
} myMessage;


#define	BROADCAST 0xffffffff
#define	PING_EVERYBODY 1
#define PONG_EVERYBODY 2

/* Send a mach message to the main thread */
void	message_main_thread(int command,const char *data)
{
	myMessage	msg;
	
	memset(&msg,0,sizeof(msg));	/* zero my message */

	msg.h.msg_simple	= TRUE;
	msg.h.msg_size 		= sizeof(msg);
	msg.h.msg_type 		= MSG_TYPE_NORMAL; /* normal message */
	msg.h.msg_local_port 	= 0;
	msg.h.msg_remote_port 	= myMachPort;

	/* fill in the type descriptor */
	msg.t1.msg_type_name 	= MSG_TYPE_INTEGER_32;
	msg.t1.msg_type_size 	= 32;
	msg.t1.msg_type_number 	= 1;
	msg.t1.msg_type_inline 	= YES;
	msg.t1.msg_type_longform = FALSE;
	msg.t1.msg_type_deallocate = FALSE;

	/* fill in the type descriptor */
	msg.t2.msg_type_name 	= MSG_TYPE_STRING_C;
	msg.t2.msg_type_size 	= 32;
	msg.t2.msg_type_number 	= 1;
	msg.t2.msg_type_inline 	= FALSE;
	msg.t2.msg_type_longform = FALSE;
	msg.t2.msg_type_deallocate = FALSE;

	msg.command	= command;
	msg.data	= data;
		
	msg_send(&msg.h,SEND_NOTIFY,0);	/* send and don't wait */
}

/* This gets called in the main thread from message_main_thread
 */
DPSPortProc	portListener(msg_header_t *msgp,void *userData)
{
	myMessage	*msg = (myMessage *)msgp;
	char		*data;

	data	= alloca(strlen(msg->data)+1);
	strcpy(data,msg->data);

	switch(msg->command){
	 case C_PRINT:
	   NXRunAlertPanel(0,data,0,0,0);
	   return 0;

	 case C_DUPLICATE_SINGLE_USER:
	   NXRunAlertPanel("License Violation",
			   "%s is already using your single user license.",
			   "Terminate program",0,0,data);
	   [NXApp fatalError];
	   return 0;
	   
	 case C_TOO_MANY_NETWORK:
	   NXRunAlertPanel("License Violation",
			   "More than %d copies of this program are already running on your network.",
			   "Terminate program",0,0,lsNumUsers(&embedded.ls));
	   [NXApp fatalError];
	   return 0;

			   
	}
	return 0;
}


/****************************************************************
  UDP STUFF
 ****************************************************************/

/*
 * udp_announcer:
 * Announce my whereabouts to the world.
 * Randomly pause between 1 and 10 seconds, which should be sufficient for most
 * networks.
 */
static	void udp_announcer(int address)
{
	struct  sockaddr_in sin;
	struct	regNetToken 	nt;
	int	pause;
	long	now;
	long	duration;

	if(address!=PING_EVERYBODY){
		mutex_lock(randomt);
		pause	= random() % RANDOM_SLEEP_TIME;
		mutex_unlock(randomt);
		sleep(pause);
	}

	
	time(&now);

	duration = now - start_time;

	memset(&nt,0,sizeof(nt));
	nt.version		= 0;
	strcpy(nt.username,username);
	strcpy(nt.person,person);
	nt.ls			= embedded.ls;
	nt.session_number	= session_number;
	nt.time[0]		= duration & 0xff;
	nt.time[1]		= (duration >> 8) & 0xff;
	nt.time[2]		= (duration >> 16) & 0xff;
	nt.time[3]		= (duration >> 24) & 0xff;
	nt.command		= C_PONG;
	memset(&nt.userData,0,sizeof(nt.userData));

	switch(address){
	      case PING_EVERYBODY:
		address		= BROADCAST;
		nt.command	= C_PING;
		break;
	      case PONG_EVERYBODY:
		address		= BROADCAST;
		nt.command	= C_PONG;
		break;
	}

	sin.sin_family		= AF_INET;
	sin.sin_port		= PRODUCT_UDP_PORT;	/* our port */
	*(int *)&sin.sin_addr	= address;

	sendto(send_sock,&nt,sizeof(nt),0,(struct sockaddr *)&sin,sizeof(sin));
}


/* duplicate_ls():
 *
 * Called when somebody tells me they are using my accession number.
 * 1. Ignore them if they were started after we were.
 * 2. If they are using our accession number on a SINGLE USER license,
 * 3. If they are using a multi-user number, then count how many
 *    people are left
 */
void	duplicate_ls(int fromaddr,struct regNetToken *nt)
{
	long	now;
	long	my_duration,their_duration;
	char	buf[1024];
	char	buf2[1024];
	int	i;

	/* First tell them that something is amis */

	time(&now);
	my_duration = now - start_time;

	their_duration	= nt->time[3]<<24 | nt->time[2]<<16 | nt->time[1]<<8 | nt->time[0];

	if(my_duration+REG_WINDOW > their_duration){

	   /* They haven't been running as long as we have been. */

	   if(embedded.ls.flag & REG_SINGLEUSER){

	      /* but they are using our single user string! */

	      sprintf(buf,"%s (%s) on %s is trying to run this application with your "
		      "single-user license string.",
		      nt->person,nt->username,hostName(fromaddr,buf2));
	      message_main_thread(C_PRINT,buf);
	   }


	   return;			/* don't annoy our user any more */
	}

	if(embedded.ls.flag & REG_SINGLEUSER){

	   /* we came second on single-user string */
	   sprintf(buf,"%s (%s) on %s",
		   nt->person,
		   nt->username,
		   hostNumberToAscii(fromaddr,buf2));
	   message_main_thread(C_DUPLICATE_SINGLE_USER,buf);
	}
	
	for(i=0;i<numOtherHosts;i++){
	   if(otherHosts[i]==fromaddr) return; /* already got this host */
	}
	otherHosts[numOtherHosts++] = fromaddr;

	/* More than maximum allowed hosts? */


	if(numOtherHosts >= lsNumUsers(&embedded.ls)){
	   message_main_thread(C_TOO_MANY_NETWORK,"");
	}

}



/* udp_listener():
 *
 * Listen for incoming UDP commands and execute them.
 */

static	void udp_listener(void *userData)
{
	struct	sockaddr_in from;
	int	fromlen;
	long	fromaddr;
	char	received_udp[4096];
	int	cc;

	while(1){
		memset(&from,0,sizeof(from));
		fromlen = sizeof(from);
		cc	= recvfrom(recv_sock, received_udp, sizeof(received_udp),
				   0, (struct sockaddr *)&from, &fromlen);

		fromaddr=*(int *)&from.sin_addr;;
		if(cc==sizeof(struct regNetToken)){
		   char	hbuf[256];

			struct	regNetToken 	*nt = (struct regNetToken *)received_udp;
			

			if(nt->session_number==session_number){
				/* got a message from myself.  Ignore */
				continue;
			}

		   
		   /* Check for match with our license string */
		   if(!memcmp(nt->ls.num,embedded.ls.num,3)){
		      duplicate_ls(fromaddr,nt); 
		   }

			/* decode command */
			switch(nt->command){
			      case C_PING:
				cthread_fork((cthread_fn_t)udp_announcer,(any_t)fromaddr);
				break;
			      case C_PRINT:
				{
					char	*buf;

					buf	= alloca(1024+strlen(nt->userData));
					
					sprintf(buf,"Message from %s on %s: %s",
						nt->username,
						hostNumberToAscii(fromaddr,hbuf),
						nt->userData);
					message_main_thread(C_PRINT,buf);
				}
				break;
			      case C_PONG:
				/* Check for match with probe */
				if(!memcmp(nt->ls.num,probing_num,3)){
					strcpy(probed_person,nt->person);
					strcpy(probed_username,nt->username);
					strncpy(probed_host,hostName(fromaddr,hbuf),63);
					probed_host[63] = 0;
					probes_found++;
				}
				break;
			}
		}
	}
}



/* called by announcement TE */
static	void	announcement_handler()
{
	if(embedded.ls.flag & REG_DEMO){
		/* don't announce if we are a demo copy */
		return;
	}
	cthread_fork((cthread_fn_t)udp_announcer,(any_t)PONG_EVERYBODY);
}

/****************************************************************
  INITIALIZATION
 ****************************************************************/

static	void	network_init()
{
	struct  sockaddr_in sin;
	struct	passwd	*pw;


	/* NETWORK INITIALIZATION */

	memset(otherHosts,0,sizeof(otherHosts));
	memset(probing_num,0,sizeof(probing_num));

	numOtherHosts = 0;

	/* set up connections for listening */
	memset(&sin,0,sizeof(sin));
	sin.sin_family	= AF_INET;
	sin.sin_port	= PRODUCT_UDP_PORT;	/* our port */
	recv_sock	= socket(AF_INET,SOCK_DGRAM,0); /* get a socket */
	if(recv_sock<0){
		NXRunAlertPanel(0,"Could not create Internet socket.","Abort program",0,0);
		[NXApp fatalError];
	}
	recv_fd 	= bind(recv_sock,(struct sockaddr *)&sin,sizeof(sin));
	if(recv_fd<0){
		NXRunAlertPanel(0,"Another copy of %s was detected running on this computer.",
				"Bye",0,0,[NXApp appName]);
		[NXApp fatalError];
	}


	randomt	= mutex_alloc();
	srandom(time(&start_time));

	pw	= getpwuid(getuid());

	memset(username,0,sizeof(username));
	memset(person,0,sizeof(person));
	strncpy(username,pw->pw_name,sizeof(username));
	strncpy(person,pw->pw_gecos,sizeof(person));
	person[sizeof(person)-1]	= 0;
	username[sizeof(username)-1]	= 0;

	session_number	= random();

	port_allocate(task_self(),&myMachPort);
	send_sock	= socket(AF_INET,SOCK_DGRAM,0);
	DPSAddPort(myMachPort,(DPSPortProc)portListener,8192,0,NX_BASETHRESHOLD);

	cthread_fork((cthread_fn_t)udp_listener,0);
	cthread_fork((cthread_fn_t)udp_announcer,(any_t)PING_EVERYBODY);

	announcementTE = DPSAddTimedEntry(ANNOUNCEMENT_FREQUENCY,
					  announcement_handler,0,NX_BASETHRESHOLD);

}

static	void	license_init()
{
	/* See if we are licensed */
	const char 	*reg;
	const char	*appName = [NXApp appName];
	BOOL		branded=YES;
	char		key[9];
	char 		ks[16][8];

	licensed= NO;
	reg	= NXGetDefaultValue(appName,REG);
	if(reg){
		/* If we have a default value, overwrite value stored in binary */
		hex_to_binary(reg,&embedded,sizeof(embedded)); 
		branded=NO;
	}

	/* Decrypt it */
	asciiToKey(PRODUCT_PASSWORD,key);
	desinit(0);
	dessetkey(ks,key);
	dedes(ks,&embedded.checksum);
	

	/* Now check to see if string is legit */
	if(checksum2(&embedded,sizeof(embedded))) return;

	if(embedded.guard1[0]!=SERIAL_GUARD_1 ||
	   embedded.guard1[1]!=SERIAL_GUARD_2 ||
	   embedded.guard2[0]!=SERIAL_GUARD_1 ||
	   embedded.guard2[1]!=SERIAL_GUARD_2){

		/* serial guard is not present */
		memset(&embedded,0,sizeof(embedded));
		return;
	}

	/* Make sure we are the right product */
	if(embedded.ls.product != PRODUCT_CODE) return;	/* doesn't match */

	/* See if it has expired */
	if(embedded.ls.flag & REG_START){
		long	t;
		struct	tm *tm;

		time(&t);
		tm	= localtime(&t);
		if(   ((embedded.ls.start & 0x40) >> 4) < (tm->tm_mon+1)
		   || ((embedded.ls.start & 0x04) + 1992) < (tm->tm_year+1900)){

			[NXApp perform:@selector(notifyLicenseExpired:) with:nil
		       afterDelay:1000 cancelPrevious:NO];
			memset(&embedded,0,sizeof(embedded));
			return;
		}
	}

	if(embedded.ls.flag & REG_END){
		long	t;
		struct	tm *tm;

		time(&t);
		tm	= localtime(&t);
		if(   ((embedded.ls.end & 0x40) >> 4) > (tm->tm_mon+1)
		   || ((embedded.ls.end & 0x04) + 1992) > (tm->tm_year+1900)){

			[NXApp perform:@selector(notifyLicenseExpired:) with:nil
		       afterDelay:1000 cancelPrevious:NO];
			memset(&embedded,0,sizeof(embedded));
			return;
		}
	}

	/* See if the file was moved and we are a network license */

	if(branded){
		struct stat sbuf;

		if(embedded.ls.flag & REG_DEMO){
		   NXRunAlertPanel(0,"This is a demo version",0,0,0);
		   licensed = YES;
		   return;
		}


		/* Not a demo.  See if it has been moved */

		if(stat(NXArgv[0],&sbuf)){
			NXRunAlertPanel(0,"Cannot access executable: %s",0,0,0,
					NXArgv[0]);
			memset(&embedded,0,sizeof(embedded));
			return;
		}
		if(embedded.mtime+10 < sbuf.st_mtime){

		   /* Only do this if we are not a demo */
		   NXRunAlertPanel(0,
				   "Branded file has been moved and "
				   "must be re-branded.",
				   0,0,0);
		   memset(&embedded,0,sizeof(embedded));
		   return;
		}
	     }
	licensed = YES;
}

static	void	demo_expired()
{
	/*  For HEREs stuff so far, we don't use timers for demo  */

	DPSRemoveTimedEntry(expiredTE);
	expiredTE = 0;
	return;

	if (licensed){
		DPSRemoveTimedEntry(expiredTE);	/* it got licensed */
		expiredTE = 0;
		return;
	}
	NXRunAlertPanel("Time's up!","This program is not licensed. "
			"Your demo period has expired",0,0,0);
	[NXApp	fatalError];
}


void	registration_init2(DPSTimedEntry teNumber, double now, char *userData)
{
   DPSRemoveTimedEntry(teNumber);	/* remove ourselves */
   network_init();
   license_init();
	
   if(licensed==NO){
      [NXApp	perform:@selector(notifyNotLicensed:) with:nil
     afterDelay:1000 cancelPrevious:NO];

      expiredTE = DPSAddTimedEntry(60 * 1,
				   demo_expired,0,NX_BASETHRESHOLD);
   }
}

/* registration_init():
 *
 * Main entry into the registration package.
 * Must be run from the main thread.
 * May be run as many times as needed.
 * 
 * Schedule the real init process with a TE
 */
 
void	registration_init()
{
	static 	inited=0;

	if(inited) return;
	inited	= 1;

	DPSAddTimedEntry(0.1,(DPSTimedEntryProc)registration_init2,
			 0,NX_BASETHRESHOLD);
}


/* bootstrap myself into the Application class */
@implementation MenuCell(Registration)
+alloc
{
	registration_init();
	return [super alloc];
}

+allocFromZone:(NXZone *)zone
{
	registration_init();
	return [super allocFromZone:zone];
}
@end

@implementation Application(Registration)
-fatalError
{
	[self terminate:nil];
	exit(0);		/* for the bozos */
}

-noisyFatalError
{
	NXRunAlertPanel("Fatal Error",
			"Unable to load Registration Panels from executable. "
			"Execution cannot continue.","Exit Program",0,0);
	[self fatalError];
	exit(0);
}

BOOL	check_position(char *start,char *pos)
{
	struct	registration_string *test = (struct registration_string *)pos;

	if(test->guard1[0]==SERIAL_GUARD_1 &&
	   test->guard1[1]==SERIAL_GUARD_2 &&
	   test->guard2[0]==SERIAL_GUARD_1 &&
	   test->guard2[1]==SERIAL_GUARD_2){

		long	offset = pos-start;
		int	fd;

		/* open up the file and write out the new token */
		fd	= open(NXArgv[0],O_RDWR);
		if(!fd){
			NXRunAlertPanel("Branding","Could not open %s for branding",0,0,0,
					NXArgv[0]);
		}
		lseek(fd,offset,0);
		write(fd,&embedded,sizeof(embedded));
		close(fd);
		return YES;
	}
	return NO;
}

-showLicenseStatus
{
	id	status  = NXGetNamedObject("LicenseStatusCell",licensePanel);
	id	user	= NXGetNamedObject("LicenseNameField",licensePanel);
	id	exp	= NXGetNamedObject("ExpField",licensePanel);
	id	userNum = NXGetNamedObject("UserNumberField",licensePanel);

	if(!licensed){
		[status 	setStringValue:"This program is unlicensed"];
		[user		setStringValue:""];
		[exp		setStringValue:""];
		[userNum	setStringValue:""];
		return self;
	}

	if(embedded.ls.flag & REG_SINGLEUSER){
		[status	setStringValue:"Licensed for single user."];
		[user	setStringValue:embedded.owner];
	}
	if(embedded.ls.flag & REG_DEMO){
		[status	setStringValue:"Demonstration License"];
		[user	setStringValue:embedded.owner];
	}
	if((embedded.ls.flag & (REG_SINGLEUSER | REG_DEMO))==0){
		char	buf[256];

		sprintf(buf,"Network License\n%d copies",lsNumUsers(&embedded.ls));
		[status	setStringValue:buf];
		[user	setStringValue:embedded.owner];
	}
	if(embedded.ls.flag & REG_END){
		char	buf[256];

		sprintf(buf,"Expires %d/%d",
			(embedded.ls.end & 0x40) >> 4,
			(embedded.ls.end & 0x04) + 92);
		[exp	setStringValue:buf];
	}
	else{
		[exp	setStringValue:""];
	}
	[userNum	setIntValue:(  (embedded.ls.num[0] << 16)
				     + (embedded.ls.num[1] <<  8)
				     + (embedded.ls.num[2] <<  0))];
				     
	return self;
}

-registerProgram:sender
{
	NXStream	*str;
	char		*addr;
	int		len,maxlen;
	long		test = SERIAL_GUARD_1;
	char		val = *(unsigned char *)&test;
	struct licenseString	ls;
	const char	*regString;
	const char	*companyName;
	char		*aa;
	unsigned char 	*cc = (unsigned char *)&ls;
	struct stat 	sbuf;
	char		key[9];
	char 		ks[16][8];

	/* Check to see if the registration string is valid */
	regString = [NXGetNamedObject("LicenseStringField",registrationPanel) stringValue];
	companyName=[NXGetNamedObject("CompanyNameField",registrationPanel) stringValue];

	if(!regString) [self	noisyFatalError];

	/* Convert to a license token */
	hex_to_binary(regString,&ls,sizeof(ls));

	/* Decrypt the token */
	asciiToKey(PRODUCT_PASSWORD,key);
	desinit(0);
	dessetkey(ks,key);
	dedes(ks,cc+2);
	dedes(ks,cc);

	if(checksum(&ls,sizeof(ls))){
		NXRunAlertPanel("License","Invalid license string",0,0,0);
		return nil;
	}
	
	if(strlen(companyName)==0){
		NXRunAlertPanel("License","Name can not be blank",0,0,0);
		return nil;
	}

	if(stat(NXArgv[0],&sbuf)){
		NXRunAlertPanel("License","Cannot access executable: %s",0,0,0,
				NXArgv[0]);
		return nil;
	}

	/* If this is a single-user string, see if anybody else is using it */
	if(ls.flag & REG_SINGLEUSER){
		probes_found	= 0;
		memcpy(probing_num,ls.num,3);
		udp_announcer(PING_EVERYBODY);  /* ping everybody in this thread */
		sleep(RANDOM_SLEEP_TIME+2);	/* wait for results */
		if(probes_found>0){
			NXRunAlertPanel("License",
					"That license string is being used by "
					"%s (%s) on the workstation named '%s.'",
					"Can't license",0,0,
					probed_person,probed_username,probed_host);
			return nil;
		}
		memset(probing_num,0,sizeof(probing_num));
	}

	licensed	= YES;


	/* Set up the embedded token */
	memset(&embedded,0,sizeof(embedded));

	embedded.guard1[0] 	= SERIAL_GUARD_1;
	embedded.guard1[1]	= SERIAL_GUARD_2;
	embedded.guard2[0]	= SERIAL_GUARD_1;
	embedded.guard2[1]	= SERIAL_GUARD_2;
	embedded.ls		= ls;
	time(&embedded.ctime);
	time(&embedded.mtime);
	strncpy(embedded.owner,companyName,sizeof(embedded.owner)-1);
		
	/* calc the checksum */

	embedded.checksum	= 0;
	embedded.checksum	= 65536-checksum2(&embedded,sizeof(embedded));

	/* Make sure we calculated it properly */
	if(checksum2(&embedded,sizeof(embedded))!=0){
		NXRunAlertPanel(0,"Internal error: checksum not 0.  Cannot license.",0,0,0);
		return nil;
	}

	
	[registrationPanel	orderOut:nil];

	/* Now encrypt it before writing */
	dessetkey(ks,key);
	endes(ks,&embedded.checksum);


	/* If this is a single-user license, write it into the defaults database */
	if(ls.flag & REG_SINGLEUSER){
		char	buf[256];
		
		NXWriteDefault(appName,REG,
			       binary_to_hex(&embedded,sizeof(embedded),buf));

		NXRunAlertPanel(0,"Registered single-user license",0,0,0);
		goto	end;
	}


	NXRemoveDefault(appName,REG); /* no longer a single user */

	/* Must be demo or multi-user; write to binary */

	str	= NXMapFile(NXArgv[0],NX_READONLY);
	NXGetMemoryBuffer(str,&addr,&len,&maxlen);

	for(aa=addr;aa<addr+len;aa++){
		if(*aa == val
		   && check_position(addr,aa)){
			NXRunAlertPanel(0,"Branded successfully for %d users",
					0,0,0,lsNumUsers(&embedded.ls));
			goto end;
		}
	}

      end:;
	/* Now decrypt the string that's in memory */
	dessetkey(ks,key);
	dedes(ks,&embedded.checksum);
	[self	showLicenseStatus];

	return self;
}

/* Display License Panel.
 * If program is unlicensed, display the registration panel...
 */
-showLicensePanel:sender
{
	if(!licensePanel){
		[NXApp loadNibSection:"Registration.nib" owner:NXApp withNames:YES];

		/* wire up everything.  You don't think that we're going to put this
		 * in the nib, do you?
		 */
		licensePanel = NXGetNamedObject("License Panel",NXApp);
	}
	if(licensePanel==nil)	[NXApp noisyFatalError];
	[self		showLicenseStatus];

	if(licensed){
		[[licensePanel 	center] makeKeyAndOrderFront:nil]; /* display it */
	}
	else{
		[self		showRegistrationPanel:nil];
	}
	return self;
}

/* Display the Registration Panel */
-showRegistrationPanel:sender
{
	if(!registrationPanel){
		[NXApp loadNibSection:"Registration.nib" owner:NXApp withNames:YES];

		/* wire up everything.  You don't think that we're going to put this
		 * in the nib, do you?
		 */
		registrationPanel = NXGetNamedObject("Registration Panel",NXApp);
	}
	if(registrationPanel==nil) [NXApp noisyFatalError];
	[NXGetNamedObject("LicenseStringField",registrationPanel) setStringValue:""];
	[NXGetNamedObject("CompanyNameField",registrationPanel) setStringValue:""];
	[[registrationPanel center] makeKeyAndOrderFront:nil]; /* display it */
	return self;

}

- notifyNotLicensed:sender
{
	NXRunAlertPanel("License","This application has not yet been licensed. "
			"Press OK to run Registration Panel or to run in Demo Mode",0,0,0);
	[self	showRegistrationPanel:nil];
	return self;
}

- notifyLicenseExpired:sender
{
	NXRunAlertPanel("License","Your license has expired.  "
			"This program is now unlicensed",
			0,0,0);
	return self;

}

@end
  

#import "des.c"
  
