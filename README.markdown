# dotgdb

This project was based on [Gdbinit](https://github.com/gdbinit/Gdbinit) by
[fG!](http://reverse.put.as/) which in turn is based on work by the following
people:

 * mammon_
 * elaine
 * pusillus
 * mong
 * zhang le
 * l0kit
 * truthix the cyberpunk
 * gln


Currently there is support for the following architectures:

 * x86
 * x86-64
 * arm
 * mips


## How do I install it?

Clone the project from git://github.com/dholm/dotgdb.git and symbolically link
*.gdb* and *.gdbinit* into your home directory.


## Commands

This section is incomplete.

### Data

```
 * hexdump

   Display a 16-byte hex/ASCII dump of memory starting at address ADDR.
   Optional parameter is the number of lines to display if you want more than
   one.

   Usage: hexdump ADDR [nr lines]
```

```
 * search

   Search for the given pattern beetween $start and $end address.

   Usage: search <start> <end> <pattern>
```

```
 * ascii_char

   Print ASCII value of byte at address ADDR.
   Print "." if the value is unprintable.

   Usage: ascii_char ADDR
```

```
 * hex_quad

   Print eight hexadecimal bytes starting at address ADDR.

   Usage: hex_quad ADDR
```


### CPU

```
 * context

   Print context window, i.e. regs, stack, ds:esi and disassemble cs:eip.
```

```
 * context-on

   Enable display of context on every program break.
```

```
 * context-off

   Disable display of context on every program break.
```

```
 * dis

   Disassemble a specified section of memory.
   Default is to disassemble the function surrounding the PC (program counter)
   of selected frame.
   With one argument, ADDR1, the function surrounding this address is dumped.
   Two arguments are taken as a range of memory to dump.

   Usage: dis <ADDR1> <ADDR2>
```

```
 * flags

   Print flags register.
```

```
 * eflags

   Print eflags register.
```

```
 * reg

   Print CPU registers.
```

```
 * cfn

   Change Negative/Less Than Flag.
```

```
 * cfc

   Change Carry Flag.
```

```
 * cfp

   Change Parity Flag.
```

```
 * cfa

   Change Auxiliary Carry Flag.
```

```
 * cfz

   Change Zero Flag.
```

```
 * cfs

   Change Sign Flag.
```

```
 * cft

   Change Trap Flag.
```

```
 * cfi

   Change Interrupt Flag.
   Only privileged applications (usually the OS kernel) may modify IF.
   This only applies to protected mode (real mode code may always modify IF).
```

```
 * cfd

   Change Direction Flag.
```

```
 * cfo

   Change Overflow Flag.
```

```
 * cfv

   Change Overflow Flag.
```


### Patch

```
 * nop

   Patch a single byte at address ADDR1, or a series of bytes between ADDR1 and
   ADDR2 to a NOP instruction.

   Usage: nop ADDR1 [ADDR2]
```

```
 * null

   Patch a single byte at address ADDR1 to NULL (0x00), or a series of bytes
   between ADDR1 and ADDR2.

   Usage: null ADDR1 [ADDR2]
```

```
 * assemble

   Assemble instructions using nasm.
   Type a line containing "end" to indicate the end.
   If an address is specified, insert/modify instructions at that address.
   If no address is specified, assembled instructions are printed to stdout.
   Use the pseudo instruction "org ADDR" to set the base address.
```

```
 * assemble_gas

   Assemble instructions to binary opcodes. Uses GNU as and objdump.

   Usage: assemble_gas
```

```
 * dump_hexfile

   Write a range of memory to a file in Intel ihex (hexdump) format.
   The range is specified by ADDR1 and ADDR2 addresses.

   Usage: dump_hexfile FILENAME ADDR1 ADDR2
```

```
 * dump_binfile

   Write a range of memory to a binary file.
   The range is specified by ADDR1 and ADDR2 addresses.

   Usage: dump_binfile FILENAME ADDR1 ADDR2
```

```
 * dumpmacho

   Dump the Mach-O header to a file.
   You need to input the start address (use info shared command to find it).

   Usage: dumpmacho STARTADDRESS FILENAME
```


### Tracing

```
 * n

   Step one instruction, but proceed through subroutine calls.
   If NUM is given, then repeat it NUM times or till program stops.
   This is alias for nexti.

   Usage: n <NUM>
```

```
 * go

   Step one instruction exactly.
   If NUM is given, then repeat it NUM times or till program stops.
   This is alias for stepi.

   Usage: go <NUM>
```

```
 * init

   Run program and break on _init().
```

```
 * start

   Run program and break on _start().
```

```
 * sstart

   Run program and break on __libc_start_main().
   Useful for stripped executables.
```

```
 * main

   Run program and break on main().
```

```
 * stepo

   Step over calls (interesting to bypass the ones to msgSend in Objective-C).
   This function will set a temporary breakpoint on next instruction after the
   call so the call will be bypassed.
   You can safely use it instead nexti or n since it will single step code if
   it's not a call instruction (unless you want to go into the call function).
```

```
 * stepoh

   Same as stepo command but uses temporary hardware breakpoints.
```

```
 * step_to_call

   Single step until a call instruction is found.
   Stop before the call is taken.
   Log is written into the file ~/gdb.txt.
```

```
 * trace_calls

   Create a runtime trace of the calls made by target.
   Log overwrites(!) the file ~/gdb_trace_calls.txt.
```

```
 * trace_run

   Create a runtime trace of target.
   Log overwrites(!) the file ~/gdb_trace_run.txt.
```

```
 * dumpjump

   Display if conditional jump will be taken or not.
```


### Breakpoints

```
 * bpl

   List all breakpoints.
```

```
 * bp

   Set breakpoint.

   Usage: bp LOCATION
     LOCATION may be a line number, function name, or "*" and an address.
     To break on a symbol you must enclose symbol name inside "".
   Example:
     bp "[NSControl stringValue]"
     Or else you can use directly the break command (break [NSControl
     stringValue])
```

```
 * bpc

   Clear breakpoint.

   Usage: bpc LOCATION
     LOCATION may be a line number, function name, or "*" and an address.
```

```
 * bpe

   Enable breakpoint with number NUM.

   Usage: bpe NUM
```

```
 * bpd

   Disable breakpoint with number NUM.

   Usage: bpd NUM
```

```
 * bpt

   Set a temporary breakpoint.
   This breakpoint will be automatically deleted when hit!.

   Usage: bpt LOCATION
     LOCATION may be a line number, function name, or "*" and an address.
```

```
 * bpm

   Set a read/write breakpoint on EXPRESSION, e.g. *address.

   Usage: bpm EXPRESSION
```

```
 * bhb

   Set hardware assisted breakpoint.

   Usage: bhb LOCATION
     LOCATION may be a line number, function name, or "*" and an address.
```

```
 * bht

   Set a temporary hardware breakpoint.
   This breakpoint will be automatically deleted when hit!

   Usage: bht LOCATION
     LOCATION may be a line number, function name, or "*" and an address.
```


### Information

```
 * stack

   Print backtrace of the call stack, or innermost COUNT frames.

   Usage: stack <COUNT>
```

```
 * frame

   Print stack frame.
```

```
 * func

   Print all function names in target, or those matching REGEXP.

   Usage: func <REGEXP>
```

```
 * var

   Print all global and static variable names (symbols), or those matching
   REGEXP.

   Usage: var <REGEXP>
```

```
 * lib

   Print shared libraries linked to target.
```

```
 * sig

   Print what debugger does when program gets various signals.
   Specify a SIGNAL as argument to print info on that signal only.

   Usage: sig <SIGNAL>
```

```
 * threads

   Print threads in target.
```


### Tips

```
 * tips

   Provide a list of tips from users on various topics.
```

```
 * tip_patch

   Tips on patching memory and binary files.
```

```
 * tip_strip

   Tips on dealing with stripped binaries.
```

```
 * tip_syntax

   Summary of Intel and AT&T syntax differences.
```

```
 * tip_display

   Tips on automatically displaying values when a program stops.
```

### MacsBug
Type `MACSBUG_HELP` to summarize the MacsBug commands

