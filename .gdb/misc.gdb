# ____________________misc____________________
# bunch of semi-useless commands

# enable and disable shortcuts for stop-on-solib-events fantastic trick!
define enablesolib
  set stop-on-solib-events 1
  printf "Stop-on-solib-events is enabled!\n"
end
document enablesolib
Shortcut to enable stop-on-solib-events trick.
end


define disablesolib
  set stop-on-solib-events 0
  printf "Stop-on-solib-events is disabled!\n"
end
document disablesolib
Shortcut to disable stop-on-solib-events trick.
end


# enable commands for different displays
define enableobjectivec
  set $SHOWOBJECTIVEC = 1
end
document enableobjectivec
Enable display of objective-c information in the context window.
end


define enablecpuregisters
  set $SHOWCPUREGISTERS = 1
end
document enablecpuregisters
Enable display of cpu registers in the context window.
end


define enablestack
  set $SHOWSTACK = 1
end
document enablestack
Enable display of stack in the context window.
end


define enabledatawin
  set $SHOWDATAWIN = 1
end
document enabledatawin
Enable display of data window in the context window.
end


# disable commands for different displays
define disableobjectivec
  set $SHOWOBJECTIVEC = 0
end
document disableobjectivec
Disable display of objective-c information in the context window.
end


define disablecpuregisters
  set $SHOWCPUREGISTERS = 0
end
document disablecpuregisters
Disable display of cpu registers in the context window.
end


define disablestack
  set $SHOWSTACK = 0
end
document disablestack
Disable display of stack information in the context window.
end


define disabledatawin
  set $SHOWDATAWIN = 0
end
document disabledatawin
Disable display of data window in the context window.
end


define 32bits
  set $64BITS = 0
  if $X86FLAVOR == 0
    set disassembly-flavor intel
  else
    set disassembly-flavor att
  end
end
document 32bits
Set gdb to work with 32bits binaries.
end


define 64bits
  set $64BITS = 1
  if $X86FLAVOR == 0
    set disassembly-flavor intel
  else
    set disassembly-flavor att
  end
end
document 64bits
Set gdb to work with 64bits binaries.
end


define arm
  if $ARMOPCODES == 1
    set arm show-opcode-bytes 1
  else
    set arm show-opcode-bytes 1
  end
  set $ARM = 1
  set $64BITS = 0
end
document arm
Set gdb to work with ARM binaries.
end


define enablelib
  set stop-on-solib-events 1
end
document enablelib
Activate stop-on-solib-events.
end


define disablelib
  set stop-on-solib-events 0
end
document disablelib
Deactivate stop-on-solib-events.
end


define intelsyntax
  if (($X86 == 1) || ($X86_64 == 1))
    set disassembly-flavor intel
    set $X86FLAVOR = 0
  end
end
document intelsyntax
Change disassembly syntax to intel flavor.
end


define attsyntax
  if (($X86 == 1) || ($X86_64 == 1))
    set disassembly-flavor att
    set $X86FLAVOR = 1
  end
end
document attsyntax
Change disassembly syntax to at&t flavor.
end
