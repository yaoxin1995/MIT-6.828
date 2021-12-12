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

### Q1: Do you have to do anything else to ensure that this I/O privilege setting is saved and restored properly when you subsequently switch from one environment to another? Why?

No. The I/O privilege is stored in eflags register. It will be saved and restored automatically when switching between environments.




