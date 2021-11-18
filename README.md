# Homework1

# Exercise: What is on the stack?
While stopped at the above breakpoint, look at the registers and the stack contents:


```
(gdb) x/24x $esp

0x7bdc:	0x00007d97	0x00000000	0x00000000	0x00000000
0x7bec:	0x00000000	0x00000000	0x00000000	0x00000000
0x7bfc:	0x00007c4d	0x8ec031fa	0x8ec08ed8	0xa864e4d0
0x7c0c:	0xb0fa7502	0xe464e6d1	0x7502a864	0xe6dfb0fa
0x7c1c:	0x16010f60	0x200f7c78	0xc88366c0	0xc0220f01
0x7c2c:	0x087c31ea	0x10b86600	0x8ed88e00	0x66d08ec0
```

## Answer
+ the stack bottom's address is 0x7c00, the current stack top is 0x7bdc, therefore the stack has the following contents:
```
0x7bdc:	0x00007d97	0x00000000	0x00000000	0x00000000
0x7bec:	0x00000000	0x00000000	0x00000000	0x00000000
0x7bfc:	0x00007c4d

```


+ 0x00007d97 : return address of function call `call bootmain`, i.e, next instruction address of `call bootmain` in `bootasm.S`(line:70)


+ 0x00007d97: return address of function call `entry()` in function `bootmain` (file bootmain.c)


