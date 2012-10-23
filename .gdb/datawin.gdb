# _______________data window__________________
define ddump
  if $argc != 1
    help ddump
  else
    echo \033[34m
    if ($ARM == 1)
      printf "[0x%08X]---------", $data_addr
    end
    if ($MIPS == 1)
      printf "[0x%016lX]-------", $data_addr
    end
    if ($X86 == 1)
      printf "[0x%04X:0x%08X]--", $ds, $data_addr
    end
    if ($X86_64 == 1)
      printf "[0x%04X:0x%016lX]", $ds, $data_addr
    end
    echo \033[34m
    printf "------------------------"
    printf "-------------------------------"
    if ($64BITS == 1)
      printf "-------------------------------------"
    end
    echo \033[1;34m
    printf "[data]\n"
    echo \033[0m
    set $_count = 0
    while ($_count < $arg0)
      set $_i = ($_count * 0x10)
      set $_addr = $data_addr + $_i
      hexdump $_addr
      set $_count++
    end
  end
end
document ddump
Display NUM lines of hexdump for address in $data_addr global variable.
Usage: ddump NUM
end


define dd
  if $argc != 1
    help dd
  else
    set $data_addr = $arg0
    ddump 0x10
  end
end
document dd
Display 16 lines of a hex dump of address starting at ADDR.
Usage: dd ADDR
end


define datawin
  if $ARM == 1
    if ((($r0 >> 0x18) == 0x40) || (($r0 >> 0x18) == 0x08) || (($r0 >> 0x18) == 0xBF))
      set $data_addr = $r0
    else
      if ((($r1 >> 0x18) == 0x40) || (($r1 >> 0x18) == 0x08) || (($r1 >> 0x18) == 0xBF))
        set $data_addr = $r1
      else
        if ((($r2 >> 0x18) == 0x40) || (($r2 >> 0x18) == 0x08) || (($r2 >> 0x18) == 0xBF))
          set $data_addr = $r2
        else
          if ((($r3 >> 0x18) == 0x40) || (($r3 >> 0x18) == 0x08) || (($r3 >> 0x18) == 0xBF))
            set $data_addr = $r3
	  else
            set $data_addr = $sp
	  end
        end
      end
    end
  end

  if $MIPS == 1
    if ((($a0 >> 0x18) == 0x40) || (($a0 >> 0x18) == 0x08) || (($a0 >> 0x18) == 0xBF))
      set $data_addr = $a0
    else
      if ((($a1 >> 0x18) == 0x40) || (($a1 >> 0x18) == 0x08) || (($a1 >> 0x18) == 0xBF))
        set $data_addr = $a1
      else
        if ((($a2 >> 0x18) == 0x40) || (($a2 >> 0x18) == 0x08) || (($a2 >> 0x18) == 0xBF))
          set $data_addr = $a2
	else
          if ((($a3 >> 0x18) == 0x40) || (($a3 >> 0x18) == 0x08) || (($a3 >> 0x18) == 0xBF))
            set $data_addr = $a3
          else
            set $data_addr = $sp
	  end
        end
      end
    end
  end

  if ($X86_64 == 1)
    if ((($rsi >> 0x18) == 0x40) || (($rsi >> 0x18) == 0x08) || (($rsi >> 0x18) == 0xBF))
      set $data_addr = $rsi
    else
      if ((($rdi >> 0x18) == 0x40) || (($rdi >> 0x18) == 0x08) || (($rdi >> 0x18) == 0xBF))
        set $data_addr = $rdi
      else
        if ((($rax >> 0x18) == 0x40) || (($rax >> 0x18) == 0x08) || (($rax >> 0x18) == 0xBF))
          set $data_addr = $rax
        else
          set $data_addr = $rsp
        end
      end
    end
  end

  if ($X86 == 1)
    if ((($esi >> 0x18) == 0x40) || (($esi >> 0x18) == 0x08) || (($esi >> 0x18) == 0xBF))
      set $data_addr = $esi
    else
      if ((($edi >> 0x18) == 0x40) || (($edi >> 0x18) == 0x08) || (($edi >> 0x18) == 0xBF))
        set $data_addr = $edi
      else
        if ((($eax >> 0x18) == 0x40) || (($eax >> 0x18) == 0x08) || (($eax >> 0x18) == 0xBF))
          set $data_addr = $eax
        else
          set $data_addr = $esp
        end
      end
    end
  end
  ddump $CONTEXTSIZE_DATA
end
document datawin
Display valid address from one register in data window.
Registers to choose are: esi, edi, eax, or esp.
end
