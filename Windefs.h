#ifndef WINDEFS_H
#define WINDEFS_H

#ifndef HEREDEFS_H
#import "/LocalLibrary/Include/HEREdefs.h"
#endif

#define DWORD LONGWORD
#define FAR	
#define NEAR
#define huge

#define MAKELONG(a, b)      ((LONG)(((WORD)(a)) | (((DWORD)((WORD)(b))) << 16)))
#define LOWORD(l)           ((WORD)(l))
#define HIWORD(l)           ((WORD)((DWORD)(l) >> 16))
#define LOBYTE(w)           ((BYTE)(w))
#define HIBYTE(w)           ((BYTE)((WORD)(w) >> 8))



typedef struct tagRGBTRIPLE {
        BYTE    rgbtBlue;
        BYTE    rgbtGreen;
        BYTE    rgbtRed;
} RGBTRIPLE;

typedef struct tagRGBQUAD {
        BYTE    rgbBlue;
        BYTE    rgbGreen;
        BYTE    rgbRed;
        BYTE    rgbReserved;
} RGBQUAD;

/* structures for defining DIBs */
typedef struct tagBITMAPCOREHEADER {
        DWORD   bcSize;                 /* used to get to color table */
        WORD    bcWidth;
        WORD    bcHeight;
        WORD    bcPlanes;
        WORD    bcBitCount;
} BITMAPCOREHEADER;
typedef BITMAPCOREHEADER FAR *LPBITMAPCOREHEADER;
typedef BITMAPCOREHEADER *PBITMAPCOREHEADER;


typedef struct tagBITMAPINFOHEADER{
        DWORD      biSize;
        DWORD      biWidth;
        DWORD      biHeight;
        WORD       biPlanes;
        WORD       biBitCount;

        DWORD      biCompression;
        DWORD      biSizeImage;
        DWORD      biXPelsPerMeter;
        DWORD      biYPelsPerMeter;
        DWORD      biClrUsed;
        DWORD      biClrImportant;
} BITMAPINFOHEADER;

typedef BITMAPINFOHEADER FAR *LPBITMAPINFOHEADER;
typedef BITMAPINFOHEADER *PBITMAPINFOHEADER;

/* constants for the biCompression field */
#define BI_RGB      0L
#define BI_RLE8     1L
#define BI_RLE4     2L

typedef struct tagBITMAPINFO {
    BITMAPINFOHEADER    bmiHeader;
    RGBQUAD             bmiColors[1];
} BITMAPINFO;
typedef BITMAPINFO FAR *LPBITMAPINFO;
typedef BITMAPINFO *PBITMAPINFO;

typedef struct tagBITMAPCOREINFO {
    BITMAPCOREHEADER    bmciHeader;
    RGBTRIPLE           bmciColors[1];
} BITMAPCOREINFO;
typedef BITMAPCOREINFO FAR *LPBITMAPCOREINFO;
typedef BITMAPCOREINFO *PBITMAPCOREINFO;

typedef struct tagBITMAPFILEHEADER {
        WORD    bfType;
        DWORD   bfSize;
        WORD    bfReserved1;
        WORD    bfReserved2;
        DWORD   bfOffBits;
} BITMAPFILEHEADER;
typedef BITMAPFILEHEADER FAR *LPBITMAPFILEHEADER;
typedef BITMAPFILEHEADER *PBITMAPFILEHEADER;

#endif
