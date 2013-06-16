define setup-detect-target
  set $ARM = 0
  set $X86 = 0
  set $X86_64 = 0
  set $MIPS = 0

  set $64BITS = 0

  set logging file /tmp/gdb_info_target
  set logging overwrite on
  set logging redirect on
  set logging on
  set pagination off
  info target
  show osabi
  set pagination on
  set logging off
  set logging redirect off
  set logging overwrite off

  shell ~/.gdb/detect-target.sh
  source /tmp/gdb_target_arch.gdb
  shell rm -f /tmp/gdb_info_target /tmp/gdb_target_arch.gdb
end
document setup-detect-target
Sets up various globals used throughout the GDB macros to provide
architecture-specific support.
end
