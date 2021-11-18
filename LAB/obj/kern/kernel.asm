
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 30 11 00       	mov    $0x113000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	# Indirect jump, %eax contains a absolute address, i.e,  Indirect JMP instructions specify an absolute address in the register eax
	jmp	*%eax     
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 10 11 f0       	mov    $0xf0111000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 6c 00 00 00       	call   f01000aa <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	f3 0f 1e fb          	endbr32 
f0100044:	55                   	push   %ebp
f0100045:	89 e5                	mov    %esp,%ebp
f0100047:	56                   	push   %esi
f0100048:	53                   	push   %ebx
f0100049:	e8 7e 01 00 00       	call   f01001cc <__x86.get_pc_thunk.bx>
f010004e:	81 c3 ba 22 01 00    	add    $0x122ba,%ebx
f0100054:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %d\n", x);
f0100057:	83 ec 08             	sub    $0x8,%esp
f010005a:	56                   	push   %esi
f010005b:	8d 83 38 f9 fe ff    	lea    -0x106c8(%ebx),%eax
f0100061:	50                   	push   %eax
f0100062:	e8 0d 0b 00 00       	call   f0100b74 <cprintf>
	if (x > 0)
f0100067:	83 c4 10             	add    $0x10,%esp
f010006a:	85 f6                	test   %esi,%esi
f010006c:	7e 29                	jle    f0100097 <test_backtrace+0x57>
		test_backtrace(x-1);
f010006e:	83 ec 0c             	sub    $0xc,%esp
f0100071:	8d 46 ff             	lea    -0x1(%esi),%eax
f0100074:	50                   	push   %eax
f0100075:	e8 c6 ff ff ff       	call   f0100040 <test_backtrace>
f010007a:	83 c4 10             	add    $0x10,%esp
	else
		mon_backtrace(0, 0, 0);
	cprintf("leaving test_backtrace %d\n", x);
f010007d:	83 ec 08             	sub    $0x8,%esp
f0100080:	56                   	push   %esi
f0100081:	8d 83 54 f9 fe ff    	lea    -0x106ac(%ebx),%eax
f0100087:	50                   	push   %eax
f0100088:	e8 e7 0a 00 00       	call   f0100b74 <cprintf>
}
f010008d:	83 c4 10             	add    $0x10,%esp
f0100090:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100093:	5b                   	pop    %ebx
f0100094:	5e                   	pop    %esi
f0100095:	5d                   	pop    %ebp
f0100096:	c3                   	ret    
		mon_backtrace(0, 0, 0);
f0100097:	83 ec 04             	sub    $0x4,%esp
f010009a:	6a 00                	push   $0x0
f010009c:	6a 00                	push   $0x0
f010009e:	6a 00                	push   $0x0
f01000a0:	e8 23 08 00 00       	call   f01008c8 <mon_backtrace>
f01000a5:	83 c4 10             	add    $0x10,%esp
f01000a8:	eb d3                	jmp    f010007d <test_backtrace+0x3d>

f01000aa <i386_init>:

void
i386_init(void)
{
f01000aa:	f3 0f 1e fb          	endbr32 
f01000ae:	55                   	push   %ebp
f01000af:	89 e5                	mov    %esp,%ebp
f01000b1:	53                   	push   %ebx
f01000b2:	83 ec 08             	sub    $0x8,%esp
f01000b5:	e8 12 01 00 00       	call   f01001cc <__x86.get_pc_thunk.bx>
f01000ba:	81 c3 4e 22 01 00    	add    $0x1224e,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000c0:	c7 c2 60 40 11 f0    	mov    $0xf0114060,%edx
f01000c6:	c7 c0 a0 46 11 f0    	mov    $0xf01146a0,%eax
f01000cc:	29 d0                	sub    %edx,%eax
f01000ce:	50                   	push   %eax
f01000cf:	6a 00                	push   $0x0
f01000d1:	52                   	push   %edx
f01000d2:	e8 ff 16 00 00       	call   f01017d6 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000d7:	e8 4b 05 00 00       	call   f0100627 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000dc:	83 c4 08             	add    $0x8,%esp
f01000df:	68 ac 1a 00 00       	push   $0x1aac
f01000e4:	8d 83 6f f9 fe ff    	lea    -0x10691(%ebx),%eax
f01000ea:	50                   	push   %eax
f01000eb:	e8 84 0a 00 00       	call   f0100b74 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000f0:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000f7:	e8 44 ff ff ff       	call   f0100040 <test_backtrace>
f01000fc:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000ff:	83 ec 0c             	sub    $0xc,%esp
f0100102:	6a 00                	push   $0x0
f0100104:	e8 a4 08 00 00       	call   f01009ad <monitor>
f0100109:	83 c4 10             	add    $0x10,%esp
f010010c:	eb f1                	jmp    f01000ff <i386_init+0x55>

f010010e <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f010010e:	f3 0f 1e fb          	endbr32 
f0100112:	55                   	push   %ebp
f0100113:	89 e5                	mov    %esp,%ebp
f0100115:	57                   	push   %edi
f0100116:	56                   	push   %esi
f0100117:	53                   	push   %ebx
f0100118:	83 ec 0c             	sub    $0xc,%esp
f010011b:	e8 ac 00 00 00       	call   f01001cc <__x86.get_pc_thunk.bx>
f0100120:	81 c3 e8 21 01 00    	add    $0x121e8,%ebx
f0100126:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f0100129:	c7 c0 a4 46 11 f0    	mov    $0xf01146a4,%eax
f010012f:	83 38 00             	cmpl   $0x0,(%eax)
f0100132:	74 0f                	je     f0100143 <_panic+0x35>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100134:	83 ec 0c             	sub    $0xc,%esp
f0100137:	6a 00                	push   $0x0
f0100139:	e8 6f 08 00 00       	call   f01009ad <monitor>
f010013e:	83 c4 10             	add    $0x10,%esp
f0100141:	eb f1                	jmp    f0100134 <_panic+0x26>
	panicstr = fmt;
f0100143:	89 38                	mov    %edi,(%eax)
	asm volatile("cli; cld");
f0100145:	fa                   	cli    
f0100146:	fc                   	cld    
	va_start(ap, fmt);
f0100147:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f010014a:	83 ec 04             	sub    $0x4,%esp
f010014d:	ff 75 0c             	pushl  0xc(%ebp)
f0100150:	ff 75 08             	pushl  0x8(%ebp)
f0100153:	8d 83 8a f9 fe ff    	lea    -0x10676(%ebx),%eax
f0100159:	50                   	push   %eax
f010015a:	e8 15 0a 00 00       	call   f0100b74 <cprintf>
	vcprintf(fmt, ap);
f010015f:	83 c4 08             	add    $0x8,%esp
f0100162:	56                   	push   %esi
f0100163:	57                   	push   %edi
f0100164:	e8 d0 09 00 00       	call   f0100b39 <vcprintf>
	cprintf("\n");
f0100169:	8d 83 c6 f9 fe ff    	lea    -0x1063a(%ebx),%eax
f010016f:	89 04 24             	mov    %eax,(%esp)
f0100172:	e8 fd 09 00 00       	call   f0100b74 <cprintf>
f0100177:	83 c4 10             	add    $0x10,%esp
f010017a:	eb b8                	jmp    f0100134 <_panic+0x26>

f010017c <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010017c:	f3 0f 1e fb          	endbr32 
f0100180:	55                   	push   %ebp
f0100181:	89 e5                	mov    %esp,%ebp
f0100183:	56                   	push   %esi
f0100184:	53                   	push   %ebx
f0100185:	e8 42 00 00 00       	call   f01001cc <__x86.get_pc_thunk.bx>
f010018a:	81 c3 7e 21 01 00    	add    $0x1217e,%ebx
	va_list ap;

	va_start(ap, fmt);
f0100190:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f0100193:	83 ec 04             	sub    $0x4,%esp
f0100196:	ff 75 0c             	pushl  0xc(%ebp)
f0100199:	ff 75 08             	pushl  0x8(%ebp)
f010019c:	8d 83 a2 f9 fe ff    	lea    -0x1065e(%ebx),%eax
f01001a2:	50                   	push   %eax
f01001a3:	e8 cc 09 00 00       	call   f0100b74 <cprintf>
	vcprintf(fmt, ap);
f01001a8:	83 c4 08             	add    $0x8,%esp
f01001ab:	56                   	push   %esi
f01001ac:	ff 75 10             	pushl  0x10(%ebp)
f01001af:	e8 85 09 00 00       	call   f0100b39 <vcprintf>
	cprintf("\n");
f01001b4:	8d 83 c6 f9 fe ff    	lea    -0x1063a(%ebx),%eax
f01001ba:	89 04 24             	mov    %eax,(%esp)
f01001bd:	e8 b2 09 00 00       	call   f0100b74 <cprintf>
	va_end(ap);
}
f01001c2:	83 c4 10             	add    $0x10,%esp
f01001c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001c8:	5b                   	pop    %ebx
f01001c9:	5e                   	pop    %esi
f01001ca:	5d                   	pop    %ebp
f01001cb:	c3                   	ret    

f01001cc <__x86.get_pc_thunk.bx>:
f01001cc:	8b 1c 24             	mov    (%esp),%ebx
f01001cf:	c3                   	ret    

f01001d0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001d0:	f3 0f 1e fb          	endbr32 

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001d4:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001d9:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001da:	a8 01                	test   $0x1,%al
f01001dc:	74 0a                	je     f01001e8 <serial_proc_data+0x18>
f01001de:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001e3:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001e4:	0f b6 c0             	movzbl %al,%eax
f01001e7:	c3                   	ret    
		return -1;
f01001e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01001ed:	c3                   	ret    

f01001ee <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001ee:	55                   	push   %ebp
f01001ef:	89 e5                	mov    %esp,%ebp
f01001f1:	57                   	push   %edi
f01001f2:	56                   	push   %esi
f01001f3:	53                   	push   %ebx
f01001f4:	83 ec 1c             	sub    $0x1c,%esp
f01001f7:	e8 88 05 00 00       	call   f0100784 <__x86.get_pc_thunk.si>
f01001fc:	81 c6 0c 21 01 00    	add    $0x1210c,%esi
f0100202:	89 c7                	mov    %eax,%edi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f0100204:	8d 1d 78 1d 00 00    	lea    0x1d78,%ebx
f010020a:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f010020d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100210:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	while ((c = (*proc)()) != -1) {
f0100213:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100216:	ff d0                	call   *%eax
f0100218:	83 f8 ff             	cmp    $0xffffffff,%eax
f010021b:	74 2b                	je     f0100248 <cons_intr+0x5a>
		if (c == 0)
f010021d:	85 c0                	test   %eax,%eax
f010021f:	74 f2                	je     f0100213 <cons_intr+0x25>
		cons.buf[cons.wpos++] = c;
f0100221:	8b 8c 1e 04 02 00 00 	mov    0x204(%esi,%ebx,1),%ecx
f0100228:	8d 51 01             	lea    0x1(%ecx),%edx
f010022b:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010022e:	88 04 0f             	mov    %al,(%edi,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f0100231:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f0100237:	b8 00 00 00 00       	mov    $0x0,%eax
f010023c:	0f 44 d0             	cmove  %eax,%edx
f010023f:	89 94 1e 04 02 00 00 	mov    %edx,0x204(%esi,%ebx,1)
f0100246:	eb cb                	jmp    f0100213 <cons_intr+0x25>
	}
}
f0100248:	83 c4 1c             	add    $0x1c,%esp
f010024b:	5b                   	pop    %ebx
f010024c:	5e                   	pop    %esi
f010024d:	5f                   	pop    %edi
f010024e:	5d                   	pop    %ebp
f010024f:	c3                   	ret    

f0100250 <kbd_proc_data>:
{
f0100250:	f3 0f 1e fb          	endbr32 
f0100254:	55                   	push   %ebp
f0100255:	89 e5                	mov    %esp,%ebp
f0100257:	56                   	push   %esi
f0100258:	53                   	push   %ebx
f0100259:	e8 6e ff ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f010025e:	81 c3 aa 20 01 00    	add    $0x120aa,%ebx
f0100264:	ba 64 00 00 00       	mov    $0x64,%edx
f0100269:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f010026a:	a8 01                	test   $0x1,%al
f010026c:	0f 84 fb 00 00 00    	je     f010036d <kbd_proc_data+0x11d>
	if (stat & KBS_TERR)
f0100272:	a8 20                	test   $0x20,%al
f0100274:	0f 85 fa 00 00 00    	jne    f0100374 <kbd_proc_data+0x124>
f010027a:	ba 60 00 00 00       	mov    $0x60,%edx
f010027f:	ec                   	in     (%dx),%al
f0100280:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100282:	3c e0                	cmp    $0xe0,%al
f0100284:	74 64                	je     f01002ea <kbd_proc_data+0x9a>
	} else if (data & 0x80) {
f0100286:	84 c0                	test   %al,%al
f0100288:	78 75                	js     f01002ff <kbd_proc_data+0xaf>
	} else if (shift & E0ESC) {
f010028a:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f0100290:	f6 c1 40             	test   $0x40,%cl
f0100293:	74 0e                	je     f01002a3 <kbd_proc_data+0x53>
		data |= 0x80;
f0100295:	83 c8 80             	or     $0xffffff80,%eax
f0100298:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010029a:	83 e1 bf             	and    $0xffffffbf,%ecx
f010029d:	89 8b 58 1d 00 00    	mov    %ecx,0x1d58(%ebx)
	shift |= shiftcode[data];
f01002a3:	0f b6 d2             	movzbl %dl,%edx
f01002a6:	0f b6 84 13 f8 fa fe 	movzbl -0x10508(%ebx,%edx,1),%eax
f01002ad:	ff 
f01002ae:	0b 83 58 1d 00 00    	or     0x1d58(%ebx),%eax
	shift ^= togglecode[data];
f01002b4:	0f b6 8c 13 f8 f9 fe 	movzbl -0x10608(%ebx,%edx,1),%ecx
f01002bb:	ff 
f01002bc:	31 c8                	xor    %ecx,%eax
f01002be:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f01002c4:	89 c1                	mov    %eax,%ecx
f01002c6:	83 e1 03             	and    $0x3,%ecx
f01002c9:	8b 8c 8b f8 1c 00 00 	mov    0x1cf8(%ebx,%ecx,4),%ecx
f01002d0:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002d4:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f01002d7:	a8 08                	test   $0x8,%al
f01002d9:	74 65                	je     f0100340 <kbd_proc_data+0xf0>
		if ('a' <= c && c <= 'z')
f01002db:	89 f2                	mov    %esi,%edx
f01002dd:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01002e0:	83 f9 19             	cmp    $0x19,%ecx
f01002e3:	77 4f                	ja     f0100334 <kbd_proc_data+0xe4>
			c += 'A' - 'a';
f01002e5:	83 ee 20             	sub    $0x20,%esi
f01002e8:	eb 0c                	jmp    f01002f6 <kbd_proc_data+0xa6>
		shift |= E0ESC;
f01002ea:	83 8b 58 1d 00 00 40 	orl    $0x40,0x1d58(%ebx)
		return 0;
f01002f1:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002f6:	89 f0                	mov    %esi,%eax
f01002f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01002fb:	5b                   	pop    %ebx
f01002fc:	5e                   	pop    %esi
f01002fd:	5d                   	pop    %ebp
f01002fe:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01002ff:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f0100305:	89 ce                	mov    %ecx,%esi
f0100307:	83 e6 40             	and    $0x40,%esi
f010030a:	83 e0 7f             	and    $0x7f,%eax
f010030d:	85 f6                	test   %esi,%esi
f010030f:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100312:	0f b6 d2             	movzbl %dl,%edx
f0100315:	0f b6 84 13 f8 fa fe 	movzbl -0x10508(%ebx,%edx,1),%eax
f010031c:	ff 
f010031d:	83 c8 40             	or     $0x40,%eax
f0100320:	0f b6 c0             	movzbl %al,%eax
f0100323:	f7 d0                	not    %eax
f0100325:	21 c8                	and    %ecx,%eax
f0100327:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
		return 0;
f010032d:	be 00 00 00 00       	mov    $0x0,%esi
f0100332:	eb c2                	jmp    f01002f6 <kbd_proc_data+0xa6>
		else if ('A' <= c && c <= 'Z')
f0100334:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100337:	8d 4e 20             	lea    0x20(%esi),%ecx
f010033a:	83 fa 1a             	cmp    $0x1a,%edx
f010033d:	0f 42 f1             	cmovb  %ecx,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100340:	f7 d0                	not    %eax
f0100342:	a8 06                	test   $0x6,%al
f0100344:	75 b0                	jne    f01002f6 <kbd_proc_data+0xa6>
f0100346:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f010034c:	75 a8                	jne    f01002f6 <kbd_proc_data+0xa6>
		cprintf("Rebooting!\n");
f010034e:	83 ec 0c             	sub    $0xc,%esp
f0100351:	8d 83 bc f9 fe ff    	lea    -0x10644(%ebx),%eax
f0100357:	50                   	push   %eax
f0100358:	e8 17 08 00 00       	call   f0100b74 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010035d:	b8 03 00 00 00       	mov    $0x3,%eax
f0100362:	ba 92 00 00 00       	mov    $0x92,%edx
f0100367:	ee                   	out    %al,(%dx)
}
f0100368:	83 c4 10             	add    $0x10,%esp
f010036b:	eb 89                	jmp    f01002f6 <kbd_proc_data+0xa6>
		return -1;
f010036d:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100372:	eb 82                	jmp    f01002f6 <kbd_proc_data+0xa6>
		return -1;
f0100374:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100379:	e9 78 ff ff ff       	jmp    f01002f6 <kbd_proc_data+0xa6>

f010037e <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010037e:	55                   	push   %ebp
f010037f:	89 e5                	mov    %esp,%ebp
f0100381:	57                   	push   %edi
f0100382:	56                   	push   %esi
f0100383:	53                   	push   %ebx
f0100384:	83 ec 1c             	sub    $0x1c,%esp
f0100387:	e8 40 fe ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f010038c:	81 c3 7c 1f 01 00    	add    $0x11f7c,%ebx
f0100392:	89 c7                	mov    %eax,%edi
	for (i = 0;
f0100394:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100399:	b9 84 00 00 00       	mov    $0x84,%ecx
f010039e:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01003a3:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003a4:	a8 20                	test   $0x20,%al
f01003a6:	75 13                	jne    f01003bb <cons_putc+0x3d>
f01003a8:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003ae:	7f 0b                	jg     f01003bb <cons_putc+0x3d>
f01003b0:	89 ca                	mov    %ecx,%edx
f01003b2:	ec                   	in     (%dx),%al
f01003b3:	ec                   	in     (%dx),%al
f01003b4:	ec                   	in     (%dx),%al
f01003b5:	ec                   	in     (%dx),%al
	     i++)
f01003b6:	83 c6 01             	add    $0x1,%esi
f01003b9:	eb e3                	jmp    f010039e <cons_putc+0x20>
	outb(COM1 + COM_TX, c);
f01003bb:	89 f8                	mov    %edi,%eax
f01003bd:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003c0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003c5:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003c6:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003cb:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003d0:	ba 79 03 00 00       	mov    $0x379,%edx
f01003d5:	ec                   	in     (%dx),%al
f01003d6:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003dc:	7f 0f                	jg     f01003ed <cons_putc+0x6f>
f01003de:	84 c0                	test   %al,%al
f01003e0:	78 0b                	js     f01003ed <cons_putc+0x6f>
f01003e2:	89 ca                	mov    %ecx,%edx
f01003e4:	ec                   	in     (%dx),%al
f01003e5:	ec                   	in     (%dx),%al
f01003e6:	ec                   	in     (%dx),%al
f01003e7:	ec                   	in     (%dx),%al
f01003e8:	83 c6 01             	add    $0x1,%esi
f01003eb:	eb e3                	jmp    f01003d0 <cons_putc+0x52>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003ed:	ba 78 03 00 00       	mov    $0x378,%edx
f01003f2:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f01003f6:	ee                   	out    %al,(%dx)
f01003f7:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003fc:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100401:	ee                   	out    %al,(%dx)
f0100402:	b8 08 00 00 00       	mov    $0x8,%eax
f0100407:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f0100408:	89 f8                	mov    %edi,%eax
f010040a:	80 cc 07             	or     $0x7,%ah
f010040d:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100413:	0f 44 f8             	cmove  %eax,%edi
	switch (c & 0xff) {
f0100416:	89 f8                	mov    %edi,%eax
f0100418:	0f b6 c0             	movzbl %al,%eax
f010041b:	89 f9                	mov    %edi,%ecx
f010041d:	80 f9 0a             	cmp    $0xa,%cl
f0100420:	0f 84 e2 00 00 00    	je     f0100508 <cons_putc+0x18a>
f0100426:	83 f8 0a             	cmp    $0xa,%eax
f0100429:	7f 46                	jg     f0100471 <cons_putc+0xf3>
f010042b:	83 f8 08             	cmp    $0x8,%eax
f010042e:	0f 84 a8 00 00 00    	je     f01004dc <cons_putc+0x15e>
f0100434:	83 f8 09             	cmp    $0x9,%eax
f0100437:	0f 85 d8 00 00 00    	jne    f0100515 <cons_putc+0x197>
		cons_putc(' ');
f010043d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100442:	e8 37 ff ff ff       	call   f010037e <cons_putc>
		cons_putc(' ');
f0100447:	b8 20 00 00 00       	mov    $0x20,%eax
f010044c:	e8 2d ff ff ff       	call   f010037e <cons_putc>
		cons_putc(' ');
f0100451:	b8 20 00 00 00       	mov    $0x20,%eax
f0100456:	e8 23 ff ff ff       	call   f010037e <cons_putc>
		cons_putc(' ');
f010045b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100460:	e8 19 ff ff ff       	call   f010037e <cons_putc>
		cons_putc(' ');
f0100465:	b8 20 00 00 00       	mov    $0x20,%eax
f010046a:	e8 0f ff ff ff       	call   f010037e <cons_putc>
		break;
f010046f:	eb 26                	jmp    f0100497 <cons_putc+0x119>
	switch (c & 0xff) {
f0100471:	83 f8 0d             	cmp    $0xd,%eax
f0100474:	0f 85 9b 00 00 00    	jne    f0100515 <cons_putc+0x197>
		crt_pos -= (crt_pos % CRT_COLS);
f010047a:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100481:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100487:	c1 e8 16             	shr    $0x16,%eax
f010048a:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010048d:	c1 e0 04             	shl    $0x4,%eax
f0100490:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
	if (crt_pos >= CRT_SIZE) {
f0100497:	66 81 bb 80 1f 00 00 	cmpw   $0x7cf,0x1f80(%ebx)
f010049e:	cf 07 
f01004a0:	0f 87 92 00 00 00    	ja     f0100538 <cons_putc+0x1ba>
	outb(addr_6845, 14);
f01004a6:	8b 8b 88 1f 00 00    	mov    0x1f88(%ebx),%ecx
f01004ac:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004b1:	89 ca                	mov    %ecx,%edx
f01004b3:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004b4:	0f b7 9b 80 1f 00 00 	movzwl 0x1f80(%ebx),%ebx
f01004bb:	8d 71 01             	lea    0x1(%ecx),%esi
f01004be:	89 d8                	mov    %ebx,%eax
f01004c0:	66 c1 e8 08          	shr    $0x8,%ax
f01004c4:	89 f2                	mov    %esi,%edx
f01004c6:	ee                   	out    %al,(%dx)
f01004c7:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004cc:	89 ca                	mov    %ecx,%edx
f01004ce:	ee                   	out    %al,(%dx)
f01004cf:	89 d8                	mov    %ebx,%eax
f01004d1:	89 f2                	mov    %esi,%edx
f01004d3:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004d7:	5b                   	pop    %ebx
f01004d8:	5e                   	pop    %esi
f01004d9:	5f                   	pop    %edi
f01004da:	5d                   	pop    %ebp
f01004db:	c3                   	ret    
		if (crt_pos > 0) {
f01004dc:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f01004e3:	66 85 c0             	test   %ax,%ax
f01004e6:	74 be                	je     f01004a6 <cons_putc+0x128>
			crt_pos--;
f01004e8:	83 e8 01             	sub    $0x1,%eax
f01004eb:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004f2:	0f b7 c0             	movzwl %ax,%eax
f01004f5:	89 fa                	mov    %edi,%edx
f01004f7:	b2 00                	mov    $0x0,%dl
f01004f9:	83 ca 20             	or     $0x20,%edx
f01004fc:	8b 8b 84 1f 00 00    	mov    0x1f84(%ebx),%ecx
f0100502:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f0100506:	eb 8f                	jmp    f0100497 <cons_putc+0x119>
		crt_pos += CRT_COLS;
f0100508:	66 83 83 80 1f 00 00 	addw   $0x50,0x1f80(%ebx)
f010050f:	50 
f0100510:	e9 65 ff ff ff       	jmp    f010047a <cons_putc+0xfc>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100515:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f010051c:	8d 50 01             	lea    0x1(%eax),%edx
f010051f:	66 89 93 80 1f 00 00 	mov    %dx,0x1f80(%ebx)
f0100526:	0f b7 c0             	movzwl %ax,%eax
f0100529:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f010052f:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
f0100533:	e9 5f ff ff ff       	jmp    f0100497 <cons_putc+0x119>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100538:	8b 83 84 1f 00 00    	mov    0x1f84(%ebx),%eax
f010053e:	83 ec 04             	sub    $0x4,%esp
f0100541:	68 00 0f 00 00       	push   $0xf00
f0100546:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010054c:	52                   	push   %edx
f010054d:	50                   	push   %eax
f010054e:	e8 cf 12 00 00       	call   f0101822 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100553:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f0100559:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010055f:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100565:	83 c4 10             	add    $0x10,%esp
f0100568:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010056d:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100570:	39 d0                	cmp    %edx,%eax
f0100572:	75 f4                	jne    f0100568 <cons_putc+0x1ea>
		crt_pos -= CRT_COLS;
f0100574:	66 83 ab 80 1f 00 00 	subw   $0x50,0x1f80(%ebx)
f010057b:	50 
f010057c:	e9 25 ff ff ff       	jmp    f01004a6 <cons_putc+0x128>

f0100581 <serial_intr>:
{
f0100581:	f3 0f 1e fb          	endbr32 
f0100585:	e8 f6 01 00 00       	call   f0100780 <__x86.get_pc_thunk.ax>
f010058a:	05 7e 1d 01 00       	add    $0x11d7e,%eax
	if (serial_exists)
f010058f:	80 b8 8c 1f 00 00 00 	cmpb   $0x0,0x1f8c(%eax)
f0100596:	75 01                	jne    f0100599 <serial_intr+0x18>
f0100598:	c3                   	ret    
{
f0100599:	55                   	push   %ebp
f010059a:	89 e5                	mov    %esp,%ebp
f010059c:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010059f:	8d 80 c8 de fe ff    	lea    -0x12138(%eax),%eax
f01005a5:	e8 44 fc ff ff       	call   f01001ee <cons_intr>
}
f01005aa:	c9                   	leave  
f01005ab:	c3                   	ret    

f01005ac <kbd_intr>:
{
f01005ac:	f3 0f 1e fb          	endbr32 
f01005b0:	55                   	push   %ebp
f01005b1:	89 e5                	mov    %esp,%ebp
f01005b3:	83 ec 08             	sub    $0x8,%esp
f01005b6:	e8 c5 01 00 00       	call   f0100780 <__x86.get_pc_thunk.ax>
f01005bb:	05 4d 1d 01 00       	add    $0x11d4d,%eax
	cons_intr(kbd_proc_data);
f01005c0:	8d 80 48 df fe ff    	lea    -0x120b8(%eax),%eax
f01005c6:	e8 23 fc ff ff       	call   f01001ee <cons_intr>
}
f01005cb:	c9                   	leave  
f01005cc:	c3                   	ret    

f01005cd <cons_getc>:
{
f01005cd:	f3 0f 1e fb          	endbr32 
f01005d1:	55                   	push   %ebp
f01005d2:	89 e5                	mov    %esp,%ebp
f01005d4:	53                   	push   %ebx
f01005d5:	83 ec 04             	sub    $0x4,%esp
f01005d8:	e8 ef fb ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f01005dd:	81 c3 2b 1d 01 00    	add    $0x11d2b,%ebx
	serial_intr();
f01005e3:	e8 99 ff ff ff       	call   f0100581 <serial_intr>
	kbd_intr();
f01005e8:	e8 bf ff ff ff       	call   f01005ac <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005ed:	8b 83 78 1f 00 00    	mov    0x1f78(%ebx),%eax
	return 0;
f01005f3:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f01005f8:	3b 83 7c 1f 00 00    	cmp    0x1f7c(%ebx),%eax
f01005fe:	74 1f                	je     f010061f <cons_getc+0x52>
		c = cons.buf[cons.rpos++];
f0100600:	8d 48 01             	lea    0x1(%eax),%ecx
f0100603:	0f b6 94 03 78 1d 00 	movzbl 0x1d78(%ebx,%eax,1),%edx
f010060a:	00 
			cons.rpos = 0;
f010060b:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100611:	b8 00 00 00 00       	mov    $0x0,%eax
f0100616:	0f 44 c8             	cmove  %eax,%ecx
f0100619:	89 8b 78 1f 00 00    	mov    %ecx,0x1f78(%ebx)
}
f010061f:	89 d0                	mov    %edx,%eax
f0100621:	83 c4 04             	add    $0x4,%esp
f0100624:	5b                   	pop    %ebx
f0100625:	5d                   	pop    %ebp
f0100626:	c3                   	ret    

f0100627 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100627:	f3 0f 1e fb          	endbr32 
f010062b:	55                   	push   %ebp
f010062c:	89 e5                	mov    %esp,%ebp
f010062e:	57                   	push   %edi
f010062f:	56                   	push   %esi
f0100630:	53                   	push   %ebx
f0100631:	83 ec 1c             	sub    $0x1c,%esp
f0100634:	e8 93 fb ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f0100639:	81 c3 cf 1c 01 00    	add    $0x11ccf,%ebx
	was = *cp;
f010063f:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100646:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010064d:	5a a5 
	if (*cp != 0xA55A) {
f010064f:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100656:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010065a:	0f 84 bc 00 00 00    	je     f010071c <cons_init+0xf5>
		addr_6845 = MONO_BASE;
f0100660:	c7 83 88 1f 00 00 b4 	movl   $0x3b4,0x1f88(%ebx)
f0100667:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010066a:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f0100671:	8b bb 88 1f 00 00    	mov    0x1f88(%ebx),%edi
f0100677:	b8 0e 00 00 00       	mov    $0xe,%eax
f010067c:	89 fa                	mov    %edi,%edx
f010067e:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010067f:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100682:	89 ca                	mov    %ecx,%edx
f0100684:	ec                   	in     (%dx),%al
f0100685:	0f b6 f0             	movzbl %al,%esi
f0100688:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010068b:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100690:	89 fa                	mov    %edi,%edx
f0100692:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100693:	89 ca                	mov    %ecx,%edx
f0100695:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100696:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100699:	89 bb 84 1f 00 00    	mov    %edi,0x1f84(%ebx)
	pos |= inb(addr_6845 + 1);
f010069f:	0f b6 c0             	movzbl %al,%eax
f01006a2:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f01006a4:	66 89 b3 80 1f 00 00 	mov    %si,0x1f80(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006ab:	b9 00 00 00 00       	mov    $0x0,%ecx
f01006b0:	89 c8                	mov    %ecx,%eax
f01006b2:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006b7:	ee                   	out    %al,(%dx)
f01006b8:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006bd:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006c2:	89 fa                	mov    %edi,%edx
f01006c4:	ee                   	out    %al,(%dx)
f01006c5:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006ca:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006cf:	ee                   	out    %al,(%dx)
f01006d0:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006d5:	89 c8                	mov    %ecx,%eax
f01006d7:	89 f2                	mov    %esi,%edx
f01006d9:	ee                   	out    %al,(%dx)
f01006da:	b8 03 00 00 00       	mov    $0x3,%eax
f01006df:	89 fa                	mov    %edi,%edx
f01006e1:	ee                   	out    %al,(%dx)
f01006e2:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006e7:	89 c8                	mov    %ecx,%eax
f01006e9:	ee                   	out    %al,(%dx)
f01006ea:	b8 01 00 00 00       	mov    $0x1,%eax
f01006ef:	89 f2                	mov    %esi,%edx
f01006f1:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006f2:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006f7:	ec                   	in     (%dx),%al
f01006f8:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006fa:	3c ff                	cmp    $0xff,%al
f01006fc:	0f 95 83 8c 1f 00 00 	setne  0x1f8c(%ebx)
f0100703:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100708:	ec                   	in     (%dx),%al
f0100709:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010070e:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010070f:	80 f9 ff             	cmp    $0xff,%cl
f0100712:	74 25                	je     f0100739 <cons_init+0x112>
		cprintf("Serial port does not exist!\n");
}
f0100714:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100717:	5b                   	pop    %ebx
f0100718:	5e                   	pop    %esi
f0100719:	5f                   	pop    %edi
f010071a:	5d                   	pop    %ebp
f010071b:	c3                   	ret    
		*cp = was;
f010071c:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100723:	c7 83 88 1f 00 00 d4 	movl   $0x3d4,0x1f88(%ebx)
f010072a:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010072d:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f0100734:	e9 38 ff ff ff       	jmp    f0100671 <cons_init+0x4a>
		cprintf("Serial port does not exist!\n");
f0100739:	83 ec 0c             	sub    $0xc,%esp
f010073c:	8d 83 c8 f9 fe ff    	lea    -0x10638(%ebx),%eax
f0100742:	50                   	push   %eax
f0100743:	e8 2c 04 00 00       	call   f0100b74 <cprintf>
f0100748:	83 c4 10             	add    $0x10,%esp
}
f010074b:	eb c7                	jmp    f0100714 <cons_init+0xed>

f010074d <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010074d:	f3 0f 1e fb          	endbr32 
f0100751:	55                   	push   %ebp
f0100752:	89 e5                	mov    %esp,%ebp
f0100754:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100757:	8b 45 08             	mov    0x8(%ebp),%eax
f010075a:	e8 1f fc ff ff       	call   f010037e <cons_putc>
}
f010075f:	c9                   	leave  
f0100760:	c3                   	ret    

f0100761 <getchar>:

int
getchar(void)
{
f0100761:	f3 0f 1e fb          	endbr32 
f0100765:	55                   	push   %ebp
f0100766:	89 e5                	mov    %esp,%ebp
f0100768:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010076b:	e8 5d fe ff ff       	call   f01005cd <cons_getc>
f0100770:	85 c0                	test   %eax,%eax
f0100772:	74 f7                	je     f010076b <getchar+0xa>
		/* do nothing */;
	return c;
}
f0100774:	c9                   	leave  
f0100775:	c3                   	ret    

f0100776 <iscons>:

int
iscons(int fdnum)
{
f0100776:	f3 0f 1e fb          	endbr32 
	// used by readline
	return 1;
}
f010077a:	b8 01 00 00 00       	mov    $0x1,%eax
f010077f:	c3                   	ret    

f0100780 <__x86.get_pc_thunk.ax>:
f0100780:	8b 04 24             	mov    (%esp),%eax
f0100783:	c3                   	ret    

f0100784 <__x86.get_pc_thunk.si>:
f0100784:	8b 34 24             	mov    (%esp),%esi
f0100787:	c3                   	ret    

f0100788 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100788:	f3 0f 1e fb          	endbr32 
f010078c:	55                   	push   %ebp
f010078d:	89 e5                	mov    %esp,%ebp
f010078f:	56                   	push   %esi
f0100790:	53                   	push   %ebx
f0100791:	e8 36 fa ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f0100796:	81 c3 72 1b 01 00    	add    $0x11b72,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010079c:	83 ec 04             	sub    $0x4,%esp
f010079f:	8d 83 f8 fb fe ff    	lea    -0x10408(%ebx),%eax
f01007a5:	50                   	push   %eax
f01007a6:	8d 83 16 fc fe ff    	lea    -0x103ea(%ebx),%eax
f01007ac:	50                   	push   %eax
f01007ad:	8d b3 1b fc fe ff    	lea    -0x103e5(%ebx),%esi
f01007b3:	56                   	push   %esi
f01007b4:	e8 bb 03 00 00       	call   f0100b74 <cprintf>
f01007b9:	83 c4 0c             	add    $0xc,%esp
f01007bc:	8d 83 d4 fc fe ff    	lea    -0x1032c(%ebx),%eax
f01007c2:	50                   	push   %eax
f01007c3:	8d 83 24 fc fe ff    	lea    -0x103dc(%ebx),%eax
f01007c9:	50                   	push   %eax
f01007ca:	56                   	push   %esi
f01007cb:	e8 a4 03 00 00       	call   f0100b74 <cprintf>
f01007d0:	83 c4 0c             	add    $0xc,%esp
f01007d3:	8d 83 2d fc fe ff    	lea    -0x103d3(%ebx),%eax
f01007d9:	50                   	push   %eax
f01007da:	8d 83 44 fc fe ff    	lea    -0x103bc(%ebx),%eax
f01007e0:	50                   	push   %eax
f01007e1:	56                   	push   %esi
f01007e2:	e8 8d 03 00 00       	call   f0100b74 <cprintf>
	return 0;
}
f01007e7:	b8 00 00 00 00       	mov    $0x0,%eax
f01007ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007ef:	5b                   	pop    %ebx
f01007f0:	5e                   	pop    %esi
f01007f1:	5d                   	pop    %ebp
f01007f2:	c3                   	ret    

f01007f3 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007f3:	f3 0f 1e fb          	endbr32 
f01007f7:	55                   	push   %ebp
f01007f8:	89 e5                	mov    %esp,%ebp
f01007fa:	57                   	push   %edi
f01007fb:	56                   	push   %esi
f01007fc:	53                   	push   %ebx
f01007fd:	83 ec 18             	sub    $0x18,%esp
f0100800:	e8 c7 f9 ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f0100805:	81 c3 03 1b 01 00    	add    $0x11b03,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010080b:	8d 83 4e fc fe ff    	lea    -0x103b2(%ebx),%eax
f0100811:	50                   	push   %eax
f0100812:	e8 5d 03 00 00       	call   f0100b74 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100817:	83 c4 08             	add    $0x8,%esp
f010081a:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f0100820:	8d 83 fc fc fe ff    	lea    -0x10304(%ebx),%eax
f0100826:	50                   	push   %eax
f0100827:	e8 48 03 00 00       	call   f0100b74 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010082c:	83 c4 0c             	add    $0xc,%esp
f010082f:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f0100835:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f010083b:	50                   	push   %eax
f010083c:	57                   	push   %edi
f010083d:	8d 83 24 fd fe ff    	lea    -0x102dc(%ebx),%eax
f0100843:	50                   	push   %eax
f0100844:	e8 2b 03 00 00       	call   f0100b74 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100849:	83 c4 0c             	add    $0xc,%esp
f010084c:	c7 c0 3d 1c 10 f0    	mov    $0xf0101c3d,%eax
f0100852:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100858:	52                   	push   %edx
f0100859:	50                   	push   %eax
f010085a:	8d 83 48 fd fe ff    	lea    -0x102b8(%ebx),%eax
f0100860:	50                   	push   %eax
f0100861:	e8 0e 03 00 00       	call   f0100b74 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100866:	83 c4 0c             	add    $0xc,%esp
f0100869:	c7 c0 60 40 11 f0    	mov    $0xf0114060,%eax
f010086f:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100875:	52                   	push   %edx
f0100876:	50                   	push   %eax
f0100877:	8d 83 6c fd fe ff    	lea    -0x10294(%ebx),%eax
f010087d:	50                   	push   %eax
f010087e:	e8 f1 02 00 00       	call   f0100b74 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100883:	83 c4 0c             	add    $0xc,%esp
f0100886:	c7 c6 a0 46 11 f0    	mov    $0xf01146a0,%esi
f010088c:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0100892:	50                   	push   %eax
f0100893:	56                   	push   %esi
f0100894:	8d 83 90 fd fe ff    	lea    -0x10270(%ebx),%eax
f010089a:	50                   	push   %eax
f010089b:	e8 d4 02 00 00       	call   f0100b74 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008a0:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01008a3:	29 fe                	sub    %edi,%esi
f01008a5:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008ab:	c1 fe 0a             	sar    $0xa,%esi
f01008ae:	56                   	push   %esi
f01008af:	8d 83 b4 fd fe ff    	lea    -0x1024c(%ebx),%eax
f01008b5:	50                   	push   %eax
f01008b6:	e8 b9 02 00 00       	call   f0100b74 <cprintf>
	return 0;
}
f01008bb:	b8 00 00 00 00       	mov    $0x0,%eax
f01008c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008c3:	5b                   	pop    %ebx
f01008c4:	5e                   	pop    %esi
f01008c5:	5f                   	pop    %edi
f01008c6:	5d                   	pop    %ebp
f01008c7:	c3                   	ret    

f01008c8 <mon_backtrace>:
		Note: %ebp contain a pointer to the stack possition which stores the saved %ebp
		
 */
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008c8:	f3 0f 1e fb          	endbr32 
f01008cc:	55                   	push   %ebp
f01008cd:	89 e5                	mov    %esp,%ebp
f01008cf:	57                   	push   %edi
f01008d0:	56                   	push   %esi
f01008d1:	53                   	push   %ebx
f01008d2:	83 ec 3c             	sub    $0x3c,%esp
f01008d5:	e8 f2 f8 ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f01008da:	81 c3 2e 1a 01 00    	add    $0x11a2e,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008e0:	89 e8                	mov    %ebp,%eax
	uint32_t i;
	uint32_t *arg_arry;
	struct Eipdebuginfo info;
	

	current_ebp = (uint32_t*)read_ebp();
f01008e2:	89 c7                	mov    %eax,%edi


	while (current_ebp != 0) {
		eip = current_ebp + 1;

		cprintf("ebp %x  eip %x  args ", current_ebp, *eip);
f01008e4:	8d 83 67 fc fe ff    	lea    -0x10399(%ebx),%eax
f01008ea:	89 45 bc             	mov    %eax,-0x44(%ebp)

		arg_arry = current_ebp + 2;

		for (i = 0; i < 5; i++) {
			cprintf("%08x ", arg_arry[i]);
f01008ed:	8d 83 7d fc fe ff    	lea    -0x10383(%ebx),%eax
f01008f3:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	while (current_ebp != 0) {
f01008f6:	eb 6b                	jmp    f0100963 <mon_backtrace+0x9b>
f01008f8:	8b 7d c0             	mov    -0x40(%ebp),%edi
		}

		cprintf("\n");
f01008fb:	83 ec 0c             	sub    $0xc,%esp
f01008fe:	8d 83 c6 f9 fe ff    	lea    -0x1063a(%ebx),%eax
f0100904:	50                   	push   %eax
f0100905:	e8 6a 02 00 00       	call   f0100b74 <cprintf>

		debuginfo_eip(*eip, &info);
f010090a:	83 c4 08             	add    $0x8,%esp
f010090d:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100910:	50                   	push   %eax
f0100911:	ff 77 04             	pushl  0x4(%edi)
f0100914:	e8 68 03 00 00       	call   f0100c81 <debuginfo_eip>

		cprintf("       %s:%d: ", info.eip_file, info.eip_line);
f0100919:	83 c4 0c             	add    $0xc,%esp
f010091c:	ff 75 d4             	pushl  -0x2c(%ebp)
f010091f:	ff 75 d0             	pushl  -0x30(%ebp)
f0100922:	8d 83 83 fc fe ff    	lea    -0x1037d(%ebx),%eax
f0100928:	50                   	push   %eax
f0100929:	e8 46 02 00 00       	call   f0100b74 <cprintf>

		cprintf("%.*s+", info.eip_fn_namelen, info.eip_fn_name);
f010092e:	83 c4 0c             	add    $0xc,%esp
f0100931:	ff 75 d8             	pushl  -0x28(%ebp)
f0100934:	ff 75 dc             	pushl  -0x24(%ebp)
f0100937:	8d 83 92 fc fe ff    	lea    -0x1036e(%ebx),%eax
f010093d:	50                   	push   %eax
f010093e:	e8 31 02 00 00       	call   f0100b74 <cprintf>

		cprintf("%d\n", eip - info.eip_fn_addr);
f0100943:	83 c4 08             	add    $0x8,%esp
f0100946:	b8 01 00 00 00       	mov    $0x1,%eax
f010094b:	2b 45 e0             	sub    -0x20(%ebp),%eax
f010094e:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0100951:	50                   	push   %eax
f0100952:	8d 83 50 f9 fe ff    	lea    -0x106b0(%ebx),%eax
f0100958:	50                   	push   %eax
f0100959:	e8 16 02 00 00       	call   f0100b74 <cprintf>

		current_ebp = (uint32_t*)*current_ebp;
f010095e:	8b 3f                	mov    (%edi),%edi
f0100960:	83 c4 10             	add    $0x10,%esp
	while (current_ebp != 0) {
f0100963:	85 ff                	test   %edi,%edi
f0100965:	74 39                	je     f01009a0 <mon_backtrace+0xd8>
		cprintf("ebp %x  eip %x  args ", current_ebp, *eip);
f0100967:	83 ec 04             	sub    $0x4,%esp
f010096a:	ff 77 04             	pushl  0x4(%edi)
f010096d:	57                   	push   %edi
f010096e:	ff 75 bc             	pushl  -0x44(%ebp)
f0100971:	e8 fe 01 00 00       	call   f0100b74 <cprintf>
f0100976:	8d 77 08             	lea    0x8(%edi),%esi
f0100979:	8d 47 1c             	lea    0x1c(%edi),%eax
f010097c:	83 c4 10             	add    $0x10,%esp
f010097f:	89 7d c0             	mov    %edi,-0x40(%ebp)
f0100982:	89 c7                	mov    %eax,%edi
			cprintf("%08x ", arg_arry[i]);
f0100984:	83 ec 08             	sub    $0x8,%esp
f0100987:	ff 36                	pushl  (%esi)
f0100989:	ff 75 c4             	pushl  -0x3c(%ebp)
f010098c:	e8 e3 01 00 00       	call   f0100b74 <cprintf>
f0100991:	83 c6 04             	add    $0x4,%esi
		for (i = 0; i < 5; i++) {
f0100994:	83 c4 10             	add    $0x10,%esp
f0100997:	39 fe                	cmp    %edi,%esi
f0100999:	75 e9                	jne    f0100984 <mon_backtrace+0xbc>
f010099b:	e9 58 ff ff ff       	jmp    f01008f8 <mon_backtrace+0x30>
	}

	return 0;
}
f01009a0:	b8 00 00 00 00       	mov    $0x0,%eax
f01009a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009a8:	5b                   	pop    %ebx
f01009a9:	5e                   	pop    %esi
f01009aa:	5f                   	pop    %edi
f01009ab:	5d                   	pop    %ebp
f01009ac:	c3                   	ret    

f01009ad <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01009ad:	f3 0f 1e fb          	endbr32 
f01009b1:	55                   	push   %ebp
f01009b2:	89 e5                	mov    %esp,%ebp
f01009b4:	57                   	push   %edi
f01009b5:	56                   	push   %esi
f01009b6:	53                   	push   %ebx
f01009b7:	83 ec 68             	sub    $0x68,%esp
f01009ba:	e8 0d f8 ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f01009bf:	81 c3 49 19 01 00    	add    $0x11949,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01009c5:	8d 83 e0 fd fe ff    	lea    -0x10220(%ebx),%eax
f01009cb:	50                   	push   %eax
f01009cc:	e8 a3 01 00 00       	call   f0100b74 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01009d1:	8d 83 04 fe fe ff    	lea    -0x101fc(%ebx),%eax
f01009d7:	89 04 24             	mov    %eax,(%esp)
f01009da:	e8 95 01 00 00       	call   f0100b74 <cprintf>
f01009df:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f01009e2:	8d 83 9c fc fe ff    	lea    -0x10364(%ebx),%eax
f01009e8:	89 45 a0             	mov    %eax,-0x60(%ebp)
f01009eb:	e9 d1 00 00 00       	jmp    f0100ac1 <monitor+0x114>
f01009f0:	83 ec 08             	sub    $0x8,%esp
f01009f3:	0f be c0             	movsbl %al,%eax
f01009f6:	50                   	push   %eax
f01009f7:	ff 75 a0             	pushl  -0x60(%ebp)
f01009fa:	e8 92 0d 00 00       	call   f0101791 <strchr>
f01009ff:	83 c4 10             	add    $0x10,%esp
f0100a02:	85 c0                	test   %eax,%eax
f0100a04:	74 6d                	je     f0100a73 <monitor+0xc6>
			*buf++ = 0;
f0100a06:	c6 06 00             	movb   $0x0,(%esi)
f0100a09:	89 7d a4             	mov    %edi,-0x5c(%ebp)
f0100a0c:	8d 76 01             	lea    0x1(%esi),%esi
f0100a0f:	8b 7d a4             	mov    -0x5c(%ebp),%edi
		while (*buf && strchr(WHITESPACE, *buf))
f0100a12:	0f b6 06             	movzbl (%esi),%eax
f0100a15:	84 c0                	test   %al,%al
f0100a17:	75 d7                	jne    f01009f0 <monitor+0x43>
	argv[argc] = 0;
f0100a19:	c7 44 bd a8 00 00 00 	movl   $0x0,-0x58(%ebp,%edi,4)
f0100a20:	00 
	if (argc == 0)
f0100a21:	85 ff                	test   %edi,%edi
f0100a23:	0f 84 98 00 00 00    	je     f0100ac1 <monitor+0x114>
f0100a29:	8d b3 18 1d 00 00    	lea    0x1d18(%ebx),%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a2f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a34:	89 7d a4             	mov    %edi,-0x5c(%ebp)
f0100a37:	89 c7                	mov    %eax,%edi
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a39:	83 ec 08             	sub    $0x8,%esp
f0100a3c:	ff 36                	pushl  (%esi)
f0100a3e:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a41:	e8 e5 0c 00 00       	call   f010172b <strcmp>
f0100a46:	83 c4 10             	add    $0x10,%esp
f0100a49:	85 c0                	test   %eax,%eax
f0100a4b:	0f 84 99 00 00 00    	je     f0100aea <monitor+0x13d>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a51:	83 c7 01             	add    $0x1,%edi
f0100a54:	83 c6 0c             	add    $0xc,%esi
f0100a57:	83 ff 03             	cmp    $0x3,%edi
f0100a5a:	75 dd                	jne    f0100a39 <monitor+0x8c>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a5c:	83 ec 08             	sub    $0x8,%esp
f0100a5f:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a62:	8d 83 be fc fe ff    	lea    -0x10342(%ebx),%eax
f0100a68:	50                   	push   %eax
f0100a69:	e8 06 01 00 00       	call   f0100b74 <cprintf>
	return 0;
f0100a6e:	83 c4 10             	add    $0x10,%esp
f0100a71:	eb 4e                	jmp    f0100ac1 <monitor+0x114>
		if (*buf == 0)
f0100a73:	80 3e 00             	cmpb   $0x0,(%esi)
f0100a76:	74 a1                	je     f0100a19 <monitor+0x6c>
		if (argc == MAXARGS-1) {
f0100a78:	83 ff 0f             	cmp    $0xf,%edi
f0100a7b:	74 30                	je     f0100aad <monitor+0x100>
		argv[argc++] = buf;
f0100a7d:	8d 47 01             	lea    0x1(%edi),%eax
f0100a80:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f0100a83:	89 74 bd a8          	mov    %esi,-0x58(%ebp,%edi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a87:	0f b6 06             	movzbl (%esi),%eax
f0100a8a:	84 c0                	test   %al,%al
f0100a8c:	74 81                	je     f0100a0f <monitor+0x62>
f0100a8e:	83 ec 08             	sub    $0x8,%esp
f0100a91:	0f be c0             	movsbl %al,%eax
f0100a94:	50                   	push   %eax
f0100a95:	ff 75 a0             	pushl  -0x60(%ebp)
f0100a98:	e8 f4 0c 00 00       	call   f0101791 <strchr>
f0100a9d:	83 c4 10             	add    $0x10,%esp
f0100aa0:	85 c0                	test   %eax,%eax
f0100aa2:	0f 85 67 ff ff ff    	jne    f0100a0f <monitor+0x62>
			buf++;
f0100aa8:	83 c6 01             	add    $0x1,%esi
f0100aab:	eb da                	jmp    f0100a87 <monitor+0xda>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100aad:	83 ec 08             	sub    $0x8,%esp
f0100ab0:	6a 10                	push   $0x10
f0100ab2:	8d 83 a1 fc fe ff    	lea    -0x1035f(%ebx),%eax
f0100ab8:	50                   	push   %eax
f0100ab9:	e8 b6 00 00 00       	call   f0100b74 <cprintf>
			return 0;
f0100abe:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100ac1:	8d bb 98 fc fe ff    	lea    -0x10368(%ebx),%edi
f0100ac7:	83 ec 0c             	sub    $0xc,%esp
f0100aca:	57                   	push   %edi
f0100acb:	e8 50 0a 00 00       	call   f0101520 <readline>
		if (buf != NULL)
f0100ad0:	83 c4 10             	add    $0x10,%esp
f0100ad3:	85 c0                	test   %eax,%eax
f0100ad5:	74 f0                	je     f0100ac7 <monitor+0x11a>
f0100ad7:	89 c6                	mov    %eax,%esi
	argv[argc] = 0;
f0100ad9:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100ae0:	bf 00 00 00 00       	mov    $0x0,%edi
f0100ae5:	e9 28 ff ff ff       	jmp    f0100a12 <monitor+0x65>
f0100aea:	89 f8                	mov    %edi,%eax
f0100aec:	8b 7d a4             	mov    -0x5c(%ebp),%edi
			return commands[i].func(argc, argv, tf);
f0100aef:	83 ec 04             	sub    $0x4,%esp
f0100af2:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100af5:	ff 75 08             	pushl  0x8(%ebp)
f0100af8:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100afb:	52                   	push   %edx
f0100afc:	57                   	push   %edi
f0100afd:	ff 94 83 20 1d 00 00 	call   *0x1d20(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100b04:	83 c4 10             	add    $0x10,%esp
f0100b07:	85 c0                	test   %eax,%eax
f0100b09:	79 b6                	jns    f0100ac1 <monitor+0x114>
				break;
	}
}
f0100b0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100b0e:	5b                   	pop    %ebx
f0100b0f:	5e                   	pop    %esi
f0100b10:	5f                   	pop    %edi
f0100b11:	5d                   	pop    %ebp
f0100b12:	c3                   	ret    

f0100b13 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100b13:	f3 0f 1e fb          	endbr32 
f0100b17:	55                   	push   %ebp
f0100b18:	89 e5                	mov    %esp,%ebp
f0100b1a:	53                   	push   %ebx
f0100b1b:	83 ec 10             	sub    $0x10,%esp
f0100b1e:	e8 a9 f6 ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f0100b23:	81 c3 e5 17 01 00    	add    $0x117e5,%ebx
	cputchar(ch);
f0100b29:	ff 75 08             	pushl  0x8(%ebp)
f0100b2c:	e8 1c fc ff ff       	call   f010074d <cputchar>
	*cnt++;
}
f0100b31:	83 c4 10             	add    $0x10,%esp
f0100b34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b37:	c9                   	leave  
f0100b38:	c3                   	ret    

f0100b39 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100b39:	f3 0f 1e fb          	endbr32 
f0100b3d:	55                   	push   %ebp
f0100b3e:	89 e5                	mov    %esp,%ebp
f0100b40:	53                   	push   %ebx
f0100b41:	83 ec 14             	sub    $0x14,%esp
f0100b44:	e8 83 f6 ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f0100b49:	81 c3 bf 17 01 00    	add    $0x117bf,%ebx
	int cnt = 0;
f0100b4f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100b56:	ff 75 0c             	pushl  0xc(%ebp)
f0100b59:	ff 75 08             	pushl  0x8(%ebp)
f0100b5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100b5f:	50                   	push   %eax
f0100b60:	8d 83 0b e8 fe ff    	lea    -0x117f5(%ebx),%eax
f0100b66:	50                   	push   %eax
f0100b67:	e8 7a 04 00 00       	call   f0100fe6 <vprintfmt>
	return cnt;
}
f0100b6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100b6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b72:	c9                   	leave  
f0100b73:	c3                   	ret    

f0100b74 <cprintf>:


/* the function would take variable argument*/
int
cprintf(const char *fmt, ...)
{
f0100b74:	f3 0f 1e fb          	endbr32 
f0100b78:	55                   	push   %ebp
f0100b79:	89 e5                	mov    %esp,%ebp
f0100b7b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;
	 /* Initializing arguments to store all values after fmt */
	va_start(ap, fmt);
f0100b7e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100b81:	50                   	push   %eax
f0100b82:	ff 75 08             	pushl  0x8(%ebp)
f0100b85:	e8 af ff ff ff       	call   f0100b39 <vcprintf>

	// Once you're done, use va_end to clean up the list: va_end( a_list );
	va_end(ap);

	return cnt;
}
f0100b8a:	c9                   	leave  
f0100b8b:	c3                   	ret    

f0100b8c <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100b8c:	55                   	push   %ebp
f0100b8d:	89 e5                	mov    %esp,%ebp
f0100b8f:	57                   	push   %edi
f0100b90:	56                   	push   %esi
f0100b91:	53                   	push   %ebx
f0100b92:	83 ec 14             	sub    $0x14,%esp
f0100b95:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100b98:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100b9b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100b9e:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100ba1:	8b 1a                	mov    (%edx),%ebx
f0100ba3:	8b 01                	mov    (%ecx),%eax
f0100ba5:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100ba8:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100baf:	eb 23                	jmp    f0100bd4 <stab_binsearch+0x48>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100bb1:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0100bb4:	eb 1e                	jmp    f0100bd4 <stab_binsearch+0x48>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100bb6:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100bb9:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100bbc:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100bc0:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100bc3:	73 46                	jae    f0100c0b <stab_binsearch+0x7f>
			*region_left = m;
f0100bc5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100bc8:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100bca:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0100bcd:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0100bd4:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100bd7:	7f 5f                	jg     f0100c38 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0100bd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100bdc:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0100bdf:	89 d0                	mov    %edx,%eax
f0100be1:	c1 e8 1f             	shr    $0x1f,%eax
f0100be4:	01 d0                	add    %edx,%eax
f0100be6:	89 c7                	mov    %eax,%edi
f0100be8:	d1 ff                	sar    %edi
f0100bea:	83 e0 fe             	and    $0xfffffffe,%eax
f0100bed:	01 f8                	add    %edi,%eax
f0100bef:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100bf2:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100bf6:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0100bf8:	39 c3                	cmp    %eax,%ebx
f0100bfa:	7f b5                	jg     f0100bb1 <stab_binsearch+0x25>
f0100bfc:	0f b6 0a             	movzbl (%edx),%ecx
f0100bff:	83 ea 0c             	sub    $0xc,%edx
f0100c02:	39 f1                	cmp    %esi,%ecx
f0100c04:	74 b0                	je     f0100bb6 <stab_binsearch+0x2a>
			m--;
f0100c06:	83 e8 01             	sub    $0x1,%eax
f0100c09:	eb ed                	jmp    f0100bf8 <stab_binsearch+0x6c>
		} else if (stabs[m].n_value > addr) {
f0100c0b:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100c0e:	76 14                	jbe    f0100c24 <stab_binsearch+0x98>
			*region_right = m - 1;
f0100c10:	83 e8 01             	sub    $0x1,%eax
f0100c13:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100c16:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100c19:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0100c1b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100c22:	eb b0                	jmp    f0100bd4 <stab_binsearch+0x48>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100c24:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100c27:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0100c29:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100c2d:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0100c2f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100c36:	eb 9c                	jmp    f0100bd4 <stab_binsearch+0x48>
		}
	}

	if (!any_matches)
f0100c38:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100c3c:	75 15                	jne    f0100c53 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0100c3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c41:	8b 00                	mov    (%eax),%eax
f0100c43:	83 e8 01             	sub    $0x1,%eax
f0100c46:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100c49:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0100c4b:	83 c4 14             	add    $0x14,%esp
f0100c4e:	5b                   	pop    %ebx
f0100c4f:	5e                   	pop    %esi
f0100c50:	5f                   	pop    %edi
f0100c51:	5d                   	pop    %ebp
f0100c52:	c3                   	ret    
		for (l = *region_right;
f0100c53:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c56:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100c58:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100c5b:	8b 0f                	mov    (%edi),%ecx
f0100c5d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100c60:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0100c63:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
		for (l = *region_right;
f0100c67:	eb 03                	jmp    f0100c6c <stab_binsearch+0xe0>
		     l--)
f0100c69:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0100c6c:	39 c1                	cmp    %eax,%ecx
f0100c6e:	7d 0a                	jge    f0100c7a <stab_binsearch+0xee>
		     l > *region_left && stabs[l].n_type != type;
f0100c70:	0f b6 1a             	movzbl (%edx),%ebx
f0100c73:	83 ea 0c             	sub    $0xc,%edx
f0100c76:	39 f3                	cmp    %esi,%ebx
f0100c78:	75 ef                	jne    f0100c69 <stab_binsearch+0xdd>
		*region_left = l;
f0100c7a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100c7d:	89 07                	mov    %eax,(%edi)
}
f0100c7f:	eb ca                	jmp    f0100c4b <stab_binsearch+0xbf>

f0100c81 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100c81:	f3 0f 1e fb          	endbr32 
f0100c85:	55                   	push   %ebp
f0100c86:	89 e5                	mov    %esp,%ebp
f0100c88:	57                   	push   %edi
f0100c89:	56                   	push   %esi
f0100c8a:	53                   	push   %ebx
f0100c8b:	83 ec 3c             	sub    $0x3c,%esp
f0100c8e:	e8 39 f5 ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f0100c93:	81 c3 75 16 01 00    	add    $0x11675,%ebx
f0100c99:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
f0100c9c:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100c9f:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100ca2:	8d 83 29 fe fe ff    	lea    -0x101d7(%ebx),%eax
f0100ca8:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f0100caa:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0100cb1:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f0100cb4:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0100cbb:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0100cbe:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100cc5:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0100ccb:	0f 86 38 01 00 00    	jbe    f0100e09 <debuginfo_eip+0x188>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100cd1:	c7 c0 a5 67 10 f0    	mov    $0xf01067a5,%eax
f0100cd7:	39 83 fc ff ff ff    	cmp    %eax,-0x4(%ebx)
f0100cdd:	0f 86 da 01 00 00    	jbe    f0100ebd <debuginfo_eip+0x23c>
f0100ce3:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100ce6:	c7 c0 61 81 10 f0    	mov    $0xf0108161,%eax
f0100cec:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0100cf0:	0f 85 ce 01 00 00    	jne    f0100ec4 <debuginfo_eip+0x243>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100cf6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100cfd:	c7 c0 4c 23 10 f0    	mov    $0xf010234c,%eax
f0100d03:	c7 c2 a4 67 10 f0    	mov    $0xf01067a4,%edx
f0100d09:	29 c2                	sub    %eax,%edx
f0100d0b:	c1 fa 02             	sar    $0x2,%edx
f0100d0e:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0100d14:	83 ea 01             	sub    $0x1,%edx
f0100d17:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100d1a:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100d1d:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100d20:	83 ec 08             	sub    $0x8,%esp
f0100d23:	57                   	push   %edi
f0100d24:	6a 64                	push   $0x64
f0100d26:	e8 61 fe ff ff       	call   f0100b8c <stab_binsearch>
	if (lfile == 0)
f0100d2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100d2e:	83 c4 10             	add    $0x10,%esp
f0100d31:	85 c0                	test   %eax,%eax
f0100d33:	0f 84 92 01 00 00    	je     f0100ecb <debuginfo_eip+0x24a>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100d39:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100d3c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d3f:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100d42:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100d45:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100d48:	83 ec 08             	sub    $0x8,%esp
f0100d4b:	57                   	push   %edi
f0100d4c:	6a 24                	push   $0x24
f0100d4e:	c7 c0 4c 23 10 f0    	mov    $0xf010234c,%eax
f0100d54:	e8 33 fe ff ff       	call   f0100b8c <stab_binsearch>

	if (lfun <= rfun) {
f0100d59:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100d5c:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100d5f:	89 4d c0             	mov    %ecx,-0x40(%ebp)
f0100d62:	83 c4 10             	add    $0x10,%esp
f0100d65:	39 c8                	cmp    %ecx,%eax
f0100d67:	0f 8f b7 00 00 00    	jg     f0100e24 <debuginfo_eip+0x1a3>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100d6d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100d70:	c7 c1 4c 23 10 f0    	mov    $0xf010234c,%ecx
f0100d76:	8d 0c 91             	lea    (%ecx,%edx,4),%ecx
f0100d79:	8b 11                	mov    (%ecx),%edx
f0100d7b:	89 55 bc             	mov    %edx,-0x44(%ebp)
f0100d7e:	c7 c2 61 81 10 f0    	mov    $0xf0108161,%edx
f0100d84:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
f0100d87:	81 ea a5 67 10 f0    	sub    $0xf01067a5,%edx
f0100d8d:	8b 5d bc             	mov    -0x44(%ebp),%ebx
f0100d90:	39 d3                	cmp    %edx,%ebx
f0100d92:	73 0c                	jae    f0100da0 <debuginfo_eip+0x11f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100d94:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0100d97:	81 c3 a5 67 10 f0    	add    $0xf01067a5,%ebx
f0100d9d:	89 5e 08             	mov    %ebx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100da0:	8b 51 08             	mov    0x8(%ecx),%edx
f0100da3:	89 56 10             	mov    %edx,0x10(%esi)
		addr -= info->eip_fn_addr;
f0100da6:	29 d7                	sub    %edx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0100da8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100dab:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0100dae:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100db1:	83 ec 08             	sub    $0x8,%esp
f0100db4:	6a 3a                	push   $0x3a
f0100db6:	ff 76 08             	pushl  0x8(%esi)
f0100db9:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100dbc:	e8 f5 09 00 00       	call   f01017b6 <strfind>
f0100dc1:	2b 46 08             	sub    0x8(%esi),%eax
f0100dc4:	89 46 0c             	mov    %eax,0xc(%esi)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.

	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100dc7:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100dca:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100dcd:	83 c4 08             	add    $0x8,%esp
f0100dd0:	57                   	push   %edi
f0100dd1:	6a 44                	push   $0x44
f0100dd3:	c7 c0 4c 23 10 f0    	mov    $0xf010234c,%eax
f0100dd9:	e8 ae fd ff ff       	call   f0100b8c <stab_binsearch>

	if (lline <= rline) {
f0100dde:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100de1:	83 c4 10             	add    $0x10,%esp
f0100de4:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0100de7:	0f 8f e5 00 00 00    	jg     f0100ed2 <debuginfo_eip+0x251>

		info->eip_line = stabs[lline].n_desc;
f0100ded:	89 c2                	mov    %eax,%edx
f0100def:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100df2:	c7 c0 4c 23 10 f0    	mov    $0xf010234c,%eax
f0100df8:	0f b7 5c 88 06       	movzwl 0x6(%eax,%ecx,4),%ebx
f0100dfd:	89 5e 04             	mov    %ebx,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100e00:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100e03:	8d 44 88 04          	lea    0x4(%eax,%ecx,4),%eax
f0100e07:	eb 35                	jmp    f0100e3e <debuginfo_eip+0x1bd>
  	        panic("User address");
f0100e09:	83 ec 04             	sub    $0x4,%esp
f0100e0c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e0f:	8d 83 33 fe fe ff    	lea    -0x101cd(%ebx),%eax
f0100e15:	50                   	push   %eax
f0100e16:	6a 7f                	push   $0x7f
f0100e18:	8d 83 40 fe fe ff    	lea    -0x101c0(%ebx),%eax
f0100e1e:	50                   	push   %eax
f0100e1f:	e8 ea f2 ff ff       	call   f010010e <_panic>
		info->eip_fn_addr = addr;
f0100e24:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0100e27:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e2a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100e2d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e30:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100e33:	e9 79 ff ff ff       	jmp    f0100db1 <debuginfo_eip+0x130>
f0100e38:	83 ea 01             	sub    $0x1,%edx
f0100e3b:	83 e8 0c             	sub    $0xc,%eax
	while (lline >= lfile
f0100e3e:	39 d7                	cmp    %edx,%edi
f0100e40:	7f 3a                	jg     f0100e7c <debuginfo_eip+0x1fb>
	       && stabs[lline].n_type != N_SOL
f0100e42:	0f b6 08             	movzbl (%eax),%ecx
f0100e45:	80 f9 84             	cmp    $0x84,%cl
f0100e48:	74 0b                	je     f0100e55 <debuginfo_eip+0x1d4>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100e4a:	80 f9 64             	cmp    $0x64,%cl
f0100e4d:	75 e9                	jne    f0100e38 <debuginfo_eip+0x1b7>
f0100e4f:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0100e53:	74 e3                	je     f0100e38 <debuginfo_eip+0x1b7>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100e55:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100e58:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100e5b:	c7 c0 4c 23 10 f0    	mov    $0xf010234c,%eax
f0100e61:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0100e64:	c7 c0 61 81 10 f0    	mov    $0xf0108161,%eax
f0100e6a:	81 e8 a5 67 10 f0    	sub    $0xf01067a5,%eax
f0100e70:	39 c2                	cmp    %eax,%edx
f0100e72:	73 08                	jae    f0100e7c <debuginfo_eip+0x1fb>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100e74:	81 c2 a5 67 10 f0    	add    $0xf01067a5,%edx
f0100e7a:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100e7c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100e7f:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100e82:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0100e87:	39 da                	cmp    %ebx,%edx
f0100e89:	7d 53                	jge    f0100ede <debuginfo_eip+0x25d>
		for (lline = lfun + 1;
f0100e8b:	8d 42 01             	lea    0x1(%edx),%eax
f0100e8e:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100e91:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100e94:	c7 c2 4c 23 10 f0    	mov    $0xf010234c,%edx
f0100e9a:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx
f0100e9e:	eb 04                	jmp    f0100ea4 <debuginfo_eip+0x223>
			info->eip_fn_narg++;
f0100ea0:	83 46 14 01          	addl   $0x1,0x14(%esi)
		for (lline = lfun + 1;
f0100ea4:	39 c3                	cmp    %eax,%ebx
f0100ea6:	7e 31                	jle    f0100ed9 <debuginfo_eip+0x258>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100ea8:	0f b6 0a             	movzbl (%edx),%ecx
f0100eab:	83 c0 01             	add    $0x1,%eax
f0100eae:	83 c2 0c             	add    $0xc,%edx
f0100eb1:	80 f9 a0             	cmp    $0xa0,%cl
f0100eb4:	74 ea                	je     f0100ea0 <debuginfo_eip+0x21f>
	return 0;
f0100eb6:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ebb:	eb 21                	jmp    f0100ede <debuginfo_eip+0x25d>
		return -1;
f0100ebd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ec2:	eb 1a                	jmp    f0100ede <debuginfo_eip+0x25d>
f0100ec4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ec9:	eb 13                	jmp    f0100ede <debuginfo_eip+0x25d>
		return -1;
f0100ecb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ed0:	eb 0c                	jmp    f0100ede <debuginfo_eip+0x25d>
		return -1;
f0100ed2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ed7:	eb 05                	jmp    f0100ede <debuginfo_eip+0x25d>
	return 0;
f0100ed9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100ede:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ee1:	5b                   	pop    %ebx
f0100ee2:	5e                   	pop    %esi
f0100ee3:	5f                   	pop    %edi
f0100ee4:	5d                   	pop    %ebp
f0100ee5:	c3                   	ret    

f0100ee6 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100ee6:	55                   	push   %ebp
f0100ee7:	89 e5                	mov    %esp,%ebp
f0100ee9:	57                   	push   %edi
f0100eea:	56                   	push   %esi
f0100eeb:	53                   	push   %ebx
f0100eec:	83 ec 2c             	sub    $0x2c,%esp
f0100eef:	e8 28 06 00 00       	call   f010151c <__x86.get_pc_thunk.cx>
f0100ef4:	81 c1 14 14 01 00    	add    $0x11414,%ecx
f0100efa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100efd:	89 c7                	mov    %eax,%edi
f0100eff:	89 d6                	mov    %edx,%esi
f0100f01:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f04:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100f07:	89 d1                	mov    %edx,%ecx
f0100f09:	89 c2                	mov    %eax,%edx
f0100f0b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100f0e:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100f11:	8b 45 10             	mov    0x10(%ebp),%eax
f0100f14:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100f17:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f1a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100f21:	39 c2                	cmp    %eax,%edx
f0100f23:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0100f26:	72 41                	jb     f0100f69 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100f28:	83 ec 0c             	sub    $0xc,%esp
f0100f2b:	ff 75 18             	pushl  0x18(%ebp)
f0100f2e:	83 eb 01             	sub    $0x1,%ebx
f0100f31:	53                   	push   %ebx
f0100f32:	50                   	push   %eax
f0100f33:	83 ec 08             	sub    $0x8,%esp
f0100f36:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100f39:	ff 75 e0             	pushl  -0x20(%ebp)
f0100f3c:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100f3f:	ff 75 d0             	pushl  -0x30(%ebp)
f0100f42:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100f45:	e8 96 0a 00 00       	call   f01019e0 <__udivdi3>
f0100f4a:	83 c4 18             	add    $0x18,%esp
f0100f4d:	52                   	push   %edx
f0100f4e:	50                   	push   %eax
f0100f4f:	89 f2                	mov    %esi,%edx
f0100f51:	89 f8                	mov    %edi,%eax
f0100f53:	e8 8e ff ff ff       	call   f0100ee6 <printnum>
f0100f58:	83 c4 20             	add    $0x20,%esp
f0100f5b:	eb 13                	jmp    f0100f70 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100f5d:	83 ec 08             	sub    $0x8,%esp
f0100f60:	56                   	push   %esi
f0100f61:	ff 75 18             	pushl  0x18(%ebp)
f0100f64:	ff d7                	call   *%edi
f0100f66:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0100f69:	83 eb 01             	sub    $0x1,%ebx
f0100f6c:	85 db                	test   %ebx,%ebx
f0100f6e:	7f ed                	jg     f0100f5d <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100f70:	83 ec 08             	sub    $0x8,%esp
f0100f73:	56                   	push   %esi
f0100f74:	83 ec 04             	sub    $0x4,%esp
f0100f77:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100f7a:	ff 75 e0             	pushl  -0x20(%ebp)
f0100f7d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100f80:	ff 75 d0             	pushl  -0x30(%ebp)
f0100f83:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100f86:	e8 65 0b 00 00       	call   f0101af0 <__umoddi3>
f0100f8b:	83 c4 14             	add    $0x14,%esp
f0100f8e:	0f be 84 03 4e fe fe 	movsbl -0x101b2(%ebx,%eax,1),%eax
f0100f95:	ff 
f0100f96:	50                   	push   %eax
f0100f97:	ff d7                	call   *%edi
}
f0100f99:	83 c4 10             	add    $0x10,%esp
f0100f9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f9f:	5b                   	pop    %ebx
f0100fa0:	5e                   	pop    %esi
f0100fa1:	5f                   	pop    %edi
f0100fa2:	5d                   	pop    %ebp
f0100fa3:	c3                   	ret    

f0100fa4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100fa4:	f3 0f 1e fb          	endbr32 
f0100fa8:	55                   	push   %ebp
f0100fa9:	89 e5                	mov    %esp,%ebp
f0100fab:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100fae:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100fb2:	8b 10                	mov    (%eax),%edx
f0100fb4:	3b 50 04             	cmp    0x4(%eax),%edx
f0100fb7:	73 0a                	jae    f0100fc3 <sprintputch+0x1f>
		*b->buf++ = ch;
f0100fb9:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100fbc:	89 08                	mov    %ecx,(%eax)
f0100fbe:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fc1:	88 02                	mov    %al,(%edx)
}
f0100fc3:	5d                   	pop    %ebp
f0100fc4:	c3                   	ret    

f0100fc5 <printfmt>:
{
f0100fc5:	f3 0f 1e fb          	endbr32 
f0100fc9:	55                   	push   %ebp
f0100fca:	89 e5                	mov    %esp,%ebp
f0100fcc:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0100fcf:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100fd2:	50                   	push   %eax
f0100fd3:	ff 75 10             	pushl  0x10(%ebp)
f0100fd6:	ff 75 0c             	pushl  0xc(%ebp)
f0100fd9:	ff 75 08             	pushl  0x8(%ebp)
f0100fdc:	e8 05 00 00 00       	call   f0100fe6 <vprintfmt>
}
f0100fe1:	83 c4 10             	add    $0x10,%esp
f0100fe4:	c9                   	leave  
f0100fe5:	c3                   	ret    

f0100fe6 <vprintfmt>:
{
f0100fe6:	f3 0f 1e fb          	endbr32 
f0100fea:	55                   	push   %ebp
f0100feb:	89 e5                	mov    %esp,%ebp
f0100fed:	57                   	push   %edi
f0100fee:	56                   	push   %esi
f0100fef:	53                   	push   %ebx
f0100ff0:	83 ec 3c             	sub    $0x3c,%esp
f0100ff3:	e8 88 f7 ff ff       	call   f0100780 <__x86.get_pc_thunk.ax>
f0100ff8:	05 10 13 01 00       	add    $0x11310,%eax
f0100ffd:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101000:	8b 75 08             	mov    0x8(%ebp),%esi
f0101003:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101006:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0101009:	8d 80 3c 1d 00 00    	lea    0x1d3c(%eax),%eax
f010100f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0101012:	e9 cd 03 00 00       	jmp    f01013e4 <.L25+0x48>
		padc = ' ';
f0101017:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
f010101b:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
f0101022:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f0101029:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
f0101030:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101035:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0101038:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010103b:	8d 43 01             	lea    0x1(%ebx),%eax
f010103e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101041:	0f b6 13             	movzbl (%ebx),%edx
f0101044:	8d 42 dd             	lea    -0x23(%edx),%eax
f0101047:	3c 55                	cmp    $0x55,%al
f0101049:	0f 87 21 04 00 00    	ja     f0101470 <.L20>
f010104f:	0f b6 c0             	movzbl %al,%eax
f0101052:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101055:	89 ce                	mov    %ecx,%esi
f0101057:	03 b4 81 dc fe fe ff 	add    -0x10124(%ecx,%eax,4),%esi
f010105e:	3e ff e6             	notrack jmp *%esi

f0101061 <.L68>:
f0101061:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
f0101064:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
f0101068:	eb d1                	jmp    f010103b <vprintfmt+0x55>

f010106a <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
f010106a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010106d:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
f0101071:	eb c8                	jmp    f010103b <vprintfmt+0x55>

f0101073 <.L31>:
f0101073:	0f b6 d2             	movzbl %dl,%edx
f0101076:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
f0101079:	b8 00 00 00 00       	mov    $0x0,%eax
f010107e:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
f0101081:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0101084:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0101088:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f010108b:	8d 4a d0             	lea    -0x30(%edx),%ecx
f010108e:	83 f9 09             	cmp    $0x9,%ecx
f0101091:	77 58                	ja     f01010eb <.L36+0xf>
			for (precision = 0; ; ++fmt) {
f0101093:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f0101096:	eb e9                	jmp    f0101081 <.L31+0xe>

f0101098 <.L34>:
			precision = va_arg(ap, int);
f0101098:	8b 45 14             	mov    0x14(%ebp),%eax
f010109b:	8b 00                	mov    (%eax),%eax
f010109d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010a0:	8b 45 14             	mov    0x14(%ebp),%eax
f01010a3:	8d 40 04             	lea    0x4(%eax),%eax
f01010a6:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01010a9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
f01010ac:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01010b0:	79 89                	jns    f010103b <vprintfmt+0x55>
				width = precision, precision = -1;
f01010b2:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01010b5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01010b8:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f01010bf:	e9 77 ff ff ff       	jmp    f010103b <vprintfmt+0x55>

f01010c4 <.L33>:
f01010c4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01010c7:	85 c0                	test   %eax,%eax
f01010c9:	ba 00 00 00 00       	mov    $0x0,%edx
f01010ce:	0f 49 d0             	cmovns %eax,%edx
f01010d1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01010d4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f01010d7:	e9 5f ff ff ff       	jmp    f010103b <vprintfmt+0x55>

f01010dc <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
f01010dc:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
f01010df:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
f01010e6:	e9 50 ff ff ff       	jmp    f010103b <vprintfmt+0x55>
f01010eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010ee:	89 75 08             	mov    %esi,0x8(%ebp)
f01010f1:	eb b9                	jmp    f01010ac <.L34+0x14>

f01010f3 <.L27>:
			lflag++;
f01010f3:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01010f7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f01010fa:	e9 3c ff ff ff       	jmp    f010103b <vprintfmt+0x55>

f01010ff <.L30>:
f01010ff:	8b 75 08             	mov    0x8(%ebp),%esi
			putch(va_arg(ap, int), putdat);
f0101102:	8b 45 14             	mov    0x14(%ebp),%eax
f0101105:	8d 58 04             	lea    0x4(%eax),%ebx
f0101108:	83 ec 08             	sub    $0x8,%esp
f010110b:	57                   	push   %edi
f010110c:	ff 30                	pushl  (%eax)
f010110e:	ff d6                	call   *%esi
			break;
f0101110:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0101113:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f0101116:	e9 c6 02 00 00       	jmp    f01013e1 <.L25+0x45>

f010111b <.L28>:
f010111b:	8b 75 08             	mov    0x8(%ebp),%esi
			err = va_arg(ap, int);
f010111e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101121:	8d 58 04             	lea    0x4(%eax),%ebx
f0101124:	8b 00                	mov    (%eax),%eax
f0101126:	99                   	cltd   
f0101127:	31 d0                	xor    %edx,%eax
f0101129:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010112b:	83 f8 06             	cmp    $0x6,%eax
f010112e:	7f 27                	jg     f0101157 <.L28+0x3c>
f0101130:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0101133:	8b 14 82             	mov    (%edx,%eax,4),%edx
f0101136:	85 d2                	test   %edx,%edx
f0101138:	74 1d                	je     f0101157 <.L28+0x3c>
				printfmt(putch, putdat, "%s", p);
f010113a:	52                   	push   %edx
f010113b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010113e:	8d 80 6f fe fe ff    	lea    -0x10191(%eax),%eax
f0101144:	50                   	push   %eax
f0101145:	57                   	push   %edi
f0101146:	56                   	push   %esi
f0101147:	e8 79 fe ff ff       	call   f0100fc5 <printfmt>
f010114c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010114f:	89 5d 14             	mov    %ebx,0x14(%ebp)
f0101152:	e9 8a 02 00 00       	jmp    f01013e1 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
f0101157:	50                   	push   %eax
f0101158:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010115b:	8d 80 66 fe fe ff    	lea    -0x1019a(%eax),%eax
f0101161:	50                   	push   %eax
f0101162:	57                   	push   %edi
f0101163:	56                   	push   %esi
f0101164:	e8 5c fe ff ff       	call   f0100fc5 <printfmt>
f0101169:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010116c:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f010116f:	e9 6d 02 00 00       	jmp    f01013e1 <.L25+0x45>

f0101174 <.L24>:
f0101174:	8b 75 08             	mov    0x8(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
f0101177:	8b 45 14             	mov    0x14(%ebp),%eax
f010117a:	83 c0 04             	add    $0x4,%eax
f010117d:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0101180:	8b 45 14             	mov    0x14(%ebp),%eax
f0101183:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f0101185:	85 d2                	test   %edx,%edx
f0101187:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010118a:	8d 80 5f fe fe ff    	lea    -0x101a1(%eax),%eax
f0101190:	0f 45 c2             	cmovne %edx,%eax
f0101193:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f0101196:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010119a:	7e 06                	jle    f01011a2 <.L24+0x2e>
f010119c:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
f01011a0:	75 0d                	jne    f01011af <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
f01011a2:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01011a5:	89 c3                	mov    %eax,%ebx
f01011a7:	03 45 d4             	add    -0x2c(%ebp),%eax
f01011aa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01011ad:	eb 58                	jmp    f0101207 <.L24+0x93>
f01011af:	83 ec 08             	sub    $0x8,%esp
f01011b2:	ff 75 d8             	pushl  -0x28(%ebp)
f01011b5:	ff 75 c8             	pushl  -0x38(%ebp)
f01011b8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01011bb:	e8 85 04 00 00       	call   f0101645 <strnlen>
f01011c0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01011c3:	29 c2                	sub    %eax,%edx
f01011c5:	89 55 bc             	mov    %edx,-0x44(%ebp)
f01011c8:	83 c4 10             	add    $0x10,%esp
f01011cb:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
f01011cd:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f01011d1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f01011d4:	85 db                	test   %ebx,%ebx
f01011d6:	7e 11                	jle    f01011e9 <.L24+0x75>
					putch(padc, putdat);
f01011d8:	83 ec 08             	sub    $0x8,%esp
f01011db:	57                   	push   %edi
f01011dc:	ff 75 d4             	pushl  -0x2c(%ebp)
f01011df:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f01011e1:	83 eb 01             	sub    $0x1,%ebx
f01011e4:	83 c4 10             	add    $0x10,%esp
f01011e7:	eb eb                	jmp    f01011d4 <.L24+0x60>
f01011e9:	8b 55 bc             	mov    -0x44(%ebp),%edx
f01011ec:	85 d2                	test   %edx,%edx
f01011ee:	b8 00 00 00 00       	mov    $0x0,%eax
f01011f3:	0f 49 c2             	cmovns %edx,%eax
f01011f6:	29 c2                	sub    %eax,%edx
f01011f8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01011fb:	eb a5                	jmp    f01011a2 <.L24+0x2e>
					putch(ch, putdat);
f01011fd:	83 ec 08             	sub    $0x8,%esp
f0101200:	57                   	push   %edi
f0101201:	52                   	push   %edx
f0101202:	ff d6                	call   *%esi
f0101204:	83 c4 10             	add    $0x10,%esp
f0101207:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010120a:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010120c:	83 c3 01             	add    $0x1,%ebx
f010120f:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0101213:	0f be d0             	movsbl %al,%edx
f0101216:	85 d2                	test   %edx,%edx
f0101218:	74 4b                	je     f0101265 <.L24+0xf1>
f010121a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010121e:	78 06                	js     f0101226 <.L24+0xb2>
f0101220:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f0101224:	78 1e                	js     f0101244 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
f0101226:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f010122a:	74 d1                	je     f01011fd <.L24+0x89>
f010122c:	0f be c0             	movsbl %al,%eax
f010122f:	83 e8 20             	sub    $0x20,%eax
f0101232:	83 f8 5e             	cmp    $0x5e,%eax
f0101235:	76 c6                	jbe    f01011fd <.L24+0x89>
					putch('?', putdat);
f0101237:	83 ec 08             	sub    $0x8,%esp
f010123a:	57                   	push   %edi
f010123b:	6a 3f                	push   $0x3f
f010123d:	ff d6                	call   *%esi
f010123f:	83 c4 10             	add    $0x10,%esp
f0101242:	eb c3                	jmp    f0101207 <.L24+0x93>
f0101244:	89 cb                	mov    %ecx,%ebx
f0101246:	eb 0e                	jmp    f0101256 <.L24+0xe2>
				putch(' ', putdat);
f0101248:	83 ec 08             	sub    $0x8,%esp
f010124b:	57                   	push   %edi
f010124c:	6a 20                	push   $0x20
f010124e:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0101250:	83 eb 01             	sub    $0x1,%ebx
f0101253:	83 c4 10             	add    $0x10,%esp
f0101256:	85 db                	test   %ebx,%ebx
f0101258:	7f ee                	jg     f0101248 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
f010125a:	8b 45 c0             	mov    -0x40(%ebp),%eax
f010125d:	89 45 14             	mov    %eax,0x14(%ebp)
f0101260:	e9 7c 01 00 00       	jmp    f01013e1 <.L25+0x45>
f0101265:	89 cb                	mov    %ecx,%ebx
f0101267:	eb ed                	jmp    f0101256 <.L24+0xe2>

f0101269 <.L29>:
f0101269:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010126c:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f010126f:	83 f9 01             	cmp    $0x1,%ecx
f0101272:	7f 1b                	jg     f010128f <.L29+0x26>
	else if (lflag)
f0101274:	85 c9                	test   %ecx,%ecx
f0101276:	74 63                	je     f01012db <.L29+0x72>
		return va_arg(*ap, long);
f0101278:	8b 45 14             	mov    0x14(%ebp),%eax
f010127b:	8b 00                	mov    (%eax),%eax
f010127d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101280:	99                   	cltd   
f0101281:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101284:	8b 45 14             	mov    0x14(%ebp),%eax
f0101287:	8d 40 04             	lea    0x4(%eax),%eax
f010128a:	89 45 14             	mov    %eax,0x14(%ebp)
f010128d:	eb 17                	jmp    f01012a6 <.L29+0x3d>
		return va_arg(*ap, long long);
f010128f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101292:	8b 50 04             	mov    0x4(%eax),%edx
f0101295:	8b 00                	mov    (%eax),%eax
f0101297:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010129a:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010129d:	8b 45 14             	mov    0x14(%ebp),%eax
f01012a0:	8d 40 08             	lea    0x8(%eax),%eax
f01012a3:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f01012a6:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01012a9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f01012ac:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f01012b1:	85 c9                	test   %ecx,%ecx
f01012b3:	0f 89 0e 01 00 00    	jns    f01013c7 <.L25+0x2b>
				putch('-', putdat);
f01012b9:	83 ec 08             	sub    $0x8,%esp
f01012bc:	57                   	push   %edi
f01012bd:	6a 2d                	push   $0x2d
f01012bf:	ff d6                	call   *%esi
				num = -(long long) num;
f01012c1:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01012c4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01012c7:	f7 da                	neg    %edx
f01012c9:	83 d1 00             	adc    $0x0,%ecx
f01012cc:	f7 d9                	neg    %ecx
f01012ce:	83 c4 10             	add    $0x10,%esp
			base = 10;
f01012d1:	b8 0a 00 00 00       	mov    $0xa,%eax
f01012d6:	e9 ec 00 00 00       	jmp    f01013c7 <.L25+0x2b>
		return va_arg(*ap, int);
f01012db:	8b 45 14             	mov    0x14(%ebp),%eax
f01012de:	8b 00                	mov    (%eax),%eax
f01012e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01012e3:	99                   	cltd   
f01012e4:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01012e7:	8b 45 14             	mov    0x14(%ebp),%eax
f01012ea:	8d 40 04             	lea    0x4(%eax),%eax
f01012ed:	89 45 14             	mov    %eax,0x14(%ebp)
f01012f0:	eb b4                	jmp    f01012a6 <.L29+0x3d>

f01012f2 <.L23>:
f01012f2:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01012f5:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f01012f8:	83 f9 01             	cmp    $0x1,%ecx
f01012fb:	7f 1e                	jg     f010131b <.L23+0x29>
	else if (lflag)
f01012fd:	85 c9                	test   %ecx,%ecx
f01012ff:	74 32                	je     f0101333 <.L23+0x41>
		return va_arg(*ap, unsigned long);
f0101301:	8b 45 14             	mov    0x14(%ebp),%eax
f0101304:	8b 10                	mov    (%eax),%edx
f0101306:	b9 00 00 00 00       	mov    $0x0,%ecx
f010130b:	8d 40 04             	lea    0x4(%eax),%eax
f010130e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101311:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
f0101316:	e9 ac 00 00 00       	jmp    f01013c7 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f010131b:	8b 45 14             	mov    0x14(%ebp),%eax
f010131e:	8b 10                	mov    (%eax),%edx
f0101320:	8b 48 04             	mov    0x4(%eax),%ecx
f0101323:	8d 40 08             	lea    0x8(%eax),%eax
f0101326:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101329:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
f010132e:	e9 94 00 00 00       	jmp    f01013c7 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0101333:	8b 45 14             	mov    0x14(%ebp),%eax
f0101336:	8b 10                	mov    (%eax),%edx
f0101338:	b9 00 00 00 00       	mov    $0x0,%ecx
f010133d:	8d 40 04             	lea    0x4(%eax),%eax
f0101340:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101343:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
f0101348:	eb 7d                	jmp    f01013c7 <.L25+0x2b>

f010134a <.L26>:
f010134a:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010134d:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f0101350:	83 f9 01             	cmp    $0x1,%ecx
f0101353:	7f 1b                	jg     f0101370 <.L26+0x26>
	else if (lflag)
f0101355:	85 c9                	test   %ecx,%ecx
f0101357:	74 2c                	je     f0101385 <.L26+0x3b>
		return va_arg(*ap, unsigned long);
f0101359:	8b 45 14             	mov    0x14(%ebp),%eax
f010135c:	8b 10                	mov    (%eax),%edx
f010135e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101363:	8d 40 04             	lea    0x4(%eax),%eax
f0101366:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0101369:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
f010136e:	eb 57                	jmp    f01013c7 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0101370:	8b 45 14             	mov    0x14(%ebp),%eax
f0101373:	8b 10                	mov    (%eax),%edx
f0101375:	8b 48 04             	mov    0x4(%eax),%ecx
f0101378:	8d 40 08             	lea    0x8(%eax),%eax
f010137b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010137e:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
f0101383:	eb 42                	jmp    f01013c7 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0101385:	8b 45 14             	mov    0x14(%ebp),%eax
f0101388:	8b 10                	mov    (%eax),%edx
f010138a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010138f:	8d 40 04             	lea    0x4(%eax),%eax
f0101392:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0101395:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
f010139a:	eb 2b                	jmp    f01013c7 <.L25+0x2b>

f010139c <.L25>:
f010139c:	8b 75 08             	mov    0x8(%ebp),%esi
			putch('0', putdat);
f010139f:	83 ec 08             	sub    $0x8,%esp
f01013a2:	57                   	push   %edi
f01013a3:	6a 30                	push   $0x30
f01013a5:	ff d6                	call   *%esi
			putch('x', putdat);
f01013a7:	83 c4 08             	add    $0x8,%esp
f01013aa:	57                   	push   %edi
f01013ab:	6a 78                	push   $0x78
f01013ad:	ff d6                	call   *%esi
			num = (unsigned long long)
f01013af:	8b 45 14             	mov    0x14(%ebp),%eax
f01013b2:	8b 10                	mov    (%eax),%edx
f01013b4:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f01013b9:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f01013bc:	8d 40 04             	lea    0x4(%eax),%eax
f01013bf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01013c2:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f01013c7:	83 ec 0c             	sub    $0xc,%esp
f01013ca:	0f be 5d cf          	movsbl -0x31(%ebp),%ebx
f01013ce:	53                   	push   %ebx
f01013cf:	ff 75 d4             	pushl  -0x2c(%ebp)
f01013d2:	50                   	push   %eax
f01013d3:	51                   	push   %ecx
f01013d4:	52                   	push   %edx
f01013d5:	89 fa                	mov    %edi,%edx
f01013d7:	89 f0                	mov    %esi,%eax
f01013d9:	e8 08 fb ff ff       	call   f0100ee6 <printnum>
			break;
f01013de:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f01013e1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01013e4:	83 c3 01             	add    $0x1,%ebx
f01013e7:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f01013eb:	83 f8 25             	cmp    $0x25,%eax
f01013ee:	0f 84 23 fc ff ff    	je     f0101017 <vprintfmt+0x31>
			if (ch == '\0')
f01013f4:	85 c0                	test   %eax,%eax
f01013f6:	0f 84 97 00 00 00    	je     f0101493 <.L20+0x23>
			putch(ch, putdat);
f01013fc:	83 ec 08             	sub    $0x8,%esp
f01013ff:	57                   	push   %edi
f0101400:	50                   	push   %eax
f0101401:	ff d6                	call   *%esi
f0101403:	83 c4 10             	add    $0x10,%esp
f0101406:	eb dc                	jmp    f01013e4 <.L25+0x48>

f0101408 <.L21>:
f0101408:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010140b:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f010140e:	83 f9 01             	cmp    $0x1,%ecx
f0101411:	7f 1b                	jg     f010142e <.L21+0x26>
	else if (lflag)
f0101413:	85 c9                	test   %ecx,%ecx
f0101415:	74 2c                	je     f0101443 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
f0101417:	8b 45 14             	mov    0x14(%ebp),%eax
f010141a:	8b 10                	mov    (%eax),%edx
f010141c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101421:	8d 40 04             	lea    0x4(%eax),%eax
f0101424:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101427:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
f010142c:	eb 99                	jmp    f01013c7 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f010142e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101431:	8b 10                	mov    (%eax),%edx
f0101433:	8b 48 04             	mov    0x4(%eax),%ecx
f0101436:	8d 40 08             	lea    0x8(%eax),%eax
f0101439:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010143c:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
f0101441:	eb 84                	jmp    f01013c7 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0101443:	8b 45 14             	mov    0x14(%ebp),%eax
f0101446:	8b 10                	mov    (%eax),%edx
f0101448:	b9 00 00 00 00       	mov    $0x0,%ecx
f010144d:	8d 40 04             	lea    0x4(%eax),%eax
f0101450:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101453:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
f0101458:	e9 6a ff ff ff       	jmp    f01013c7 <.L25+0x2b>

f010145d <.L35>:
f010145d:	8b 75 08             	mov    0x8(%ebp),%esi
			putch(ch, putdat);
f0101460:	83 ec 08             	sub    $0x8,%esp
f0101463:	57                   	push   %edi
f0101464:	6a 25                	push   $0x25
f0101466:	ff d6                	call   *%esi
			break;
f0101468:	83 c4 10             	add    $0x10,%esp
f010146b:	e9 71 ff ff ff       	jmp    f01013e1 <.L25+0x45>

f0101470 <.L20>:
f0101470:	8b 75 08             	mov    0x8(%ebp),%esi
			putch('%', putdat);
f0101473:	83 ec 08             	sub    $0x8,%esp
f0101476:	57                   	push   %edi
f0101477:	6a 25                	push   $0x25
f0101479:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010147b:	83 c4 10             	add    $0x10,%esp
f010147e:	89 d8                	mov    %ebx,%eax
f0101480:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0101484:	74 05                	je     f010148b <.L20+0x1b>
f0101486:	83 e8 01             	sub    $0x1,%eax
f0101489:	eb f5                	jmp    f0101480 <.L20+0x10>
f010148b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010148e:	e9 4e ff ff ff       	jmp    f01013e1 <.L25+0x45>
}
f0101493:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101496:	5b                   	pop    %ebx
f0101497:	5e                   	pop    %esi
f0101498:	5f                   	pop    %edi
f0101499:	5d                   	pop    %ebp
f010149a:	c3                   	ret    

f010149b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010149b:	f3 0f 1e fb          	endbr32 
f010149f:	55                   	push   %ebp
f01014a0:	89 e5                	mov    %esp,%ebp
f01014a2:	53                   	push   %ebx
f01014a3:	83 ec 14             	sub    $0x14,%esp
f01014a6:	e8 21 ed ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f01014ab:	81 c3 5d 0e 01 00    	add    $0x10e5d,%ebx
f01014b1:	8b 45 08             	mov    0x8(%ebp),%eax
f01014b4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01014b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01014ba:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01014be:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01014c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01014c8:	85 c0                	test   %eax,%eax
f01014ca:	74 2b                	je     f01014f7 <vsnprintf+0x5c>
f01014cc:	85 d2                	test   %edx,%edx
f01014ce:	7e 27                	jle    f01014f7 <vsnprintf+0x5c>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01014d0:	ff 75 14             	pushl  0x14(%ebp)
f01014d3:	ff 75 10             	pushl  0x10(%ebp)
f01014d6:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01014d9:	50                   	push   %eax
f01014da:	8d 83 9c ec fe ff    	lea    -0x11364(%ebx),%eax
f01014e0:	50                   	push   %eax
f01014e1:	e8 00 fb ff ff       	call   f0100fe6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01014e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01014e9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01014ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01014ef:	83 c4 10             	add    $0x10,%esp
}
f01014f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01014f5:	c9                   	leave  
f01014f6:	c3                   	ret    
		return -E_INVAL;
f01014f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01014fc:	eb f4                	jmp    f01014f2 <vsnprintf+0x57>

f01014fe <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01014fe:	f3 0f 1e fb          	endbr32 
f0101502:	55                   	push   %ebp
f0101503:	89 e5                	mov    %esp,%ebp
f0101505:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101508:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010150b:	50                   	push   %eax
f010150c:	ff 75 10             	pushl  0x10(%ebp)
f010150f:	ff 75 0c             	pushl  0xc(%ebp)
f0101512:	ff 75 08             	pushl  0x8(%ebp)
f0101515:	e8 81 ff ff ff       	call   f010149b <vsnprintf>
	va_end(ap);

	return rc;
}
f010151a:	c9                   	leave  
f010151b:	c3                   	ret    

f010151c <__x86.get_pc_thunk.cx>:
f010151c:	8b 0c 24             	mov    (%esp),%ecx
f010151f:	c3                   	ret    

f0101520 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101520:	f3 0f 1e fb          	endbr32 
f0101524:	55                   	push   %ebp
f0101525:	89 e5                	mov    %esp,%ebp
f0101527:	57                   	push   %edi
f0101528:	56                   	push   %esi
f0101529:	53                   	push   %ebx
f010152a:	83 ec 1c             	sub    $0x1c,%esp
f010152d:	e8 9a ec ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f0101532:	81 c3 d6 0d 01 00    	add    $0x10dd6,%ebx
f0101538:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010153b:	85 c0                	test   %eax,%eax
f010153d:	74 13                	je     f0101552 <readline+0x32>
		cprintf("%s", prompt);
f010153f:	83 ec 08             	sub    $0x8,%esp
f0101542:	50                   	push   %eax
f0101543:	8d 83 6f fe fe ff    	lea    -0x10191(%ebx),%eax
f0101549:	50                   	push   %eax
f010154a:	e8 25 f6 ff ff       	call   f0100b74 <cprintf>
f010154f:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0101552:	83 ec 0c             	sub    $0xc,%esp
f0101555:	6a 00                	push   $0x0
f0101557:	e8 1a f2 ff ff       	call   f0100776 <iscons>
f010155c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010155f:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0101562:	bf 00 00 00 00       	mov    $0x0,%edi
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
			buf[i++] = c;
f0101567:	8d 83 98 1f 00 00    	lea    0x1f98(%ebx),%eax
f010156d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101570:	eb 51                	jmp    f01015c3 <readline+0xa3>
			cprintf("read error: %e\n", c);
f0101572:	83 ec 08             	sub    $0x8,%esp
f0101575:	50                   	push   %eax
f0101576:	8d 83 34 00 ff ff    	lea    -0xffcc(%ebx),%eax
f010157c:	50                   	push   %eax
f010157d:	e8 f2 f5 ff ff       	call   f0100b74 <cprintf>
			return NULL;
f0101582:	83 c4 10             	add    $0x10,%esp
f0101585:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f010158a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010158d:	5b                   	pop    %ebx
f010158e:	5e                   	pop    %esi
f010158f:	5f                   	pop    %edi
f0101590:	5d                   	pop    %ebp
f0101591:	c3                   	ret    
			if (echoing)
f0101592:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101596:	75 05                	jne    f010159d <readline+0x7d>
			i--;
f0101598:	83 ef 01             	sub    $0x1,%edi
f010159b:	eb 26                	jmp    f01015c3 <readline+0xa3>
				cputchar('\b');
f010159d:	83 ec 0c             	sub    $0xc,%esp
f01015a0:	6a 08                	push   $0x8
f01015a2:	e8 a6 f1 ff ff       	call   f010074d <cputchar>
f01015a7:	83 c4 10             	add    $0x10,%esp
f01015aa:	eb ec                	jmp    f0101598 <readline+0x78>
				cputchar(c);
f01015ac:	83 ec 0c             	sub    $0xc,%esp
f01015af:	56                   	push   %esi
f01015b0:	e8 98 f1 ff ff       	call   f010074d <cputchar>
f01015b5:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01015b8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01015bb:	89 f0                	mov    %esi,%eax
f01015bd:	88 04 39             	mov    %al,(%ecx,%edi,1)
f01015c0:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f01015c3:	e8 99 f1 ff ff       	call   f0100761 <getchar>
f01015c8:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f01015ca:	85 c0                	test   %eax,%eax
f01015cc:	78 a4                	js     f0101572 <readline+0x52>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01015ce:	83 f8 08             	cmp    $0x8,%eax
f01015d1:	0f 94 c2             	sete   %dl
f01015d4:	83 f8 7f             	cmp    $0x7f,%eax
f01015d7:	0f 94 c0             	sete   %al
f01015da:	08 c2                	or     %al,%dl
f01015dc:	74 04                	je     f01015e2 <readline+0xc2>
f01015de:	85 ff                	test   %edi,%edi
f01015e0:	7f b0                	jg     f0101592 <readline+0x72>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01015e2:	83 fe 1f             	cmp    $0x1f,%esi
f01015e5:	7e 10                	jle    f01015f7 <readline+0xd7>
f01015e7:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f01015ed:	7f 08                	jg     f01015f7 <readline+0xd7>
			if (echoing)
f01015ef:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01015f3:	74 c3                	je     f01015b8 <readline+0x98>
f01015f5:	eb b5                	jmp    f01015ac <readline+0x8c>
		} else if (c == '\n' || c == '\r') {
f01015f7:	83 fe 0a             	cmp    $0xa,%esi
f01015fa:	74 05                	je     f0101601 <readline+0xe1>
f01015fc:	83 fe 0d             	cmp    $0xd,%esi
f01015ff:	75 c2                	jne    f01015c3 <readline+0xa3>
			if (echoing)
f0101601:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101605:	75 13                	jne    f010161a <readline+0xfa>
			buf[i] = 0;
f0101607:	c6 84 3b 98 1f 00 00 	movb   $0x0,0x1f98(%ebx,%edi,1)
f010160e:	00 
			return buf;
f010160f:	8d 83 98 1f 00 00    	lea    0x1f98(%ebx),%eax
f0101615:	e9 70 ff ff ff       	jmp    f010158a <readline+0x6a>
				cputchar('\n');
f010161a:	83 ec 0c             	sub    $0xc,%esp
f010161d:	6a 0a                	push   $0xa
f010161f:	e8 29 f1 ff ff       	call   f010074d <cputchar>
f0101624:	83 c4 10             	add    $0x10,%esp
f0101627:	eb de                	jmp    f0101607 <readline+0xe7>

f0101629 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101629:	f3 0f 1e fb          	endbr32 
f010162d:	55                   	push   %ebp
f010162e:	89 e5                	mov    %esp,%ebp
f0101630:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101633:	b8 00 00 00 00       	mov    $0x0,%eax
f0101638:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010163c:	74 05                	je     f0101643 <strlen+0x1a>
		n++;
f010163e:	83 c0 01             	add    $0x1,%eax
f0101641:	eb f5                	jmp    f0101638 <strlen+0xf>
	return n;
}
f0101643:	5d                   	pop    %ebp
f0101644:	c3                   	ret    

f0101645 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101645:	f3 0f 1e fb          	endbr32 
f0101649:	55                   	push   %ebp
f010164a:	89 e5                	mov    %esp,%ebp
f010164c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010164f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101652:	b8 00 00 00 00       	mov    $0x0,%eax
f0101657:	39 d0                	cmp    %edx,%eax
f0101659:	74 0d                	je     f0101668 <strnlen+0x23>
f010165b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010165f:	74 05                	je     f0101666 <strnlen+0x21>
		n++;
f0101661:	83 c0 01             	add    $0x1,%eax
f0101664:	eb f1                	jmp    f0101657 <strnlen+0x12>
f0101666:	89 c2                	mov    %eax,%edx
	return n;
}
f0101668:	89 d0                	mov    %edx,%eax
f010166a:	5d                   	pop    %ebp
f010166b:	c3                   	ret    

f010166c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010166c:	f3 0f 1e fb          	endbr32 
f0101670:	55                   	push   %ebp
f0101671:	89 e5                	mov    %esp,%ebp
f0101673:	53                   	push   %ebx
f0101674:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101677:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010167a:	b8 00 00 00 00       	mov    $0x0,%eax
f010167f:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f0101683:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f0101686:	83 c0 01             	add    $0x1,%eax
f0101689:	84 d2                	test   %dl,%dl
f010168b:	75 f2                	jne    f010167f <strcpy+0x13>
		/* do nothing */;
	return ret;
}
f010168d:	89 c8                	mov    %ecx,%eax
f010168f:	5b                   	pop    %ebx
f0101690:	5d                   	pop    %ebp
f0101691:	c3                   	ret    

f0101692 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0101692:	f3 0f 1e fb          	endbr32 
f0101696:	55                   	push   %ebp
f0101697:	89 e5                	mov    %esp,%ebp
f0101699:	53                   	push   %ebx
f010169a:	83 ec 10             	sub    $0x10,%esp
f010169d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01016a0:	53                   	push   %ebx
f01016a1:	e8 83 ff ff ff       	call   f0101629 <strlen>
f01016a6:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f01016a9:	ff 75 0c             	pushl  0xc(%ebp)
f01016ac:	01 d8                	add    %ebx,%eax
f01016ae:	50                   	push   %eax
f01016af:	e8 b8 ff ff ff       	call   f010166c <strcpy>
	return dst;
}
f01016b4:	89 d8                	mov    %ebx,%eax
f01016b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01016b9:	c9                   	leave  
f01016ba:	c3                   	ret    

f01016bb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01016bb:	f3 0f 1e fb          	endbr32 
f01016bf:	55                   	push   %ebp
f01016c0:	89 e5                	mov    %esp,%ebp
f01016c2:	56                   	push   %esi
f01016c3:	53                   	push   %ebx
f01016c4:	8b 75 08             	mov    0x8(%ebp),%esi
f01016c7:	8b 55 0c             	mov    0xc(%ebp),%edx
f01016ca:	89 f3                	mov    %esi,%ebx
f01016cc:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01016cf:	89 f0                	mov    %esi,%eax
f01016d1:	39 d8                	cmp    %ebx,%eax
f01016d3:	74 11                	je     f01016e6 <strncpy+0x2b>
		*dst++ = *src;
f01016d5:	83 c0 01             	add    $0x1,%eax
f01016d8:	0f b6 0a             	movzbl (%edx),%ecx
f01016db:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01016de:	80 f9 01             	cmp    $0x1,%cl
f01016e1:	83 da ff             	sbb    $0xffffffff,%edx
f01016e4:	eb eb                	jmp    f01016d1 <strncpy+0x16>
	}
	return ret;
}
f01016e6:	89 f0                	mov    %esi,%eax
f01016e8:	5b                   	pop    %ebx
f01016e9:	5e                   	pop    %esi
f01016ea:	5d                   	pop    %ebp
f01016eb:	c3                   	ret    

f01016ec <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01016ec:	f3 0f 1e fb          	endbr32 
f01016f0:	55                   	push   %ebp
f01016f1:	89 e5                	mov    %esp,%ebp
f01016f3:	56                   	push   %esi
f01016f4:	53                   	push   %ebx
f01016f5:	8b 75 08             	mov    0x8(%ebp),%esi
f01016f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01016fb:	8b 55 10             	mov    0x10(%ebp),%edx
f01016fe:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101700:	85 d2                	test   %edx,%edx
f0101702:	74 21                	je     f0101725 <strlcpy+0x39>
f0101704:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0101708:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f010170a:	39 c2                	cmp    %eax,%edx
f010170c:	74 14                	je     f0101722 <strlcpy+0x36>
f010170e:	0f b6 19             	movzbl (%ecx),%ebx
f0101711:	84 db                	test   %bl,%bl
f0101713:	74 0b                	je     f0101720 <strlcpy+0x34>
			*dst++ = *src++;
f0101715:	83 c1 01             	add    $0x1,%ecx
f0101718:	83 c2 01             	add    $0x1,%edx
f010171b:	88 5a ff             	mov    %bl,-0x1(%edx)
f010171e:	eb ea                	jmp    f010170a <strlcpy+0x1e>
f0101720:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0101722:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101725:	29 f0                	sub    %esi,%eax
}
f0101727:	5b                   	pop    %ebx
f0101728:	5e                   	pop    %esi
f0101729:	5d                   	pop    %ebp
f010172a:	c3                   	ret    

f010172b <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010172b:	f3 0f 1e fb          	endbr32 
f010172f:	55                   	push   %ebp
f0101730:	89 e5                	mov    %esp,%ebp
f0101732:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101735:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101738:	0f b6 01             	movzbl (%ecx),%eax
f010173b:	84 c0                	test   %al,%al
f010173d:	74 0c                	je     f010174b <strcmp+0x20>
f010173f:	3a 02                	cmp    (%edx),%al
f0101741:	75 08                	jne    f010174b <strcmp+0x20>
		p++, q++;
f0101743:	83 c1 01             	add    $0x1,%ecx
f0101746:	83 c2 01             	add    $0x1,%edx
f0101749:	eb ed                	jmp    f0101738 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010174b:	0f b6 c0             	movzbl %al,%eax
f010174e:	0f b6 12             	movzbl (%edx),%edx
f0101751:	29 d0                	sub    %edx,%eax
}
f0101753:	5d                   	pop    %ebp
f0101754:	c3                   	ret    

f0101755 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101755:	f3 0f 1e fb          	endbr32 
f0101759:	55                   	push   %ebp
f010175a:	89 e5                	mov    %esp,%ebp
f010175c:	53                   	push   %ebx
f010175d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101760:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101763:	89 c3                	mov    %eax,%ebx
f0101765:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0101768:	eb 06                	jmp    f0101770 <strncmp+0x1b>
		n--, p++, q++;
f010176a:	83 c0 01             	add    $0x1,%eax
f010176d:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0101770:	39 d8                	cmp    %ebx,%eax
f0101772:	74 16                	je     f010178a <strncmp+0x35>
f0101774:	0f b6 08             	movzbl (%eax),%ecx
f0101777:	84 c9                	test   %cl,%cl
f0101779:	74 04                	je     f010177f <strncmp+0x2a>
f010177b:	3a 0a                	cmp    (%edx),%cl
f010177d:	74 eb                	je     f010176a <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010177f:	0f b6 00             	movzbl (%eax),%eax
f0101782:	0f b6 12             	movzbl (%edx),%edx
f0101785:	29 d0                	sub    %edx,%eax
}
f0101787:	5b                   	pop    %ebx
f0101788:	5d                   	pop    %ebp
f0101789:	c3                   	ret    
		return 0;
f010178a:	b8 00 00 00 00       	mov    $0x0,%eax
f010178f:	eb f6                	jmp    f0101787 <strncmp+0x32>

f0101791 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101791:	f3 0f 1e fb          	endbr32 
f0101795:	55                   	push   %ebp
f0101796:	89 e5                	mov    %esp,%ebp
f0101798:	8b 45 08             	mov    0x8(%ebp),%eax
f010179b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010179f:	0f b6 10             	movzbl (%eax),%edx
f01017a2:	84 d2                	test   %dl,%dl
f01017a4:	74 09                	je     f01017af <strchr+0x1e>
		if (*s == c)
f01017a6:	38 ca                	cmp    %cl,%dl
f01017a8:	74 0a                	je     f01017b4 <strchr+0x23>
	for (; *s; s++)
f01017aa:	83 c0 01             	add    $0x1,%eax
f01017ad:	eb f0                	jmp    f010179f <strchr+0xe>
			return (char *) s;
	return 0;
f01017af:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01017b4:	5d                   	pop    %ebp
f01017b5:	c3                   	ret    

f01017b6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01017b6:	f3 0f 1e fb          	endbr32 
f01017ba:	55                   	push   %ebp
f01017bb:	89 e5                	mov    %esp,%ebp
f01017bd:	8b 45 08             	mov    0x8(%ebp),%eax
f01017c0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01017c4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01017c7:	38 ca                	cmp    %cl,%dl
f01017c9:	74 09                	je     f01017d4 <strfind+0x1e>
f01017cb:	84 d2                	test   %dl,%dl
f01017cd:	74 05                	je     f01017d4 <strfind+0x1e>
	for (; *s; s++)
f01017cf:	83 c0 01             	add    $0x1,%eax
f01017d2:	eb f0                	jmp    f01017c4 <strfind+0xe>
			break;
	return (char *) s;
}
f01017d4:	5d                   	pop    %ebp
f01017d5:	c3                   	ret    

f01017d6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01017d6:	f3 0f 1e fb          	endbr32 
f01017da:	55                   	push   %ebp
f01017db:	89 e5                	mov    %esp,%ebp
f01017dd:	57                   	push   %edi
f01017de:	56                   	push   %esi
f01017df:	53                   	push   %ebx
f01017e0:	8b 7d 08             	mov    0x8(%ebp),%edi
f01017e3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01017e6:	85 c9                	test   %ecx,%ecx
f01017e8:	74 31                	je     f010181b <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01017ea:	89 f8                	mov    %edi,%eax
f01017ec:	09 c8                	or     %ecx,%eax
f01017ee:	a8 03                	test   $0x3,%al
f01017f0:	75 23                	jne    f0101815 <memset+0x3f>
		c &= 0xFF;
f01017f2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01017f6:	89 d3                	mov    %edx,%ebx
f01017f8:	c1 e3 08             	shl    $0x8,%ebx
f01017fb:	89 d0                	mov    %edx,%eax
f01017fd:	c1 e0 18             	shl    $0x18,%eax
f0101800:	89 d6                	mov    %edx,%esi
f0101802:	c1 e6 10             	shl    $0x10,%esi
f0101805:	09 f0                	or     %esi,%eax
f0101807:	09 c2                	or     %eax,%edx
f0101809:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010180b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f010180e:	89 d0                	mov    %edx,%eax
f0101810:	fc                   	cld    
f0101811:	f3 ab                	rep stos %eax,%es:(%edi)
f0101813:	eb 06                	jmp    f010181b <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101815:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101818:	fc                   	cld    
f0101819:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010181b:	89 f8                	mov    %edi,%eax
f010181d:	5b                   	pop    %ebx
f010181e:	5e                   	pop    %esi
f010181f:	5f                   	pop    %edi
f0101820:	5d                   	pop    %ebp
f0101821:	c3                   	ret    

f0101822 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101822:	f3 0f 1e fb          	endbr32 
f0101826:	55                   	push   %ebp
f0101827:	89 e5                	mov    %esp,%ebp
f0101829:	57                   	push   %edi
f010182a:	56                   	push   %esi
f010182b:	8b 45 08             	mov    0x8(%ebp),%eax
f010182e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101831:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101834:	39 c6                	cmp    %eax,%esi
f0101836:	73 32                	jae    f010186a <memmove+0x48>
f0101838:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010183b:	39 c2                	cmp    %eax,%edx
f010183d:	76 2b                	jbe    f010186a <memmove+0x48>
		s += n;
		d += n;
f010183f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101842:	89 fe                	mov    %edi,%esi
f0101844:	09 ce                	or     %ecx,%esi
f0101846:	09 d6                	or     %edx,%esi
f0101848:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010184e:	75 0e                	jne    f010185e <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0101850:	83 ef 04             	sub    $0x4,%edi
f0101853:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101856:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0101859:	fd                   	std    
f010185a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010185c:	eb 09                	jmp    f0101867 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010185e:	83 ef 01             	sub    $0x1,%edi
f0101861:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0101864:	fd                   	std    
f0101865:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101867:	fc                   	cld    
f0101868:	eb 1a                	jmp    f0101884 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010186a:	89 c2                	mov    %eax,%edx
f010186c:	09 ca                	or     %ecx,%edx
f010186e:	09 f2                	or     %esi,%edx
f0101870:	f6 c2 03             	test   $0x3,%dl
f0101873:	75 0a                	jne    f010187f <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0101875:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0101878:	89 c7                	mov    %eax,%edi
f010187a:	fc                   	cld    
f010187b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010187d:	eb 05                	jmp    f0101884 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
f010187f:	89 c7                	mov    %eax,%edi
f0101881:	fc                   	cld    
f0101882:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101884:	5e                   	pop    %esi
f0101885:	5f                   	pop    %edi
f0101886:	5d                   	pop    %ebp
f0101887:	c3                   	ret    

f0101888 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101888:	f3 0f 1e fb          	endbr32 
f010188c:	55                   	push   %ebp
f010188d:	89 e5                	mov    %esp,%ebp
f010188f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0101892:	ff 75 10             	pushl  0x10(%ebp)
f0101895:	ff 75 0c             	pushl  0xc(%ebp)
f0101898:	ff 75 08             	pushl  0x8(%ebp)
f010189b:	e8 82 ff ff ff       	call   f0101822 <memmove>
}
f01018a0:	c9                   	leave  
f01018a1:	c3                   	ret    

f01018a2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01018a2:	f3 0f 1e fb          	endbr32 
f01018a6:	55                   	push   %ebp
f01018a7:	89 e5                	mov    %esp,%ebp
f01018a9:	56                   	push   %esi
f01018aa:	53                   	push   %ebx
f01018ab:	8b 45 08             	mov    0x8(%ebp),%eax
f01018ae:	8b 55 0c             	mov    0xc(%ebp),%edx
f01018b1:	89 c6                	mov    %eax,%esi
f01018b3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01018b6:	39 f0                	cmp    %esi,%eax
f01018b8:	74 1c                	je     f01018d6 <memcmp+0x34>
		if (*s1 != *s2)
f01018ba:	0f b6 08             	movzbl (%eax),%ecx
f01018bd:	0f b6 1a             	movzbl (%edx),%ebx
f01018c0:	38 d9                	cmp    %bl,%cl
f01018c2:	75 08                	jne    f01018cc <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01018c4:	83 c0 01             	add    $0x1,%eax
f01018c7:	83 c2 01             	add    $0x1,%edx
f01018ca:	eb ea                	jmp    f01018b6 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
f01018cc:	0f b6 c1             	movzbl %cl,%eax
f01018cf:	0f b6 db             	movzbl %bl,%ebx
f01018d2:	29 d8                	sub    %ebx,%eax
f01018d4:	eb 05                	jmp    f01018db <memcmp+0x39>
	}

	return 0;
f01018d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01018db:	5b                   	pop    %ebx
f01018dc:	5e                   	pop    %esi
f01018dd:	5d                   	pop    %ebp
f01018de:	c3                   	ret    

f01018df <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01018df:	f3 0f 1e fb          	endbr32 
f01018e3:	55                   	push   %ebp
f01018e4:	89 e5                	mov    %esp,%ebp
f01018e6:	8b 45 08             	mov    0x8(%ebp),%eax
f01018e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01018ec:	89 c2                	mov    %eax,%edx
f01018ee:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01018f1:	39 d0                	cmp    %edx,%eax
f01018f3:	73 09                	jae    f01018fe <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
f01018f5:	38 08                	cmp    %cl,(%eax)
f01018f7:	74 05                	je     f01018fe <memfind+0x1f>
	for (; s < ends; s++)
f01018f9:	83 c0 01             	add    $0x1,%eax
f01018fc:	eb f3                	jmp    f01018f1 <memfind+0x12>
			break;
	return (void *) s;
}
f01018fe:	5d                   	pop    %ebp
f01018ff:	c3                   	ret    

f0101900 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101900:	f3 0f 1e fb          	endbr32 
f0101904:	55                   	push   %ebp
f0101905:	89 e5                	mov    %esp,%ebp
f0101907:	57                   	push   %edi
f0101908:	56                   	push   %esi
f0101909:	53                   	push   %ebx
f010190a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010190d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101910:	eb 03                	jmp    f0101915 <strtol+0x15>
		s++;
f0101912:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0101915:	0f b6 01             	movzbl (%ecx),%eax
f0101918:	3c 20                	cmp    $0x20,%al
f010191a:	74 f6                	je     f0101912 <strtol+0x12>
f010191c:	3c 09                	cmp    $0x9,%al
f010191e:	74 f2                	je     f0101912 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
f0101920:	3c 2b                	cmp    $0x2b,%al
f0101922:	74 2a                	je     f010194e <strtol+0x4e>
	int neg = 0;
f0101924:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0101929:	3c 2d                	cmp    $0x2d,%al
f010192b:	74 2b                	je     f0101958 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010192d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101933:	75 0f                	jne    f0101944 <strtol+0x44>
f0101935:	80 39 30             	cmpb   $0x30,(%ecx)
f0101938:	74 28                	je     f0101962 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010193a:	85 db                	test   %ebx,%ebx
f010193c:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101941:	0f 44 d8             	cmove  %eax,%ebx
f0101944:	b8 00 00 00 00       	mov    $0x0,%eax
f0101949:	89 5d 10             	mov    %ebx,0x10(%ebp)
f010194c:	eb 46                	jmp    f0101994 <strtol+0x94>
		s++;
f010194e:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0101951:	bf 00 00 00 00       	mov    $0x0,%edi
f0101956:	eb d5                	jmp    f010192d <strtol+0x2d>
		s++, neg = 1;
f0101958:	83 c1 01             	add    $0x1,%ecx
f010195b:	bf 01 00 00 00       	mov    $0x1,%edi
f0101960:	eb cb                	jmp    f010192d <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101962:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0101966:	74 0e                	je     f0101976 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f0101968:	85 db                	test   %ebx,%ebx
f010196a:	75 d8                	jne    f0101944 <strtol+0x44>
		s++, base = 8;
f010196c:	83 c1 01             	add    $0x1,%ecx
f010196f:	bb 08 00 00 00       	mov    $0x8,%ebx
f0101974:	eb ce                	jmp    f0101944 <strtol+0x44>
		s += 2, base = 16;
f0101976:	83 c1 02             	add    $0x2,%ecx
f0101979:	bb 10 00 00 00       	mov    $0x10,%ebx
f010197e:	eb c4                	jmp    f0101944 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f0101980:	0f be d2             	movsbl %dl,%edx
f0101983:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0101986:	3b 55 10             	cmp    0x10(%ebp),%edx
f0101989:	7d 3a                	jge    f01019c5 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f010198b:	83 c1 01             	add    $0x1,%ecx
f010198e:	0f af 45 10          	imul   0x10(%ebp),%eax
f0101992:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0101994:	0f b6 11             	movzbl (%ecx),%edx
f0101997:	8d 72 d0             	lea    -0x30(%edx),%esi
f010199a:	89 f3                	mov    %esi,%ebx
f010199c:	80 fb 09             	cmp    $0x9,%bl
f010199f:	76 df                	jbe    f0101980 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
f01019a1:	8d 72 9f             	lea    -0x61(%edx),%esi
f01019a4:	89 f3                	mov    %esi,%ebx
f01019a6:	80 fb 19             	cmp    $0x19,%bl
f01019a9:	77 08                	ja     f01019b3 <strtol+0xb3>
			dig = *s - 'a' + 10;
f01019ab:	0f be d2             	movsbl %dl,%edx
f01019ae:	83 ea 57             	sub    $0x57,%edx
f01019b1:	eb d3                	jmp    f0101986 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
f01019b3:	8d 72 bf             	lea    -0x41(%edx),%esi
f01019b6:	89 f3                	mov    %esi,%ebx
f01019b8:	80 fb 19             	cmp    $0x19,%bl
f01019bb:	77 08                	ja     f01019c5 <strtol+0xc5>
			dig = *s - 'A' + 10;
f01019bd:	0f be d2             	movsbl %dl,%edx
f01019c0:	83 ea 37             	sub    $0x37,%edx
f01019c3:	eb c1                	jmp    f0101986 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
f01019c5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01019c9:	74 05                	je     f01019d0 <strtol+0xd0>
		*endptr = (char *) s;
f01019cb:	8b 75 0c             	mov    0xc(%ebp),%esi
f01019ce:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f01019d0:	89 c2                	mov    %eax,%edx
f01019d2:	f7 da                	neg    %edx
f01019d4:	85 ff                	test   %edi,%edi
f01019d6:	0f 45 c2             	cmovne %edx,%eax
}
f01019d9:	5b                   	pop    %ebx
f01019da:	5e                   	pop    %esi
f01019db:	5f                   	pop    %edi
f01019dc:	5d                   	pop    %ebp
f01019dd:	c3                   	ret    
f01019de:	66 90                	xchg   %ax,%ax

f01019e0 <__udivdi3>:
f01019e0:	f3 0f 1e fb          	endbr32 
f01019e4:	55                   	push   %ebp
f01019e5:	57                   	push   %edi
f01019e6:	56                   	push   %esi
f01019e7:	53                   	push   %ebx
f01019e8:	83 ec 1c             	sub    $0x1c,%esp
f01019eb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01019ef:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f01019f3:	8b 74 24 34          	mov    0x34(%esp),%esi
f01019f7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f01019fb:	85 d2                	test   %edx,%edx
f01019fd:	75 19                	jne    f0101a18 <__udivdi3+0x38>
f01019ff:	39 f3                	cmp    %esi,%ebx
f0101a01:	76 4d                	jbe    f0101a50 <__udivdi3+0x70>
f0101a03:	31 ff                	xor    %edi,%edi
f0101a05:	89 e8                	mov    %ebp,%eax
f0101a07:	89 f2                	mov    %esi,%edx
f0101a09:	f7 f3                	div    %ebx
f0101a0b:	89 fa                	mov    %edi,%edx
f0101a0d:	83 c4 1c             	add    $0x1c,%esp
f0101a10:	5b                   	pop    %ebx
f0101a11:	5e                   	pop    %esi
f0101a12:	5f                   	pop    %edi
f0101a13:	5d                   	pop    %ebp
f0101a14:	c3                   	ret    
f0101a15:	8d 76 00             	lea    0x0(%esi),%esi
f0101a18:	39 f2                	cmp    %esi,%edx
f0101a1a:	76 14                	jbe    f0101a30 <__udivdi3+0x50>
f0101a1c:	31 ff                	xor    %edi,%edi
f0101a1e:	31 c0                	xor    %eax,%eax
f0101a20:	89 fa                	mov    %edi,%edx
f0101a22:	83 c4 1c             	add    $0x1c,%esp
f0101a25:	5b                   	pop    %ebx
f0101a26:	5e                   	pop    %esi
f0101a27:	5f                   	pop    %edi
f0101a28:	5d                   	pop    %ebp
f0101a29:	c3                   	ret    
f0101a2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101a30:	0f bd fa             	bsr    %edx,%edi
f0101a33:	83 f7 1f             	xor    $0x1f,%edi
f0101a36:	75 48                	jne    f0101a80 <__udivdi3+0xa0>
f0101a38:	39 f2                	cmp    %esi,%edx
f0101a3a:	72 06                	jb     f0101a42 <__udivdi3+0x62>
f0101a3c:	31 c0                	xor    %eax,%eax
f0101a3e:	39 eb                	cmp    %ebp,%ebx
f0101a40:	77 de                	ja     f0101a20 <__udivdi3+0x40>
f0101a42:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a47:	eb d7                	jmp    f0101a20 <__udivdi3+0x40>
f0101a49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101a50:	89 d9                	mov    %ebx,%ecx
f0101a52:	85 db                	test   %ebx,%ebx
f0101a54:	75 0b                	jne    f0101a61 <__udivdi3+0x81>
f0101a56:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a5b:	31 d2                	xor    %edx,%edx
f0101a5d:	f7 f3                	div    %ebx
f0101a5f:	89 c1                	mov    %eax,%ecx
f0101a61:	31 d2                	xor    %edx,%edx
f0101a63:	89 f0                	mov    %esi,%eax
f0101a65:	f7 f1                	div    %ecx
f0101a67:	89 c6                	mov    %eax,%esi
f0101a69:	89 e8                	mov    %ebp,%eax
f0101a6b:	89 f7                	mov    %esi,%edi
f0101a6d:	f7 f1                	div    %ecx
f0101a6f:	89 fa                	mov    %edi,%edx
f0101a71:	83 c4 1c             	add    $0x1c,%esp
f0101a74:	5b                   	pop    %ebx
f0101a75:	5e                   	pop    %esi
f0101a76:	5f                   	pop    %edi
f0101a77:	5d                   	pop    %ebp
f0101a78:	c3                   	ret    
f0101a79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101a80:	89 f9                	mov    %edi,%ecx
f0101a82:	b8 20 00 00 00       	mov    $0x20,%eax
f0101a87:	29 f8                	sub    %edi,%eax
f0101a89:	d3 e2                	shl    %cl,%edx
f0101a8b:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101a8f:	89 c1                	mov    %eax,%ecx
f0101a91:	89 da                	mov    %ebx,%edx
f0101a93:	d3 ea                	shr    %cl,%edx
f0101a95:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101a99:	09 d1                	or     %edx,%ecx
f0101a9b:	89 f2                	mov    %esi,%edx
f0101a9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101aa1:	89 f9                	mov    %edi,%ecx
f0101aa3:	d3 e3                	shl    %cl,%ebx
f0101aa5:	89 c1                	mov    %eax,%ecx
f0101aa7:	d3 ea                	shr    %cl,%edx
f0101aa9:	89 f9                	mov    %edi,%ecx
f0101aab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101aaf:	89 eb                	mov    %ebp,%ebx
f0101ab1:	d3 e6                	shl    %cl,%esi
f0101ab3:	89 c1                	mov    %eax,%ecx
f0101ab5:	d3 eb                	shr    %cl,%ebx
f0101ab7:	09 de                	or     %ebx,%esi
f0101ab9:	89 f0                	mov    %esi,%eax
f0101abb:	f7 74 24 08          	divl   0x8(%esp)
f0101abf:	89 d6                	mov    %edx,%esi
f0101ac1:	89 c3                	mov    %eax,%ebx
f0101ac3:	f7 64 24 0c          	mull   0xc(%esp)
f0101ac7:	39 d6                	cmp    %edx,%esi
f0101ac9:	72 15                	jb     f0101ae0 <__udivdi3+0x100>
f0101acb:	89 f9                	mov    %edi,%ecx
f0101acd:	d3 e5                	shl    %cl,%ebp
f0101acf:	39 c5                	cmp    %eax,%ebp
f0101ad1:	73 04                	jae    f0101ad7 <__udivdi3+0xf7>
f0101ad3:	39 d6                	cmp    %edx,%esi
f0101ad5:	74 09                	je     f0101ae0 <__udivdi3+0x100>
f0101ad7:	89 d8                	mov    %ebx,%eax
f0101ad9:	31 ff                	xor    %edi,%edi
f0101adb:	e9 40 ff ff ff       	jmp    f0101a20 <__udivdi3+0x40>
f0101ae0:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0101ae3:	31 ff                	xor    %edi,%edi
f0101ae5:	e9 36 ff ff ff       	jmp    f0101a20 <__udivdi3+0x40>
f0101aea:	66 90                	xchg   %ax,%ax
f0101aec:	66 90                	xchg   %ax,%ax
f0101aee:	66 90                	xchg   %ax,%ax

f0101af0 <__umoddi3>:
f0101af0:	f3 0f 1e fb          	endbr32 
f0101af4:	55                   	push   %ebp
f0101af5:	57                   	push   %edi
f0101af6:	56                   	push   %esi
f0101af7:	53                   	push   %ebx
f0101af8:	83 ec 1c             	sub    $0x1c,%esp
f0101afb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f0101aff:	8b 74 24 30          	mov    0x30(%esp),%esi
f0101b03:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0101b07:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101b0b:	85 c0                	test   %eax,%eax
f0101b0d:	75 19                	jne    f0101b28 <__umoddi3+0x38>
f0101b0f:	39 df                	cmp    %ebx,%edi
f0101b11:	76 5d                	jbe    f0101b70 <__umoddi3+0x80>
f0101b13:	89 f0                	mov    %esi,%eax
f0101b15:	89 da                	mov    %ebx,%edx
f0101b17:	f7 f7                	div    %edi
f0101b19:	89 d0                	mov    %edx,%eax
f0101b1b:	31 d2                	xor    %edx,%edx
f0101b1d:	83 c4 1c             	add    $0x1c,%esp
f0101b20:	5b                   	pop    %ebx
f0101b21:	5e                   	pop    %esi
f0101b22:	5f                   	pop    %edi
f0101b23:	5d                   	pop    %ebp
f0101b24:	c3                   	ret    
f0101b25:	8d 76 00             	lea    0x0(%esi),%esi
f0101b28:	89 f2                	mov    %esi,%edx
f0101b2a:	39 d8                	cmp    %ebx,%eax
f0101b2c:	76 12                	jbe    f0101b40 <__umoddi3+0x50>
f0101b2e:	89 f0                	mov    %esi,%eax
f0101b30:	89 da                	mov    %ebx,%edx
f0101b32:	83 c4 1c             	add    $0x1c,%esp
f0101b35:	5b                   	pop    %ebx
f0101b36:	5e                   	pop    %esi
f0101b37:	5f                   	pop    %edi
f0101b38:	5d                   	pop    %ebp
f0101b39:	c3                   	ret    
f0101b3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101b40:	0f bd e8             	bsr    %eax,%ebp
f0101b43:	83 f5 1f             	xor    $0x1f,%ebp
f0101b46:	75 50                	jne    f0101b98 <__umoddi3+0xa8>
f0101b48:	39 d8                	cmp    %ebx,%eax
f0101b4a:	0f 82 e0 00 00 00    	jb     f0101c30 <__umoddi3+0x140>
f0101b50:	89 d9                	mov    %ebx,%ecx
f0101b52:	39 f7                	cmp    %esi,%edi
f0101b54:	0f 86 d6 00 00 00    	jbe    f0101c30 <__umoddi3+0x140>
f0101b5a:	89 d0                	mov    %edx,%eax
f0101b5c:	89 ca                	mov    %ecx,%edx
f0101b5e:	83 c4 1c             	add    $0x1c,%esp
f0101b61:	5b                   	pop    %ebx
f0101b62:	5e                   	pop    %esi
f0101b63:	5f                   	pop    %edi
f0101b64:	5d                   	pop    %ebp
f0101b65:	c3                   	ret    
f0101b66:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101b6d:	8d 76 00             	lea    0x0(%esi),%esi
f0101b70:	89 fd                	mov    %edi,%ebp
f0101b72:	85 ff                	test   %edi,%edi
f0101b74:	75 0b                	jne    f0101b81 <__umoddi3+0x91>
f0101b76:	b8 01 00 00 00       	mov    $0x1,%eax
f0101b7b:	31 d2                	xor    %edx,%edx
f0101b7d:	f7 f7                	div    %edi
f0101b7f:	89 c5                	mov    %eax,%ebp
f0101b81:	89 d8                	mov    %ebx,%eax
f0101b83:	31 d2                	xor    %edx,%edx
f0101b85:	f7 f5                	div    %ebp
f0101b87:	89 f0                	mov    %esi,%eax
f0101b89:	f7 f5                	div    %ebp
f0101b8b:	89 d0                	mov    %edx,%eax
f0101b8d:	31 d2                	xor    %edx,%edx
f0101b8f:	eb 8c                	jmp    f0101b1d <__umoddi3+0x2d>
f0101b91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101b98:	89 e9                	mov    %ebp,%ecx
f0101b9a:	ba 20 00 00 00       	mov    $0x20,%edx
f0101b9f:	29 ea                	sub    %ebp,%edx
f0101ba1:	d3 e0                	shl    %cl,%eax
f0101ba3:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101ba7:	89 d1                	mov    %edx,%ecx
f0101ba9:	89 f8                	mov    %edi,%eax
f0101bab:	d3 e8                	shr    %cl,%eax
f0101bad:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101bb1:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101bb5:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101bb9:	09 c1                	or     %eax,%ecx
f0101bbb:	89 d8                	mov    %ebx,%eax
f0101bbd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101bc1:	89 e9                	mov    %ebp,%ecx
f0101bc3:	d3 e7                	shl    %cl,%edi
f0101bc5:	89 d1                	mov    %edx,%ecx
f0101bc7:	d3 e8                	shr    %cl,%eax
f0101bc9:	89 e9                	mov    %ebp,%ecx
f0101bcb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0101bcf:	d3 e3                	shl    %cl,%ebx
f0101bd1:	89 c7                	mov    %eax,%edi
f0101bd3:	89 d1                	mov    %edx,%ecx
f0101bd5:	89 f0                	mov    %esi,%eax
f0101bd7:	d3 e8                	shr    %cl,%eax
f0101bd9:	89 e9                	mov    %ebp,%ecx
f0101bdb:	89 fa                	mov    %edi,%edx
f0101bdd:	d3 e6                	shl    %cl,%esi
f0101bdf:	09 d8                	or     %ebx,%eax
f0101be1:	f7 74 24 08          	divl   0x8(%esp)
f0101be5:	89 d1                	mov    %edx,%ecx
f0101be7:	89 f3                	mov    %esi,%ebx
f0101be9:	f7 64 24 0c          	mull   0xc(%esp)
f0101bed:	89 c6                	mov    %eax,%esi
f0101bef:	89 d7                	mov    %edx,%edi
f0101bf1:	39 d1                	cmp    %edx,%ecx
f0101bf3:	72 06                	jb     f0101bfb <__umoddi3+0x10b>
f0101bf5:	75 10                	jne    f0101c07 <__umoddi3+0x117>
f0101bf7:	39 c3                	cmp    %eax,%ebx
f0101bf9:	73 0c                	jae    f0101c07 <__umoddi3+0x117>
f0101bfb:	2b 44 24 0c          	sub    0xc(%esp),%eax
f0101bff:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0101c03:	89 d7                	mov    %edx,%edi
f0101c05:	89 c6                	mov    %eax,%esi
f0101c07:	89 ca                	mov    %ecx,%edx
f0101c09:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101c0e:	29 f3                	sub    %esi,%ebx
f0101c10:	19 fa                	sbb    %edi,%edx
f0101c12:	89 d0                	mov    %edx,%eax
f0101c14:	d3 e0                	shl    %cl,%eax
f0101c16:	89 e9                	mov    %ebp,%ecx
f0101c18:	d3 eb                	shr    %cl,%ebx
f0101c1a:	d3 ea                	shr    %cl,%edx
f0101c1c:	09 d8                	or     %ebx,%eax
f0101c1e:	83 c4 1c             	add    $0x1c,%esp
f0101c21:	5b                   	pop    %ebx
f0101c22:	5e                   	pop    %esi
f0101c23:	5f                   	pop    %edi
f0101c24:	5d                   	pop    %ebp
f0101c25:	c3                   	ret    
f0101c26:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101c2d:	8d 76 00             	lea    0x0(%esi),%esi
f0101c30:	29 fe                	sub    %edi,%esi
f0101c32:	19 c3                	sbb    %eax,%ebx
f0101c34:	89 f2                	mov    %esi,%edx
f0101c36:	89 d9                	mov    %ebx,%ecx
f0101c38:	e9 1d ff ff ff       	jmp    f0101b5a <__umoddi3+0x6a>
