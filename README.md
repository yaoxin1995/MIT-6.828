#Homework 5: xv6 CPU alarm


## Key points

### calling conventions

+ Example instruction	What it does
```
pushl %eax	            subl $4, %esp
                        movl %eax, (%esp)

popl %eax	            movl (%esp), %eax
                        addl $4, %esp

call 0x12345	        pushl %eip (*)
                        movl $0x12345, %eip (*)
                        
ret	                    popl %eip (*)
```
+ GCC dictates how the stack is used. Contract between caller and callee on x86:
    + at entry to a function (i.e. just after call):
        + %eip points at first instruction of function
        + %esp+4 points at first argument
        + %esp points at return address
    + after ret instruction:
        + %eip contains return address
        + %esp points at arguments pushed by caller
        + called function may have trashed arguments
        + %eax (and %edx, if return type is 64-bit) contains return value (or trash if function is void)
        + %eax, %edx (above), and %ecx may be trashed
        + %ebp, %ebx, %esi, %edi must contain contents from time of call
    + Terminology:
        + %eax, %ecx, %edx are "caller save" registers
        + %ebp, %ebx, %esi, %edi are "callee save" registers



```
		       +------------+   |
		       | arg 2      |   \
		       +------------+    >- previous function's stack frame
		       | arg 1      |   /
		       +------------+   |
		       | ret %eip   |   /
		       +============+   
		       | saved %ebp |   \
		%ebp-> +------------+   |
		       |            |   |
		       |   local    |   \
		       | variables, |    >- current function's stack frame
		       |    etc.    |   /
		       |            |   |
		       |            |   |
		%esp-> +------------+   /



```

+ function prologue:
```
			pushl %ebp
			movl %esp, %ebp
```

+ function epilogue can easily find return EIP on stack:
```
			movl %ebp, %esp
			popl %ebp
```

+ Big example:
```
//C code
		int main(void) { return f(8)+1; }
		int f(int x) { return g(x); }
		int g(int x) { return x+3; }
		
//assembler
		_main:
					prologue
			pushl %ebp
			movl %esp, %ebp
					body
			pushl $8
			call _f
			addl $1, %eax
					epilogue
			movl %ebp, %esp
			popl %ebp
			ret
		_f:
					prologue
			pushl %ebp
			movl %esp, %ebp
					body
			pushl 8(%esp)
			call _g
					epilogue
			movl %ebp, %esp
			popl %ebp
			ret

		_g:
					prologue
			pushl %ebp
			movl %esp, %ebp
					save %ebx
			pushl %ebx
					body
			movl 8(%ebp), %ebx
			addl $3, %ebx
			movl %ebx, %eax
					restore %ebx
			popl %ebx
					epilogue
			movl %ebp, %esp
			popl %ebp
			ret
```	

## Answer

This is the code I added to `trap.c`:
```
      if(myproc() != 0 && (tf->cs & 3) == 3) {

      	if (!myproc()->ticksleft) {
				myproc()->ticksleft = myproc()->alarmticks;

				tf->esp = tf->esp - 4;
				*(uint *)tf->esp = tf->eip;

				tf->eip = (uint)myproc()->alarmhandler;
				
        } else
				myproc()->ticksleft--;

      }
```

The code manipulates the trapframe such that when we return from the current interrupt, the alarm handler code gets executed, followed by a return to the code in user space that was executing when the interrupt happened.

Let's call the `eip` to which we ultimate need to return in `main`, `eip-orig`, and the `eip` of the alarm handler `eip-handler`. The trapframe contains the stack pointer to which we go back to and `eip-orig`. We extend this esp by 4 bytes and place `eip-orig` there, thus simulating a function call. We also overwrite `eip-orig` in the trapframe with `eip-handler`, forcing `trapret` to begin executing the alarm handler. The last instruction of the alarm handler assembly code is a ret, which pops off a 4 byte word into the `eip`. Recall that we placed `eip-orig` there. The result is that after the alarm handler returns, we continue executing in the original user space code before the interrupt.
