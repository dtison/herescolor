/* HEREpsw.h generated from HEREpsw.psw
   by unix pswrap V1.009  Wed Apr 19 17:50:24 PDT 1989
 */

#ifndef HEREPSW_H
#define HEREPSW_H

extern void PSWsetgamma(float gamma);

extern void PSWsetredgamma(float gamma);

extern void PSWsetgreengamma(float gamma);

extern void PSWsetbluegamma(float gamma);

extern void PSarrow(float x, float y);

extern void PSWdrawbox(float c, float m, float y, float k, float boxsize);

extern void PSWdrawboxrgb(float r, float g, float b, float boxsize);

extern void PSWsetfont(const char *name, float size);

extern void PSWremoveblackgen( void );

#endif HEREPSW_H
