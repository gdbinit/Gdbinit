# used by ptraceme/rptraceme
set $ptrace_bpnum = 0

# _______________process control______________
define n
  if $argc == 0
    nexti
  end
  if $argc == 1
    nexti $arg0
  end
  if $argc > 1
    help n
  end
end
document n
Step one instruction, but proceed through subroutine calls.
If NUM is given, then repeat it NUM times or till program stops.
This is alias for nexti.
Usage: n <NUM>
end


define go
  if $argc == 0
    stepi
  end
  if $argc == 1
    stepi $arg0
  end
  if $argc > 1
    help go
  end
end
document go
Step one instruction exactly.
If NUM is given, then repeat it NUM times or till program stops.
This is alias for stepi.
Usage: go <NUM>
end


define pret
  finish
end
document pret
Execute until selected stack frame returns (step out of current call).
Upon return, the value returned is printed and put in the value history.
end


define init
  set $SHOW_NEST_INSN = 0
  tbreak _init
  r
end
document init
Run program and break on _init().
end


define start
  set $SHOW_NEST_INSN = 0
  tbreak _start
  r
end
document start
Run program and break on _start().
end


define sstart
  set $SHOW_NEST_INSN = 0
  tbreak __libc_start_main
  r
end
document sstart
Run program and break on __libc_start_main().
Useful for stripped executables.
end


define main
  set $SHOW_NEST_INSN = 0
  tbreak main
  r
end
document main
Run program and break on main().
end


# FIXME64
#### WARNING ! WARNING !!
#### More more messy stuff starting !!!
#### I was thinking about how to do this and then it ocurred me that it could be as simple as this ! :)
define stepoframework
  if $ARM == 1
    stepoframeworkarm
  end

  if (($X86 == 1) || ($X86_64 == 1))
    stepoframeworkx86
  end
end
document stepoframework
Auxiliary function to stepo command.
end

define stepo
  stepoframework 0
end
document stepo
Step over calls (interesting to bypass the ones to msgSend).
This function will set a temporary breakpoint on next instruction after the call so the call will be bypassed.
You can safely use it instead nexti or n since it will single step code if it's not a call instruction (unless you want to go into the call function).
end


define stepoh
  stepoframework 1
end
document stepoh
Same as stepo command but uses temporary hardware breakpoints.
end


# FIXME: ARM
define skip
  x/2i $pc
  set $instruction_size = (int) ($_ - $pc)
  set $pc = $pc + $instruction_size
  if ($SKIPEXECUTE == 1)
    if ($SKIPSTEP == 1)
      stepo
    else
      stepi
    end
  else
    context
  end
end
document skip
Skip over the instruction located at EIP/RIP. By default, the instruction will not be executed!
Some configurable options are available on top of gdbinit to override this.
end


define step_to_call
  set $_saved_ctx = $SHOW_CONTEXT
  set $SHOW_CONTEXT = 0
  set $SHOW_NEST_INSN = 0

  set logging file /dev/null
  set logging redirect on
  set logging on

  set $_cont = 1
  while ($_cont > 0)
    stepi
    get_insn_type $pc
    if ($INSN_TYPE == 3)
      set $_cont = 0
    end
  end

  set logging off

  if ($_saved_ctx > 0)
    context
  end

  set $SHOW_CONTEXT = $_saved_ctx
  set $SHOW_NEST_INSN = 0

  set logging file ~/gdb.txt
  set logging redirect off
  set logging on

  printf "step_to_call command stopped at:\n  "
  x/i $pc
  printf "\n"
  set logging off
end
document step_to_call
Single step until a call instruction is found.
Stop before the call is taken.
Log is written into the file ~/gdb.txt.
end


define trace_calls

  printf "Tracing...please wait...\n"

  set $_saved_ctx = $SHOW_CONTEXT
  set $SHOW_CONTEXT = 0
  set $SHOW_NEST_INSN = 0
  set $_nest = 1
  set listsize 0

  set logging overwrite on
  set logging file ~/gdb_trace_calls.txt
  set logging on
  set logging off
  set logging overwrite off

  while ($_nest > 0)
    get_insn_type $pc
    # handle nesting
    if ($INSN_TYPE == 3)
      set $_nest = $_nest + 1
    else
      if ($INSN_TYPE == 4)
        set $_nest = $_nest - 1
      end
    end
    # if a call, print it
    if ($INSN_TYPE == 3)
      set logging file ~/gdb_trace_calls.txt
      set logging redirect off
      set logging on

      set $x = $_nest - 2
      while ($x > 0)
        printf "\t"
        set $x = $x - 1
      end
      x/i $pc
    end

    set logging off
    set logging file /dev/null
    set logging redirect on
    set logging on
    stepi
    set logging redirect off
    set logging off
  end

  set $SHOW_CONTEXT = $_saved_ctx
  set $SHOW_NEST_INSN = 0

  printf "Done, check ~/gdb_trace_calls.txt\n"
end
document trace_calls
Create a runtime trace of the calls made by target.
Log overwrites(!) the file ~/gdb_trace_calls.txt.
end


define trace_run

  printf "Tracing...please wait...\n"

  set $_saved_ctx = $SHOW_CONTEXT
  set $SHOW_CONTEXT = 0
  set $SHOW_NEST_INSN = 1
  set logging overwrite on
  set logging file ~/gdb_trace_run.txt
  set logging redirect on
  set logging on
  set $_nest = 1

  while ($_nest > 0)
    get_insn_type $pc
    # jmp, jcc, or cll
    if ($INSN_TYPE == 3)
      set $_nest = $_nest + 1
    else
      # ret
      if ($INSN_TYPE == 4)
        set $_nest = $_nest - 1
      end
    end
    stepi
  end

  printf "\n"

  set $SHOW_CONTEXT = $_saved_ctx
  set $SHOW_NEST_INSN = 0
  set logging redirect off
  set logging off

  # clean up trace file
  shell  grep -v ' at ' ~/gdb_trace_run.txt > ~/gdb_trace_run.1
  shell  grep -v ' in ' ~/gdb_trace_run.1 > ~/gdb_trace_run.txt
  shell  rm -f ~/gdb_trace_run.1
  printf "Done, check ~/gdb_trace_run.txt\n"
end
document trace_run
Create a runtime trace of target.
Log overwrites(!) the file ~/gdb_trace_run.txt.
end

#define ptraceme
#  catch syscall ptrace
#  commands
#    if ($X86 == 1)
#      if ($ebx == 0)
#        set $eax = 0
#        continue
#      end
#    end
#
#    if ($X86_64 == 1)
#      if ($rdi == 0)
#        set $rax = 0
#        continue
#      end
#    end
#  end
#  set $ptrace_bpnum = $bpnum
#end
#document ptraceme
#Hook ptrace to bypass PTRACE_TRACEME anti debugging technique
#end

define rptraceme
  if ($ptrace_bpnum != 0)
    delete $ptrace_bpnum
    set $ptrace_bpnum = 0
  end
end
document rptraceme
Remove ptrace hook.
end
