#include "/LocalLibrary/HERELibrary/Include/CmsLib.h"

//#define EMULATE_CMS

#ifdef EMULATE_CMS

int	CiCircClose(void)
{
	return CE_OK;
}

int	CiCircColor(long nColors, uchar **ip, int iStep, uchar **op, int oStep)
{
	return CE_OK;
}


int	CiCircCreate(int qualLevel, int direction)
{
	return CE_OK;
}
int	CiCircModify(int modID, void *pars)
{
	return CE_OK;
}
int	CiCircRead(char *fileName)
{
	return CE_OK;
}
int	CiCircWrite(char *fileName)
{
	return CE_OK;
}

int	CiCmsCallbackSet(int type, void *function)
{
	return CE_OK;
}
int	CiCmsClose(void)
{
	return CE_OK;
}
int	CiCmsGroupClose(void)
{
	return CE_OK;
}
int	CiCmsGroupSet(int group, char *label)
{
	return CE_OK;
}
int	CiCmsOpen(void)
{
	return CE_OK;
}
int	CiCmsPathSet(char *path)
{
	return CE_OK;
}
int	CiCmsRcsColor(int convType, ColorV iCol, ColorV oCol)
{
	return CE_OK;
}
int	CiCmsRcsSet(ColorV prim[3], ulong refWhite, int compandType, Flt *compandPars)
{
	return CE_OK;
}

int	CiLinkAdd(void)
{
	return CE_OK;
}
int	CiLinkClose(void)
{
	return CE_OK;
}
int	CiLinkColor(ColorV iCol, ColorV oCol, int direction)
{
	return CE_OK;
}
int	CiLinkCreate(int linkType, void *pars)
{
	return CE_OK;
}
int	CiLinkFDirSet(int fwdDirection)
{
	return CE_OK;
}
int	CiLinkModify(int modID, void *pars)
{
	return CE_OK;
}
int	CiLinkOpen(int linkID)
{
	return CE_OK;
}
int	CiLinkParsFree(void *pars)
{
	return CE_OK;
}
int	CiLinkRead(char *fileName)
{
	return CE_OK;
}
int	CiLinkWrite(char *fileName)
{
	return CE_OK;
}

int	CiMiscGainCalc(Flt dens0, Flt dens50, Flt dens100, Flt *dotGain)
{
	return CE_OK;
}
int	CiMiscPatternMake(int tpID, ulong xs, ulong ys, char *fileName, FormatSpecs *specs)
{
	return CE_OK;
}
int	CiMiscQuery(int queryType, void *queryResult)
{
	return CE_OK;
}

int	CiTranClose(void)
{
	return CE_OK;
}
int	CiTranColor(ColorV iCol, ColorV oCol, int direction)
{
	return CE_OK;
}
int	CiTranCreate(void)
{
	return CE_OK;
}
int	CiTranRead(char *fileName)
{
	return CE_OK;
}
int	CiTranWrite(char *fileName)
{
	return CE_OK;
}

int	CiMiscCalc(int calcType, void *input, void *output)
{
	return CE_OK;
}

int Ci_MapRefWhite (ColorV sourceV, long sourceWhitepoint, ColorV destV, long destWhitepoint)
{
	return CE_OK;
}

#endif