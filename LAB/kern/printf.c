// Simple implementation of cprintf console output for the kernel,
// based on printfmt() and the kernel console's cputchar().

#include <inc/types.h>
#include <inc/stdio.h>
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
	cputchar(ch);
	*cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
	int cnt = 0;

	vprintfmt((void*)putch, &cnt, fmt, ap);
	return cnt;
}


/* the function would take variable argument*/
int
cprintf(const char *fmt, ...)
{
	va_list ap;
	int cnt;
	 /* Initializing arguments to store all values after fmt */
	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);

	// Once you're done, use va_end to clean up the list: va_end( a_list );
	va_end(ap);

	return cnt;
}

