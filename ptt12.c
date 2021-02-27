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

int aflag;	// don't skip "parity error" cases
int tflag;	// emit typeball table
int xflag;	// emit in "2025" format
// 2025 bit order: see page 1-32 figure 1-36 "Tilt Rotate Code (PR-KB)
// on pdf page 42 of Y24-3528-1_2025_Processing_Unit_FEMM_Jul69.pdf

int countbits(unsigned x)
{
	int r = 0;
	while (x) {
		if (x&1) ++r;
		x >>= 1;

	}
	return r;
}

unsigned char
e2tt(unsigned char e)
{
	int tt;
	tt = e_to_tt[e];
	return tt & 077;
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

struct element {
	int flags;
	int ebcdic;
	int lc;
	int ptt8;
	int tt;
	int tilt;
	int rotate;
	char *pc;
	char *tilt_rotate;
	char temp[512];
};

void
print_entry(struct element *ep)
{
	int par1, par2;
	par1 = countbits(ep->ptt8 & 077) & 1;
	par2 = countbits(ep->tt) & 1;
	if (xflag) {
		printf ("%-4s %02x %d %d %d %d  %d %d %d\n",
			ep->pc,
			ep->ebcdic,
			!!(ep->tt & 0x20),	// t1
			!!(ep->tt & 0x10),	// t2
			!!(ep->tt & 0x1),	// r5
			!!(ep->tt & 0x2),	// r2a
			!!(ep->tt & 0x4),	// r2
			!!(ep->tt & 0x8),	// r1
			!ep->lc);
		return;
	}
	printf ("%02x p=%s.%02o.%d tt=%02x.%d %s %s\n",
		ep->ebcdic,
		ep->lc ? "LC" : "UC",
		ep->ptt8,
		par1,
		ep->tt,
		par2,
		ep->tilt_rotate,
		ep->pc);
}

void
free_entry(struct element *ep)
{
	free(ep);
}

int
ecmp(const void *_a, const void *_b)
{
	struct element *const* a = _a;
	struct element *const* b = _b;
	if ((*a)->tilt != (*b)->tilt)
		return (*a)->tilt - (*b)->tilt;
	if ((*a)->lc != (*b)->lc)
		return (*a)->lc - (*b)->lc;
	if ((*a)->rotate != (*b)->rotate)
		return (*a)->rotate - (*b)->rotate;
	return 0;
}

int nentries;
struct element *entries[512];

int
test_parity()
{
	int p, par1;
	int tt, par2;
	char *pc;
	char *cp;
	int er, et;
	struct element **epp = entries;
	struct element *ep, *last;
	char dups[512];

	for (int i = 0; i < 256; ++i) {
		if (i > 0x40)
			;
		else if (i == 0x40) continue;
		else if ((i&0x0f) < 0x4)
			;
		else if ((i&0x0f) > 0x7)
			;
		else continue;
		p = e_to_ptt[i];
		if (p & 0200)
			continue;
		ep = malloc(sizeof *ep);
		memset(ep, 0, sizeof *ep);
		ep->ebcdic = i;
		ep->lc = !!(p & 0100);
		ep->ptt8 = p & 077;
		tt = e2tt(i);
		ep->tt = tt;
		ep->tilt = 3;
		ep->rotate = 5;
		if (tt & 32) ep->tilt -= 1;
		if (tt & 16) ep->tilt -= 2;
		if (tt & 1)
			ep->rotate -= 5;
		if (tt & 2)
			ep->rotate -= 2;
		if (tt & 4)
			ep->rotate -= 2;
		if (tt & 8)
			ep->rotate -= 1;
		par1 = countbits(p & 077) & 1;
		par2 = countbits(tt) & 1;
		cp = cat_tt(ep->temp, tt);
		pc = ++cp;
		cp = cat_pchar(cp, i);
		ep->pc = pc;
		ep->tilt_rotate = ep->temp;
		if (par1 == par2 || (aflag && !tflag)) {
			if (!aflag || tflag) printf ("PAR ");
			print_entry(ep);
		}
		if (par1 == par2 && !aflag && !tflag)
			free_entry(ep);
		else
			*epp++ = ep;
	}
	*epp = 0;
	nentries = epp - entries;
	qsort(entries, nentries, sizeof *entries, ecmp);
	et = 0;
	last = 0;
	for (int i = 0; ep=entries[i], i < nentries; last=ep, ++i) if (last) {
		if (ep->tilt == last->tilt
			&& ep->rotate == last->rotate
			&& ep->lc == last->lc) {
last->flags = 1;
printf ("DUP "); print_entry(last);
printf ("    "); print_entry(ep);
		}
	}
	if (!tflag) goto Done;
	*dups = 0;
	er = -6;
	for (int i = 0; i < nentries; ++i) {
		ep = entries[i];
		if (ep->flags) {
			strcat(dups, ep->pc);
			continue;
		}
		if (et != ep->lc + (ep->tilt<<1)) {
			et=ep->lc + (ep->tilt<<1);
			printf ("\n");
			er = -6;
		}
		while (er+1 < ep->rotate)
		{
			++er;
			printf ("    ");
		}
		er = ep->rotate;
		if (*dups) {
		strcat(dups, ep->pc);
		printf ("%4s", dups);
		} else
		printf ("%4s", ep->pc);
		*dups = 0;
	}
	printf ("\n");
Done:
	for (int i = 0; i < nentries; ++i)
		free_entry(entries[i]);
	return 0;
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
	case 'a':
		++aflag;
		break;
	case 'x':
		++xflag;
		break;
	default:
		fprintf(stderr,"Bad switch <%c>\n", *ap);
	Usage:
		fprintf(stderr,"Usage: ./ptt12 [-atx]\n");
		exit(1);
	} else {
		f = 1;
		fprintf(stderr,"takes no arg\n");
		goto Usage;
	}
	if (!f) {
		r = 0;
		r |= test_parity();
	}
	exit(r);
}
