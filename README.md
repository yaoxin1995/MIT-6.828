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