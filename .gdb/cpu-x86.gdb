# Initialize these variables else comparisons will fail for colouring
set $oldrax = 0
set $oldrbx = 0
set $oldrcx = 0
set $oldrdx = 0
set $oldrsi = 0
set $oldrdi = 0
set $oldrbp = 0
set $oldrsp = 0
set $oldr8  = 0
set $oldr9  = 0
set $oldr10 = 0
set $oldr11 = 0
set $oldr12 = 0
set $oldr13 = 0
set $oldr14 = 0
set $oldr15 = 0

set $oldeax = 0
set $oldebx = 0
set $oldecx = 0
set $oldedx = 0
set $oldesi = 0
set $oldedi = 0
set $oldebp = 0
set $oldesp = 0


define flagsx86
  # OF (overflow) flag
  if (($eflags >> 0xB) & 1)
    printf "O "
    set $_of_flag = 1
  else
    printf "o "
    set $_of_flag = 0
  end
  # DF (direction) flag
  if (($eflags >> 0xA) & 1)
    printf "D "
  else
    printf "d "
  end
  # IF (interrupt enable) flag
  if (($eflags >> 9) & 1)
    printf "I "
  else
    printf "i "
  end
  # TF (trap) flag
  if (($eflags >> 8) & 1)
    printf "T "
  else
    printf "t "
  end
  # SF (sign) flag
  if (($eflags >> 7) & 1)
    printf "S "
    set $_sf_flag = 1
  else
    printf "s "
    set $_sf_flag = 0
  end
  # ZF (zero) flag
  if (($eflags >> 6) & 1)
    printf "Z "
    set $_zf_flag = 1
  else
    printf "z "
    set $_zf_flag = 0
  end
  # AF (adjust) flag
  if (($eflags >> 4) & 1)
    printf "A "
  else
    printf "a "
  end
  # PF (parity) flag
  if (($eflags >> 2) & 1)
    printf "P "
    set $_pf_flag = 1
  else
    printf "p "
    set $_pf_flag = 0
  end
  # CF (carry) flag
  if ($eflags & 1)
    printf "C "
    set $_cf_flag = 1
  else
    printf "c "
    set $_cf_flag = 0
  end
  printf "\n"
end
document flagsx86
Auxiliary function to set X86/X64 cpu flags.
end


define eflagsx86
  printf "     OF <%d>  DF <%d>  IF <%d>  TF <%d>", \
         (($eflags >> 0xB) & 1), (($eflags >> 0xA) & 1), \
         (($eflags >> 9) & 1), (($eflags >> 8) & 1)
  printf "  SF <%d>  ZF <%d>  AF <%d>  PF <%d>  CF <%d>\n", \
         (($eflags >> 7) & 1), (($eflags >> 6) & 1), \
         (($eflags >> 4) & 1), (($eflags >> 2) & 1), ($eflags & 1)
  printf "     ID <%d>  VIP <%d> VIF <%d> AC <%d>", \
         (($eflags >> 0x15) & 1), (($eflags >> 0x14) & 1), \
         (($eflags >> 0x13) & 1), (($eflags >> 0x12) & 1)
  printf "  VM <%d>  RF <%d>  NT <%d>  IOPL <%d>\n", \
         (($eflags >> 0x11) & 1), (($eflags >> 0x10) & 1), \
         (($eflags >> 0xE) & 1), (($eflags >> 0xC) & 3)
end
document eflagsx86
Auxillary function to print X86/X64 eflags register.
end


define regx86_64
  # 64bits stuff
  printf "  "

  # RAX
  echo \033[32m
  printf "RAX:"
  echo \033[0m
  if $rax
    if ($rax != $oldrax && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX  ", $rax
  else
    printf " 0x%016lX  ", 0
  end

  # RBX
  echo \033[32m
  printf "RBX:"
  echo \033[0m
  if $rbx
    if ($rbx != $oldrbx && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX  ", $rbx
  else
    printf " 0x%016lX  ", 0
  end

  # RCX
  echo \033[32m
  printf "RCX:"
  echo \033[0m
  if $rcx
    if ($rcx != $oldrcx && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX  ", $rcx
  else
    printf " 0x%016lX  ", 0
  end

  # RDX
  echo \033[32m
  printf "RDX:"
  echo \033[0m
  if $rdx
    if ($rdx != $oldrdx && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX  ", $rdx
  else
    printf " 0x%016lX  ", 0
  end

  echo \033[1m\033[4m\033[31m
  flags
  echo \033[0m
  printf "  "

  # RSI
  echo \033[32m
  printf "RSI:"
  echo \033[0m
  if $rsi
    if ($rsi != $oldrsi && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX  ", $rsi
  else
    printf " 0x%016lX  ", 0
  end

  # RDI
  echo \033[32m
  printf "RDI:"
  echo \033[0m
  if $rdi
    if ($rdi != $oldrdi && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX  ", $rdi
  else
    printf " 0x%016lX  ", 0
  end

  # RBP
  echo \033[32m
  printf "RBP:"
  echo \033[0m
  if $rbp
    if ($rbp != $oldrbp && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX  ", $rbp
  else
    printf " 0x%016lX  ", 0
  end

  # RSP
  echo \033[32m
  printf "RSP:"
  echo \033[0m
  if $rsp
    if ($rsp != $oldrsp && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX  ", $rsp
  else
    printf " 0x%016lX  ", 0
  end

  echo \033[32m
  printf "RIP:"
  echo \033[0m
  if $rip
    printf " 0x%016lX", $rip
  else
    printf " 0x%016lX", 0
  end


  # Newline
  printf "\n  "

  # R8
  echo \033[32m
  printf "R8 :"
  echo \033[0m
  if $r8
    if ($r8 != $oldr8 && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX  ", $r8
  else
    printf " 0x%016lX  ", 0
  end

  # R9
  echo \033[32m
  printf "R9 :"
  echo \033[0m
  if $r9
    if ($r9 != $oldr9 && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX  ", $r9
  else
    printf " 0x%016lX  ", 0
  end

  # R10
  echo \033[32m
  printf "R10:"
  echo \033[0m
  if $r10
    if ($r10 != $oldr10 && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX  ", $r10
  else
    printf " 0x%016lX  ", 0
  end

  # R11
  echo \033[32m
  printf "R11:"
  echo \033[0m
  if $r11
    if ($r11 != $oldr11 && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX  ", $r11
  else
    printf " 0x%016lX  ", 0
  end

  # R12
  echo \033[32m
  printf "R12:"
  echo \033[0m
  if $r12
    if ($r12 != $oldr12 && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX", $r12
  else
    printf " 0x%016lX", 0
  end


  # Newline
  printf "\n  "

  # R13
  echo \033[32m
  printf "R13:"
  echo \033[0m
  if $r13
    if ($r13 != $oldr13 && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX  ", $r13
  else
    printf " 0x%016lX  ", 0
  end

  # R14
  echo \033[32m
  printf "R14:"
  echo \033[0m
  if $r14
    if ($r14 != $oldr14 && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX  ", $r14
  else
    printf " 0x%016lX  ", 0
  end

  # R15
  echo \033[32m
  printf "R15:"
  echo \033[0m
  if $r15
    if ($r15 != $oldr15 && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX  ", $r15
  else
    printf " 0x%016lX  ", 0
  end


  # Newline
  printf "\n  "

  echo \033[32m
  printf "CS:"
  echo \033[0m
  if $cs
    printf " %04X  ", $cs
  else
    printf " %04X  ", 0
  end
  echo \033[32m
  printf "DS:"
  echo \033[0m
  if $ds
    printf " %04X  ", $ds
  else
    printf " %04X  ", 0
  end
  echo \033[32m
  printf "ES:"
  echo \033[0m
  if $es
    printf " %04X  ", $es
  else
    printf " %04X  ", 0
  end
  echo \033[32m
  printf "FS:"
  echo \033[0m
  if $fs
    printf " %04X  ", $fs
  else
    printf " %04X  ", 0
  end
  echo \033[32m
  printf "GS:"
  echo \033[0m
  if $gs
    printf " %04X  ", $gs
  else
    printf " %04X  ", 0
  end
  echo \033[32m
  printf "SS:"
  echo \033[0m
  if $ss
    printf " %04X", $ss
  else
    printf " %04X  ", 0
  end
  echo \033[0m

  if ($SHOWREGCHANGES == 1)
    if $rax
      set $oldrax = $rax
    end
    if $rbx
      set $oldrbx = $rbx
    end
    if $rcx
      set $oldrcx = $rcx
    end
    if $rdx
      set $oldrdx = $rdx
    end
    if $rsi
      set $oldrsi = $rsi
    end
    if $rdi
      set $oldrdi = $rdi
    end
    if $rbp
      set $oldrbp = $rbp
    end
    if $rsp
      set $oldrsp = $rsp
    end
    if $r8
      set $oldr8  = $r8
    end
    if $r9
      set $oldr9  = $r9
    end
    if $r10
      set $oldr10 = $r10
    end
    if $r11
      set $oldr11 = $r11
    end
    if $r12
      set $oldr12 = $r12
    end
    if $r13
      set $oldr13 = $r13
    end
    if $r14
      set $oldr14 = $r14
    end
    if $r15
      set $oldr15 = $r15
    end
  end
end
document regx86_64
Auxiliary function to display X86_64 registers.
end


define regx86
  printf "  "
  # EAX
  echo \033[32m
  printf "EAX:"
  echo \033[0m
  if $eax
    if ($eax != $oldeax && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%08X  ", $eax
  else
    printf " 0x%08X  ", 0
  end

  # EBX
  echo \033[32m
  printf "EBX:"
  echo \033[0m
  if $ebx
    if ($ebx != $oldebx && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%08X  ", $ebx
  else
    printf " 0x%08X  ", 0
  end

  # ECX
  echo \033[32m
  printf "ECX:"
  echo \033[0m
  if $ecx
    if ($ecx != $oldecx && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%08X  ", $ecx
  else
    printf " 0x%08X  ", 0
  end

  # EDX
  if $edx
    if ($edx != $oldedx && $SHOWREGCHANGES == 1)
      echo \033[32m
      printf "EDX:"
      echo \033[31m
      printf " 0x%08X  ", $edx
    else
      echo \033[32m
      printf "EDX:"
      echo \033[0m
      printf " 0x%08X  ", $edx
    end
  else
      printf "EDX:"
    echo \033[0m
    printf " 0x%08X  ", 0
  end

  echo \033[1m\033[4m\033[31m
  flags
  echo \033[0m


  # Newline
  printf "\n  "

  # ESI
  echo \033[32m
  printf "ESI:"
  echo \033[0m
  if $esi
    if ($esi != $oldesi && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%08X  ", $esi
  else
    printf " 0x%08X  ", 0
  end

  # EDI
  echo \033[32m
  printf "EDI:"
  echo \033[0m
  if $edi
    if ($edi != $oldedi && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%08X  ", $edi
  else
    printf " 0x%08X  ", 0
  end

  # EBP
  echo \033[32m
  printf "EBP:"
  echo \033[0m
  if $ebp
    if ($ebp != $oldebp && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%08X  ", $ebp
  else
    printf " 0x%08X  ", 0
  end

  # ESP
  echo \033[32m
  printf "ESP:"
  echo \033[0m
  if $esp
    if ($esp != $oldesp && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%08X  ", $esp
  else
    printf " 0x%08X  ", 0
  end

  # EIP
  echo \033[32m
  printf "EIP:"
  echo \033[0m
  if $eip
    printf " 0x%08X", $eip
  else
    printf " 0x%08X", 0
  end


  # Newline
  printf "\n  "

  echo \033[32m
  printf "CS:"
  echo \033[0m
  if $cs
    printf " %04X  ", $cs
  else
    printf " %04X  ", 0
  end
  echo \033[32m
  printf "DS:"
  echo \033[0m
  if $ds
    printf " %04X  ", $ds
  else
    printf " %04X  ", 0
  end
  echo \033[32m
  printf "ES:"
  echo \033[0m
  if $es
    printf " %04X  ", $es
  else
    printf " %04X  ", 0
  end
  echo \033[32m
  printf "FS:"
  echo \033[0m
  if $fs
    printf " %04X  ", $fs
  else
    printf " %04X  ", 0
  end
  echo \033[32m
  printf "GS:"
  echo \033[0m
  if $gs
    printf " %04X  ", $gs
  else
    printf " %04X  ", 0
  end
  echo \033[32m
  printf "SS:"
  echo \033[0m
  if $ss
    printf " %04X  ", $ss
  else
    printf " %04X  ", 0
  end
  echo \033[0m

  if ($SHOWREGCHANGES == 1)
    if $eax
      set $oldeax = $eax
    end
    if $ebx
      set $oldebx = $ebx
    end
    if $ecx
      set $oldecx = $ecx
    end
    if $edx
      set $oldedx = $edx
    end
    if $esi
      set $oldesi = $esi
    end
    if $edi
      set $oldedi = $edi
    end
    if $ebp
      set $oldebp = $ebp
    end
    if $esp
      set $oldesp = $esp
    end
  end
end
document regx86
Auxiliary function to display X86 registers.
end


define smallregisters
  if ($X86_64 == 1)
    #64bits stuff
    # from rax
    set $eax = $rax & 0xffffffff
    set $ax  = $rax & 0xffff
    set $al  = $ax & 0xff
    set $ah  = $ax >> 8
    # from rbx
    set $ebx = $rbx & 0xffffffff
    set $bx  = $rbx & 0xffff
    set $bl  = $bx & 0xff
    set $bh  = $bx >> 8
    # from rcx
    set $ecx = $rcx & 0xffffffff
    set $cx  = $rcx & 0xffff
    set $cl  = $cx & 0xff
    set $ch  = $cx >> 8
    # from rdx
    set $edx = $rdx & 0xffffffff
    set $dx  = $rdx & 0xffff
    set $dl  = $dx & 0xff
    set $dh  = $dx >> 8
    # from rsi
    set $esi = $rsi & 0xffffffff
    set $si  = $rsi & 0xffff
    # from rdi
    set $edi = $rdi & 0xffffffff
    set $di  = $rdi & 0xffff		
    #32 bits stuff
  end

  if ($X86 == 1)
    # from eax
    set $ax = $eax & 0xffff
    set $al = $ax & 0xff
    set $ah = $ax >> 8
    # from ebx
    set $bx = $ebx & 0xffff
    set $bl = $bx & 0xff
    set $bh = $bx >> 8
    # from ecx
    set $cx = $ecx & 0xffff
    set $cl = $cx & 0xff
    set $ch = $cx >> 8
    # from edx
    set $dx = $edx & 0xffff
    set $dl = $dx & 0xff
    set $dh = $dx >> 8
    # from esi
    set $si = $esi & 0xffff
    # from edi
    set $di = $edi & 0xffff		
  end
end
document smallregisters
Create the 16 and 8 bit cpu registers (gdb doesn't have them by default).
And 32bits if we are dealing with 64bits binaries.
end


define stepoframeworkx86
  ## we know that an opcode starting by 0xE8 has a fixed length
  ## for the 0xFF opcodes, we can enumerate what is possible to have
  # first we grab the first 3 bytes from the current program counter
  set $_byte1 = *(unsigned char *) $pc
  set $_byte2 = *(unsigned char *) ($pc+1)
  set $_byte3 = *(unsigned char *) ($pc+2)
  # and start the fun
  # if it's a 0xE8 opcode, the total instruction size will be 5 bytes
  # so we can simply calculate the next address and use a temporary breakpoint ! Voila :)
  set $_nextaddress = 0
  # this one is the must useful for us !!!
  if ($_byte1 == 0xE8)
    set $_nextaddress = $pc + 0x5
  else
    # just other cases we might be interested in... maybe this should be removed since the 0xE8 opcode is the one we will use more
    # this is a big fucking mess and can be improved for sure :) I don't like the way it is ehehehe
    if ($_byte1 == 0xFF)
      # call *%eax (0xFFD0) || call *%edx (0xFFD2) || call *(%ecx) (0xFFD1) || call (%eax) (0xFF10) || call *%esi (0xFFD6) || call *%ebx (0xFFD3) || call   DWORD PTR [edx] (0xFF12)
      if ($_byte2 == 0xD0 || $_byte2 == 0xD1 || $_byte2 == 0xD2 || $_byte2 == 0xD3 || $_byte2 == 0xD6 || $_byte2 == 0x10 || $_byte2 == 0x11 || $_byte2 == 0xD7 || $_byte2 == 0x12)
        set $_nextaddress = $pc + 0x2
      end
      # call *0x??(%ebp) (0xFF55??) || call *0x??(%esi) (0xFF56??) || call *0x??(%edi) (0xFF5F??) || call *0x??(%ebx)
      # call *0x??(%edx) (0xFF52??) || call *0x??(%ecx) (0xFF51??) || call *0x??(%edi) (0xFF57??) || call *0x??(%eax) (0xFF50??)
      if ($_byte2 == 0x55 || $_byte2 == 0x56 || $_byte2 == 0x5F || $_byte2 == 0x53 || $_byte2 == 0x52 || $_byte2 == 0x51 || $_byte2 == 0x57 || $_byte2 == 0x50)
        set $_nextaddress = $pc + 0x3
      end
      # call *0x????????(%ebx) (0xFF93????????) ||
      if ($_byte2 == 0x93 || $_byte2 == 0x94 || $_byte2 == 0x90 || $_byte2 == 0x92 || $_byte2 == 0x95)
        set $_nextaddress = $pc + 6
      end
      # call *0x????????(%ebx,%eax,4) (0xFF94??????????)
      if ($_byte2 == 0x94)
        set $_nextaddress = $pc + 7
      end
    end
  end
  # if we have found a call to bypass we set a temporary breakpoint on next instruction and continue
  if ($_nextaddress != 0)
    if ($arg0 == 1)
      thbreak *$_nextaddress
    else
      tbreak *$_nextaddress
    end
    continue
    # else we just single step
  else
    nexti
  end
end
document stepoframeworkx86
Auxiliary function to stepo command.
end


define cfcx86
  # Carry/Borrow/Extend (C), bit 29
  if ($eflags & 1)
    set $eflags = $eflags & ~0x1
  else
    set $eflags = $eflags | 0x1
  end
end
document cfcx86
Auxiliary function to change x86 Carry Flag.
end


define cfzx86
  # zero (Z), bit 30
  if (($eflags >> 6) & 1)
    set $eflags = $eflags & ~0x40
  else
    set $eflags = $eflags | 0x40
  end
end
document cfzx86
Auxiliary function to change x86 Zero Flag.
end


define hookstopx86
  # Display instructions formats
  if $X86FLAVOR == 0
    set disassembly-flavor intel
  else
    set disassembly-flavor att
  end
end
document hookstopx86
!!! FOR INTERNAL USE ONLY - DO NOT CALL !!!
end
