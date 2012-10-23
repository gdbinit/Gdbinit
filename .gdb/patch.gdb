# ____________________patch___________________
# the usual nops are mov r0,r0 for arm (0xe1a00000)
# and mov r8,r8 in Thumb (0x46c0)
# armv7 has other nops
# FIXME: make sure that the interval fits the 32bits address for arm and 16bits for thumb
# status: works, fixme
define nop
  if ($argc > 2 || $argc == 0)
    help nop
  end

  if $ARM == 1
    if ($argc == 1)
      if ($cpsr->t &1)
        # thumb
        set *(short *) $arg0 = 0x46c0
      else
        # arm
        set *(int *) $arg0 = 0xe1a00000
      end
    else
      set $addr = $arg0
      if ($cpsr->t & 1)
    	# thumb
	while ($addr < $arg1)
	  set *(short *) $addr = 0x46c0
	  set $addr = $addr + 2
	end
      else
	# arm
	while ($addr < $arg1)
	  set *(int *) $addr = 0xe1a00000
	  set $addr = $addr + 4
	end
      end			
    end
  end

  if (($X86 == 1) || ($X86_64 == 1))
    if ($argc == 1)
      set *(unsigned char *) $arg0 = 0x90
    else
      set $addr = $arg0
      while ($addr < $arg1)
	set *(unsigned char *) $addr = 0x90
	set $addr = $addr + 1
      end
    end
  end
end
document nop
Usage: nop ADDR1 [ADDR2]
Patch a single byte at address ADDR1, or a series of bytes between ADDR1 and ADDR2 to a NOP (0x90) instruction.
ARM or Thumb code will be patched accordingly.
end


define null
  if ($argc >2 || $argc == 0)
    help null
  end

  if ($argc == 1)
    set *(unsigned char *) $arg0 = 0
  else
    set $addr = $arg0
    while ($addr < $arg1)
      set *(unsigned char *) $addr = 0
      set $addr = $addr + 1
    end
  end
end
document null
Usage: null ADDR1 [ADDR2]
Patch a single byte at address ADDR1 to NULL (0x00), or a series of bytes between ADDR1 and ADDR2.
end

# FIXME: thumb breakpoint ?
define int3
  if $argc != 1
    help int3
  else
    if $ARM == 1
      set $ORIGINAL_INT3 = *(unsigned int *) $arg0
      set $ORIGINAL_INT3ADDRESS = $arg0
      set *(unsigned int*) $arg0 = 0xe7ffdefe
    end

    if (($X86 == 1) || ($X86_64 == 1))
      # save original bytes and address
      set $ORIGINAL_INT3 = *(unsigned char *) $arg0
      set $ORIGINAL_INT3ADDRESS = $arg0
      # patch
      set *(unsigned char *) $arg0 = 0xCC
    end
  end
end
document int3
Patch byte at address ADDR to an INT3 (0xCC) instruction or the equivalent software breakpoint for ARM.
Usage: int3 ADDR
end


define rint3
  if $ARM == 1
    set *(unsigned int *) $ORIGINAL_INT3ADDRESS = $ORIGINAL_INT3
    set $pc = $ORIGINAL_INT3ADDRESS
  end

  if (($X86 == 1) || ($X86_64 == 1))
    set *(unsigned char *) $ORIGINAL_INT3ADDRESS = $ORIGINAL_INT3
    if $64BITS == 1
      set $rip = $ORIGINAL_INT3ADDRESS
    else
      set $eip = $ORIGINAL_INT3ADDRESS
    end
  end
end
document rint3
Restore the original byte previous to int3 patch issued with "int3" command.
end


# original by Tavis Ormandy (http://my.opera.com/taviso/blog/index.dml/tag/gdb) (great fix!)
# modified to work with Mac OS X by fG!
# seems nasm shipping with Mac OS X has problems accepting input from stdin or heredoc
# input is read into a variable and sent to a temporary file which nasm can read
define assemble
  # dont enter routine again if user hits enter
  dont-repeat
  if ($argc)
    if (*$arg0 = *$arg0)
      # check if we have a valid address by dereferencing it,
      # if we havnt, this will cause the routine to exit.
    end
    printf "Instructions will be written to %#x.\n", $arg0
  else
    printf "Instructions will be written to stdout.\n"
  end
  printf "Type instructions, one per line."
  echo \033[1m
  printf " Do not forget to use NASM assembler syntax!\n"
  echo \033[0m
  printf "End with a line saying just \"end\".\n"

  if ($argc)
    if ($X86_64 == 1)
      # argument specified, assemble instructions into memory at address specified.
      shell ASMOPCODE="$(while read -ep '>' r && test "$r" != end ; do echo -E "$r"; done)"; \
            GDBASMFILENAME=$RANDOM; \
            echo -e "BITS 64\n$ASMOPCODE" >/tmp/$GDBASMFILENAME; \
	    /usr/local/bin/nasm -f bin -o /dev/stdout /tmp/$GDBASMFILENAME | \
	    /usr/bin/hexdump -ve '1/1 "set *((unsigned char *) $arg0 + %#2_ax) = %#02x\n"' >/tmp/gdbassemble; \
	    /bin/rm -f /tmp/$GDBASMFILENAME
      source /tmp/gdbassemble
      # all done. clean the temporary file
      shell /bin/rm -f /tmp/gdbassemble
    end

    if ($X86 == 1)
      # argument specified, assemble instructions into memory at address specified.
      shell ASMOPCODE="$(while read -ep '>' r && test "$r" != end ; do echo -E "$r"; done)"; \
            GDBASMFILENAME=$RANDOM; \
            echo -e "BITS 32\n$ASMOPCODE" >/tmp/$GDBASMFILENAME; \
	    /usr/bin/nasm -f bin -o /dev/stdout /tmp/$GDBASMFILENAME | \
	    /usr/bin/hexdump -ve '1/1 "set *((unsigned char *) $arg0 + %#2_ax) = %#02x\n"' >/tmp/gdbassemble; \
	    /bin/rm -f /tmp/$GDBASMFILENAME
      source /tmp/gdbassemble
      # all done. clean the temporary file
      shell /bin/rm -f /tmp/gdbassemble
    end
  else
    if ($X86_64 == 1)
      # no argument, assemble instructions to stdout
      shell ASMOPCODE="$(while read -ep '>' r && test "$r" != end ; do echo -E "$r"; done)";
            GDBASMFILENAME=$RANDOM; \
	    echo -e "BITS 64\n$ASMOPCODE" >/tmp/$GDBASMFILENAME; \
	    /usr/local/bin/nasm -f bin -o /dev/stdout /tmp/$GDBASMFILENAME | \
	    /usr/local/bin/ndisasm -i -b64 /dev/stdin; \
	    /bin/rm -f /tmp/$GDBASMFILENAME
    end

    if ($X86 == 1)
      # no argument, assemble instructions to stdout
      shell ASMOPCODE="$(while read -ep '>' r && test "$r" != end ; do echo -E "$r"; done)"; \
            GDBASMFILENAME=$RANDOM; \
	    echo -e "BITS 32\n$ASMOPCODE" >/tmp/$GDBASMFILENAME; \
	    /usr/bin/nasm -f bin -o /dev/stdout /tmp/$GDBASMFILENAME | \
	    /usr/bin/ndisasm -i -b32 /dev/stdin; \
	    /bin/rm -f /tmp/$GDBASMFILENAME
    end
  end
end
document assemble
Assemble instructions using nasm.
Type a line containing "end" to indicate the end.
If an address is specified, insert/modify instructions at that address.
If no address is specified, assembled instructions are printed to stdout.
Use the pseudo instruction "org ADDR" to set the base address.
end


define asm
  if $argc == 1
    assemble $arg0
  else
    assemble
  end
end
document asm
Shortcut to the asssemble command.
end


define assemble_gas
  printf "\nType code to assemble and hit Ctrl-D when finished.\n"
  printf "You must use GNU assembler (AT&T) syntax.\n"

  shell filename=$(mktemp); \
        binfilename=$(mktemp); \
	echo -e "Writing into: ${filename}\n"; \
	cat > $filename; echo ""; \
	as -o $binfilename < $filename; \
	objdump -d -j .text $binfilename; \
	rm -f $binfilename; \
	rm -f $filename; \
	echo -e "temporaly files deleted.\n"
end
document assemble_gas
Assemble instructions to binary opcodes. Uses GNU as and objdump.
Usage: assemble_gas
end


define dump_hexfile
  dump ihex memory $arg0 $arg1 $arg2
end
document dump_hexfile
Write a range of memory to a file in Intel ihex (hexdump) format.
The range is specified by ADDR1 and ADDR2 addresses.
Usage: dump_hexfile FILENAME ADDR1 ADDR2
end


define dump_binfile
  dump memory $arg0 $arg1 $arg2
end
document dump_binfile
Write a range of memory to a binary file.
The range is specified by ADDR1 and ADDR2 addresses.
Usage: dump_binfile FILENAME ADDR1 ADDR2
end


define dumpmacho
  if $argc != 2
    help dumpmacho
  end
  set $headermagic = *$arg0
  # the || operator isn't working as it should, wtf!!!
  if $headermagic != 0xfeedface
    if $headermagic != 0xfeedfacf
      printf "[Error] Target address doesn't contain a valid Mach-O binary!\n"
      help dumpmacho
    end
  end
  set $headerdumpsize = *($arg0 + 0x14)
  if $headermagic == 0xfeedface
    dump memory $arg1 $arg0 ($arg0 + 0x1c + $headerdumpsize)
  end
  if $headermagic == 0xfeedfacf
    dump memory $arg1 $arg0 ($arg0 + 0x20 + $headerdumpsize)
  end
end
document dumpmacho
Dump the Mach-O header to a file.
You need to input the start address (use info shared command to find it).
Usage: dumpmacho STARTADDRESS FILENAME
end
