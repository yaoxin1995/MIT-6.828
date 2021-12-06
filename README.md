# LAB 4

## Key points

### 1. STATIC in C
+ A static variable inside a function keeps its value between invocations.
+ A static global variable or a function is "seen" only in the file it's declared in.

### 2. Write Through and Write Back in Cache

+ Write-through: 
  + data is simultaneously updated to cache and memory
  + Solves the inconsistency problem between cache and memory
  + More expensive

+ Write Back: 
  + The data is updated only in the cache and updated into the memory at a later time.  
  + Data is updated in the memory only when the cache line is ready to be replaced
  + Dirty Bit: Each Block in the cache needs a bit to indicate if the data present in the cache was modified(Dirty) or not modified(Clean). If it is clean there is no need to write it into the memory. 
  + Efficient but complexes

### Direct and indirect call

+ Indirect call:
```
	movl    $mp_main, %eax  # see mpentry.s line 83 and explaination
	call    *%eax

```


+ Direct call:
```
  call mp_main
```
## Q&A

### Q1: Compare `kern/mpentry.S` side by side with `boot/boot.S`. Bearing in mind that `kern/mpentry.S` is compiled and linked to run above `KERNBASE` just like everything else in the kernel, what is the purpose of macro `MPBOOTPHYS`? Why is it necessary in `kern/mpentry.S` but not in `boot/boot.S`? In other words, what could go wrong if it were omitted in `kern/mpentry.S`?

`MPBOOTPHYS` is used to calculate the corresponding physical address of its symbols at `MPENTRY_PADDR` since APs are in real mode when starting and it can only run codes below 640K and `boot_aps()` has made a copy of the code at `MPENTRY_PADDR`, so the code can be accessed by the APs with the help of this macro.

The bootloader in `boot/boot.S` doesn't need such macro because it is an independent module linked to 0x7c00 which is addressable in real mode.

If it were omitted in `kern/mpentry.S`. The APs will try to load code at high address, which is unaddressable in real mode


### Q2: It seems that using the big kernel lock guarantees that only one CPU can run the kernel code at a time. Why do we still need separate kernel stacks for each CPU? Describe a scenario in which using a shared kernel stack will go wrong, even with the protection of the big kernel lock

Assume CPU O is running in kernel mode. Now, an interrupt happens in CPU1, the CPU 1 trap into the kernel and push its info into the share the kernel stack. In this case CPU1 may overwrite info belonging to CPU 0 on the stack.


### Q3: In your implementation of env_run() you should have called lcr3(). Before and after the call to lcr3(), your code makes references (at least it should) to the variable e, the argument to env_run. Upon loading the %cr3 register, the addressing context used by the MMU is instantly changed. But a virtual address (namely e) has meaning relative to a given address context--the address context specifies the physical address to which the virtual address maps. Why can the pointer e be dereferenced both before and after the addressing switch?

In env_setup_vm(), the comment says the virtual address space of all environments is identical from UTOP to UVPT, as well as the address space of the kernel. The virtual address of e is always the same whatever the address space it is, so it can be dereferenced both before and after the addressing switch.


### Q4: Whenever the kernel switches from one environment to another, it must ensure the old environment's registers are saved so they can be restored properly later. Why? Where does this happen?

The context switch needs to ensure the environment can resume the execution at exactly where it stops as the switch has never happened. So all the registers need to be saved. They are pushed onto the stack when it triggers sys_yield() syscall, and then the trap handler (here it is kern/trap.c:trap()) will save them in env_tf. And they are restored by env_pop_tf() when env_run() is executed.