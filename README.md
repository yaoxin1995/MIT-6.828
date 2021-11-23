# LAB 2

## Key points

### Address translation procedure
```

           Selector  +--------------+         +-----------+
          ---------->|              |         |           |
                     | Segmentation |         |  Paging   |
Software             |              |-------->|           |---------->  RAM
            Offset   |  Mechanism   |         | Mechanism |
          ---------->|              |         |           |
                     +--------------+         +-----------+
            Virtual(logic)            Linear                Physical
```

### Addresses format

The JOS kernel often needs to manipulate addresses as opaque values or as integers, without dereferencing them, for example in the physical memory allocator. Sometimes these are virtual addresses, and sometimes they are physical addresses. To help document the code, the JOS source distinguishes the two cases: the type `uintptr_t` represents opaque virtual addresses, and `physaddr_t` represents physical addresses. Both these types are really just synonyms for 32-bit integers (uint32_t), so the compiler won't stop you from assigning one type to another! Since they are integer types (not pointers), the compiler will complain if you try to dereference them.

The JOS kernel can dereference a `uintptr_t` by first casting it to a pointer type. In contrast, the kernel can't sensibly dereference a physical address, since the MMU translates all memory references. If you cast a `physaddr_t` to a pointer and dereference it, you may be able to load and store to the resulting address (the hardware will interpret it as a virtual address), but you probably won't get the memory location you intended.

To summarize:

              C type	Address type
                + T*  	Virtual
                + uintptr_t  	Virtual
                + physaddr_t  	Physical


## Questions

### Question in part 2

Assuming that the following JOS kernel code is correct, what type should variable x have, `uintptr_t` or `physaddr_t`?
```
	mystery_t x;
	char* value = return_a_pointer();
	*value = 10;
	x = (mystery_t) value;

```
Answer: `uintptr_t`


### Question in part 3
1. What entries (rows) in the page directory have been filled in at this point? What addresses do they map and where do they point? In other words, fill out this table as much as possible:



2. We have placed the kernel and user environment in the same address space. Why will user programs not be able to read or write the kernel's memory? What specific mechanisms protect the kernel memory?

  + CPU does not allow user program to read kernel memory. Specifically MMU use the access bit PTE_S to protect kernel memory from reading by user level programs. When user-lever programs try to read kernel memory, MMU raises a fault informing OS to kill the program.

3. What is the maximum amount of physical memory that this operating system can support? Why?
```
  ULIM, MMIOBASE -->  +------------------------------+ 0xef800000
                      |  Cur. Page Table (User R-)   | R-/R-  PTSIZE
     UVPT      ---->  +------------------------------+ 0xef400000
                      |          RO PAGES            | R-/R-  PTSIZE
     UPAGES    ---->  +------------------------------+ 0xef000000
                      |           RO ENVS            | R-/R-  PTSIZE
  UTOP,UENVS ------>  +------------------------------+ 0xeec00000

```
 
  + 2GB

  + The OS use `struc PageInfo` to represent a 4 KiB physical memory. Each the size `struc   PageInfo` is 8 bytes. From the figure we can see that OS assign memory region (0xef000000-0xef400000 ----> 4MB) to record a array of `struc PageInfo` so that processes can read pages anytime they want. Therefore, OS can has max. 4MB/8Byte = 0.5M = 524288 pages, which means 524288 * 4K (2GB) physical memory.

4. How much space overhead is there for managing memory, if we actually had the maximum amount of physical memory? How is this overhead broken down?
  Overheads:
  + physical memory allocated for `struc PageInfo`: 4MB
  + 2-level page table: max. 1024*1024 (page table entry) * 4 Bytes (page table entry size) + 1024*8 Bytes (page directory size)