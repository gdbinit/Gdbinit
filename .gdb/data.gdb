# __________hex/ascii dump an address_________
define ascii_char
  if $argc != 1
    help ascii_char
  else
    # thanks elaine :)
    set $_c = *(unsigned char *) ($arg0)
    if ($_c < 0x20 || $_c > 0x7E)
      printf "."
    else
      printf "%c", $_c
    end
  end
end
document ascii_char
Print ASCII value of byte at address ADDR.
Print "." if the value is unprintable.
Usage: ascii_char ADDR
end


define hex_quad
  if $argc != 1
    help hex_quad
  else
    printf "%02X %02X %02X %02X %02X %02X %02X %02X", \
           *(unsigned char*) ($arg0), *(unsigned char*) ($arg0 + 1), \
           *(unsigned char*) ($arg0 + 2), *(unsigned char*) ($arg0 + 3), \
           *(unsigned char*) ($arg0 + 4), *(unsigned char*) ($arg0 + 5), \
	   *(unsigned char*) ($arg0 + 6), *(unsigned char*) ($arg0 + 7)
  end
end
document hex_quad
Print eight hexadecimal bytes starting at address ADDR.
Usage: hex_quad ADDR
end


define hexdump
  if $argc == 1
    hexdump_aux $arg0
  else
    if $argc == 2
      set $_count = 0
      while ($_count < $arg1)
	set $_i = ($_count * 0x10)
	set $_addr = $data_addr + $_i
	hexdump_aux $_addr
	set $_count++
      end
    else
      help hexdump
    end
  end
end
document hexdump
Display a 16-byte hex/ASCII dump of memory starting at address ADDR.
Optional parameter is the number of lines to display if you want more than one.
Usage: hexdump ADDR [nr lines]
end


define hexdump_aux
  if $argc != 1
    help hexdump_aux
  else
    echo \033[1m
    if ($64BITS == 1)
      printf "0x%016lX : ", $arg0
    else
      printf "0x%08X : ", $arg0
    end
    echo \033[0m
    hex_quad $arg0
    echo \033[1m
    printf " - "
    echo \033[0m
    set $_addr = $arg0 + 8
    hex_quad $_addr
    printf " "
    echo \033[1m
    set $_count = 0
    while ($_count < 0xf)
      set $_addr = $arg0 + $_count
      ascii_char $_addr
      set $_count++
    end
    echo \033[0m
    printf "\n"
  end
end
document hexdump_aux
Display a 16-byte hex/ASCII dump of memory at address ADDR.
Usage: hexdump_aux ADDR
end


define search
  set $start = (char *) $arg0
  set $end = (char *) $arg1
  set $pattern = (short) $arg2
  set $p = $start
  while $p < $end
    if (*(short *) $p) == $pattern
      printf "pattern 0x%hx found at 0x%x\n", $pattern, $p
    end
    set $p++
  end
end
document search
Search for the given pattern beetween $start and $end address.
Usage: search <start> <end> <pattern>
end
