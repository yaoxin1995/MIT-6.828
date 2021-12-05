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