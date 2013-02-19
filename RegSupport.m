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
 
/* RegSupport.m:
 *
 * Support functions for registration.  Usually included by
 * Registration.m
 */

/****************************************************************
  UTILITY FUNCTIONS
 ****************************************************************/

char	*binary_to_hex(void *binary,int len,char *buf)
{
	char	buf2[8];
	int	i;
	unsigned char *cc = binary;

	buf[0]	= 0;
	for(i=0;i<len;i++){
		sprintf(buf2,"%02X",(unsigned) cc[i]);
		strcat(buf,buf2);
		if((i & 0x01) == 0x01 && (i!=len-1)){
			strcat(buf,"-");
		}
	}
	return buf;
}

void	*hex_to_binary(const char *buf,void *binary,int len)
{
	const char 	*cc = buf;
	unsigned char 	*out = binary;

	int	i;

	for(i=0;i<len;i++){
		char	digit;
		int	i;
		
		if(*cc == '-') cc++;
		*out	= 0;
		for(i=0;i<2;i++){
			digit	 	= NXToUpper(*cc++);
			if(digit=='L') digit='1';
			if(digit=='O') digit='0';
			*out	= (*out << 4);
			if(NXIsDigit(digit)) *out += digit - '0';
			if(NXIsAlpha(digit)) *out += digit - 'A' + 10;
		}
		out++;
	}

	return binary;
}

int	checksum(void *data,int len)
{
	unsigned char *cc = data;
	int	 i;
	unsigned char sum;

	sum	= 0;
	for(i=0;i<len;i++){
		sum	+= cc[i];
	}
	return sum;
}

int	checksum2(void *data,int len)
{
	unsigned short *dd = data;
	int	 i;
	unsigned short dsum;

	dsum	= 0;
	for(i=0;i<len/2;i++){
		dsum	+= dd[i];
	}
	return dsum;
}

void	asciiToKey(char *ascii,char *key)
{
	memset(key,0,8);
	strncpy(key,ascii,8);
}

char 	*hostNumberToAscii(int address,char *buf)
{
	sprintf(buf,"%u.%u.%u.%u",
(unsigned) ((address >> 24) & 0xff),
(unsigned) ((address >> 16) & 0xff),
(unsigned) ((address >> 8)  & 0xff),
(unsigned) ((address >> 0)  & 0xff));
	return buf;
}

char	*hostName(int  address,char *buf)
{
   struct  hostent 	*hp;
   
   hp = gethostbyaddr((char *)&address,4,AF_INET);
   
   return hp ? hp->h_name : hostNumberToAscii(address,buf);
}

/****************************************************************
 MESSAGES FOR DEALING WITH LICENSE STRINGS AND SUCH
 ****************************************************************/

int	lsNumUsers(struct licenseString *ls)
{
	return (ls->maxMachines[0] << 8) + ls->maxMachines[1];

}


