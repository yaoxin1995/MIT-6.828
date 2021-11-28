# LAB 2

## Key points

### CONTROL REGISTERS IN CPU

1. CR0:CR0 contains system control flags, which control or indicate conditions that apply to the system as a whole, not to an individual task.

  + EM (Emulation, bit 2)
    EM indicates whether coprocessor functions are to be emulated. Refer to
    Chapter 11 for details.
  + ET (Extension Type, bit 4)
     ET indicates the type of coprocessor present in the system (80287 or
    80387). Refer to Chapter 11 and Chapter 10 for details.
  + MP (Math Present, bit 1)
    MP controls the function of the WAIT instruction, which is used to
    coordinate a coprocessor. Refer to Chapter 11 for details.
  + PE (Protection Enable, bit 0)
    Setting PE causes the processor to begin executing in protected mode.
    Resetting PE returns to real-address mode. Refer to Chapter 14 and

  + PG (Paging, bit 31)
     PG indicates whether the processor uses page tables to translate linear
    addresses into physical addresses. Refer to Chapter 5 for a description
     of page translation; refer to Chapter 10 for a discussion of how to set
    PG.
  + TS (Task Switched, bit 3)
   The processor sets TS with every task switch and tests TS when
   interpreting coprocessor instructions. Refer to Chapter 11 for details.


2. CR2: CR2 is used for handling page faults when PG is set. The processor stores in CR2 the linear address(virtual address) that triggers the fault. 

3. CR3: cr3 contains the physical address of the current page table

4. EFLAGS register: The systems flags of the EFLAGS register control I/O, maskable interrupts, debugging, task switching, and enabling of virtual 8086 execution in a protected, multitasking environment. These flags are highlighted in Figure 4-1.

## Questions


  