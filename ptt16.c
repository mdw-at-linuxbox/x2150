// SY22-2909-2_1052_Adapter_and_2150_Console_FETOP_Jan69.pdf
// GA24-3231-7_360-30_funcChar.pdf
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
typedef unsigned short uint16;
typedef unsigned char uint8;
#include "ptt8.h"
#include "etoa.h"
#include "tt2.h"

int aflag;
int tflag;
int vflag;
int hflag;

int countbits(unsigned x)
{
	int r = 0;
	while (x) {
		if (x&1) ++r;
		x >>= 1;

	}
	return r;
}

char *catstr(char *d, char *s)
{
	while (*d++ = *s++)
		;
	return --d;
}

char *cat_pchar(char *cp, unsigned char e)
{
	unsigned char p = e_to_ptt[e];
	unsigned char a = etoa[e];
	if (a <= 32 || a >= 0x7f || a == '\\') switch(p & 077)
	{
	// GA24-3231-7_360-30_funcChar.pdf page 62
	case 014: return catstr(cp, "pn");
	case 015: return catstr(cp, "rs");
	case 016: return catstr(cp, "uc");
	case 017: return catstr(cp, "eot");
	case 034: return catstr(cp, "byp");
	case 035: return catstr(cp, "lf");
	case 036: return catstr(cp, "eob");
	case 037: return catstr(cp, "pre");
	case 054: return catstr(cp, "res");
	case 055: return catstr(cp, "nl");
	case 056: return catstr(cp, "bs");
	case 057: return catstr(cp, "il");
	case 074: return catstr(cp, "pf");
	case 075: return catstr(cp, "ht");
	case 076: return catstr(cp, "lc");
	case 077: return catstr(cp, "del");
	case 0: return catstr(cp, "sp");
	default:
		sprintf (cp, "\\x%02x", e);
		while (*cp)
			++cp;
		return cp;
	}
	*cp++ = a;
	*cp = 0;
	return cp;
}

char *cat_tt(char *cp, unsigned char tt)
{
	int tilt = 3;
	int rotate = 5;
	char temp[512];
	if (tt & 32) tilt -= 1;
	if (tt & 16) tilt -= 2;
	if (tt & 1)
		rotate -= 5;
	if (tt & 2)
		rotate -= 2;
	if (tt & 4)
		rotate -= 2;
	if (tt & 8)
		rotate -= 1;
	cp = catstr(cp, "tilt=");
	if (tilt >= 0)
		*cp++ = '+';
	sprintf(cp, "%d", tilt);
	cp += strlen(cp);
	cp = catstr(cp, " rotate=");
	if (rotate >= 0)
		*cp++ = '+';
	sprintf(cp, "%d", rotate);
	cp += strlen(cp);
	return cp;
}

unsigned char
e2tt(unsigned char e)
{
	int b0,b1,b2,b3,b4,b5,b6,b7;
	b0 = !!(e&128);
	b1 = !!(e&64);
	b2 = !!(e&32);
	b3 = !!(e&16);
	b4 = !!(e&8);
	b5 = !!(e&4);
	b6 = !!(e&2);
	b7 = !!(e&1);
int not_t1 = (!b3 & !b5 & (b6 | b7)) |	// [.,bcstBCST
					// ./,acitzACITZ
	(!b3 & !b4 & b5) |		// defguvwxDEFGUVWX
	(!b3 & b4 & !b5) |		// [.,hiyzHIYZ
	(b2 & !b3 & b6 & b7) |		// ,?txTX
	(!b2 & !b3 & b6 & !b7) |	// [+bfBF
	(b2 & b3 & b4 & b5 & !b6 & !b7) |	// @
	(!b2 & b3 & b4 & b5 & b6 & b7) |	// ^
	(!b2 & !b4 & !b5 & !b6 & !b7) |		// &
	(!b2 & b4 & !b5 & b6 & !b7);		// []
int t2 = (b2 & b3) |			// :#@'="0123456789
	(b2 & b5 & !b7) |		// %>@=uwUW46
	(b2 & !b4 & (b6 | b7)) |	// stwxSTWX2367
					// /tvxTVX1357
	(b2 & b6 & b7) |		// ,?#"txTX37
	(!b2 & b4 & b5 & !b6) |		// <(*)
	(b3 & b4 & b6 & !b7) |		// ];:=
	(b2 & b4 & !b5 & !b6) |		// yzYZ89
	(!b2 & b4 & !b5 & b6 & !b7);	// []
int not_r1 = (!b4 & b6 ) |		// bcfgklopstwxBCFGKLOPSTWX2367
	((!b2 | !b5)  & b6 & b7) |	// .!$^cglpCGLP
					// .$,#cltCLT3
	(b3 & b4 & b5 & b7) |		// )^'"
	(!b2 & b3 & b6) |		// ]$;^klopKLOP
	(b2 & !b3 & b6 & !b7) |		// >swSW
	(b2 & b3 & !b4 & !b5 & !b7) |	// 02
	(!b2 & !b3 & b4 & b5 & !b6 & !b7);	// <
int not_r2 = (b4 & !b5 & !b6) |		// hiqryzHIQRYZ89
	(!b4 & b5) |			// defgmnopuvwxDEFGMNOPUVWX4567
	(b3 & b5 & b7) |		// )^'"npNP57
	(!b2 & b4 & b7) |		// .(!$)^irIR
	(b3 & b4 & !b5) |		// ]$:#qrQR89
	(b2 & !b3 & b5 & !b7) |		// %>uwUW
	(!b2 & b3 & b5 & !b6) |		// *)mnMN
	(b2 & b4 & !b5) |		// ,:#yzYZ89
	(b2 & b3 & !b4 & !b6 & !b7);	// 04
int not_r2a = (b4 & !b5 & b7) |		// .$,#irzIRZ9
	(b2 & b3 & !b5 & !b6 & !b7) |	// 08
	(!b2 & !b3 & !b5 & !b6 & !b7) |	// hH
	(b3 & b4 & b6 & b7) |		// $^#"
	(!b2 & b4 & b7) |		// .(!$)^irIR
	(!b2 & b3 & b4 & (!b5 | !b6)) |	// ]$qrQR
					// *)qrQR
	(b2 & !b3 & b4 & !b5);		// ,yzYZ
int not_r5 = ((!b2 | !b3) & !b4 & !b7) |	// &bdfkmoBDFKMO
					// -bdfsuwBDFSUW
	((!b4 | !b5) & b6 & !b7) |	// bfkoswBFKOSW26
					// []:bksBKS2
	(!b4 & b5 & !b7) |		// dfmouwDFMOUW46
	(!b2 & !b3 & b4 & b5) |		// <(+!
	(b3 & b4 & b6 & b7) |		// $^#"
	(b2 & b4 & !b6 & b7) |		// _'zZ9
	(b2 & b3 & b5 & !b6 & !b7) |	// @4
	(b4 & !b5 & b7);		// .$,#irzIRZ9
int lower_case_character = (!b1) |		// a-z
	(b0 & b2 & b3) |			// 0-9
	(!b0 & !b5 & b7) |			// .$/,#
	(b2 & b3 & !b6 & !b7) |			// @048
	(!b0 & !b4);				// &-/

	int r = (t2<<4)
		| (lower_case_character << 6)
		| ((!not_t1)<<5)
		| ((!not_r1)<<3)
		| ((!not_r2)<<2)
		| ((!not_r2a)<<1)
		| ((!not_r5)<<0);
	return r;
}

int
test_e2tt()
{
	int e;
	int r;
	int ebits = 0;
	int x;
	int wrong = 0;
	int i;
	char buf[30];
	r = 0;
	char xbits[8][20];

	memset(xbits, 0, sizeof xbits);
	for (e = 0; e < 256; ++e) {
		int tt1, tt2;
		tt2 = e_to_tt[e];
		if (tt2 == 0377)	// invalid
			continue;
		tt1 = e2tt(e);
		cat_pchar(buf, e);
		if (tt1 != tt2) {
			++wrong;
			x=tt1^tt2;
			ebits += countbits(x);
			if (tflag) {
			for (i = 0; i < 8; ++i)
			if (x & (1<<i))
			strcat(xbits[i], buf);
			}
			printf ("%2x: (%s) %03o should be %03o x=%03o",
				e, buf, tt1, tt2, x);
//			printf ("; %02x makes %03x",
//				ptt_to_e[tt1], tt1);
			printf ("\n");
			++r;
		} else if (vflag) {
			printf ("%2x: (%s) %03o\n", e, buf, tt1);
		}
	}
	if (tflag) {
	for (i = 0; i < 8; ++i)
	if (*xbits[i])
		printf ("%d\t%s\n", i, xbits[i]);
	}
	printf ("e2tt: %d bits in error; %d characters wrong\n", ebits, wrong);
	return !!r;
}

#if 0
int
test_ptt8()
{
	int i, r;
	int ebits = 0;
	int wrong = 0;
	r = 0;

	for (i = 0; i < 128; ++i) {
		int e1, e2;

		if (!aflag)
		switch(i & 077) {
		case 055: case 075: case 076:
		case 016:
		case 035:
		// case 036:
			break;
		default:
			switch(i & 017)
			{
			// control characters
			case 014: case 015: case 016: case 017:
				continue;
			// undefined
			case 012:
				if (i & 060) continue;
			}
		}

		e1 = ptt8(i);
		e2 = ptt_to_e[i];
		if (e1 != e2) {
			++wrong;
			if (e1 >= 0 && e2 >= 0)
				ebits += countbits(e1 ^ e2);
			printf ("p %03o e %02x: expected %02x",
				i, e1, e2);
			if (e1 >= 0 && e1 < 256)
				printf ("; p %03o makes e %02x",
					e_to_tt[e1], e1);
			printf ("; X=%02x", e1 ^ e2);
			if (e1 & ~e2)
				printf (" S=%02x", e1 & ~e2);
			printf ("\n");
			++r;
		} else if (vflag && e1 >= 0) {
			printf ("p %03o e %02x\n", i, e1);
		}
	}
	printf ("ptt8: %d bits in error; %d characters wrong\n", ebits, wrong);
	return !!r;
}
#endif

int
process_just_one(char *cp)
{
	int ptt8;
	char buf[20];
#if 0
	ptt8 = strtol(cp, 0, 16);
	printf ("p %03o -> e %02x; %s\n", ptt8, ptt8(ptt8), convert_bcd(ptt8,buf));
//	printf ("p %02x -> 3 %02x\n", ptt8, e2case(ptt8));
#endif
}

int
main(int ac, char **av)
{
	char *ap;
	int r = 0;
	int f;
	f = 0;
	while (--ac > 0) if (*(ap = *++av) == '-' && ap[1]) while (*++ap) switch (*ap) {
	case 't':
		++tflag;
		break;
	case 'v':
		++vflag;
		break;
	case 'a':
		++aflag;
		break;
	case 'h':
		++hflag;
		break;
	default:
		fprintf(stderr,"Bad switch <%c>\n", *ap);
	Usage:
		fprintf(stderr,"Usage: ./ptt9 [-te] [h]\n");
		exit(1);
	} else {
		f = 1;
		process_just_one(ap);
	}
	if (!f) {
		r = 0;
		if (!hflag)
			r = test_e2tt();
//		r |= test_e2tt();
	}
	exit(r);
}
