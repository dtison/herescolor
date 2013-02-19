/*
 * (C) 1992 Simson Garfinkel and Associates, Inc.
 *
 * NeXTSTEP developers may freely use and redistribute this software as long
 * as credit is given to Simson Garfinkel and Associates.
 *
 * EXPORT RESTRICTIONS:
 *
 * You may not ship the source-code module des.c outside of the US or canada.
 *
 * You may ship a program which uses the des.o compiled module outside of the
 * United States to any type T or type V country as long as you do not provide
 * cryptographic services to the user in your program and you clearly
 * declare "commodity control number 5D11A" on your export declaration.
 *
 * Type T countries include all countries in the Western Hemisphere except Cuba.
 * Type V countries include all countries in the Eastern Hemisphere except
 * the previous communist block countries and the People's Republic of China,
 * Vietnam, Cambodia, and Laos.
 *
 * For further information, contact the Office of Export Control:
 *
 *	Bureau of Export Administration
 *	P.O. Box 273
 *	Washington, DC 20044
 *	202-377-2694
 */
 
/****************************************************************
  SGAI's Registration System
 ****************************************************************/


/* token a user might type */
struct licenseString {
	unsigned char	product;
	unsigned char	num[3];		/* accession number */
	unsigned char	start;		/* month in top half / year in bottom */
	unsigned char 	end;
	unsigned char 	maxMachines[2];
	unsigned char 	flag;
	unsigned char 	checksum;
};

/* Product Codes */
#define	SBOOK		1
#define	EDITBENCH	2
#define	SECURITY	3
#define	REGGEN		4


/* flags */

#define	REG_SINGLEUSER 	0x0001		/* single user license */
#define REG_DEMO	0x0002		/* demo license */
#define REG_START	0x0004		/* look at start time */
#define REG_END		0x0008		/* look at end time */

/* What we transmit on the network in UDP packets */

struct regNetToken {
	char		version;
	char		username[10];
	char		person[64];	/* person full name who is using 	*/
	struct  	licenseString ls; /* that they are using with 		*/
	int		session_number;	/* (hopefully) unique session number	*/
	unsigned char	time[4];	/* how long we have been running, in sec*/
	char		command;	/* what we should do with this command 	*/
	char		userData[256];	/* any other data 			*/
};

/* commands */

#define	C_PING	1			/* generate a reply */
#define	C_PRINT	2			/* print a message */
#define C_PONG  3			/* reponse to a ping */

/* internal commands */
#define C_DUPLICATE_SINGLE_USER	1000	/* duplicate single user on network */
#define C_TOO_MANY_NETWORK	1001	/* too many network copies running  */

/* Tuneable parameters (you can tune a filesystem but you can't...) */

#define	RANDOM_SLEEP_TIME	5	/* how long to wait after a PING before a PONG */
#define REG_WINDOW		5	/* for calculating if people started before us */

/* What we stamp into our binary.  Don't worry --- it's DES encrypted! */
struct	registration_string {
	unsigned long 		guard1[2];
	unsigned short 		checksum;		/* validation */
	struct licenseString	ls; 			/* typed in */
	long			ctime;
	long			mtime; 			/* time of inode */
	char			owner[80];		/* name */
	unsigned long 		guard2[2];
};

#define	SERIAL_GUARD_1	0x10709030
#define	SERIAL_GUARD_2	0x80fe7020

#import <appkit/Application.h>
@interface Application(Simson)
- fatalError;
- noisyFatalError;
- showLicenseStatus;
- showLicensePanel:sender;
- showRegistrationPanel:sender;
@end

/* RegSupport.m */
char	*binary_to_hex(void *binary,int len,char *buf);
void	*hex_to_binary(const char *buf,void *binary,int len);
int	checksum(void *data,int len);
int	checksum2(void *data,int len);
void	asciiToKey( char *ascii,char *key);
char	*hostNumberToAscii(int address,char *buf);
char	*hostName(int address,char *buf);
int	lsNumUsers(struct licenseString *ls);
  
/* des.c */
int	desinit(int);
int	dessetkey(char kn[16][8],char *key);
int	endes(char kn[16][8],void *data);
int	dedes(char kn[16][8],void *data);
