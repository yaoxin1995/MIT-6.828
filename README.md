# MIT-6.828
6.828 teaches the fundamentals of engineering operating systems. You will study, in detail, virtual memory, kernel and user mode, system calls, threads, context switches, interrupts, interprocess communication, coordination of concurrent activities, and the interface between software and hardware. Most importantly, you will study the interactions between these concepts, and how to manage the complexity introduced by the interactions.  

6.828 is organized in three parts: lectures, readings, and a sequence of programming labs. The lectures and readings familiarize you with the main concepts. The labs lead you to understand the concepts at a deep level, since you will build an operating system from the ground up. After the labs you will appreciate the meaning of design goals such as "reducing complexity" and "conceptual integrity".

The labs are split into 6 major parts that build on each other, culminating in a primitive operating system on which you can run simple commands through your own shell.

The operating system you will build, called JOS, will have Unix-like functions (e.g., fork, exec), but is implemented in an exokernel style (i.e., the Unix functions are implemented mostly in a user-level library instead of in the kernel). The major parts of the JOS operating system are:

+ Booting
+ Memory management
+ User environments
+ Preemptive multitasking
+ File system, spawn, and shell
+ Network driver


# For the implementation of xv6 and jos, please see the branches
(hw1)[https://github.com/yaoxin1995/MIT-6.828/tree/hw1]
