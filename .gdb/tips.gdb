# _________________user tips_________________
# The 'tips' command is used to provide tutorial-like info to the user
define tips
  printf "Tip Topic Commands:\n"
  printf "\ttip_display : Automatically display values on each break\n"
  printf "\ttip_patch   : Patching binaries\n"
  printf "\ttip_strip   : Dealing with stripped binaries\n"
  printf "\ttip_syntax  : AT&T vs Intel syntax\n"
end
document tips
Provide a list of tips from users on various topics.
end


define tip_patch
  printf "\n"
  printf "                   PATCHING MEMORY\n"
  printf "Any address can be patched using the 'set' command:\n"
  printf "\t`set ADDR = VALUE` \te.g. `set *0x8049D6E = 0x90`\n"
  printf "\n"
  printf "                 PATCHING BINARY FILES\n"
  printf "Use `set write` in order to patch the target executable\n"
  printf "directly, instead of just patching memory\n"
  printf "\t`set write on` \t`set write off`\n"
  printf "Note that this means any patches to the code or data segments\n"
  printf "will be written to the executable file\n"
  printf "When either of these commands has been issued,\n"
  printf "the file must be reloaded.\n"
  printf "\n"
end
document tip_patch
Tips on patching memory and binary files.
end


define tip_strip
  printf "\n"
  printf "             STOPPING BINARIES AT ENTRY POINT\n"
  printf "Stripped binaries have no symbols, and are therefore tough to\n"
  printf "start automatically. To debug a stripped binary, use\n"
  printf "\tinfo file\n"
  printf "to get the entry point of the file\n"
  printf "The first few lines of output will look like this:\n"
  printf "\tSymbols from '/tmp/a.out'\n"
  printf "\tLocal exec file:\n"
  printf "\t        `/tmp/a.out', file type elf32-i386.\n"
  printf "\t        Entry point: 0x80482e0\n"
  printf "Use this entry point to set an entry point:\n"
  printf "\t`tbreak *0x80482e0`\n"
  printf "The breakpoint will delete itself after the program stops as\n"
  printf "the entry point\n"
  printf "\n"
end
document tip_strip
Tips on dealing with stripped binaries.
end


define tip_syntax
  printf "\n"
  printf "\t    INTEL SYNTAX                        AT&T SYNTAX\n"
  printf "\tmnemonic dest, src, imm            mnemonic src, dest, imm\n"
  printf "\t[base+index*scale+disp]            disp(base, index, scale)\n"
  printf "\tregister:      eax                 register:      %%eax\n"
  printf "\timmediate:     0xFF                immediate:     $0xFF\n"
  printf "\tdereference:   [addr]              dereference:   addr(,1)\n"
  printf "\tabsolute addr: addr                absolute addr: *addr\n"
  printf "\tbyte insn:     mov byte ptr        byte insn:     movb\n"
  printf "\tword insn:     mov word ptr        word insn:     movw\n"
  printf "\tdword insn:    mov dword ptr       dword insn:    movd\n"
  printf "\tfar call:      call far            far call:      lcall\n"
  printf "\tfar jump:      jmp far             far jump:      ljmp\n"
  printf "\n"
  printf "Note that order of operands in reversed, and that AT&T syntax\n"
  printf "requires that all instructions referencing memory operands \n"
  printf "use an operand size suffix (b, w, d, q)\n"
  printf "\n"
end
document tip_syntax
Summary of Intel and AT&T syntax differences.
end


define tip_display
  printf "\n"
  printf "Any expression can be set to automatically be displayed every time\n"
  printf "the target stops. The commands for this are:\n"
  printf "\t`display expr'     : automatically display expression 'expr'\n"
  printf "\t`display'          : show all displayed expressions\n"
  printf "\t`undisplay num'    : turn off autodisplay for expression # 'num'\n"
  printf "Examples:\n"
  printf "\t`display/x *(int *)$esp`      : print top of stack\n"
  printf "\t`display/x *(int *)($ebp+8)`  : print first parameter\n"
  printf "\t`display (char *)$esi`        : print source string\n"
  printf "\t`display (char *)$edi`        : print destination string\n"
  printf "\n"
end
document tip_display
Tips on automatically displaying values when a program stops.
end
