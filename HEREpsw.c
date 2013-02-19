/* HEREpsw.c generated from HEREpsw.psw
   by unix pswrap V1.009  Wed Apr 19 17:50:24 PDT 1989
 */

#include <dpsclient/dpsfriends.h>
#include <string.h>

#line 1 "HEREpsw.psw"
#line 10 "HEREpsw.c"
void PSWsetgamma(float gamma)
{
  typedef struct {
    unsigned char tokenType;
    unsigned char topLevelCount;
    unsigned short nBytes;

    DPSBinObjGeneric obj0;
    DPSBinObjGeneric obj1;
    DPSBinObjGeneric obj2;
    DPSBinObjGeneric obj3;
    DPSBinObjGeneric obj4;
    DPSBinObjGeneric obj5;
    DPSBinObjGeneric obj6;
    DPSBinObjReal obj7;
    DPSBinObjGeneric obj8;
    DPSBinObjGeneric obj9;
    char obj10[22];
    } _dpsQ;
  static const _dpsQ _dpsStat = {
    DPS_DEF_TOKENTYPE, 6, 106,
    {DPS_EXEC|DPS_ARRAY, 0, 4, 48},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 56},	/* dup */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 56},	/* dup */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 56},	/* dup */
    {DPS_LITERAL|DPS_INT, 0, 0, 0},
    {DPS_EXEC|DPS_NAME, 0, 22, 80},	/* setframebuffertransfer */
    {DPS_LITERAL|DPS_INT, 0, 0, 1},
    {DPS_LITERAL|DPS_REAL, 0, 0, 0},	/* param: gamma */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 54},	/* div */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 300},	/* exp */
    {'s','e','t','f','r','a','m','e','b','u','f','f','e','r','t','r','a','n','s','f','e','r'},
    }; /* _dpsQ */
  _dpsQ _dpsF;	/* local copy  */
  register DPSContext _dpsCurCtxt = DPSPrivCurrentContext();
  char pad[3];
  register DPSBinObjRec *_dpsP = (DPSBinObjRec *)&_dpsF.obj0;
  _dpsF = _dpsStat;	/* assign automatic variable */

  _dpsP[7].val.realVal = gamma;
  DPSBinObjSeqWrite(_dpsCurCtxt,(char *) &_dpsF,106);
  if (0) *pad = 0;    /* quiets compiler warnings */
}
#line 4 "HEREpsw.psw"

#line 56 "HEREpsw.c"
void PSWsetredgamma(float gamma)
{
  typedef struct {
    unsigned char tokenType;
    unsigned char topLevelCount;
    unsigned short nBytes;

    DPSBinObjGeneric obj0;
    DPSBinObjGeneric obj1;
    DPSBinObjGeneric obj2;
    DPSBinObjGeneric obj3;
    DPSBinObjGeneric obj4;
    DPSBinObjGeneric obj5;
    DPSBinObjGeneric obj6;
    DPSBinObjGeneric obj7;
    DPSBinObjGeneric obj8;
    DPSBinObjGeneric obj9;
    DPSBinObjReal obj10;
    DPSBinObjGeneric obj11;
    DPSBinObjGeneric obj12;
    char obj13[22];
    char obj14[26];
    } _dpsQ;
  static const _dpsQ _dpsStat = {
    DPS_DEF_TOKENTYPE, 9, 156,
    {DPS_EXEC|DPS_ARRAY, 0, 4, 72},
    {DPS_LITERAL|DPS_INT, 0, 0, 0},
    {DPS_EXEC|DPS_NAME, 0, 26, 126},	/* currentframebuffertransfer */
    {DPS_LITERAL|DPS_INT, 0, 0, 4},
    {DPS_LITERAL|DPS_INT, 0, 0, -1},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 135},	/* roll */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 117},	/* pop */
    {DPS_LITERAL|DPS_INT, 0, 0, 0},
    {DPS_EXEC|DPS_NAME, 0, 22, 104},	/* setframebuffertransfer */
    {DPS_LITERAL|DPS_INT, 0, 0, 1},
    {DPS_LITERAL|DPS_REAL, 0, 0, 0},	/* param: gamma */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 54},	/* div */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 300},	/* exp */
    {'s','e','t','f','r','a','m','e','b','u','f','f','e','r','t','r','a','n','s','f','e','r'},
    {'c','u','r','r','e','n','t','f','r','a','m','e','b','u','f','f','e','r','t','r','a','n','s','f','e','r'},
    }; /* _dpsQ */
  _dpsQ _dpsF;	/* local copy  */
  register DPSContext _dpsCurCtxt = DPSPrivCurrentContext();
  char pad[3];
  register DPSBinObjRec *_dpsP = (DPSBinObjRec *)&_dpsF.obj0;
  _dpsF = _dpsStat;	/* assign automatic variable */

  _dpsP[10].val.realVal = gamma;
  DPSBinObjSeqWrite(_dpsCurCtxt,(char *) &_dpsF,156);
  if (0) *pad = 0;    /* quiets compiler warnings */
}
#line 12 "HEREpsw.psw"

#line 110 "HEREpsw.c"
void PSWsetgreengamma(float gamma)
{
  typedef struct {
    unsigned char tokenType;
    unsigned char topLevelCount;
    unsigned short nBytes;

    DPSBinObjGeneric obj0;
    DPSBinObjGeneric obj1;
    DPSBinObjGeneric obj2;
    DPSBinObjGeneric obj3;
    DPSBinObjGeneric obj4;
    DPSBinObjGeneric obj5;
    DPSBinObjGeneric obj6;
    DPSBinObjGeneric obj7;
    DPSBinObjGeneric obj8;
    DPSBinObjGeneric obj9;
    DPSBinObjGeneric obj10;
    DPSBinObjGeneric obj11;
    DPSBinObjGeneric obj12;
    DPSBinObjReal obj13;
    DPSBinObjGeneric obj14;
    DPSBinObjGeneric obj15;
    char obj16[22];
    char obj17[26];
    } _dpsQ;
  static const _dpsQ _dpsStat = {
    DPS_DEF_TOKENTYPE, 12, 180,
    {DPS_LITERAL|DPS_INT, 0, 0, 0},
    {DPS_EXEC|DPS_NAME, 0, 26, 150},	/* currentframebuffertransfer */
    {DPS_LITERAL|DPS_INT, 0, 0, 4},
    {DPS_LITERAL|DPS_INT, 0, 0, 2},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 135},	/* roll */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 117},	/* pop */
    {DPS_EXEC|DPS_ARRAY, 0, 4, 96},
    {DPS_LITERAL|DPS_INT, 0, 0, 4},
    {DPS_LITERAL|DPS_INT, 0, 0, -2},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 135},	/* roll */
    {DPS_LITERAL|DPS_INT, 0, 0, 0},
    {DPS_EXEC|DPS_NAME, 0, 22, 128},	/* setframebuffertransfer */
    {DPS_LITERAL|DPS_INT, 0, 0, 1},
    {DPS_LITERAL|DPS_REAL, 0, 0, 0},	/* param: gamma */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 54},	/* div */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 300},	/* exp */
    {'s','e','t','f','r','a','m','e','b','u','f','f','e','r','t','r','a','n','s','f','e','r'},
    {'c','u','r','r','e','n','t','f','r','a','m','e','b','u','f','f','e','r','t','r','a','n','s','f','e','r'},
    }; /* _dpsQ */
  _dpsQ _dpsF;	/* local copy  */
  register DPSContext _dpsCurCtxt = DPSPrivCurrentContext();
  char pad[3];
  register DPSBinObjRec *_dpsP = (DPSBinObjRec *)&_dpsF.obj0;
  _dpsF = _dpsStat;	/* assign automatic variable */

  _dpsP[13].val.realVal = gamma;
  DPSBinObjSeqWrite(_dpsCurCtxt,(char *) &_dpsF,180);
  if (0) *pad = 0;    /* quiets compiler warnings */
}
#line 21 "HEREpsw.psw"

#line 170 "HEREpsw.c"
void PSWsetbluegamma(float gamma)
{
  typedef struct {
    unsigned char tokenType;
    unsigned char topLevelCount;
    unsigned short nBytes;

    DPSBinObjGeneric obj0;
    DPSBinObjGeneric obj1;
    DPSBinObjGeneric obj2;
    DPSBinObjGeneric obj3;
    DPSBinObjGeneric obj4;
    DPSBinObjGeneric obj5;
    DPSBinObjGeneric obj6;
    DPSBinObjGeneric obj7;
    DPSBinObjGeneric obj8;
    DPSBinObjGeneric obj9;
    DPSBinObjGeneric obj10;
    DPSBinObjGeneric obj11;
    DPSBinObjGeneric obj12;
    DPSBinObjReal obj13;
    DPSBinObjGeneric obj14;
    DPSBinObjGeneric obj15;
    char obj16[22];
    char obj17[26];
    } _dpsQ;
  static const _dpsQ _dpsStat = {
    DPS_DEF_TOKENTYPE, 12, 180,
    {DPS_LITERAL|DPS_INT, 0, 0, 0},
    {DPS_EXEC|DPS_NAME, 0, 26, 150},	/* currentframebuffertransfer */
    {DPS_LITERAL|DPS_INT, 0, 0, 4},
    {DPS_LITERAL|DPS_INT, 0, 0, 1},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 135},	/* roll */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 117},	/* pop */
    {DPS_EXEC|DPS_ARRAY, 0, 4, 96},
    {DPS_LITERAL|DPS_INT, 0, 0, 4},
    {DPS_LITERAL|DPS_INT, 0, 0, -1},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 135},	/* roll */
    {DPS_LITERAL|DPS_INT, 0, 0, 0},
    {DPS_EXEC|DPS_NAME, 0, 22, 128},	/* setframebuffertransfer */
    {DPS_LITERAL|DPS_INT, 0, 0, 1},
    {DPS_LITERAL|DPS_REAL, 0, 0, 0},	/* param: gamma */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 54},	/* div */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 300},	/* exp */
    {'s','e','t','f','r','a','m','e','b','u','f','f','e','r','t','r','a','n','s','f','e','r'},
    {'c','u','r','r','e','n','t','f','r','a','m','e','b','u','f','f','e','r','t','r','a','n','s','f','e','r'},
    }; /* _dpsQ */
  _dpsQ _dpsF;	/* local copy  */
  register DPSContext _dpsCurCtxt = DPSPrivCurrentContext();
  char pad[3];
  register DPSBinObjRec *_dpsP = (DPSBinObjRec *)&_dpsF.obj0;
  _dpsF = _dpsStat;	/* assign automatic variable */

  _dpsP[13].val.realVal = gamma;
  DPSBinObjSeqWrite(_dpsCurCtxt,(char *) &_dpsF,180);
  if (0) *pad = 0;    /* quiets compiler warnings */
}
#line 30 "HEREpsw.psw"

#line 230 "HEREpsw.c"
void PSarrow(float x, float y)
{
  typedef struct {
    unsigned char tokenType;
    unsigned char topLevelCount;
    unsigned short nBytes;

    DPSBinObjReal obj0;
    DPSBinObjReal obj1;
    DPSBinObjGeneric obj2;
    DPSBinObjGeneric obj3;
    DPSBinObjGeneric obj4;
    DPSBinObjGeneric obj5;
    DPSBinObjGeneric obj6;
    DPSBinObjGeneric obj7;
    DPSBinObjGeneric obj8;
    DPSBinObjGeneric obj9;
    DPSBinObjGeneric obj10;
    DPSBinObjGeneric obj11;
    DPSBinObjGeneric obj12;
    DPSBinObjGeneric obj13;
    DPSBinObjGeneric obj14;
    } _dpsQ;
  static const _dpsQ _dpsStat = {
    DPS_DEF_TOKENTYPE, 15, 124,
    {DPS_LITERAL|DPS_REAL, 0, 0, 0},	/* param: x */
    {DPS_LITERAL|DPS_REAL, 0, 0, 0},	/* param: y */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 111},	/* newpath */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 107},	/* moveto */
    {DPS_LITERAL|DPS_INT, 0, 0, -6},
    {DPS_LITERAL|DPS_INT, 0, 0, 0},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 133},	/* rlineto */
    {DPS_LITERAL|DPS_INT, 0, 0, 6},
    {DPS_LITERAL|DPS_INT, 0, 0, 6},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 133},	/* rlineto */
    {DPS_LITERAL|DPS_INT, 0, 0, 6},
    {DPS_LITERAL|DPS_INT, 0, 0, -6},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 133},	/* rlineto */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 22},	/* closepath */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 66},	/* fill */
    }; /* _dpsQ */
  _dpsQ _dpsF;	/* local copy  */
  register DPSContext _dpsCurCtxt = DPSPrivCurrentContext();
  char pad[3];
  register DPSBinObjRec *_dpsP = (DPSBinObjRec *)&_dpsF.obj0;
  _dpsF = _dpsStat;	/* assign automatic variable */

  _dpsP[0].val.realVal = x;
  _dpsP[1].val.realVal = y;
  DPSBinObjSeqWrite(_dpsCurCtxt,(char *) &_dpsF,124);
  if (0) *pad = 0;    /* quiets compiler warnings */
}
#line 45 "HEREpsw.psw"

#line 285 "HEREpsw.c"
void PSWdrawbox(float c, float m, float y, float k, float boxsize)
{
  typedef struct {
    unsigned char tokenType;
    unsigned char topLevelCount;
    unsigned short nBytes;

    DPSBinObjGeneric obj0;
    DPSBinObjGeneric obj1;
    DPSBinObjGeneric obj2;
    DPSBinObjReal obj3;
    DPSBinObjReal obj4;
    DPSBinObjReal obj5;
    DPSBinObjReal obj6;
    DPSBinObjGeneric obj7;
    DPSBinObjReal obj8;
    DPSBinObjGeneric obj9;
    DPSBinObjGeneric obj10;
    DPSBinObjGeneric obj11;
    DPSBinObjReal obj12;
    DPSBinObjGeneric obj13;
    DPSBinObjReal obj14;
    DPSBinObjGeneric obj15;
    DPSBinObjGeneric obj16;
    DPSBinObjGeneric obj17;
    DPSBinObjGeneric obj18;
    DPSBinObjGeneric obj19;
    } _dpsQ;
  static const _dpsQ _dpsStat = {
    DPS_DEF_TOKENTYPE, 20, 164,
    {DPS_LITERAL|DPS_INT, 0, 0, 0},
    {DPS_LITERAL|DPS_INT, 0, 0, 0},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 107},	/* moveto */
    {DPS_LITERAL|DPS_REAL, 0, 0, 0},	/* param: c */
    {DPS_LITERAL|DPS_REAL, 0, 0, 0},	/* param: m */
    {DPS_LITERAL|DPS_REAL, 0, 0, 0},	/* param: y */
    {DPS_LITERAL|DPS_REAL, 0, 0, 0},	/* param: k */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 147},	/* setcmykcolor */
    {DPS_LITERAL|DPS_REAL, 0, 0, 0},	/* param: boxsize */
    {DPS_LITERAL|DPS_INT, 0, 0, 0},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 133},	/* rlineto */
    {DPS_LITERAL|DPS_INT, 0, 0, 0},
    {DPS_LITERAL|DPS_REAL, 0, 0, 0},	/* param: boxsize */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 133},	/* rlineto */
    {DPS_LITERAL|DPS_REAL, 0, 0, 0},	/* param: boxsize */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 110},	/* neg */
    {DPS_LITERAL|DPS_INT, 0, 0, 0},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 133},	/* rlineto */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 22},	/* closepath */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 66},	/* fill */
    }; /* _dpsQ */
  _dpsQ _dpsF;	/* local copy  */
  register DPSContext _dpsCurCtxt = DPSPrivCurrentContext();
  char pad[3];
  register DPSBinObjRec *_dpsP = (DPSBinObjRec *)&_dpsF.obj0;
  _dpsF = _dpsStat;	/* assign automatic variable */

  _dpsP[3].val.realVal = c;
  _dpsP[4].val.realVal = m;
  _dpsP[5].val.realVal = y;
  _dpsP[6].val.realVal = k;
  _dpsP[8].val.realVal =
  _dpsP[12].val.realVal =
  _dpsP[14].val.realVal = boxsize;
  DPSBinObjSeqWrite(_dpsCurCtxt,(char *) &_dpsF,164);
  if (0) *pad = 0;    /* quiets compiler warnings */
}
#line 55 "HEREpsw.psw"

#line 355 "HEREpsw.c"
void PSWdrawboxrgb(float r, float g, float b, float boxsize)
{
  typedef struct {
    unsigned char tokenType;
    unsigned char topLevelCount;
    unsigned short nBytes;

    DPSBinObjGeneric obj0;
    DPSBinObjGeneric obj1;
    DPSBinObjGeneric obj2;
    DPSBinObjGeneric obj3;
    DPSBinObjGeneric obj4;
    DPSBinObjReal obj5;
    DPSBinObjReal obj6;
    DPSBinObjReal obj7;
    DPSBinObjGeneric obj8;
    DPSBinObjReal obj9;
    DPSBinObjGeneric obj10;
    DPSBinObjGeneric obj11;
    DPSBinObjGeneric obj12;
    DPSBinObjReal obj13;
    DPSBinObjGeneric obj14;
    DPSBinObjReal obj15;
    DPSBinObjGeneric obj16;
    DPSBinObjGeneric obj17;
    DPSBinObjGeneric obj18;
    DPSBinObjGeneric obj19;
    DPSBinObjGeneric obj20;
    char obj21[8];
    char obj22[13];
    char obj23[9];
    } _dpsQ;
  static const _dpsQ _dpsStat = {
    DPS_DEF_TOKENTYPE, 21, 202,
    {DPS_LITERAL|DPS_INT, 0, 0, 0},
    {DPS_LITERAL|DPS_INT, 0, 0, 0},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 107},	/* moveto */
    {DPS_LITERAL|DPS_NAME, 0, 9, 189},	/* DeviceRGB */
    {DPS_EXEC|DPS_NAME, 0, 13, 176},	/* setcolorspace */
    {DPS_LITERAL|DPS_REAL, 0, 0, 0},	/* param: r */
    {DPS_LITERAL|DPS_REAL, 0, 0, 0},	/* param: g */
    {DPS_LITERAL|DPS_REAL, 0, 0, 0},	/* param: b */
    {DPS_EXEC|DPS_NAME, 0, 8, 168},	/* setcolor */
    {DPS_LITERAL|DPS_REAL, 0, 0, 0},	/* param: boxsize */
    {DPS_LITERAL|DPS_INT, 0, 0, 0},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 133},	/* rlineto */
    {DPS_LITERAL|DPS_INT, 0, 0, 0},
    {DPS_LITERAL|DPS_REAL, 0, 0, 0},	/* param: boxsize */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 133},	/* rlineto */
    {DPS_LITERAL|DPS_REAL, 0, 0, 0},	/* param: boxsize */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 110},	/* neg */
    {DPS_LITERAL|DPS_INT, 0, 0, 0},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 133},	/* rlineto */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 22},	/* closepath */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 66},	/* fill */
    {'s','e','t','c','o','l','o','r'},
    {'s','e','t','c','o','l','o','r','s','p','a','c','e'},
    {'D','e','v','i','c','e','R','G','B'},
    }; /* _dpsQ */
  _dpsQ _dpsF;	/* local copy  */
  register DPSContext _dpsCurCtxt = DPSPrivCurrentContext();
  char pad[3];
  register DPSBinObjRec *_dpsP = (DPSBinObjRec *)&_dpsF.obj0;
  _dpsF = _dpsStat;	/* assign automatic variable */

  _dpsP[5].val.realVal = r;
  _dpsP[6].val.realVal = g;
  _dpsP[7].val.realVal = b;
  _dpsP[9].val.realVal =
  _dpsP[13].val.realVal =
  _dpsP[15].val.realVal = boxsize;
  DPSBinObjSeqWrite(_dpsCurCtxt,(char *) &_dpsF,202);
  if (0) *pad = 0;    /* quiets compiler warnings */
}
#line 65 "HEREpsw.psw"

#line 432 "HEREpsw.c"
void PSWsetfont(const char *name, float size)
{
  typedef struct {
    unsigned char tokenType;
    unsigned char sizeFlag;
    unsigned short topLevelCount;
    unsigned long nBytes;

    DPSBinObjGeneric obj0;
    DPSBinObjGeneric obj1;
    DPSBinObjReal obj2;
    DPSBinObjGeneric obj3;
    DPSBinObjGeneric obj4;
    } _dpsQ;
  static const _dpsQ _dpsStat = {
    DPS_DEF_TOKENTYPE, 0, 5, 48,
    {DPS_LITERAL|DPS_NAME, 0, DPSSYSNAME, 203},	/* Helvetica */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 67},	/* findfont */
    {DPS_LITERAL|DPS_REAL, 0, 0, 0},	/* param: size */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 140},	/* scalefont */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 149},	/* setfont */
    }; /* _dpsQ */
  _dpsQ _dpsF;	/* local copy  */
  register DPSContext _dpsCurCtxt = DPSPrivCurrentContext();
  char pad[3];
  register DPSBinObjRec *_dpsP = (DPSBinObjRec *)&_dpsF.obj0;
  _dpsF = _dpsStat;	/* assign automatic variable */

  _dpsP[2].val.realVal = size;
  DPSBinObjSeqWrite(_dpsCurCtxt,(char *) &_dpsF,48);
  if (0) *pad = 0;    /* quiets compiler warnings */
}
#line 70 "HEREpsw.psw"

#line 467 "HEREpsw.c"
void PSWremoveblackgen( void )
{
  typedef struct {
    unsigned char tokenType;
    unsigned char topLevelCount;
    unsigned short nBytes;

    DPSBinObjGeneric obj0;
    DPSBinObjGeneric obj1;
    DPSBinObjGeneric obj2;
    DPSBinObjGeneric obj3;
    DPSBinObjGeneric obj4;
    DPSBinObjGeneric obj5;
    DPSBinObjGeneric obj6;
    DPSBinObjGeneric obj7;
    DPSBinObjGeneric obj8;
    DPSBinObjGeneric obj9;
    DPSBinObjGeneric obj10;
    DPSBinObjGeneric obj11;
    DPSBinObjGeneric obj12;
    DPSBinObjGeneric obj13;
    DPSBinObjGeneric obj14;
    } _dpsQ;
  static const _dpsQ _dpsF = {
    DPS_DEF_TOKENTYPE, 11, 124,
    {DPS_EXEC|DPS_ARRAY, 0, 2, 104},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 337},	/* setblackgeneration */
    {DPS_EXEC|DPS_ARRAY, 0, 2, 88},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 353},	/* setundercolorremoval */
    {DPS_EXEC|DPS_ARRAY, 0, 0, 88},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 56},	/* dup */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 56},	/* dup */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 56},	/* dup */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 341},	/* setcolortransfer */
    {DPS_EXEC|DPS_ARRAY, 0, 0, 88},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 351},	/* settransfer */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 117},	/* pop */
    {DPS_LITERAL|DPS_INT, 0, 0, 0},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 117},	/* pop */
    {DPS_LITERAL|DPS_INT, 0, 0, 0},
    }; /* _dpsQ */
  register DPSContext _dpsCurCtxt = DPSPrivCurrentContext();
  char pad[3];
  DPSBinObjSeqWrite(_dpsCurCtxt,(char *) &_dpsF,124);
  if (0) *pad = 0;    /* quiets compiler warnings */
}
#line 77 "HEREpsw.psw"




