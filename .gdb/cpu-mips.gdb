# Initialize these variables else comparisons will fail for colouring
set $oldv0  = 0
set $oldv1  = 0

set $olda0  = 0
set $olda1  = 0
set $olda2  = 0
set $olda3  = 0

set $oldt0  = 0
set $oldt1  = 0
set $oldt2  = 0
set $oldt3  = 0
set $oldt4  = 0
set $oldt5  = 0
set $oldt6  = 0
set $oldt8  = 0
set $oldt9  = 0

set $olds0  = 0
set $olds1  = 0
set $olds2  = 0
set $olds3  = 0
set $olds4  = 0
set $olds5  = 0
set $olds6  = 0
set $olds7  = 0
set $olds8  = 0

set $oldkt0 = 0
set $oldkt1 = 0

set $oldgp  = 0
set $oldsp  = 0
set $oldra  = 0
set $oldat  = 0


define regmips
  # 64bits stuff
  printf "  "

  echo \033[32m
  printf "V0: "
  echo \033[0m
  if $v0
    if ($v0 != $oldv0 && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX  ", $v0
  else
    printf " 0x%016lX  ", 0
  end

  echo \033[32m
  printf "V1: "
  echo \033[0m
  if $v1
    if ($v1 != $oldv1 && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX  ", $v1
  else
    printf " 0x%016lX  ", 0
  end

  echo \033[32m
  printf "A0: "
  echo \033[0m
  if $a0
    if ($a0 != $olda0 && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX  ", $a0
  else
    printf " 0x%016lX  ", 0
  end

  echo \033[32m
  printf "A1: "
  echo \033[0m
  if $a1
    if ($a1 != $olda1 && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX  ", $a1
  else
    printf " 0x%016lX  ", 0
  end

  echo \033[32m
  printf "A2: "
  echo \033[0m
  if $a2
    if ($a2 != $oldt5 && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX", $a2
  else
    printf " 0x%016lX", 0
  end


  # Newline
  printf "\n  "

  echo \033[32m
  printf "A3: "
  echo \033[0m
  if $a3
    if ($a3 != $olda3 && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX  ", $a3
  else
    printf " 0x%016lX  ", 0
  end

  echo \033[32m
  printf "T0: "
  echo \033[0m
  if $t0
    if ($t0 != $oldt0 && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX  ", $t0
  else
    printf " 0x%016lX  ", 0
  end

  echo \033[32m
  printf "T1: "
  echo \033[0m
  if $t1
    if ($t1 != $oldt1 && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX  ", $t1
  else
    printf " 0x%016lX  ", 0
  end

  echo \033[32m
  printf "T2: "
  echo \033[0m
  if $t2
    if ($t2 != $oldt2 && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX  ", $t2
  else
    printf " 0x%016lX  ", 0
  end

  echo \033[32m
  printf "T3: "
  echo \033[0m
  if $t3
    if ($t3 != $oldt3 && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX", $t3
  else
    printf " 0x%016lX", 0
  end


  # Newline
  printf "\n  "

  echo \033[32m
  printf "T4: "
  echo \033[0m
  if $t4
    if ($t4 != $oldt4 && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX  ", $t4
  else
    printf " 0x%016lX  ", 0
  end

  echo \033[32m
  printf "T5: "
  echo \033[0m
  if $t5
    if ($t5 != $oldt5 && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX  ", $t5
  else
    printf " 0x%016lX  ", 0
  end

  echo \033[32m
  printf "T6: "
  echo \033[0m
  if $t6
    if ($t6 != $oldt6 && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX  ", $t6
  else
    printf " 0x%016lX  ", 0
  end

  echo \033[32m
  printf "T7: "
  echo \033[0m
  if $t7
    if ($t7 != $oldt7 && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX  ", $t7
  else
    printf " 0x%016lX  ", 0
  end

  echo \033[32m
  printf "T8: "
  echo \033[0m
  if $t8
    if ($t8 != $oldt8 && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX", $t8
  else
    printf " 0x%016lX", 0
  end


  # Newline
  printf "\n  "

  echo \033[32m
  printf "T9: "
  echo \033[0m
  if $t9
    if ($t9 != $oldt9 && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX  ", $t9
  else
    printf " 0x%016lX  ", 0
  end

  echo \033[32m
  printf "S0: "
  echo \033[0m
  if $s0
    if ($s0 != $olds0 && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX  ", $s0
  else
    printf " 0x%016lX  ", 0
  end

  echo \033[32m
  printf "S1: "
  echo \033[0m
  if $s1
    if ($s1 != $olds1 && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX  ", $s1
  else
    printf " 0x%016lX  ", 0
  end

  echo \033[32m
  printf "S2: "
  echo \033[0m
  if $s2
    if ($s2 != $olds2 && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX  ", $s2
  else
    printf " 0x%016lX  ", 0
  end

  echo \033[32m
  printf "S3: "
  echo \033[0m
  if $s3
    if ($s3 != $olds3 && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX", $s3
  else
    printf " 0x%016lX", 0
  end


  # Newline
  printf "\n  "

  echo \033[32m
  printf "S4: "
  echo \033[0m
  if $s4
    if ($s4 != $olds4 && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX  ", $s4
  else
    printf " 0x%016lX  ", 0
  end

  echo \033[32m
  printf "S5: "
  echo \033[0m
  if $s5
    if ($s5 != $olds5 && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX  ", $s5
  else
    printf " 0x%016lX  ", 0
  end

  echo \033[32m
  printf "S6: "
  echo \033[0m
  if $s6
    if ($s6 != $olds6 && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX  ", $s6
  else
    printf " 0x%016lX  ", 0
  end

  echo \033[32m
  printf "S7: "
  echo \033[0m
  if $s7
    if ($s7 != $olds7 && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX  ", $s7
  else
    printf " 0x%016lX  ", 0
  end

  echo \033[32m
  printf "S8: "
  echo \033[0m
  if $s8
    if ($s8 != $olds8 && $SHOWREGCHANGES == 1)
      echo \033[31m
    end
    printf " 0x%016lX", $s8
  else
    printf " 0x%016lX", 0
  end


  # Newline
  printf "\n\n  "

  echo \033[32m
  printf "0:  "
  echo \033[0m
  printf " 0x%016lX  ", $zero
  echo \033[32m
  printf "AT: "
  echo \033[0m
  printf " 0x%016lX  ", $at
  echo \033[32m
  printf "GP: "
  echo \033[0m
  printf " 0x%016lX  ", $gp
  echo \033[32m
  printf "SP: "
  echo \033[0m
  printf " 0x%016lX", $sp


  # Newline
  printf "\n  "

  echo \033[32m
  printf "KT0:"
  echo \033[0m
  printf " 0x%016lX  ", $kt0
  echo \033[32m
  printf "KT1:"
  echo \033[0m
  printf " 0x%016lX  ", $kt1
  echo \033[0m


  # End of registers
  printf "\n"

  if ($SHOWREGCHANGES == 1)
    if $v0
      set $oldv0  = $v0
    end
    if $v1
      set $oldv1  = $v1
    end

    if $a0
      set $olda0  = $a0
    end
    if $a1
      set $olda1  = $a1
    end
    if $a2
      set $olda2  = $a2
    end
    if $a3
      set $olda3  = $a3
    end

    if $t0
      set $oldt0  = $t0
    end
    if $t1
      set $oldt1  = $t1
    end
    if $t2
      set $oldt2  = $t2
    end
    if $t3
      set $oldt3  = $t3
    end
    if $t4
      set $oldt4  = $t4
    end
    if $t5
      set $oldt5  = $t5
    end
    if $t6
      set $oldt6  = $t6
    end
    if $t7
      set $oldt8  = $t8
    end
    if $t9
      set $oldt9  = $t9
    end

    if $s0
      set $olds0  = $s0
    end
    if $s1
      set $olds1  = $s1
    end
    if $s2
      set $olds2  = $s2
    end
    if $s3
      set $olds3  = $s3
    end
    if $s4
      set $olds4  = $s4
    end
    if $s5
      set $olds5  = $s5
    end
    if $s6
      set $olds6  = $s6
    end
    if $s7
      set $olds8  = $s8
    end

    if $kt0
      set $oldkt0 = $kt0
    end
    if $kt1
      set $oldkt1 = $kt1
    end

    if $gp
      set $oldgp  = $gp
    end
    if $sp
      set $oldsp  = $sp
    end
    if $ra
      set $oldra  = $ra
    end
    if $at
      set $oldat  = $at
    end
  end
end
document regmips
Auxiliary function to display MIPS registers.
end
