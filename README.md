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


### GDB commands

1. Set breakpoints
  + `b *0x...` set a breakpoint at address 0x...

### x86 Protections

On the x86, interrupt handlers are defined in the interrupt descriptor table (IDT).
The IDT has 256 entries, each giving the %cs and %eip to be used when handling the
corresponding interrupt.

```
                                80386 INTERRUPT GATE
   31                23                15                7                0
  +-----------------+-----------------+---+---+---------+-----+-----------+
  |           OFFSET 31..16           | P |DPL|0 1 1 1 0|0 0 0|(NOT USED) |4
  |-----------------------------------+---+---+---------+-----+-----------|
  |             SELECTOR              |           OFFSET 15..0            |0
  +-----------------+-----------------+-----------------+-----------------+
```

The int instruction performs the following steps:
  + Fetch the n’th descriptor from the IDT, where n is the argument of int.
  + Check that CPL in %cs is <= DPL, where DPL is the privilege level in the descriptor.
  + Save %esp and %ss in CPU-internal registers, but only if the target segment selector’s PL < CPL.
  + Load %ss and %esp from a task segment descriptor.
  + Push %ss.
  + Push %esp.
  + Push %eflags.
  + Push %cs.
  + Push %eip.
  + Clear the IF bit in %eflags, but only on an interrupt.
  + Set %cs and %eip to the values in the descriptor

Kernel stack after an int instruction:

```
                     +--------------------+ KSTACKTOP             
                     | 0x00000 | old SS   |     " - 4
                     |      old ESP       |     " - 8
                     |     old EFLAGS     |     " - 12
                     | 0x00000 | old CS   |     " - 16
                     |      old EIP       |     " - 20
                     |     error code     |     " - 24 <---- ESP
                     +--------------------+
```
After an int instruction completes and there was a
privilege-level change (the privilege level in the descriptor is lower than CPL). If the
int instruction didn’t require a privilege-level change, the x86 won’t save `%ss` and
`%esp`. After both cases, `%eip` is pointing to the address specified in the descriptor table, and the instruction at that address is the next instruction to be executed and the
first instruction of the handler for int n. It is job of the operating system to implement these handlers, and below we will see what xv6 does.

An operating system can use the `iret` instruction to return from an int instruction. It pops the saved values during the int instruction from the stack, and resumes
execution at the saved `%eip`

## Questions

### PART1

1. What is the purpose of having an individual handler function for each exception/interrupt? (i.e., if all exceptions/interrupts were delivered to the same handler, what feature that exists in the current implementation could not be provided?)
  + To push the corresponding error code onto the stack. This is used for the codes going to handle it further like trap_dispatch() to distinguish the interrupts.

  + To provide permission control or isolation. For each standalone interrupt handler, we can define it whether can be triggered by a user program or not. By putting such limits on interrupt handlers, we can ensure user programs would not interfere with the kernel, corrupt the kernel or even take control of the whole computer





2. Did you have to do anything to make the user/softint program behave correctly? The grade script expects it to produce a general protection fault (trap 13), but softint's code says int $14. Why should this produce interrupt vector 13? What happens if the kernel actually allows softint's int $14 instruction to invoke the kernel's page fault handler (which is interrupt vector 14)?

I didn't have to do anything extra to do. It triggers an Interrupt 13 because only the kernel running in Ring 0 can trigger the handler of page fault as we defined above. This meets the "Executing the INT n instruction when the CPL is greater than the DPL of the referenced interrupt, trap, or task gate." condition, so the processor triggers a General Protection Exception (Interrupt 13)

If we allow a page fault to be triggered by a user program like softint. It can manipulate virtual memory and may cause serious security issues.
  