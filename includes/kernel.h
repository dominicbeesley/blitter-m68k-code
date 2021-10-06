// quick kernel call wrappers

#ifndef __KERNEL_H__
#define __KERNEL_H__

typedef struct {
	int errnum;
	char errmess[252];
} _kernel_oserror;

typedef struct {
	int r[10];
} _kernel_swi_regs;


extern _kernel_oserror* _kernel_swi(int swinum, _kernel_swi_regs *in, _kernel_swi_regs *out);

extern _kernel_oserror* _kernel_swi_c(int swinum, _kernel_swi_regs *in, _kernel_swi_regs *out, int *carry);

extern int _kernel_osbyte(int operation, int x, int y);

extern int _kernel_osword(int operation, int *data);

extern int _kernel_oswrch(int ch);

extern int _kernel_osrdch(void);

extern _kernel_oserror *_kernel_last_oserror (void);

extern int _kernel_oscli (const char *__s);

#endif