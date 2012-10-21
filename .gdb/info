define stack
  if $argc == 0
    info stack
  end
  if $argc == 1
    info stack $arg0
  end
  if $argc > 1
    help stack
  end
end
document stack
Print backtrace of the call stack, or innermost COUNT frames.
Usage: stack <COUNT>
end


define frame
  info frame
  info args
  info locals
end
document frame
Print stack frame.
end


define func
  if $argc == 0
    info functions
  end
  if $argc == 1
    info functions $arg0
  end
  if $argc > 1
    help func
  end
end
document func
Print all function names in target, or those matching REGEXP.
Usage: func <REGEXP>
end


define var
  if $argc == 0
    info variables
  end
  if $argc == 1
    info variables $arg0
  end
  if $argc > 1
    help var
  end
end
document var
Print all global and static variable names (symbols), or those matching REGEXP.
Usage: var <REGEXP>
end


define lib
  info sharedlibrary
end
document lib
Print shared libraries linked to target.
end


define sig
  if $argc == 0
    info signals
  end
  if $argc == 1
    info signals $arg0
  end
  if $argc > 1
    help sig
  end
end
document sig
Print what debugger does when program gets various signals.
Specify a SIGNAL as argument to print info on that signal only.
Usage: sig <SIGNAL>
end


define threads
  info threads
end
document threads
Print threads in target.
end
