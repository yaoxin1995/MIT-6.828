/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>

#include <kern/picirq.h>


###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.

 */



TRAPHANDLER_NOEC(VECTOR0, T_DIVIDE)

TRAPHANDLER_NOEC(VECTOR1, T_DEBUG)

TRAPHANDLER_NOEC(VECTOR2, T_NMI)

TRAPHANDLER_NOEC(VECTOR3, T_BRKPT)

TRAPHANDLER_NOEC(VECTOR4, T_OFLOW)

TRAPHANDLER_NOEC(VECTOR5, T_BOUND)

TRAPHANDLER_NOEC(VECTOR6, T_ILLOP)

TRAPHANDLER_NOEC(VECTOR7, T_DEVICE)

TRAPHANDLER(VECTOR8, T_DBLFLT)

TRAPHANDLER(VECTOR10, T_TSS)

TRAPHANDLER(VECTOR11, T_SEGNP)

TRAPHANDLER(VECTOR12, T_STACK)

TRAPHANDLER(VECTOR13, T_GPFLT)

TRAPHANDLER(VECTOR14, T_PGFLT)

TRAPHANDLER_NOEC(VECTOR16, T_FPERR)

TRAPHANDLER(VECTOR17, T_ALIGN)

TRAPHANDLER_NOEC(VECTOR18, T_MCHK)

TRAPHANDLER_NOEC(VECTOR19, T_SIMDERR)

TRAPHANDLER_NOEC(VECTOR48, T_SYSCALL)

TRAPHANDLER_NOEC(VECTOR32, IRQ_OFFSET)

TRAPHANDLER_NOEC(VECTOR33, IRQ_OFFSET + 1)

TRAPHANDLER_NOEC(VECTOR34, IRQ_OFFSET + 2)

TRAPHANDLER_NOEC(VECTOR35, IRQ_OFFSET + 3)

TRAPHANDLER_NOEC(VECTOR36, IRQ_OFFSET + 4)

TRAPHANDLER_NOEC(VECTOR37, IRQ_OFFSET + 5)

TRAPHANDLER_NOEC(VECTOR38, IRQ_OFFSET + 6)

TRAPHANDLER_NOEC(VECTOR39, IRQ_OFFSET + 7)

TRAPHANDLER_NOEC(VECTOR40, IRQ_OFFSET + 8)

TRAPHANDLER_NOEC(VECTOR41, IRQ_OFFSET + 9)

TRAPHANDLER_NOEC(VECTOR42, IRQ_OFFSET + 10)

TRAPHANDLER_NOEC(VECTOR43, IRQ_OFFSET + 11)

TRAPHANDLER_NOEC(VECTOR44, IRQ_OFFSET + 12)

TRAPHANDLER_NOEC(VECTOR45, IRQ_OFFSET + 13)

TRAPHANDLER_NOEC(VECTOR46, IRQ_OFFSET + 14)

TRAPHANDLER_NOEC(VECTOR47, IRQ_OFFSET + 15)
/*
 * Lab 3: Your code here for _alltraps
 */
.globl _alltraps
_alltraps:
  # Build trap frame.
  pushl %ds
  pushl %es


  pushal
  
  # Set up data segments.
  movw $GD_KD, %ax
  movw %ax, %ds
  movw %ax, %es

  # Call trap(tf), where tf=%esp
  pushl %esp
  call trap
;   addl $4, %esp
