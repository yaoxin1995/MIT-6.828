// implement fork from user space

#include <inc/string.h>
#include <inc/lib.h>

// PTE_COW marks copy-on-write page table entries.
// It is one of the bits explicitly allocated to user processes (PTE_AVAIL).
#define PTE_COW		0x800

extern volatile pte_t uvpt[];     // VA of "virtual page table"
extern volatile pte_t uvpd[];     // VA of "virtual page table"
//

// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	pte_t ptindex;
	envid_t cpro_id;
	int r;

	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.


	if ((err & FEC_WR) != FEC_WR)
		panic("pgfault:  faulting access was not a write");
	
	ptindex = uvpt[PGNUM(addr)];

	if ((ptindex & PTE_COW) != PTE_COW)
		panic("pgfault:  faulting page is not copy-on-write");
	




	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// get current proc id: sys_getenvid
	// allocate a new page, map it at a temporary location: sys_page_alloc
	// copy the data from the old page to the new page: memcopy

	// LAB 4: Your code here.

	cpro_id = sys_getenvid();

	if ((r = sys_page_alloc(cpro_id, (void *)PFTEMP, PTE_U | PTE_W | PTE_P)) < 0)
		panic("pgfault:  sys_page_alloc failed");
	
	memcpy((void *)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);

	if ((r = sys_page_map(cpro_id, (void *)PFTEMP, cpro_id, 
			ROUNDDOWN(addr, PGSIZE), PTE_U | PTE_W | PTE_P)) < 0)
		panic("pgfault:  sys_page_map failed");
	
	if ((r = sys_page_unmap(cpro_id, PFTEMP)) != 0) {
        panic("pgfault: %e", r);
    }
		
}

//
// Map our virtual page pn (address pn*PGSIZE) into the target envid
// at the same virtual address.  If the page is writable or copy-on-write,
// the new mapping must be created copy-on-write, and then our mapping must be
// marked copy-on-write as well.  (Exercise: Why do we need to mark ours
// copy-on-write again if it was already copy-on-write at the beginning of
// this function?)
//
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	pte_t ptindex;
	envid_t cpro_id;

	// LAB 4: Your code here.

	cpro_id = sys_getenvid();

	
	ptindex = uvpt[pn];

	// page is read only
	if (!(ptindex & PTE_W) && !(ptindex & PTE_COW)) {

		if ((r = sys_page_map(cpro_id, (void *)(pn*PGSIZE), 
				envid, (void *)(pn*PGSIZE), PTE_U | PTE_P)) < 0)
			panic("duppage:  sys_page_alloc failed for read only page");
		return 0;
	}

	// Map the page copy-on-write into the address space of the child 
	if ((r = sys_page_map(cpro_id, (void *)(pn*PGSIZE), 
				envid, (void *)(pn*PGSIZE), PTE_U | PTE_P | PTE_COW)) < 0)
			panic("duppage:  sys_page_alloc failed for cow page in child");


	// Remap the page copy-on-write in its own address space
	if ((r = sys_page_map(cpro_id, (void *)(pn*PGSIZE), 
				cpro_id, (void *)(pn*PGSIZE), PTE_U | PTE_P | PTE_COW)) < 0)
		panic("duppage:  sys_page_alloc failed for cow page in child");

	return r;
}

//
// User-level fork with copy-on-write.
// Set up our page fault handler appropriately.
// Create a child.
// Copy our address space and page fault handler setup to the child.
// Then mark the child as runnable and return.
//
// Returns: child's envid to the parent, 0 to the child, < 0 on error.
// It is also OK to panic on error.
//
// Hint:
//   Use uvpd, uvpt, and duppage.
//   Remember to fix "thisenv" in the child process.
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
	envid_t envid;
	uint32_t addr;;
	int r;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);

	envid = sys_exofork();
	if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	// We're the parent.
	// Here we need to imitate the MMU's vitual address translation process
	// We need to first check whether the page table is present
	// Then we can check whethe the page is present
	// Otherwise we may got trouble
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && (uvpt[PGNUM(addr)] & PTE_P) == PTE_P)
            duppage(envid, PGNUM(addr));
	}


	// Set one page for exception stack for child
	sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_P | PTE_U);

	// Set the page fault handler for child
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0) 
		panic("set_pgfault_handler: set page fault handler failed %e", r);

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return envid;

}

// Challenge!
int
sfork(void)
{
	panic("sfork not implemented");
	return -E_INVAL;
}
