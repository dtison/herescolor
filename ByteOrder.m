#import "appkit/appkit.h"
#import "Windefs.h"
#import "/LocalLibrary/Include/HEREutils.h"
 
WORD ByteOrderWord (WORD wValue, BOOL bReverse)
{
    WORD wRetval;

    if (! bReverse)
        wRetval = wValue;
    else
    {
        // Swap bytes

        wRetval = LOBYTE (wValue);
        wRetval <<= 8;
        wRetval |= (WORD) HIBYTE (wValue);
    }

    return (wRetval);
}

LONGWORD ByteOrderLong (LONGWORD *dwValue, BOOL bReverse)
{
    LONGWORD dwRetval;
    PBYTE  pBytes1;
    PBYTE  pBytes2;
    BYTE  bTmp;

    dwRetval = *dwValue;

    if (! bReverse)
        return (dwRetval);
    else
    {
        // Swap bytes

        pBytes1 = (PBYTE) &dwRetval;
        pBytes2 = (PBYTE) &dwRetval + 3;

        bTmp     = *pBytes1;
        *pBytes1 = *pBytes2;
        *pBytes2 = bTmp;

        pBytes1++;
        pBytes2--;

        bTmp     = *pBytes1;
        *pBytes1 = *pBytes2;
        *pBytes2 = bTmp;


    }
    return (dwRetval);
}