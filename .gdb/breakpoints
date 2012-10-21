define bpl
  info breakpoints
end
document bpl
List all breakpoints.
end


define bp
  if $argc != 1
    help bp
  else
    break $arg0
  end
end
document bp
Set breakpoint.
Usage: bp LOCATION
LOCATION may be a line number, function name, or "*" and an address.
To break on a symbol you must enclose symbol name inside "".
Example:
bp "[NSControl stringValue]"
Or else you can use directly the break command (break [NSControl stringValue])
end


define bpc
  if $argc != 1
    help bpc
  else
    clear $arg0
  end
end
document bpc
Clear breakpoint.
Usage: bpc LOCATION
LOCATION may be a line number, function name, or "*" and an address.
end


define bpe
  if $argc != 1
    help bpe
  else
    enable $arg0
  end
end
document bpe
Enable breakpoint with number NUM.
Usage: bpe NUM
end


define bpd
  if $argc != 1
    help bpd
  else
    disable $arg0
  end
end
document bpd
Disable breakpoint with number NUM.
Usage: bpd NUM
end


define bpt
  if $argc != 1
    help bpt
  else
    tbreak $arg0
  end
end
document bpt
Set a temporary breakpoint.
This breakpoint will be automatically deleted when hit!.
Usage: bpt LOCATION
LOCATION may be a line number, function name, or "*" and an address.
end


define bpm
  if $argc != 1
    help bpm
  else
    awatch $arg0
  end
end
document bpm
Set a read/write breakpoint on EXPRESSION, e.g. *address.
Usage: bpm EXPRESSION
end


define bhb
  if $argc != 1
    help bhb
  else
    hb $arg0
  end
end
document bhb
Set hardware assisted breakpoint.
Usage: bhb LOCATION
LOCATION may be a line number, function name, or "*" and an address.
end


define bht
  if $argc != 1
    help bht
  else
    thbreak $arg0
  end
end
document bht
Set a temporary hardware breakpoint.
This breakpoint will be automatically deleted when hit!
Usage: bht LOCATION
LOCATION may be a line number, function name, or "*" and an address.
end
