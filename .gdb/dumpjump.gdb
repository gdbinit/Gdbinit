################################
##### ALERT ALERT ALERT ########
################################
# Huge mess going here :) HAHA #
################################
define dumpjump
  if $ARM == 1
    ## Most ARM and Thumb instructions are conditional!
    # each instruction is 32 bits long
    # 4 bits are for condition codes (16 in total) (bits 31:28 in ARM contain the condition or 1111 if instruction is unconditional)
    # 2x4 bits for destination and first operand registers
    # one for the set-status flag
    # an assorted number for other stuff
    # 12 bits for any immediate value
    # $_t_flag == 0 => ARM mode
    # $_t_flag == 1 => Thumb or ThumbEE
    if ($cpsr->t & 1)
      set $_t_flag = 1
    else
      set $_t_flag = 0
    end

    if $_t_flag == 0
      set $_lastbyte = *(unsigned char *)($pc+3)
      #set $_bit31 = ($_lastbyte >> 7) & 1
      #set $_bit30 = ($_lastbyte >> 6) & 1
      #set $_bit29 = ($_lastbyte >> 5) & 1
      #set $_bit28 = ($_lastbyte >> 4) & 1
      set $_conditional = $_lastbyte >> 4
      dumpjumphelper
    else
      # if bits 15-12 (opcode in Thumb instructions) are equal to 1 1 0 1 (0xD) then we have a conditional branch
      # bits 11-8 for the conditional execution code (check ARMv7 manual A8.3)
      if ((*(unsigned char *) ($pc + 1) >> 4) == 0xD)
	set $_conditional = *(unsigned char *) ($pc+1) ^ 0xD0
        dumpjumphelper
      end
    end
  end

  if (($X86 == 1) || ($X86_64 == 1))
    ## grab the first two bytes from the instruction so we can determine the jump instruction
    set $_byte1 = *(unsigned char *) $pc
    set $_byte2 = *(unsigned char *) ($pc+1)
    ## and now check what kind of jump we have (in case it's a jump instruction)
    ## I changed the flags routine to save the flag into a variable, so we don't need to repeat the process :) (search for "define flags")

    ## opcode 0x77: JA, JNBE (jump if CF=0 and ZF=0)
    ## opcode 0x0F87: JNBE, JA
    if (($_byte1 == 0x77) || ($_byte1 == 0x0F && $_byte2 == 0x87))
      # cf=0 and zf=0
      if ($_cf_flag == 0 && $_zf_flag == 0)
	echo \033[31m
        printf "  Jump is taken (c=0 and z=0)"
      else
        # cf != 0 or zf != 0
        echo \033[31m
        printf "  Jump is NOT taken (c!=0 or z!=0)"
      end
    end
    ## opcode 0x73: JAE, JNB, JNC (jump if CF=0)
    ## opcode 0x0F83: JNC, JNB, JAE (jump if CF=0)
    if (($_byte1 == 0x73) || ($_byte1 == 0x0F && $_byte2 == 0x83))
      # cf=0
      if ($_cf_flag == 0)
	echo \033[31m
        printf "  Jump is taken (c=0)"
      else
        # cf != 0
        echo \033[31m
   	printf "  Jump is NOT taken (c!=0)"
      end
    end
    ## opcode 0x72: JB, JC, JNAE (jump if CF=1)
    ## opcode 0x0F82: JNAE, JB, JC
    if (($_byte1 == 0x72) || ($_byte1 == 0x0F && $_byte2 == 0x82))
      # cf=1
      if ($_cf_flag == 1)
	echo \033[31m
        printf "  Jump is taken (c=1)"
      else
        # cf != 1
        echo \033[31m
   	printf "  Jump is NOT taken (c!=1)"
      end
    end
    ## opcode 0x76: JBE, JNA (jump if CF=1 or ZF=1)
    ## opcode 0x0F86: JBE, JNA
    if (($_byte1 == 0x76) || ($_byte1 == 0x0F && $_byte2 == 0x86))
      # cf=1 or zf=1
      if (($_cf_flag == 1) || ($_zf_flag == 1))
	echo \033[31m
        printf "  Jump is taken (c=1 or z=1)"
      else
        # cf != 1 or zf != 1
        echo \033[31m
        printf "  Jump is NOT taken (c!=1 or z!=1)"
      end
    end
    ## opcode 0xE3: JCXZ, JECXZ, JRCXZ (jump if CX=0 or ECX=0 or RCX=0)
    if ($_byte1 == 0xE3)
      # cx=0 or ecx=0
      if (($ecx == 0) || ($cx == 0))
        echo \033[31m
   	printf "  Jump is taken (cx=0 or ecx=0)"
      else
   	echo \033[31m
       	printf "  Jump is NOT taken (cx!=0 or ecx!=0)"
      end
    end
    ## opcode 0x74: JE, JZ (jump if ZF=1)
    ## opcode 0x0F84: JZ, JE, JZ (jump if ZF=1)
    if (($_byte1 == 0x74) || ($_byte1 == 0x0F && $_byte2 == 0x84))
      # ZF = 1
      if ($_zf_flag == 1)
   	echo \033[31m
        printf "  Jump is taken (z=1)"
      else
        # ZF = 0
        echo \033[31m
   	printf "  Jump is NOT taken (z!=1)"
      end
    end
    ## opcode 0x7F: JG, JNLE (jump if ZF=0 and SF=OF)
    ## opcode 0x0F8F: JNLE, JG (jump if ZF=0 and SF=OF)
    if (($_byte1 == 0x7F) || ($_byte1 == 0x0F && $_byte2 == 0x8F))
      # zf = 0 and sf = of
      if (($_zf_flag == 0) && ($_sf_flag == $_of_flag))
   	echo \033[31m
   	printf "  Jump is taken (z=0 and s=o)"
      else
   	echo \033[31m
   	printf "  Jump is NOT taken (z!=0 or s!=o)"
      end
    end
    ## opcode 0x7D: JGE, JNL (jump if SF=OF)
    ## opcode 0x0F8D: JNL, JGE (jump if SF=OF)
    if (($_byte1 == 0x7D) || ($_byte1 == 0x0F && $_byte2 == 0x8D))
      # sf = of
      if ($_sf_flag == $_of_flag)
   	echo \033[31m
   	printf "  Jump is taken (s=o)"
      else
   	echo \033[31m
   	printf "  Jump is NOT taken (s!=o)"
      end
    end
    ## opcode: 0x7C: JL, JNGE (jump if SF != OF)
    ## opcode: 0x0F8C: JNGE, JL (jump if SF != OF)
    if (($_byte1 == 0x7C) || ($_byte1 == 0x0F && $_byte2 == 0x8C))
      # sf != of
      if ($_sf_flag != $_of_flag)
   	echo \033[31m
   	printf "  Jump is taken (s!=o)"
      else
        echo \033[31m
   	printf "  Jump is NOT taken (s=o)"
      end
    end
    ## opcode 0x7E: JLE, JNG (jump if ZF = 1 or SF != OF)
    ## opcode 0x0F8E: JNG, JLE (jump if ZF = 1 or SF != OF)
    if (($_byte1 == 0x7E) || ($_byte1 == 0x0F && $_byte2 == 0x8E))
      # zf = 1 or sf != of
      if (($_zf_flag == 1) || ($_sf_flag != $_of_flag))
   	echo \033[31m
   	printf "  Jump is taken (zf=1 or sf!=of)"
      else
   	echo \033[31m
   	printf "  Jump is NOT taken (zf!=1 or sf=of)"
      end
    end
    ## opcode 0x75: JNE, JNZ (jump if ZF = 0)
    ## opcode 0x0F85: JNE, JNZ (jump if ZF = 0)
    if (($_byte1 == 0x75) || ($_byte1 == 0x0F && $_byte2 == 0x85))
      # ZF = 0
      if ($_zf_flag == 0)
   	echo \033[31m
        printf "  Jump is taken (z=0)"
      else
        # ZF = 1
   	echo \033[31m
   	printf "  Jump is NOT taken (z!=0)"
      end
    end
    ## opcode 0x71: JNO (OF = 0)
    ## opcode 0x0F81: JNO (OF = 0)
    if (($_byte1 == 0x71) || ($_byte1 == 0x0F && $_byte2 == 0x81))
      # OF = 0
      if ($_of_flag == 0)
   	echo \033[31m
   	printf "  Jump is taken (o=0)"
      else
        # OF != 0
        echo \033[31m
        printf "  Jump is NOT taken (o!=0)"
      end
    end
    ## opcode 0x7B: JNP, JPO (jump if PF = 0)
    ## opcode 0x0F8B: JPO (jump if PF = 0)
    if (($_byte1 == 0x7B) || ($_byte1 == 0x0F && $_byte2 == 0x8B))
      # PF = 0
      if ($_pf_flag == 0)
        echo \033[31m
        printf "  Jump is NOT taken (p=0)"
      else
        # PF != 0
        echo \033[31m
   	printf "  Jump is taken (p!=0)"
      end
    end
    ## opcode 0x79: JNS (jump if SF = 0)
    ## opcode 0x0F89: JNS (jump if SF = 0)
    if (($_byte1 == 0x79) || ($_byte1 == 0x0F && $_byte2 == 0x89))
      # SF = 0
      if ($_sf_flag == 0)
   	echo \033[31m
        printf "  Jump is taken (s=0)"
      else
        # SF != 0
        echo \033[31m
   	printf "  Jump is NOT taken (s!=0)"
      end
    end
    ## opcode 0x70: JO (jump if OF=1)
    ## opcode 0x0F80: JO (jump if OF=1)
    if (($_byte1 == 0x70) || ($_byte1 == 0x0F && $_byte2 == 0x80))
      # OF = 1
      if ($_of_flag == 1)
        echo \033[31m
   	printf "  Jump is taken (o=1)"
      else
        # OF != 1
        echo \033[31m
   	printf "  Jump is NOT taken (o!=1)"
      end
    end
    ## opcode 0x7A: JP, JPE (jump if PF=1)
    ## opcode 0x0F8A: JP, JPE (jump if PF=1)
    if (($_byte1 == 0x7A) || ($_byte1 == 0x0F && $_byte2 == 0x8A))
      # PF = 1
      if ($_pf_flag == 1)
   	echo \033[31m
        printf "  Jump is taken (p=1)"
      else
        # PF = 0
        echo \033[31m
   	printf "  Jump is NOT taken (p!=1)"
      end
    end
    ## opcode 0x78: JS (jump if SF=1)
    ## opcode 0x0F88: JS (jump if SF=1)
    if (($_byte1 == 0x78) || ($_byte1 == 0x0F && $_byte2 == 0x88))
      # SF = 1
      if ($_sf_flag == 1)
   	echo \033[31m
        printf "  Jump is taken (s=1)"
      else
        # SF != 1
        echo \033[31m
        printf "  Jump is NOT taken (s!=1)"
      end
    end
  end
end
document dumpjump
Display if conditional jump will be taken or not.
end

define dumpjumphelper
  # 0000 - EQ: Z == 1
  if ($_conditional == 0x0)
    if ($_z_flag == 1)
      echo \033[31m
      printf " Jump is taken (z==1)"
    else
      echo \033[31m
      printf " Jump is NOT taken (z!=1)"
    end
  end
  # 0001 - NE: Z == 0
  if ($_conditional == 0x1)
    if ($_z_flag == 0)
      echo \033[31m
      printf " Jump is taken (z==0)"
    else
      echo \033[31m
      printf " Jump is NOT taken (z!=0)"
    end
  end
  # 0010 - CS: C == 1
  if ($_conditional == 0x2)
    if ($_c_flag == 1)
      echo \033[31m
      printf " Jump is taken (c==1)"
    else
      echo \033[31m
      printf " Jump is NOT taken (c!=1)"
    end
  end
  # 0011 - CC: C == 0
  if ($_conditional == 0x3)
    if ($_c_flag == 0)
      echo \033[31m
      printf " Jump is taken (c==0)"
    else
      echo \033[31m
      printf " Jump is NOT taken (c!=0)"
    end
  end
  # 0100 - MI: N == 1
  if ($_conditional == 0x4)
    if ($_n_flag == 1)
      echo \033[31m
      printf " Jump is taken (n==1)"
    else
      echo \033[31m
      printf " Jump is NOT taken (n!=1)"
    end
  end
  # 0101 - PL: N == 0
  if ($_conditional == 0x5)
    if ($_n_flag == 0)
      echo \033[31m
      printf " Jump is taken (n==0)"
    else
      echo \033[31m
      printf " Jump is NOT taken (n!=0)"
    end
  end
  # 0110 - VS: V == 1
  if ($_conditional == 0x6)
    if ($_v_flag == 1)
      echo \033[31m
      printf " Jump is taken (v==1)"
    else
      echo \033[31m
      printf " Jump is NOT taken (v!=1)"
    end
  end
  # 0111 - VC: V == 0
  if ($_conditional == 0x7)
    if ($_v_flag == 0)
      echo \033[31m
      printf " Jump is taken (v==0)"
    else
      echo \033[31m
      printf " Jump is NOT taken (v!=0)"
    end
  end
  # 1000 - HI: C == 1 and Z == 0
  if ($_conditional == 0x8)
    if ($_c_flag == 1 && $_z_flag == 0)
      echo \033[31m
      printf " Jump is taken (c==1 and z==0)"
    else
      echo \033[31m
      printf " Jump is NOT taken (c!=1 or z!=0)"
    end
  end
  # 1001 - LS: C == 0 or Z == 1
  if ($_conditional == 0x9)
    if ($_c_flag == 0 || $_z_flag == 1)
      echo \033[31m
      printf " Jump is taken (c==0 or z==1)"
    else
      echo \033[31m
      printf " Jump is NOT taken (c!=0 or z!=1)"
    end
  end
  # 1010 - GE: N == V
  if ($_conditional == 0xA)
    if ($_n_flag == $_v_flag)
      echo \033[31m
      printf " Jump is taken (n==v)"
    else
      echo \033[31m
      printf " Jump is NOT taken (n!=v)"
    end
  end
  # 1011 - LT: N != V
  if ($_conditional == 0xB)
    if ($_n_flag != $_v_flag)
      echo \033[31m
      printf " Jump is taken (n!=v)"
    else
      echo \033[31m
      printf " Jump is NOT taken (n==v)"
    end
  end
  # 1100 - GT: Z == 0 and N == V
  if ($_conditional == 0xC)
    if ($_z_flag == 0 && $_n_flag == $_v_flag)
      echo \033[31m
      printf " Jump is taken (z==0 and n==v)"
    else
      echo \033[31m
      printf " Jump is NOT taken (z!=0 or n!=v)"
    end
  end
  # 1101 - LE: Z == 1 or N != V
  if ($_conditional == 0xD)
    if ($_z_flag == 1 || $_n_flag != $_v_flag)
      echo \033[31m
      printf " Jump is taken (z==1 or n!=v)"
    else
      echo \033[31m
      printf " Jump is NOT taken (z!=1 or n==v)"
    end
  end
end
document dumpjumphelper
Helper function to decide if conditional jump will be taken or not, for ARM and Thumb.
end
