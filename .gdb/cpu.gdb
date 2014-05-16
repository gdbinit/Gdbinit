source ~/.gdb/cpu-arm.gdb
source ~/.gdb/cpu-x86.gdb
source ~/.gdb/cpu-mips.gdb

define flags
  # call the auxiliary functions based on target cpu
  if ($ARM == 1)
    flagsarm
  end

  if (($X86 == 1) || ($X86_64 == 1))
    flagsx86
  end
end
document flags
Print flags register.
end

define eflags
  # call the auxiliary functions based on target cpu
  if $ARM == 1
    eflagsarm
  end

  if (($X86 == 1) || ($X86_64 == 1))
    eflagsx86
  end
end
document eflags
Print eflags register.
end


define reg
  if $ARM == 1
    regarm
  end

  if (($X86 == 1) || ($X86_64 == 1))
    if ($X86_64 == 1)
      regx86_64
    else
      regx86
    end
    # call smallregisters
    smallregisters
    # display conditional jump routine
    if ($X86_64 == 1)
      printf "\t\t\t\t"
    end
    dumpjump
    printf "\n"
  end

  if ($MIPS == 1)
    regmips
  end
end
document reg
Print CPU registers.
end


# _______________eflags commands______________
# conditional flags are
# negative/less than (N), bit 31 of CPSR
# zero (Z), bit 30
# Carry/Borrow/Extend (C), bit 29
# Overflow (V), bit 28

# negative/less than (N), bit 31 of CPSR
define cfn
  if $ARM == 1
    cfnarm
  end
end
document cfn
Change Negative/Less Than Flag.
end


define cfc
  # Carry/Borrow/Extend (C), bit 29
  if $ARM == 1
    cfcarm
  end

  if (($X86 == 1) || ($X86_64 == 1))
    cfcx86
  end
end
document cfc
Change Carry Flag.
end


define cfp
  if (($eflags >> 2) & 1)
    set $eflags = $eflags & ~0x4
  else
    set $eflags = $eflags | 0x4
  end
end
document cfp
Change Parity Flag.
end


define cfa
  if (($eflags >> 4) & 1)
    set $eflags = $eflags & ~0x10
  else
    set $eflags = $eflags | 0x10
  end
end
document cfa
Change Auxiliary Carry Flag.
end


define cfz
  # zero (Z), bit 30
  if $ARM == 1
    cfzarm
  end

  if (($X86 == 1) || ($X86_64 == 1))
    cfzx86
  end
end
document cfz
Change Zero Flag.
end


define cfs
  if (($eflags >> 7) & 1)
    set $eflags = $eflags & ~0x80
  else
    set $eflags = $eflags | 0x80
  end
end
document cfs
Change Sign Flag.
end


define cft
  if (($eflags >> 8) & 1)
    set $eflags = $eflags & ~0x100
  else
    set $eflags = $eflags | 0x100
  end
end
document cft
Change Trap Flag.
end


define cfi
  if (($eflags >> 9) & 1)
    set $eflags = $eflags & ~0x200
  else
    set $eflags = $eflags | 0x200
  end
end
document cfi
Change Interrupt Flag.
Only privileged applications (usually the OS kernel) may modify IF.
This only applies to protected mode (real mode code may always modify IF).
end


define cfd
  if (($eflags >> 0xA) & 1)
    set $eflags = $eflags & ~0x400
  else
    set $eflags = $eflags | 0x400
  end
end
document cfd
Change Direction Flag.
end


define cfo
  if (($eflags >> 0xB) & 1)
    set $eflags = $eflags & ~0x800
  else
    set $eflags = $eflags | 0x800
  end
end
document cfo
Change Overflow Flag.
end


# Overflow (V), bit 28
define cfv
  if $ARM == 1
    cfvarm
  end
end
document cfv
Change Overflow Flag.
end


# ____________________cflow___________________
define print_insn_type
  if $argc != 1
    help print_insn_type
  else
    if ($arg0 < 0 || $arg0 > 5)
      printf "UNDEFINED/WRONG VALUE"
    end
    if ($arg0 == 0)
      printf "UNKNOWN"
    end
    if ($arg0 == 1)
      printf "JMP"
    end
    if ($arg0 == 2)
      printf "JCC"
    end
    if ($arg0 == 3)
      printf "CALL"
    end
    if ($arg0 == 4)
      printf "RET"
    end
    if ($arg0 == 5)
      printf "INT"
    end
  end
end
document print_insn_type
Print human-readable mnemonic for the instruction type (usually $INSN_TYPE).
Usage: print_insn_type INSN_TYPE_NUMBER
end


define get_insn_type
  if $argc != 1
    help get_insn_type
  else
    set $INSN_TYPE = 0
    set $_byte1 = *(unsigned char *) $arg0
    if ($_byte1 == 0x9A || $_byte1 == 0xE8)
      # "call"
      set $INSN_TYPE = 3
    end
    if ($_byte1 >= 0xE9 && $_byte1 <= 0xEB)
      # "jmp"
      set $INSN_TYPE = 1
    end
    if ($_byte1 >= 0x70 && $_byte1 <= 0x7F)
      # "jcc"
      set $INSN_TYPE = 2
    end
    if ($_byte1 >= 0xE0 && $_byte1 <= 0xE3)
      # "jcc"
      set $INSN_TYPE = 2
    end
    if ($_byte1 == 0xC2 || $_byte1 == 0xC3 || $_byte1 == 0xCA || \
        $_byte1 == 0xCB || $_byte1 == 0xCF)
      # "ret"
      set $INSN_TYPE = 4
    end
    if ($_byte1 >= 0xCC && $_byte1 <= 0xCE)
      # "int"
      set $INSN_TYPE = 5
    end
    if ($_byte1 == 0x0F)
      # two-byte opcode
      set $_byte2 = *(unsigned char *) ($arg0 + 1)
      if ($_byte2 >= 0x80 && $_byte2 <= 0x8F)
        # "jcc"
        set $INSN_TYPE = 2
      end
    end
    if ($_byte1 == 0xFF)
      # opcode extension
      set $_byte2 = *(unsigned char *) ($arg0 + 1)
      set $_opext = ($_byte2 & 0x38)
      if ($_opext == 0x10 || $_opext == 0x18)
        # "call"
        set $INSN_TYPE = 3
      end
      if ($_opext == 0x20 || $_opext == 0x28)
        # "jmp"
        set $INSN_TYPE = 1
      end
    end
  end
end
document get_insn_type
Recognize instruction type at address ADDR.
Take address ADDR and set the global $INSN_TYPE variable to
0, 1, 2, 3, 4, 5 if the instruction at that address is
unknown, a jump, a conditional jump, a call, a return, or an interrupt.
Usage: get_insn_type ADDR
end


define hookstopcpu
  if $ARM == 1
    hookstoparm
  end

  if (($X86 == 1) || ($X86_64 == 1))
    hookstopx86
  end
end
document hookstopcpu
!!! FOR INTERNAL USE ONLY - DO NOT CALL !!!
end


define context
  echo \033[34m
  if $SHOWCPUREGISTERS == 1
    printf "----------------------------------------"
    printf "----------------------------------"
    if ($64BITS == 1)
      printf "---------------------------------------------"
    end
    echo \033[34m\033[1m
    printf "[regs]\n"
    echo \033[0m
    reg
    echo \033[36m
  end

  if $SHOWSTACK == 1
    echo \033[34m
    if ($ARM == 1)
      printf "[0x%08X]---------", $sp
    end
    if ($MIPS == 1)
      printf "[0x%016lX]-------", $sp
    end
    if ($X86_64 == 1)
      printf "[0x%04X:0x%016lX]", $ss, $rsp
    end
    if ($X86 == 1)
      printf "[0x%04X:0x%08X]--", $ss, $esp
    end
    echo \033[34m
    printf "-------------------------"
    printf "-----------------------------"
    if ($64BITS == 1)
      printf "-------------------------------------"
    end
    echo \033[34m\033[1m
    printf "[stack]\n"
    echo \033[0m
    set $context_i = $CONTEXTSIZE_STACK
    while ($context_i > 0)
      set $context_t = $sp + 0x10 * ($context_i - 1)
      hexdump $context_t
      set $context_i--
    end
  end

  # show the objective C message being passed to msgSend
  if $SHOWOBJECTIVEC == 1
    #FIXME: X64 and ARM
    # What a piece of crap that's going on here :)
    # detect if it's the correct opcode we are searching for
    if (($X86 == 1) || ($X86_64 == 1))
      set $__byte1 = *(unsigned char *) $pc
      set $__byte = *(int *) $pc
      if ($__byte == 0x4244489)
        set $objectivec = $eax
      	set $displayobjectivec = 1
      end

      if ($__byte == 0x4245489)
        set $objectivec = $edx
     	set $displayobjectivec = 1
      end

      if ($__byte == 0x4244c89)
        set $objectivec = $ecx
     	set $displayobjectivec = 1
      end
    end

    if ($ARM == 1)
      set $__byte1 = 0
    end
    # and now display it or not (we have no interest in having the info displayed after the call)
    if $__byte1 == 0xE8
      if $displayobjectivec == 1
        echo \033[34m
        printf "--------------------------------------------------------------------"
        if ($64BITS == 1)
          printf "---------------------------------------------"
        end
    	echo \033[34m\033[1m
	printf "[ObjectiveC]\n"
      	echo \033[0m\033[30m
      	x/s $objectivec
      end
      set $displayobjectivec = 0
    end
    if $displayobjectivec == 1
      echo \033[34m
      printf "--------------------------------------------------------------------"
      if ($64BITS == 1)
	printf "---------------------------------------------"
      end
      echo \033[34m\033[1m
      printf "[ObjectiveC]\n"
      echo \033[0m\033[30m
      x/s $objectivec
    end
  end
  echo \033[0m
  # and this is the end of this little crap

  if $SHOWDATAWIN == 1
    datawin
  end

  set $context_i = $CONTEXTSIZE_CODE
  if ($context_i > 0)
    echo \033[34m
    printf "--------------------------------------------------------------------------"
    if ($64BITS == 1)
      printf "---------------------------------------------"
    end
    echo \033[34m\033[1m
    printf "[code]\n"
    echo \033[0m
    if ($SETCOLOUR1STLINE == 1)	
      echo \033[32m
      x /i $pc
      echo \033[0m
    else
      x /i $pc
    end
    set $context_i--
    while ($context_i > 0)
      x /i
      set $context_i--
    end
    echo \033[34m
    printf "----------------------------------------"
    printf "----------------------------------------"
    if ($64BITS == 1)
      printf "---------------------------------------------\n"
    else
      printf "\n"
    end
    echo \033[0m
  end
end
document context
Print context window, i.e. regs, stack, ds:esi and disassemble cs:eip.
end


define context-on
  set $SHOW_CONTEXT = 1
  printf "Displaying of context is now ON\n"
end
document context-on
Enable display of context on every program break.
end


define context-off
  set $SHOW_CONTEXT = 0
  printf "Displaying of context is now OFF\n"
end
document context-off
Disable display of context on every program break.
end


define dis
  if $argc == 0
    disassemble
  end
  if $argc == 1
    disassemble $arg0
  end
  if $argc == 2
    disassemble $arg0 $arg1
  end
  if $argc > 2
    help dis
  end
end
document dis
Disassemble a specified section of memory.
Default is to disassemble the function surrounding the PC (program counter) of selected frame.
With one argument, ADDR1, the function surrounding this address is dumped.
Two arguments are taken as a range of memory to dump.
Usage: dis <ADDR1> <ADDR2>
end
