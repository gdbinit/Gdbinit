#################################################################################
#                                                                               #
#                         gdbinit-MacsBug-without-plugin                        #
#                                                                               #
#                     Macsbug-style gdb command definitions                     #
#                                                                               #
#                                 Ira L. Ruben                                  #
#                    Copyright Apple Computer, Inc. 2000-2001                   #
#                                                                               #
#################################################################################

# This file can be either sourced'ed in by .gdbinit or explicitly to define a set
# of gdb commands that simulate a subset of MacsBug commands.  It is as faithful
# a simulation as possible within the limits of the gdb command language.  There
# may also be an extension or two where it makes sense in the context of the
# debugging paradigm imposed by gdb.

# See MACSBUG_HELP below (or execute it) for summary documentation of the 
# supported MacsBug commands.  See individual help documentation for more
# details and any MacsBug restrictions imposed on the commands.

# NOTE: The expression syntax used in these functions is written using C
#       syntax so this script is only applicable for debugging C/C++.  If
#       you are trying to debug any other language, you're probably 
#	screwed!

# The author has endeavored to produce as complete a set of MacsBug commands as
# feasible within the restrictions imposed by the rather limited gdb command
# language.  But others may have additional ideas.  So contributions and
# embellishments are welcome, particularly to the types supported by the DM
# command.  The only restrictions are that to be placed in this particular
# universe of commands (i.e., this file), they must be variants of *EXISTING*
# MacsBug commands.  Any other "flavors" do not belong here.

# Revision history
#
#	 1-Sep-2000	ILR	Initial creation.
#	 2-Sep-2000	ILR	Added basic type support to DM.
#				Fixed DB and DW decimal display bug.
#				Changed __print_char to bold octals and handle more
#				  known escape letters.
#				Fixed argument handling to not cause possible
#				  reevaluation of their values in private 
#				  functions.
#				Prefixed all "local" internal function variables
#				  with double underbars to minimize potential
#				  name conflicts with their callers. Damn gdb!
#				More tutorial info in MACSBUG_HELP.
#	 3-Sep-2000	ILR	Added ES, FIND, FB, FW, FL, and FILL commands.
#				Allow SB, SW, SL, SM to have string values using
#				  the same machinery created for FIND and FILL.
#	 4-Sept-2000	ILR	Fixed size checking in SM and set.
#				Add __lower_case function.
#				Set $dot in DM for addr n case and let DM call
#				  __lower_case instead of doing it in DM command.
#				Added GT, DMA, BRM, DX, MSET, and Rn commands.
#				Enhanced DMA and __hexdump to check for repeated
#				  lines under the MSET DITTO state switch.
#				Polished everything up for initial "release",
#				  whatever that means.
#	 5-Sept-2000	ILR	Added PC command.
#				Made memory and disassembly displays contiguous
#				  when possible (i.e., removed the gdb prompt).
#	 9-Sept-2000	ILR	Changed MacsBug S to SI since it's a superset of
#				  gdb's S but essentially the same action.  This
#				  free's up S to be gdb's S which executes single
#				  statements including stepping into called functions.
#				  I prefer to back the MacsBug compatibilty with S
#				  to preserve gdb's S.
#				Changed T command to call SO to emphasize their
#				   same-ness and to have the actual code in one
#				   place just like I do for other aliased commands.
#	12-Sept-2000	ILR	Added 2nd argument to T, SO and SI to disassemble m
#				  lines (default 4) instead of just 1.
#				Removed a debugging printf from IP that I forgot
#				  to previously remove when I was debugging it.
#				T was not missing in the MACSBUG_HELP display.
#				ID's "Disassembly from" format string was missing
#				  a '%' causing a gdb error report.
#	25-Sept-2000	ILR	Added __branch_taken to determine if a conditional
#				  branch at $pc will be taken or not.
#				Added routines to display the registers in various
#				  ways along with disassembly.  Only added, it's
#				  work in progress, and not yet hooked in.
#	 9-Oct-2000	ILR	Call __display_registers_h from __disasmN so that
#				  all disassemblies cause a register display at a
#				  fixed place at the top to the screen.  This is
#				  brain dead version, i.e., no split screen scrolling.
#	 			SM of log values was missing 3rd byte.
#	10-Oct-2000	ILR	MSET UNMANGLE used as toggle was not setting gdb.
#	13-Oct-2000	ILR	Fix DM so that repeated DM commands even with
#				  arguments (i.e., just hitting return to repeat the
#				  DM) causes a contiguous hexdump display.
#				Similar fix for DMA.
#	11-Nov-2000	ILR	__save_all_regs_h now saves compare and count portions
#				  of $xer.
#				__display_registers_h changed to display compare and
#				  count portions of $xer.
#				TD fixed to correct shift value of $xer to get compare
#				  field.
#	16-Nov-2000	ILR	Added test to __branch_taken to not consider "branch
#				  always" branches as conditional branches.
#				Changed __disasmN to use the vertical register display
#				  instead of the horizontal since the horizontal form
#				  screws up the scroll back.  Vertical has less impact.
#	25-Nov-2000	ILR	DM did not default to displaying the amount of the
#				  immediately preceeding DM.
#				__display_registers_h and __display_registers_v changed
#				  to use red and normal/off color instead of red and
#				  black since black is not necessarily the same as
#				  normal on some terminal color schemes.
#       -------------------------------------------------------------------------------
#	12-Dec-2000	ILR	Minor tweaks to various commands.
#				Added RA command ("run again").
#
#	This script now deprecated.  For the Mac it has been replaced with a version
#       that works in conjunction with the Mac gdb plugin support.  Not only does it
#	do all the stuff this script does, it does so much more efficiently (i.e, 
#	it's faster), genaralized many of the functions becuase they are not limited
#	by the gdb command language, and also has a MacsBug-like UI!
#
###################################################################################
###################################################################################

# Current highest command identifier value for $__lastcmd__ is 41

# In each command assign $__lastcmd__ to a unique command number for each new
# command where applicable and update the above comment to make it easier to
# remember what to assign to future commands.

# $__lastcmd__ is not just "noise".  Some MacsBug simulated commands need to
# know what the previous command was to perform the required MacsBug semantics. 

###################################################################################
###################################################################################
#
# MACSBUG_HELP - List of supported commands.
#
define MACSBUG_HELP
    #       12345678901234567890123456789012345678901234567890123456789012345678901234567890
    printf "\n"
    printf "BRC [addr]                  Clear all breakpoints or one breakpoint at addr\n"
    printf "BRD                         Show all breakpoints (or breakpoint n)\n"
    printf "BRM regex                   Set breakpoints at all functs matching regular expr\n"
    printf "BRP [gdb-spec [expr]]       Break at gdb-spec (under specified condition)\n"
    printf "DB addr                     Display in hex the byte at addr (or $dot)\n"
    printf "DL [addr]                   Display in hex the 4 bytes at addr (or $dot)\n"
    printf "DM [addr [n | basicType]]   Display memory from addr for n bytes or as a basic type\n"
    printf "DMA [addr [n]]              Display memory as ASCII from addr for n (default 512) bytes\n"
    printf "DP [addr]                   Display 128 bytes at addr (or $dot)\n"
    printf "DW [addr]                   Display in hex the two bytes at addr (or $dot)\n"
    printf "DX [ON|OFF|NOW|SHOW]        Temporarily enable/disable/toggle breakpoints\n"
    printf "ES                          Exit to shell (unconditionally quit gdb)\n"
    printf "FB addr n expr|\"string\"     Search from addr to addr+n-1 for the byte\n"
    printf "FILL addr n expr|\"string\"   Fill from addr to addr+n-1 with expr or string\n"
    printf "FIND addr n expr            Search from addr to addr+n-1 for the pattern\n"
    printf "FL addr n expr|\"string\"     Search from addr to addr+n-1 for the 4-byte long\n"
    printf "FW addr n expr|\"string\"     Search from addr to addr+n-1 for the 2-byte word\n"
    printf "G [addr]                    Continue execution (at addr if supplied)\n"
    printf "GT gdb-spec                 Go (continue) until the gdb-spec is reached\n"
    printf "ID [addr]                   Disassemble 1 line starting at addr (or pc)\n"
    printf "IDP [addr]                  Same as ID\n"
    printf "IL [addr [n]]               Disassemble n (default 20) lines from the addr (or pc)\n"
    printf "ILP [addr [n]]              Same as IL\n"
    printf "IP [addr]                   Disassemble 20 lines centered around the addr (or pc)\n"
    printf "MR                          Return from current frame\n"
    printf "MSET opt [ON|OFF|NOW|SHOW]  Temporarially change the specified behavior\n"
    printf "PC                          Display the value of the PC\n"
    printf "Rn  (n = 0, ... ,31)        Display the value of register Rn\n"
    printf "SB addr value1 [... value9] Assign up to 9 values to bytes starting at addr\n"
    printf "SC                          Display back trace (stack crawl)\n"
    printf "SC6                         Same as SC\n"
    printf "SC7                         Same as SC\n"
    printf "SI [n] [m]                  Step n (or 1) instruction(s), disassmble m lines\n"
    printf "SL addr value1 [... value9] Assign up to 9 values to (4-byte) longs starting at addr\n"
    printf "SM addr value1 [... value9] Assign up to 9 values to memory starting at addr\n"
    printf "SO [n] [m]                  Step over n instructions, disassmble m lines\n"
    printf "SW addr value1 [... value9] Assign up to 9 values to (2-byte) words starting at addr\n"
    printf "T [n] [m]                   Same as SO\n"
    printf "TD                          Display integer and machine registers\n"
    printf "TF                          Display the floating point registers\n"
    printf "TV                          Display the vector registers (not yet supported)\n"
    printf "\n"
    printf "The $dot gdb variable is the last address referenced by certain commands.\n"
    printf "For instance, SM sets $dot to the first address that was changed.  The\n"
    printf "default for many commands is to use $dot as their address argument.  Typing\n"
    printf "DM will display the memory just set and set the last command to DM.  A\n"
    printf "return after the parameterless DM command will use the $dot set by it to\n"
    printf "display then next block of memory in sequence.\n\n"
    printf "This isn't quite like MacsBug but its as close an approximation as\n"
    printf "possible in the gdb environment.\n"
    printf "\n"
    printf "Other differences between the gdb MacsBug commands and MacsBug itself:\n"
    printf "\n"
    printf "  1. Only C/C++ can be debugged since the gdb commands use C/C++ syntax\n"
    printf "     for their implementation (restriction imposed by gdb).\n\n"
    printf "  2. Arguments are written using C/C++ syntax (e.g., use -> instead of\n"
    printf "     ^, != instead of <>, etc.).\n"
    printf "\n"
    printf "  3. Only one command per line allowed (gdb restriction).\n"
    printf "\n"
    printf "  4. Return executes previous command (gdb convention).  This works\n"
    printf "     like MacsBug after a parameterless version of the command is entered\n"
    printf "     following a parameterized version (like the SM/DM example mentioned\n"
    printf "     above).\n"
    printf "\n"
    printf "  5. $dot instead of '.'.\n"
    printf "\n"
    printf "  6. Some restrictions on the commands that are supported.  Do help on\n"
    printf "     individual commands for details.\n"
    printf "\n"
    printf "  7. Decimal values are shown without leading '#' and hex is shown with\n"
    printf "     a '0x' prefix.\n"
    printf "\n"
    printf "  8. The input radix is as defined by the gdb 'set input-radix' command.\n"
    printf "     The default is decimal unlike MacsBug which is hex.  Use the gdb\n"
    printf "     command 'show input-radix' to verify the input radix.\n"
    printf "\n"
    printf "  9. Most of the MacsBug commands will cause gdb error reports until there\n"
    printf "     is a thread to debug (sometimes the error messages are rather cryptic).\n"
    printf "     So unlike MacsBug where you can issue commands as soon as you enter\n"
    printf "     MacsBug, you will need to start a debugging thread before issuing many\n"
    printf "     of the gdb MacsBug commands.\n"
    printf "\n"
    printf " 10. MSET is a subset of the macsBug SET command (gdb SET already exists).\n"
    printf "\n"
    printf " 11. SI is defined as the MacsBug S command (gdb S already exists).\n"
    printf "\n"
end
document MACSBUG_HELP
MACSBUG_HELP <------- Summarize just the MacsBug commands -------
end

#printf "Type MACSBUG_HELP for help on the MacsBug commands.\n"

###################################################################################
###################################################################################
#
# BRC [addr]
#
define BRC
    if ($argc == 0)
	delete
    else
	clear $arg0
    end
    
    set $__lastcmd__ = 1
end
document BRC
BRC [addr] -- Clear all breakpoints or one breakpoint at addr.
See also gdb's DELETE command (clears breakpoints by number), and DISABLE.
end

###################################################################################
#
# BRD [n]
#
define BRD
    if ($argc == 0)
    	info breakpoints
    else
    	info breakpoints $arg0
    end
    
    set $__lastcmd__ = 2
end
document BRD
BRD -- Show all breakpoints (or breakpoint n).
end

###################################################################################
#
# BRM regex
#
define BRM
    if ($argc == 0)
    	printf "usage: BRM regex (regex expected)\n"
    else
    	if ($argc == 1)
    	    rbreak $arg0
    	else
    	    if ($argc == 2)
    	    	rbreak $arg0 $arg1
    	    else
    	    	if ($argc == 3)
    	    	    rbreak $arg0 $arg1 $arg2
    	    	else
    	    	    if ($argc == 4)
    	    	    	rbreak $arg0 $arg1 $arg2 $arg3
    	    	    else
    	    	    	if ($argc == 5)
    	    	    	    rbreak $arg0 $arg1 $arg2 $arg3 $arg4
    	    	    	else
    	    	    	    if ($argc == 6)
   	    	    	    	rbreak $arg0 $arg1 $arg2 $arg3 $arg4 $arg5
    	    	    	    else
    	    	    	    	if ($argc == 7)
    	    	    	    	    rbreak $arg0 $arg1 $arg2 $arg3 $arg4 $arg5 $arg6
    	    	    	    	else
    	    	    	    	    if ($argc == 8)
    	    	    	    	    	rbreak $arg0 $arg1 $arg2 $arg3 $arg4 $arg5 $arg6 $arg7
    	    	    	    	    else
    	    	    	    	    	if ($argc == 9)
    	    	    	    	    	    rbreak $arg0 $arg1 $arg2 $arg3 $arg4 $arg5 $arg6 $arg7 $arg8
    	    	    	    	    	else
    	    	    	    	    	    # gdb will report error if > 10 args
    	    	    	    	    	    rbreak $arg0 $arg1 $arg2 $arg3 $arg4 $arg5 $arg6 $arg7 $arg8 $arg9
    	    	    	    	    	end
    	    	    	    	    end
    	    	    	    	end
    	    	    	    end
    	    	    	end
    	    	    end
    	    	end
    	    end
    	end
    end
    
    set $__lastcmd__ = 38
end
document BRM
BRM regex -- Set breakpoints at all functions matching regular expression.
This sets unconditional breakpoints on all matches, printing a list of all
breakpoints set.
Ê
Note, due to gdb function limitations there can be no more than 10 "words"
in the BRM regular expression, where a word is a sequence of non-blanks
characters.
end

###################################################################################
#
# BRP [gdb-spec [expr]]
#
define BRP
    if ($argc == 0)
    	br
    else
    	if ($argc == 1)
    	    br $arg0
    	else
    	    if ($argc == 2)
    	    	br $arg0 if $arg1
    	    else
    	    	if ($argc == 3)
    	    	    br $arg0 if $arg1 $arg2
    	    	else
    	    	    if ($argc == 4)
    	    	    	br $arg0 if $arg1 $arg2 $arg3
    	    	    else
    	    	    	if ($argc == 5)
    	    	    	    br $arg0 if $arg1 $arg2 $arg3 $arg4
    	    	    	else
    	    	    	    if ($argc == 6)
   	    	    	    	br $arg0 if $arg1 $arg2 $arg3 $arg4 $arg5
    	    	    	    else
    	    	    	    	if ($argc == 7)
    	    	    	    	    br $arg0 if $arg1 $arg2 $arg3 $arg4 $arg5 $arg6
    	    	    	    	else
    	    	    	    	    if ($argc == 8)
    	    	    	    	    	br $arg0 if $arg1 $arg2 $arg3 $arg4 $arg5 $arg6 $arg7
    	    	    	    	    else
    	    	    	    	    	if ($argc == 9)
    	    	    	    	    	    br $arg0 if $arg1 $arg2 $arg3 $arg4 $arg5 $arg6 $arg7 $arg8
    	    	    	    	    	else
    	    	    	    	    	    # gdb will report error if > 10 args
    	    	    	    	    	    br $arg0 if $arg1 $arg2 $arg3 $arg4 $arg5 $arg6 $arg7 $arg8 $arg9
    	    	    	    	    	end
    	    	    	    	    end
    	    	    	    	end
    	    	    	    end
    	    	    	end
    	    	    end
    	    	end
    	    end
    	end
    end
    
    set $__lastcmd__ = 33
end
document BRP
BRP [gdb-spec [expr]] -- Break at gdb-spec (under specified condition).
This implements the gdb "BREAK gdb-spec [if condition]".  See gdb BREAK
documentation for further details.
Ê
Note, due to gdb function limitations there can be no more than 8 "words"
in the BRP condition expr, where a word is a sequence of non-blanks
characters.
Ê
Macsbug features not supported: Interation count.
Ê                               No semicolon before the command.
Ê                               Command is not enclosed in quotes.
Ê                               Only a single command is allowed.
end

###################################################################################
#
# DB [addr]
#
define DB
    if ($argc == 0)
    	if ($__lastcmd__ == 3)
    	    set $dot = (unsigned char *)$dot + 1
     	    # The following makes the displays contiguous by moving the cursor
    	    # up over the gdb prompt.  But just in case the display would fail
    	    # because the memory is inaccessible we try to access the first
    	    # byte of the display and let gdb error it out before moving the
    	    # cursor if the memory is inaccessible.
    	    set $accessible = *(char *)$dot
    	    printf "%c[2A\n", 0x1B
    	end
    else
    	set $dot = $arg0
    end
        
    set $value = *(unsigned char *)$dot
    
    printf "Byte at %.8X = 0x%.2X   %u    %d    ", $dot, $value, $value, (char)$value
    __print_1 $value
    printf "\n"
    
    set $__lastcmd__ = 3
end
document DB
DB addr -- Display in hex the byte at addr (or $dot).
end

###################################################################################
#
# DL [addr]
#
define DL
    if ($argc == 0)
    	if ($__lastcmd__ == 4)
    	    set $dot = (unsigned char *)$dot + 4
     	    # The following makes the displays contiguous by moving the cursor
    	    # up over the gdb prompt.  But just in case the display would fail
    	    # because the memory is inaccessible we try to access the first
    	    # byte of the display and let gdb error it out before moving the
    	    # cursor if the memory is inaccessible.
    	    set $accessible = *(char *)$dot
    	    printf "%c[2A\n", 0x1B
    	end
    else
    	set $dot = $arg0
    end
    
    set $addr  = $dot
    
    set $value = *(unsigned char *)$addr
    set $addr  = (unsigned char *)$addr + 1
    
    set $value = ((unsigned long)$value << 8) | *(unsigned char *)$addr
    set $addr  = (unsigned char *)$addr + 1
    
    set $value = ((unsigned long)$value << 8) | *(unsigned char *)$addr
    set $addr  = (unsigned char *)$addr + 1

    set $value = ((unsigned long)$value << 8) | *(unsigned char *)$addr

    printf "Four bytes at %.8X = 0x%.8X   %u    %d    ", $dot, $value, $value, $value
    __print_4 $value
    printf "\n"
    
    set $__lastcmd__ = 4
end
document DL
DL [addr] -- Display in hex the 4 bytes at addr (or $dot).
end

# This is written assuming no alignment requiremnts.  However, most machines
# actuall allow unaligned access.   We could actually get away with set
# $value = *(unsigned long *)$addr.  But I'll leave it the way it is since
# that way never has alignement concerns.

###################################################################################
#
# DM [addr [n | basic type]]
#
define DM
    if ($argc == 0)
    	if ($__lastcmd__ == 5)
	    set $dot = (unsigned char *)$dot + $__prev_dm_n__
     	    # The following makes the displays contiguous by moving the cursor
    	    # up over the gdb prompt.  But just in case the display would fail
    	    # because the memory is inaccessible we try to access the first
    	    # byte of the display and let gdb error it out before moving the
    	    # cursor if the memory is inaccessible.
    	    set $accessible = *(char *)$dot
    	    printf "%c[2A\n", 0x1B
    	else
	    printf "Displaying memory from %.8X\n", $dot
	    set $__prev_dm_n__ = 16
	end
	__hexdump $dot
	set $__next_addr__ = (unsigned char *)$dot + 16
	set $__lastcmd__ = 5
    else
	if ($argc == 1)
	    if (0 && $__lastcmd__ == 5 && $__next_addr__ == (unsigned char *)$dot + $__prev_dm_n__)
	    	set $dot = (unsigned char *)$dot + $__prev_dm_n__
	    	set $accessible = *(char *)$dot
	    	printf "%c[2A\n", 0x1B
	    else
	    	set $dot = (unsigned char *)$arg0
	    	printf "Displaying memory from %.8X\n", $dot
	        set $__prev_dm_n__ = 16
	    end
	    __hexdump $dot
	    set $__next_addr__ = (unsigned char *)$dot + 16
	    set $__lastcmd__ = 5
	else
	    set $addr0 = (unsigned char *)$arg0
	    set $n     = (char *)"$arg1"
	    if ($n[0] >= '0' && $n[0] <= '9')
	    	if (0 && $__lastcmd__ == 5 && $__next_addr__ == (unsigned char *)$dot + $__prev_dm_n__)
	    	    set $addr0 = (unsigned char *)$dot + $__prev_dm_n__
	    	    set $accessible = *(char *)$dot
	    	    printf "%c[2A\n", 0x1B
	    	else
	    	    printf "Displaying memory from %.8X\n", $addr0
	    	end
	    	set $dot           = $addr0
	    	set $__prev_dm_n__ = $arg1
	    	__hexdump $dot $__prev_dm_n__
	    	set $__next_addr__ = (unsigned char *)$dot + $__prev_dm_n__
	    	set $__lastcmd__ = 5
	    else
	    	# Basic types displays have no effect on $dot and invalidate the
	    	# previous command ($__lastcmd__) state for all other commands forcing
	    	# them to use the current $dot value as their default.
	    	
	    	set $__lastcmd__ = -5
	    	
	    	# Handle the types specified by MacsBug (or at least trhy to where we can).
	    	
	    	# The types are: Byte, Word, Long, SignedByte, SignedWord, SignedLong,
	    	#                UnsignedByte, UnsignedWord, UnsignedLong, PString,
	    	#                CString, Boolean, Text, Pointer, Handle, IORefNum,
		#		 VRefNum, Seconds, ATrapWord, Binary8, Binary16, Binary32,
		#		 OSType, AbsTicks, TickInterval, RgnHandle, IOTrapWord,
		#		 Version, RGBColor, Fixed, ShortFixed, UnsignedFixed,
		#		 Fract, Rect, and Region.  Who knows what else?  These,
		#		 (actually except for Region) are the only ones
		#		 documented in MacsBug help command.
	    	
		# Because of gdb's brain-dead command language this leads to the mother
		# of all nested if statements!  To avoid overly indenting this turkey and
		# to at least give the taste of a switch statement each "case" is not
		# indented.  Of course this means all the 'end's for the if's pile up at
		# the end of this "switch".  And NO, gdb won't let me comment them either
		# to indicate which 'end' goes with which 'if'.  Trust me, I tried.  I
		# also tried "else if".  Like I said, gdb's command language is brain
		# dead :-(
		
		__lower_case $arg1
		
		set $unsupported = 0
		
		__strcmp $lower_case "byte"
		if ($strcmp)
		    printf "Displaying Byte\n"
		    printf " %.8X: %.2X\n", $addr0, *(unsigned char *)$addr0 & 0xFF
		else
		__strcmp $lower_case "word"
		if ($strcmp)
		    printf "Displaying Word\n"
		    printf " %.8X: %.4X\n", $addr0, *(unsigned short *)$addr0 & 0xFFFF
		else
		__strcmp $lower_case "long"
		if ($strcmp)
		    printf "Displaying Long\n"
		    printf " %.8X: %.8X\n", $addr0, *(unsigned long *)$addr0
		else
		__strcmp $lower_case "signedbyte"
		if ($strcmp)
		    printf "Displaying SignedByte\n"
		    printf " %.8X: %d\n", $addr0, *(char *)$addr0
		else
		__strcmp $lower_case "signedword"
		if ($strcmp)
		    printf "Displaying SignedWord\n"
		    printf " %.8X: %d\n", $addr0, *(short *)$addr0
		else
		__strcmp $lower_case "signedlong"
		if ($strcmp)
		    printf "Displaying SignedLong\n"
		    printf " %.8X: %d\n", $addr0, *(long *)$addr0
		else
		__strcmp $lower_case "unsignedbyte"
		if ($strcmp)
		    printf "Displaying UnsignedByte\n"
		    printf " %.8X: %u\n", $addr0, *(unsigned char *)$addr0
		else
		__strcmp $lower_case "unsignedword"
		if ($strcmp)
		    printf "Displaying UnsignedWord\n"
		    printf " %.8X: %u\n", $addr0, *(unsigned short *)$addr0
		else
		__strcmp $lower_case "unsignedlong"
		if ($strcmp)
		    printf "Displaying UnsignedLong\n"
		    printf " %.8X: %u\n", $addr0, *(unsigned long *)$addr0
		else
		__strcmp $lower_case "pstring"
		if ($strcmp)
		    printf "Displaying PString\n"
		    set $len = *((unsigned char *)$addr0)++
		    printf " %.8X: (%d) \"", $addr0, $len
		    while ($len--)
			set $c = *((unsigned char *)$addr0)++
			__print_char $c 1
		    end
		    printf "\"\n"
		else
		__strcmp $lower_case "cstring"
		if ($strcmp)
		    printf "Displaying CString\n"
		    printf " %.8X: \"",  $addr0
		    set $c = *((unsigned char *)$addr0)++
		    while ($c)
			__print_char $c 1
			set $c = *((unsigned char *)$addr0)++
		    end
		    printf "\"\n"
		else
		__strcmp $lower_case "boolean"
		if ($strcmp)
		    printf "Displaying Boolean\n"
		    if (*(unsigned char *)$addr0)
			printf " %.8X: true\n", $addr0
		    else
			printf " %.8X: false\n", $addr0
		    end
		else
		__strcmp $lower_case "binary8"
		if ($strcmp)
		    printf "Displaying Binary8\n"
		    set $value = *(unsigned char *)$addr0
		    printf " %.8X: %.2X = ", $addr0, $value & 0xFF
		    __binary ($value>>4&15) 4
		    printf " "
		    __binary ($value&15) 4
		    printf "\n"
		else
		__strcmp $lower_case "binary16"
		if ($strcmp)
		    printf "Displaying Binary16\n"
		    set $value = *(unsigned short *)$addr0
		    printf " %.8X: %.4X = ", $addr0, $value & 0xFFFF
		    __binary ($value>>12&15) 4
		    printf " "
		    __binary ($value>>8&15) 4
		    printf " "
		    __binary ($value>>4&15) 4
		    printf " "
		    __binary ($value&15) 4
		    printf "\n"
		else
		__strcmp $lower_case "binary32"
		if ($strcmp)
		    printf "Displaying Binary32\n"
		    set $value = *(unsigned long *)$addr0
		    printf " %.8X: %.8X = ", $addr0, $value
		    __binary ($value>>28&15) 4
		    printf " "
		    __binary ($value>>24&15) 4
		    printf " "
		    __binary ($value>>20&15) 4
		    printf " "
		    __binary ($value>>16&15) 4
		    printf " "
		    __binary ($value>>12&15) 4
		    printf " "
		    __binary ($value>>8&15) 4
		    printf " "
		    __binary ($value>>4&15) 4
		    printf " "
		    __binary ($value&15) 4
		    printf "\n"
		else
		__strcmp $lower_case "ostype"
		if ($strcmp)
		    printf "Displaying OSType\n"
		    set $value = *(unsigned long *)$addr0
		    printf " %.8X: %.8X = ", $addr0, $value
		    __print_4 $value
		    printf "\n"
		else
		__strcmp $lower_case "rect"
		if ($strcmp)
		     printf "Displaying Rect\n"
		     set $addr   = $addr0
		     set $top    = *((unsigned short *)$addr)++
		     set $left   = *((unsigned short *)$addr)++
		     set $bottom = *((unsigned short *)$addr)++
		     set $right  = *((unsigned short *)$addr)
		     printf " %.8X: %d %d %d %d (t,l,b,r) %d %d (w,h)\n", $addr0, \
			      $top, $left, $bottom, $right, $right-$left, $bottom-$top
		else
		__strcmp $lower_case "pointer"
		if ($strcmp)
		    set $unsupported = "Pointer"
		else
		__strcmp $lower_case "handle"
		if ($strcmp)
		    set $unsupported = "Handle"
		else
		__strcmp $lower_case "region"
		if ($strcmp)
		    set $unsupported = "Region"
		else
		__strcmp $lower_case "rgnhandle"
		if ($strcmp)
		    set $unsupported = "RgnHandle"
		else
		__strcmp $lower_case "fixed"
		if ($strcmp)
		    set $unsupported = "Fixed"
		else
		__strcmp $lower_case "shortfixed"
		if ($strcmp)
		    set $unsupported = "ShortFixed"
		else
		__strcmp $lower_case "unsignedfixed"
		if ($strcmp)
		    set $unsupported = "UnsignedFixed"
		else
		__strcmp $lower_case "fract"
		if ($strcmp)
		    set $unsupported = "Fract"
		else
		__strcmp $lower_case "rgbcolor"
		if ($strcmp)
		    set $unsupported = "RGBColor"
		else
		__strcmp $lower_case "text"
		if ($strcmp)
		    set $unsupported = "Text"
		else
		__strcmp $lower_case "iorefnum"
		if ($strcmp)
		    set $unsupported = "IORefNum"
		else
		__strcmp $lower_case "vrefnum"
		if ($strcmp)
		    set $unsupported = "VRefNum"
		else
		__strcmp $lower_case "seconds"
		if ($strcmp)
		    set $unsupported = "Seconds"
		else
		__strcmp $lower_case "atrapword"
		if ($strcmp)
		    set $unsupported = "ATrapWord"
		else
		__strcmp $lower_case "absticks"
		if ($strcmp)
		    set $unsupported = "AbsTicks"
		else
		__strcmp $lower_case "tickinterval"
		if ($strcmp)
		    set $unsupported = "TickInterval"
		else
		__strcmp $lower_case "iotrapword"
		if ($strcmp)
		    set $unsupported = "IOTrapWord"
		else
		__strcmp $lower_case "version"
		if ($strcmp)
		    set $unsupported = "Version"
		else
		    printf "Unrecognized type.\n"
		end
		end
		end
		end
		end
		end
		end
		end
		end
		end
		end
		end
		end
		end
		end
		end
		end
		end
		end
		end
		end
		end
		end
		end
		end
		end
		end
		end
		end
		end
		end
		end
		end
		end
		end
		
		if ($unsupported)
		    printf "%s is not supported in the gdb MacsBug commands.\n", $unsupported
		    printf "Use the gdb PRINT command.  With appropriate type\n"
		    printf "casts you'll probably get better results anyhow.\n"
		end
	    end
	end
    end
end
document DM
DM [addr [n | basic type]] -- Display memory from addr for n bytes or as a basic type.
The basic types are Byte, Word, Long, SignedByte, SignedWord, SignedLong,
UnsignedByte, UnsignedWord, UnsignedLong, PString, CString, Boolean,
Binary8, Binary16, Binary32, OSType, and Rect.
Ê
Also see MSET for DITTO mode.
Ê
Macsbug features not supported: templates and the following basic types.
Ê                               Pointer, Handle, RGBColor, Text, IORefNum,
Ê                               VRefNum, Seconds, ATrapWord, AbsTicks,
Ê                               TickInterval, Region, RgnHandle, IOTrapWord,
Ê                               Version, Fixed, ShortFixed, UnsignedFixed,
Ê                               and Fract.
end

###################################################################################
#
# DMA [addr [n]]
#
define DMA
    if ($argc == 0)
    	if ($__lastcmd__ == 37)
	    set $dot = (unsigned char *)$dot + $__prev_dma_n__
     	    # The following makes the displays contiguous by moving the cursor
    	    # up over the gdb prompt.  But just in case the display would fail
    	    # because the memory is inaccessible we try to access the first
    	    # byte of the display and let gdb error it out before moving the
    	    # cursor if the memory is inaccessible.
    	    set $accessible = *(char *)$dot
    	    printf "%c[2A\n", 0x1B
    	else
    	    printf "Displaying memory from %.8X\n", $dot
	    set $__prev_dma_n__ = 512
	end
    else
    	if (0 && $__lastcmd__ == 37 && $__next_addr__ == (unsigned char *)$dot + $__prev_dma_n__)
    	    set $dot = (unsigned char *)$dot + $__prev_dma_n__
    	    set $accessible = *(char *)$dot
    	    printf "%c[2A\n", 0x1B
    	else
    	    set $dot = (unsigned char *)$arg0
    	    printf "Displaying memory from %.8X\n", $dot
    	end
	if ($argc == 1)
	    set $__prev_dma_n__ = 512
	else
	    set $__prev_dma_n__ = $arg1
    	end
    end
    
    set $addr  = $dot
    set $addr1 = (unsigned char *)$addr + $__prev_dma_n__
    
    set $prevaddr = (unsigned char *)$addr
    set $rep_count = 0
    
    while ($addr < $addr1)
   	# Only allow full ditto lines and never the last line
    	if ((unsigned char *)$addr + 64 < $addr1)
    	    __repeated_dump_line $prevaddr $addr 64
    	else
    	    set $repeated = 0
    	end
    	set $prevaddr = (unsigned char *)$addr

     	if ($repeated)
     	    if ($rep_count++ == 0)
     		printf " %.8X: ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''\n", $addr
     	    end
      	    set $addr = (char *)$addr + 64
	else
	    set $rep_count = 0
	    printf " %.8X: ", $addr
	    set $i = 0
	    while ($i++ < 64 && $addr < $addr1)
		set $x = *((unsigned char *)$addr)++
	   	if ($x >= 0x20 && $x <= 0x7F)
	   	    printf "%c", $x
	   	else
	   	    printf "."
	   	end
	    end
	    printf "\n"
	end
    end
    
    set $__next_addr__ = $addr1
    
    set $__lastcmd__ = 37
end
document DMA
DMA [addr [n]] -- Display memory as ASCII from addr for n (default 512) bytes.
ASCII characters outside the range 0x20 to 0x7F are shown as '.'s.
Ê
Also see MSET for DITTO mode.
end

###################################################################################
#
# DP [addr]
#
define DP
    if ($argc == 0)
    	if ($__lastcmd__ == 6)
    	    set $dot = (unsigned char *)$dot + 128
     	    # The following makes the displays contiguous by moving the cursor
    	    # up over the gdb prompt.  But just in case the display would fail
    	    # because the memory is inaccessible we try to access the first
    	    # byte of the display and let gdb error it out before moving the
    	    # cursor if the memory is inaccessible.
    	    set $accessible = *(char *)$dot
    	    printf "%c[2A\n", 0x1B
    	else
    	    printf "Displaying memory from %.8X\n", $dot
    	end
    else
    	set $dot = $arg0
        printf "Displaying memory from %.8X\n", $dot
    end
        
    __hexdump $dot 128
    
    set $__lastcmd__ = 6
end
document DP
DP [addr] -- Display 128 bytes at addr (or $dot).
end

###################################################################################
#
# DW [addr]
#
define DW
    if ($argc == 0)
    	if ($__lastcmd__ == 7)
    	    set $dot = (unsigned char *)$dot + 2
     	    # The following makes the displays contiguous by moving the cursor
    	    # up over the gdb prompt.  But just in case the display would fail
    	    # because the memory is inaccessible we try to access the first
    	    # byte of the display and let gdb error it out before moving the
    	    # cursor if the memory is inaccessible.
    	    set $accessible = *(char *)$dot
    	    printf "%c[2A\n", 0x1B
    	end
    else
    	set $dot = $arg0
    end
    
    set $addr = $dot
    
    set $value = *(unsigned char *)$addr
    set $addr  = (unsigned char *)$addr + 1

    set $value = ((unsigned long)$value << 8) | *(unsigned char *)$addr
    
    printf "Two bytes at %.8X = 0x%.4X   %u    %d    ", $dot, $value, $value, (short)$value
    __print_2 $value
    printf "\n"
    
    set $__lastcmd__ = 7
end
document DW
DW [addr] -- Display in hex the two bytes at addr (or $dot).
end

# This is written assuming no alignment requiremnts.  However, most machines
# actuall allow unaligned access.   We could actually get away with set
# $value = *(unsigned short *)$addr.  But I'll leave it the way it is since
# that way never has alignement concerns.

###################################################################################
#
# DX [ON | OFF | NOW | SHOW]
#
# Note the "polarity" of the DX state switch is reversed, i.e., 0 means enabled/on,
# 1 means disabled/off.  The reason for this is that if this command could be done
# before the DX state switch is defined (void in gdb, setting it outside the function
# has no effect).  We can only test undefined gdb convenience variables with 'if ($dx)'
# (can't even negate it) which would be false when the switch is undefined, i.e., same
# result as if it were 0.  Our initial default is to be ON, so undefined must also
# mean ON.  Hence the polarity reversal.  #%$@!()& gdb!
#
define DX
    if ($argc == 0)
    	if ($__dx__)
	    set $__dx__ = 0
	    enable breakpoints
	    printf "Breakpoints enabled\n"
	else
	    set $__dx__ = 1
	    disable breakpoints
	    printf "Breakpoints disabled\n"
	end
    else
	__lower_case $arg0
	__strcmp $lower_case "on"
	if ($strcmp)
	    if ($__dx__)
		set $__dx__ = 0
		enable breakpoints
		printf "Breakpoints enabled\n"
	    else
		printf "Breakpoints still enabled\n"
	    end
	else
	    __strcmp $lower_case "off"
	    if ($strcmp)
		if ($__dx__)
		    printf "Breakpoints still disabled\n"
		else
		    set $__dx__ = 1
		    disable breakpoints
		    printf "Breakpoints disabled\n"
		end
	    else
	    	set $e = 1
	    	__strcmp $lower_case "now"
		if ($strcmp)
		    set $e = 0
		else
		    __strcmp $lower_case "show"
		    if ($strcmp)
		    	set $e = 0
		    end
		end
		if ($e || $argc > 1)
		    printf "usage: DX [ON | OFF | NOW | SHOW] (invalid setting)\n"
		else
		    if ($__dx__)
		    	printf "Breakpoints still disabled\n"
		    else
		    	printf "Breakpoints still enabled\n"
		    end
		end
	    end
	end
    end
    
    set $__lastcmd__ = 39
end
document DX
DX [ON | OFF | NOW | SHOW] -- Temporarily enable/disable/toggle breakpoints.
The setting is toggled when there is no argument.
Ê
SHOW is the same as NOW to display the current setting.  It was added
since gdb uses SHOW to show settings.
end

###################################################################################
#
# ES
#
define ES
    set confirm off
    quit
end
document ES
ES -- exit to shell (unconditionally quit gdb).
end

###################################################################################
#
# FB addr n expr|"string"
#
define FB
    FIND $arg0 $arg1 $arg2 1
end
document FB
FB addr n expr|"string" -- Search from addr to addr+n-1 for the byte.
Ê
The MacsBug FB command overrides the gdb FB alias for a gdb FUTURE_BREAK
command.  Use FU for the FUTURE_BREAK command.
end

###################################################################################
#
# FILL addr n expr|"string"
#
define FILL
    set $addr = $arg0
    set $n    = $arg1
    
    set $dot = $addr
    
    __is_string ($arg2)
    
    if ($string)
    	set $p = (unsigned char *)$string
    	__strlen $string
    	set $b = 0
    	while ($n--)
    	    set *((unsigned char *)$addr)++ = $string[$b]
    	    if (++$b >= $strlen)
    	    	set $b = 0
    	    end
    	end
    else
    	set $value = (long)$arg2
    	if ($value >= -128 && $value <= 255)
    	    while ($n--)
    	    	set *((unsigned char *)$addr)++ = (unsigned char)$value & 0xFF
    	    end
    	else
    	    if ($value >= -32768 && $value <= 65535)
    	    	set $b = 0
    	    	while ($n--)
    	    	    if ($b == 0)
    	    	    	set *((unsigned char *)$addr)++ = ((unsigned short)$value >> 8) & 0xFF
    	    	    	set $b = 1
    	    	    else
    	    	    	set *((unsigned char *)$addr)++ = (unsigned short)$value & 0xFF
    	    	    	set $b = 0
    	    	    end
    	    	end
    	    else
    	    	set $b = 0
    	    	while ($n--)
    	    	    if ($b == 0)
    	    	    	set *((unsigned char *)$addr)++ = ((unsigned long)$value >> 24) & 0xFF
    	    	    	set $b = 1
    	    	    else
    	    	    	if ($b == 1)
    	    	    	    set *((unsigned char *)$addr)++ = ((unsigned long)$value >> 16) & 0xFF
    	    	    	    set $b = 2
    	    	    	else
    	    	    	    if ($b == 2)
    	    	    		set *((unsigned char *)$addr)++ = ((unsigned long)$value >> 8) & 0xFF
    	    	    	    	set $b = 3
    	    	    	    else
    	    	    		set *((unsigned char *)$addr)++ = (unsigned long)$value & 0xFF
    	    	    		set $b = 0
    	    	    	    end
    	    	    	end
		    end
    	    	end
    	    end
    	end
    end
    
    printf "Memory set starting at %.8X\n", $dot
    __hexdump $dot $arg1
    
    set $__lastcmd__ = 34
end
document FILL
FILL addr n expr|"string" -- Fill from addr to addr+n with expr or string.
The fill is repeatedly used as a byte, word, or long (determined by the size
of the expr value) or the string.
end

###################################################################################
#
# FIND addr n expr|"string" [size]
#
# The size is an INTERNAL option to be able to use the general FIND function for
# FB, FW, and FL.
#
define FIND
    set $e = 0
    
    if ($argc > 3)
    	if ($arg3 != 1 && $arg3 != 2 && $arg3 != 4)
    	    printf "usage: FIND addr n expr|"string" (wrong number of arguments)\n"
    	    set $e = 1
    	else
    	    set $size = $arg3
    	end
    else
    	set $size = 0
    end
    
    if (!$e)
	set $addr  = $arg0
	set $addr1 = (unsigned char *)$addr + ($arg1)
	set $found = 0
	
	__is_string ($arg2)
	
	if ($string)
	    set $n = $arg1
	    set $addr1 = $addr1 - $n
	    while (!$found && $addr < $addr1)
		__strncmp $string $addr $n
		if ($strncmp)
		    set $found = $addr
		else
		    set ++((unsigned char *)$addr)
		end
	    end
	else
	    set $value = (long)$arg2
	    if ($size == 1 || (!$size && ($value >= -128 && $value <= 255)))
	    	set $size = 1
	    	set $value = (unsigned char)$value & 0xFF
	    	while (!$found && $addr < $addr1)
		    if (*(unsigned char *)$addr == (unsigned char)$value)
		    	set $found = $addr
		    else
		    	set ++((unsigned char *)$addr)
		    end
		end
	    else
		if ($size == 2 || (!$size && ($value >= -32768 && $value <= 65535)))
		    set $size = 2
		    set $addr1 = $addr1 - 2
		    set $value = (unsigned short)$value & 0xFFFF
		    while (!$found && $addr < $addr1)
		    	if (*(unsigned char *)$addr     == (((unsigned short)$value >> 8) & 0xFF) && \
			    *((unsigned char *)$addr+1) == ((unsigned short)$value & 0xFF))
			    set $found = $addr
			else
			    set ++((unsigned char *)$addr)
			end
		    end
		else
		    set $size = 4
		    set $addr1 = $addr1 - 4
		    while (!$found && $addr < $addr1)
		    	if (*(unsigned char *)$addr     == (((unsigned long)$value >> 24) & 0xFF) && \
			    *((unsigned char *)$addr+1) == (((unsigned long)$value >> 16) & 0xFF) && \
			    *((unsigned char *)$addr+2) == (((unsigned long)$value >>  8) & 0xFF) && \
			    *((unsigned char *)$addr+3) == ((unsigned long)$value & 0xFF))
			    set $found = $addr
			else
			    set ++((unsigned char *)$addr)
			end
		    end
		end
	    end
	end
    end
    
    if (!$e)
    	printf "Searching for "
    	if ($string)
    	    __strlen $string
    	    printf "\""
    	    set $i = 0
    	    while ($strlen--)
    	    	__print_char $string[$i++]
    	    end
    	    printf "\""
    	else
    	    if ($size == 1)
    	    	 printf "0x%.2X", $value
    	    else
    	    	if ($size == 2)
    	    	    printf "0x%.4X", $value
    	    	else
    	    	    printf "0x%.8X", $value
    	    	end
    	    end
    	end
    	printf " from 0x%.8X to 0x%.8X\n", $addr, (char *)$addr1-1
	
    	if (!$found)
	    printf "%c[31m Not found%c[0m\n", 0x1B, 0x1B
	else
	    set $dot = $found
	    __hexdump $dot
	end
    end
    
    set $__lastcmd__ = 35
end
document FIND
FIND addr n expr -- Search from addr to addr+n-1 for the pattern.
If pattern is an expr then the width of the pattern is the smallest
unit (byte, word or long) that contains its value.
Ê
Restriction: The expr value may not have any embedded blanks.  For example
Ê            a value like (unsigned char *)&a is invalid.
Ê
Macsbug features not supported: MacsBug F must be FIND here since F conflicts
Ê                               with the gdb FRAME command abbreviation.
Ê
Ê                               Double quoted "string" instead of single quoted
Ê                               'string'.
Ê
Ê                               To keep the same semantics as MacsBug you run
Ê                               the risk of trying to search beyond the end of
Ê                               your memory since the comparison limit is based
Ê                               on the first byte of the objects to be matched
Ê                               rather than the last.
end

###################################################################################
#
# FL addr n expr|"string"
#
define FL
    FIND $arg0 $arg1 $arg2 4
end
document FL
FL addr n expr|"string" -- Search from addr to addr+n-1 for the 4-byte long.
end

###################################################################################
#
# FW addr n expr|"string"
#
define FW
    FIND $arg0 $arg1 $arg2 2
end
document FW
FW addr n expr|"string" -- Search from addr to addr+n-1 for the 2-byte word.
end

###################################################################################
#
# G [addr]
#
define G
    if ($argc != 0)
	set $pc = $arg0
    end
    
    set $__lastcmd__ = 8
    continue
end
document G
G [addr] -- Continue execution (at addr if supplied)
end

###################################################################################
#
# GT gdb-spec
#
define GT
    tbreak $arg0
    set $__lastcmd__ = 36
    continue
end
document GT
GT gdb-spec -- Go (continue) until the gdb-spec is reached.
This implements the gdb "TBREAK gdb-spec".  See gdb TBREAK
documentation for further details.
Ê
Macsbug features not supported: Command list not allowed.
end

###################################################################################
#
# ID [addr]
#
define ID
    if ($argc == 1)
    	set $dot = $arg0
    else
    	if ($__lastcmd__ == 9)
    	    set $dot = (unsigned char *)$dot + 4
     	    # The following makes the displays contiguous by moving the cursor
    	    # up over the gdb prompt.  But just in case the display would fail
    	    # because the memory is inaccessible we try to access the first
    	    # byte of the display and let gdb error it out before moving the
    	    # cursor if the memory is inaccessible.
    	    set $accessible = *(char *)$dot
    	    printf "%c[%dA\n", 0x1B, 2+($branch_taken!=0)
    	else
    	    set $dot = $pc
    	    printf "Disassembly from %.8X\n", $dot
    	end
    end
    __disasmN $dot 1
    
    set $__lastcmd__ = 9
end
document ID
ID [addr] -- Disassemble 1 line starting at addr (or pc).
Ê
Macsbug features not supported: -c option.
end

###################################################################################
#
# IDP [addr]
#
define IDP
    if ($argc == 1)
    	id $arg0
    else
    	id
    end
    
    #set $__lastcmd__ = $__lastcmd__ 
end
document IDP
IDP [addr] -- Same as ID.
end

###################################################################################
#
# IL [addr [n]]
#
define IL
    if ($argc == 0)
    	if ($__lastcmd__ == 11)
    	    set $dot = (unsigned char *)$dot + (4*20)
     	    # The following makes the displays contiguous by moving the cursor
    	    # up over the gdb prompt.  But just in case the display would fail
    	    # because the memory is inaccessible we try to access the first
    	    # byte of the display and let gdb error it out before moving the
    	    # cursor if the memory is inaccessible.
    	    set $accessible = *(char *)$dot
    	    printf "%c[%dA\n", 0x1B, 2+($branch_taken!=0)
   	else
    	    set $dot = $pc
    	end
    	set $n = 20
    else
    	if ($argc == 1)
    	    set $dot = $arg0
    	    set $n   = 20
    	else
    	    set $dot = $arg0
    	    set $n   = $arg1
    	end
    end
    
    __disasmN $dot $n
    
    set $__lastcmd__ = 11
end
document IL
IL [addr [n]] -- Disassemble n (default 20) lines from the addr or pc.
Ê
Macsbug features not supported: -c option.
end

###################################################################################
#
# ILP [addr [n]]
#
define ILP
    if ($argc == 0)
    	il
    else
    	if ($argc == 1)
    	    il $arg0
    	else
    	    il $arg0 $arg1
    	end
    end
    
    #set $__lastcmd__ = $__lastcmd__ 
end
document ILP
ILP [addr [n]] -- Same as IL.
end

###################################################################################
#
# IP [addr]
#
define IP
    if ($argc == 1)
    	set $dot = $arg0
    else
    	if ($__lastcmd__ == 13)
    	    set $dot = (unsigned char *)$dot + (21*4)
    	    # The following makes the displays contiguous by moving the cursor
    	    # up over the gdb prompt.  But just in case the display would fail
    	    # because the memory is inaccessible we try to access the first
    	    # byte of the display and let gdb error it out before moving the
    	    # cursor if the memory is inaccessible.
    	    set $accessible = *((char *)$dot - 40)
    	    printf "%c[%dA\n", 0x1B, 2+($branch_taken!=0)
    	else
    	    set $dot = $pc
    	end
    end
    
    # __disasmN takes a third argument only used here.  This third argument is
    # $dot so we can specially flag the $dot address in the disassembly to make
    # it more easily identifiable in the display.
    
    __disasmN ($dot-40) 21 $dot
    
    set $__lastcmd__ = 13
end
document IP
IP [addr] -- Disassemble 20 lines centered around the addr (or pc).
Ê
Macsbug features not supported: -c option.
end

###################################################################################
#
# IPP [addr]
#
define IPP
    if ($argc == 1)
    	ip $arg0
    else
    	ip
    end
    
    #set $__lastcmd__ = $__lastcmd__
end
document IPP
IPP [addr] -- Same as IP.
end

###################################################################################
#
# MR
#
define MR
    if ($argc != 0)
    	printf "Only the parameterless form of MR is supported.\n"
    else
	finish
    end
    
    set $__lastcmd__ = 15
end
document MR
MR -- Return from current frame.
Ê
Macsbug features not supported: offset and addr arguments
end

###################################################################################
#
# MSET DITTO | UNMANGLE [ON | OFF | NOW | SHOW]
#
# Note that the initial settings for these state switches is OFF.  I'm mentioning this
# to point out the fact because it is possible that this command could be executed
# BEFORE the switches are defined (void in gdb, setting it outside the function has no
# effect).  We can only test undefined gdb convenience variables with 'if ($dx)'
# (can't even negate it) which would be false when the switch is undefined, i.e., same
# result as if it were 0.  Our initial default for these switches is OFF, so undefined
# and 0 have the same effect to indicate OFF.  Bit if any future switches are added,
# and their default is to be ON, then their polarity will have to be reversed; 0 meaning
# ON and 1 meaning OFF.  This is so the testing for those switches when they are
# initially undefined has the desired effect.  #%$@!()& gdb!
#
define MSET
    set $e = 0
    
    if ($argc == 0)
	printf "usage: MSET DITTO | UNMANGLE [ON | OFF | NOW | SHOW] (missing arguments)\n"
    else
	__lower_case $arg0
	__strcmp $lower_case "ditto"
	if ($strcmp)
	    set $which = 1
	else
	    __strcmp $lower_case "unmangle"
	    if ($strcmp)
	    	set $which = 2
	    else
	    	set $e = 1
		printf "usage: MSET DITTO | UNMANGLE [ON | OFF | NOW | SHOW] (invalid option)\n"
	    end
	end
	
	if (!$e)
	    if ($argc == 1)
	    	if ($which == 1)
		    if ($__ditto__)
		    	set $__ditto__ = 0
	    		printf "Ditto-display in memory dumps disabled\n"
		    else
		    	set $__ditto__ = 1
	    		printf "Ditto-display in memory dumps enabled\n"
		    end
	    	else
		    if ($__unmangle__)
		    	set $__unmangle__ = 0
	    		printf "Unmangling of symbols disabled\n"
			set print demangle off
			set print asm-demangle off
		    else
		    	set $__unmangle__ = 1
			set print demangle on
			set print asm-demangle on
	    		printf "Unmangling of symbols enabled\n"
		    end
		end
	    else
		__lower_case $arg1
		__strcmp $lower_case "on"
		if ($strcmp)
		    if ($which == 1)
			if ($__ditto__)
			    printf "Ditto-display in memory dumps is still enabled\n"
			else
			    set $__ditto__ = 1
			    printf "Ditto-display in memory dumps is enabled\n"
			end
		    else
			if ($__unmangle__)
			    printf "Unmangling of symbols is still enabled\n"
			else
			    set $__unmangle__ = 1
			    set print demangle on
			    set print asm-demangle on
			    printf "Unmangling of symbols is enabled\n"
			end
		    end
		else
		    __strcmp $lower_case "off"
		    if ($strcmp)
			if ($which == 1)
			    if ($__ditto__)
				set $__ditto__ = 0
				printf "Ditto-display in memory dumps is disabled\n"
			    else
				printf "Ditto-display in memory dumps is still disabled\n"
			    end
			else
			    if ($__unmangle__)
				set $__unmangle__ = 0
				set print demangle off
				set print asm-demangle off
				printf "Unmangling of symbols is disabled\n"
			    else
				printf "Unmangling of symbols is still disabled\n"
			    end
			end
		    else
			__strcmp $lower_case "now"
			if (!$strcmp)
			    __strcmp $lower_case "show"
			    if (!$strcmp)
				set $e = 1
			    end
			end
			if ($e || $argc > 2)
			    printf "usage: MSET DITTO | UNMANGLE [ON | OFF | NOW | SHOW] (invalid setting)\n"
			else
			    if ($which == 1)
				if ($__ditto__)
				    printf "Ditto-display in memory dumps is enabled\n"
				else
				    printf "Ditto-display in memory dumps is disabled\n"
				end
			    else
				if ($__unmangle__)
				    printf "Unmangling of symbols is still enabled\n"
				else
				    printf "Unmangling of symbols is still disabled\n"
				end
			    end
			end
		    end
		end
	    end
	end
    end
    
    set $__lastcmd__ = 40
end
document MSET
MSET option [ON|OFF|NOW|SHOW] -- Temporarially change the specified gdb MacsBug behavior.
On/off options toggle if you don't specify ON or OFF.  NOW or SHOW lets you check
the setting without disturbing it.  The options are:
Ê
Ê  DITTO:    When on, DM and DMA show ditto marks (''''''') instead of groups
Ê            of identical lines.
       
Ê  UNMANGLE: When on, C++ symbols appear as in source code, such as "TFoo::Bar()".
Ê            When off, you'll see stuff like "Bar__4TFooFv" instead.

SHOW is the same as NOW to display the current setting.  It was added since gdb
uses SHOW to show settings.
Ê
Macsbug features not supported: The is the MacsBug SET command was changed to
Ê                               MSET since SET conflicts with the SET gdb command.
Ê
Ê                               Options AUTOGP, ECHO, MOUSE, MENUBAR, SCROLLPROMPT,
Ê                               SUSPENDPROMPT, and SIMPLIFIED not supported.
end

###################################################################################
#
# PC, R0 - R31
#
define PC
    __rn $pc
end
document PC
PC -- display the value of PC
end
#
define R0
    __Rn $r0
end
document R0
R0 -- display the value of R0
end
#
define R1
    __Rn $r1
end
document R1
R1 -- display the value of R1
end
#
define R2
    __Rn $r2
end
document R2
R2 -- display the value of R2
end
#
define R3
    __Rn $r3
end
document R3
R3 -- display the value of R3
end
#
define R4
    __Rn $r4
end
document R4
R4 -- display the value of R4
end
#
define R5
    __Rn $r5
end
document R5
R5 -- display the value of R5
end
#
define R6
    __Rn $r6
end
document R6
R6 -- display the value of R6
end
#
define R7
    __Rn $r7
end
document R7
R7 -- display the value of R7
end
#
define R8
    __Rn $r8
end
document R8
R8 -- display the value of R8
end
#
define R9
    __Rn $r9
end
document R9
R9 -- display the value of R9
end
#
define R10
    __Rn $r10
end
document R10
R10 -- display the value of R10
end
#
define R11
    __Rn $r11
end
document R11
R11 -- display the value of R11
end
#
define R12
    __Rn $r12
end
document R12
R12 -- display the value of R12
end
#
define R13
    __Rn $r13
end
document R13
R13 -- display the value of R13
end
#
define R14
    __Rn $r14
end
document R14
R14 -- display the value of R14
end
#
define R15
    __Rn $r15
end
document R15
R15 -- display the value of R15
end
#
define R16
    __Rn $r16
end
document R16
R16 -- display the value of R16
end
#
define R17
    __Rn $r17
end
document R17
R17 -- display the value of R17
end
#
define R18
    __Rn $r18
end
document R18
R18 -- display the value of R18
end
#
define R19
    __Rn $r19
end
document R19
R19 -- display the value of R19
end
#
define R20
    __Rn $r20
end
document R20
R20 -- display the value of R20
end
#
define R21
    __Rn $r21
end
document R21
R21 -- display the value of R21
end
#
define R22
    __Rn $r22
end
document R22
R22 -- display the value of R22
end
#
define R23
    __Rn $r23
end
document R23
R23 -- display the value of R23
end
#
define R24
    __Rn $r24
end
document R24
R24 -- display the value of R24
end
#
define R25
    __Rn $r25
end
document R25
R25 -- display the value of R25
end
#
define R26
    __Rn $r26
end
document R26
R26 -- display the value of R26
end
#
define R27
    __Rn $r27
end
document R27
R27 -- display the value of R27
end
#
define R28
    __Rn $r28
end
document R28
R28 -- display the value of R28
end
#
define R29
    __Rn $r29
end
document R29
R29 -- display the value of R29
end
#
define R30
    __Rn $r30
end
document R30
R30 -- display the value of R30
end
#
define R31
    __Rn $r31
end
document R31
R31 -- display the value of R31
end
#
# __rn reg - display a single register value
#
# This is the common routine used by all Rn (n = 0...31) functions.  The
# register arg is the actual register specified ($rn) in lower case (since
# upper case $Ri appears to be a undefined convenience symbol).  This 
# internal routine is placed here since it is only for the singe register
# command displays immediate above here.
#
# The format we use is identical to the DL command.  MacsBug also puts some
# just in parenthesis after the value which I think is of dubious use.  So
# the hell with it.
#
define __Rn
    set $__r = (char *)"$arg0"
    set $__r[1] = 'A' + ($__r[1] - 'a')
    if ($__r[1] == 'P')
    	set $__r[2] = 'A' + ($__r[2] - 'a')
    end
    printf "%s = 0x%.8X   %u    %d    ", &$__r[1], $arg0, $arg0, $arg0
    __print_4 $arg0
    printf "\n"
    set $__lastcmd__ = 41
end
document __Rn
For internal use only -- do not use.
end

###################################################################################
#
# RA
#
define RA
    set confirm off
    run
    set confirm on
end
document RA
RA -- Unconditionaly restart (run) with current argument list ("run again").
This is identical to RUN except no prompt is displayed if the program is
currently running.  The debugged program is unconditionally restarted.
 
Assumes confirmation is on, or it will be on after this command is executed.
 
Note, this is NOT a MacsBug command but it is useful in a gdb environment.
end

###################################################################################
#
# SB addr value1 [... value9]
#
define SB
    if ($argc < 2)
	printf "usage: SB addr value1 [... value9]\n"
	set $e = 1
    else
    	set $addr = $arg0
    	set $e = 0
    end

    set $debug = 0

    set $i = 1
    
    while ($i < $argc && $e == 0)
        if ($i == 1)
    	    set $value = $arg1
    	    __is_string ($arg1)
        else
    	    if ($i == 2)
    	    	set $value = $arg2
    	    	__is_string ($arg2)
    	    else
    	    	if ($i == 3)
		    set $value = $arg3
		    __is_string ($arg3)
    	    	else
    		    if ($i == 4)
    		    	set $value = $arg4
    		    	__is_string ($arg4)
    		    else
    		    	if ($i == 5)
    			    set $value = $arg5
    			    __is_string ($arg5)
    		    	else
    			    if ($i == 6)
    			    	set $value = $arg6
    			    	__is_string ($arg6)
    			    else
    			    	if ($i == 7)
    				    set $value = $arg7
    				    __is_string ($arg7)
    			    	else
    				    if ($i == 8)
    				    	set $value = $arg8
    				    	__is_string ($arg8)
    				    else
    				    	set $value = $arg9
    				    	__is_string ($arg9)
    				    	# gdb limits to 10 args and errors out for us
    				    end
    			    	end
    			    end
    		    	end
    		    end
    	    	end
    	    end
        end
	
	if ($i == 1)
	    printf "Memory set starting at %.8X\n", $addr
	    set $dot = $addr
	end
	
	if ($string)
	    __strlen $string
	    if ($debug)
	    	printf "__memcpy %.8X \"%s\" %d\n", $addr, $string, $strlen
	    else
	    	__memcpy $addr $string $strlen
	    end
	    set $addr = (unsigned char *)$addr + $strlen
	else
	    if ($debug)
	    	printf "%.8X = %.2X\n", $addr, (unsigned long)$value & 0xFF
	    else
	    	set *((unsigned char *)$addr) = (unsigned long)$value & 0xFF
	    end
	    set $addr = (unsigned char *)$addr + 1
	end
	
	set $i = $i + 1
    end
     
    if ($e == 0)
     	set $start = $arg0
      	set $n     = (unsigned long)$addr - (unsigned long)$start
     	if ($debug)
      	    printf "__hexdump %X %d\n", $start, (($n+15)/16)*16
      	else
     	    __hexdump $start (($n+15)/16)*16
    	end
    end
    
    set $__lastcmd__ = 17
end
document SB
SB addr values -- Assign up to 9 values to bytes starting at addr.
String values are fully assigned at the next assignable byte.
Ê
Restrictions: The values value may not have any embedded blanks.  For example
Ê             a value like (unsigned char *)0x1234 is invalid.
Ê
Ê             There is a limit of 9 values that can be set.
Ê
Macsbug features not supported: Double quoted "string" instead of single quoted
Ê                               'string'.
end

# Note, SB, SL, SW, and SM are parse their args exactly the same way.  We could
# generalize SM and let SB, SL, SW call it.  But that would mean taking away one
# or two arguments from the possible total of 10.  So to keep them all consistent
# with the 10 limit we repeat the code in each of these routines.

###################################################################################
#
# SC
#
define SC
    bt
    set $__lastcmd__ = 18
end
document SC
SC -- Display back trace.
end

###################################################################################
#
# SC6
#
define SC6
    bt
    set $__lastcmd__ = 19
end
document SC6
SC6 -- Same as SC.
end

###################################################################################
#
# SC7
#
define SC7
    bt
    set $__lastcmd__ = 20
end
document SC7
SC7 -- Same as SC.
end

###################################################################################
#
# SI [n] [m]
#
define SI
    if ($argc == 0)
    	if ($__lastcmd__ != 16 && $__lastcmd__ != 23)
	    set $__STEP__   = 1
	    set $__WINDOW__ = 4
	end
    else
    	if ($argc == 1)
    	    set $__STEP__   = $arg0
	    set $__WINDOW__ = 4
	else
	    set $__STEP__   = $arg0
	    set $__WINDOW__ = $arg1
	end
    end
    
    stepi $__STEP__
    set $dot = $pc
    __disasmN $pc $__WINDOW__ $pc
    
    set $__lastcmd__ = 16
end
document SI
SI [n] [m] -- Step n (or 1) instruction(s) and disassemble m (or 4) lines from new pc.
See also gdb's next and step instructions, which step by source lines,
not instructions.
Ê
The second argument is a extension to the MacsBug syntax to allow a disassembly
of m lines to show the next instructions to be executed.  This approximates the
disassembly window that MacsBug always shows.
Ê
Macsbug features not supported: S expr
Ê
Ê                               The MacsBug S is SI here.  This was done to preserve
Ê                               gdb's definition of S[tep] to single statement step.
Ê                               There is (was) a gdb SI to which does exactly what
Ê                               this MacsBug SI does except that now the instruction
Ê                               is also displayed at each instruction step.
end

###################################################################################
#
# SL addr value1 [... value9]
#
define SL
    if ($argc < 2)
	printf "usage: SL addr value1 [... value9]\n"
	set $e = 1
    else
    	set $addr = $arg0
    	set $e = 0
    end

    set $debug = 0
    
    set $i = 1
    
    while ($i < $argc && $e == 0)
        if ($i == 1)
    	    set $value = $arg1
    	    __is_string ($arg1)
        else
    	    if ($i == 2)
    	    	set $value = $arg2
    	    	__is_string ($arg2)
    	    else
    	    	if ($i == 3)
		    set $value = $arg3
		    __is_string ($arg3)
    	    	else
    		    if ($i == 4)
    		    	set $value = $arg4
    		    	__is_string ($arg4)
    		    else
    		    	if ($i == 5)
    			    set $value = $arg5
    			    __is_string ($arg5)
    		    	else
    			    if ($i == 6)
    			    	set $value = $arg6
    			    	__is_string ($arg6)
    			    else
    			    	if ($i == 7)
    				    set $value = $arg7
    				    __is_string ($arg7)
    			    	else
    				    if ($i == 8)
    				    	set $value = $arg8
    				    	__is_string ($arg8)
    				    else
    				    	set $value = $arg9
    				    	__is_string ($arg9)
    				    	# gdb limits to 10 args and errors out for us
    				    end
    			    	end
    			    end
    		    	end
    		    end
    	    	end
    	    end
        end
	
	if ($i == 1)
	    printf "Memory set starting at %.8X\n", $addr
	    set $dot = $addr
	end
	
	# Although we probably can use unaligned access, why take chances?  So
	# the following sets memory a byte at a time.
	
	if ($string)
	    __strlen $string
	    if ($debug)
	    	printf "__memcpy %.8X \"%s\" %d\n", $addr, $string, $strlen
	    else
	    	__memcpy $addr $string $strlen
	    end
	    set $addr = (unsigned char *)$addr + $strlen
	else
	    if ($debug)
	    	printf "%.8X = %.8X\n", $addr, (unsigned long)$value
	    	set $addr = (unsigned char *)$addr + 4
	    else
           	set *((unsigned char *)$addr) = ((unsigned long)$value >> 24) & 0xFF
           	set $addr = (unsigned char *)$addr + 1
           
           	set *((unsigned char *)$addr) = ((unsigned long)$value >> 16) & 0xFF
           	set $addr = (unsigned char *)$addr + 1
           
           	set *((unsigned char *)$addr) = ((unsigned long)$value >> 8) & 0xFF
           	set $addr = (unsigned char *)$addr + 1
           
           	set *((unsigned char *)$addr) = (unsigned long)$value & 0xFF
           	set $addr = (unsigned char *)$addr + 1
           end
	end
	
	set $i = $i + 1
    end
     
    if ($e == 0)
      	set $start = $arg0
      	set $n     = (unsigned long)$addr - (unsigned long)$start
    	if ($debug)
     	    printf "__hexdump %X %d\n", $start, (($n+15)/16)*16
     	else
     	    __hexdump $start (($n+15)/16)*16
     	end
    end
    
    set $__lastcmd__ = 21
end
document SL
SL addr values -- Assign up to 9 values to (4-byte) longs starting at addr.
String values are fully assigned at the next assignable byte.
Ê
Restrictions: The values value may not have any embedded blanks.  For example
Ê             a value like (unsigned char *)0x1234 is invalid.
Ê
Ê             There is a limit of 9 values that can be set.
Ê
Macsbug features not supported: Double quoted "string" instead of single quoted
Ê                               'string'.
end

# Note, SB, SL, SW, and SM are parse their args exactly the same way.  We could
# generalize SM and let SB, SL, SW call it.  But that would mean taking away one
# or two arguments from the possible total of 10.  So to keep them all consistent
# with the 10 limit we repeat the code in each of these routines.

###################################################################################
#
# SM addr value1 [... value9]
#
define SM
    if ($argc < 2)
	printf "usage: SM addr value1 [... value9]\n"
	set $e = 1
    else
    	set $addr = $arg0
    	set $e = 0
    end
    
    set $debug = 0
    
    set $i = 1
    
    while ($i < $argc && $e == 0)
        if ($i == 1)
    	    set $value = $arg1
    	    __is_string ($arg1)
        else
    	    if ($i == 2)
    	    	set $value = $arg2
    	    	__is_string ($arg2)
    	    else
    	    	if ($i == 3)
		    set $value = $arg3
		    __is_string ($arg3)
    	    	else
    		    if ($i == 4)
    		    	set $value = $arg4
    		    	__is_string ($arg4)
    		    else
    		    	if ($i == 5)
    			    set $value = $arg5
    			    __is_string ($arg5)
    		    	else
    			    if ($i == 6)
    			    	set $value = $arg6
    			    	__is_string ($arg6)
    			    else
    			    	if ($i == 7)
    				    set $value = $arg7
    				    __is_string ($arg7)
    			    	else
    				    if ($i == 8)
    				    	set $value = $arg8
    				    	__is_string ($arg8)
    				    else
    				    	set $value = $arg9
    				    	__is_string ($arg9)
    				    	# gdb limits to 10 args and errors out for us
    				    end
    			    	end
    			    end
    		    	end
    		    end
    	    	end
    	    end
        end
	
	if ($i == 1)
	    printf "Memory set starting at %.8X\n", $addr
	    set $dot = $addr
	end
	
	# Although we probably can use unaligned access, why take chances?  So
	# the following sets memory a byte at a time.
	
	if ($string)
	    __strlen $string
	    if ($debug)
	    	printf "__memcpy %.8X \"%s\" %d\n", $addr, $string, $strlen
	    else
	    	__memcpy $addr $string $strlen
	    end
	    set $addr = (unsigned char *)$addr + $strlen
	else
    	    if ((long)$value >= -128 && (long)$value <= 255)
    	    	set $size = 1
    	    else
    	    	if ((long)$value >= -32768 && (long)$value <= 65535)
    	    	    set $size = 2
	    	else
	    	    set $size = 4
	    	end
	    end
	    
	    if ($debug)
		if ($size == 4)
		    printf "%.8X = %.8X\n", $addr, (unsigned long)$value
		else
		    if ($size == 2)
		    	printf "%.8X = %.4X\n", $addr, (unsigned long)$value & 0xFFFF
		    else
		    	printf "%.8X = %.2X\n", $addr, (unsigned long)$value & 0xFF
		    end
		end
		set $addr = (unsigned char *)$addr + $size
	    else
	        if ($size == 4)
	           set *((unsigned char *)$addr) = ((unsigned long)$value >> 24) & 0xFF
	           set $addr = (unsigned char *)$addr + 1
	           	
	           set *((unsigned char *)$addr) = ((unsigned long)$value >> 16) & 0xFF
	           set $addr = (unsigned char *)$addr + 1
	        end
	        
	        if ($size == 2 || $size == 4)
	            set *((unsigned char *)$addr) = ((unsigned long)$value >> 8) & 0xFF
	            set $addr = (unsigned char *)$addr + 1
	        end
	        
	        set *((unsigned char *)$addr) = (unsigned long)$value & 0xFF
	        set $addr = (unsigned char *)$addr + 1
	    end
	end
	
	set $i = $i + 1
    end
     
    if ($e == 0)
     	set $start = $arg0
      	set $n     = (unsigned long)$addr - (unsigned long)$start
     	if ($debug)
     	    printf "__hexdump %X %d\n", $start, (($n+15)/16)*16
     	else
     	    __hexdump $start (($n+15)/16)*16
     	end
    end
    
    set $__lastcmd__ = 22
end
document SM
SM addr value -- Assign up to 9 values to memory starting at addr.
Each value determines the assignment size (byte, 2-byte word, or 4-byte
long).  Specific sizes can be set using SB, SW, or SL.  String values
are fully assigned at the next assignable byte.
Ê
Restrictions: The values value may not have any embedded blanks.  For example
Ê             a value like (unsigned char *)0x1234 is invalid.
Ê
Ê             There is a limit of 9 values that can be set.
Ê
Macsbug features not supported: Double quoted "string" instead of single quoted
Ê                               'string'.
end

# Note, SB, SL, SW, and SM are parse their args exactly the same way.  We could
# generalize SM and let SB, SL, SW call it.  But that would mean taking away one
# or two arguments from the possible total of 10.  So to keep them all consistent
# with the 10 limit we repeat the code in each of these routines.

###################################################################################
#
# SO [n] [m]
#
define SO
    if ($argc == 0)
    	if ($__lastcmd__ != 23 && $__lastcmd__ != 16)
	    set $__STEP__   = 1
	    set $__WINDOW__ = 4
	end
    else
    	if ($argc == 1)
    	    set $__STEP__   = $arg0
	    set $__WINDOW__ = 4
	else
	    set $__STEP__   = $arg0
	    set $__WINDOW__ = $arg1
	end
    end
    
    nexti $__STEP__
    set $dot = $pc
    __disasmN $pc $__WINDOW__ $pc
    
    set $__lastcmd__ = 23
end
document SO
SO [n] [m] -- Step over n instructions and disassemble m (or 4) lines from new pc.
See also gdb's next and step instructions, which step by source lines,
not instructions.
Ê
The second argument is a extension to the MacsBug syntax to allow a disassembly
of m lines to show the next instructions to be executed.  This approximates the
disassembly window that MacsBug always shows.
end

###################################################################################
#
# SW addr value1 [... value9]
#
define sw
    if ($argc < 2)
	printf "usage: SW addr value1 [... value9]\n"
	set $e = 1
    else
    	set $addr = $arg0
    	set $e = 0
    end

    set $debug = 0
    
    set $i = 1
    
    while ($i < $argc && $e == 0)
        if ($i == 1)
    	    set $value = $arg1
    	    __is_string ($arg1)
        else
    	    if ($i == 2)
    	    	set $value = $arg2
    	    	__is_string ($arg2)
    	    else
    	    	if ($i == 3)
		    set $value = $arg3
		    __is_string ($arg3)
    	    	else
    		    if ($i == 4)
    		    	set $value = $arg4
    		    	__is_string ($arg4)
    		    else
    		    	if ($i == 5)
    			    set $value = $arg5
    			    __is_string ($arg5)
    		    	else
    			    if ($i == 6)
    			    	set $value = $arg6
    			    	__is_string ($arg6)
    			    else
    			    	if ($i == 7)
    				    set $value = $arg7
    				    __is_string ($arg7)
    			    	else
    				    if ($i == 8)
    				    	set $value = $arg8
    				    	__is_string ($arg8)
    				    else
    				    	set $value = $arg9
    				    	__is_string ($arg9)
    				    	# gdb limits to 10 args and errors out for us
    				    end
    			    	end
    			    end
    		    	end
    		    end
    	    	end
    	    end
        end
	
	if ($i == 1)
	    printf "Memory set starting at %.8X\n", $addr
	    set $dot = $addr
	end
	
	# Although we probably can use unaligned access, why take chances?  So
	# the following sets memory a byte at a time.
	
	if ($string)
	    __strlen $string
	    if ($debug)
	    	printf "__memcpy %.8X \"%s\" %d\n", $addr, $string, $strlen
	    else
	    	__memcpy $addr $string $strlen
	    end
	    set $addr = (unsigned char *)$addr + $strlen
	else
            if ($debug)
	    	printf "%.8X = %.4X\n", $addr, (unsigned long)$value & 0xFFFF
            	set $addr = (unsigned char *)$addr + 2
            else
            	set *((unsigned char *)$addr) = ((unsigned long)$value >> 8) & 0xFF
            	set $addr = (unsigned char *)$addr + 1
            
            	set *((unsigned char *)$addr) = (unsigned long)$value & 0xFF
            	set $addr = (unsigned char *)$addr + 1
            end
        end
                
	set $i = $i + 1
     end
     
     if ($e == 0)
     	set $start = $arg0
      	set $n     = (unsigned long)$addr - (unsigned long)$start
     	if ($debug)
     	    printf "__hexdump %X %d\n", $start, (($n+15)/16)*16
     	else
     	    __hexdump $start (($n+15)/16)*16
     	end
     end
     
    set $__lastcmd__ = 24
end
document SW
SW addr values -- Assign up to 9 values to (2-byte) words starting at addr.
String values are fully assigned at the next assignable byte.
Ê
Restrictions: The values value may not have any embedded blanks.  For example
Ê             a value like (unsigned char *)0x1234 is invalid.
Ê
Ê             There is a limit of 9 values that can be set.
Ê
Macsbug features not supported: Double quoted "string" instead of single quoted
Ê                               'string'.
end

# Note, SB, SL, SW, and SM are parse their args exactly the same way.  We could
# generalize SM and let SB, SL, SW call it.  But that would mean taking away one
# or two arguments from the possible total of 10.  So to keep them all consistent
# with the 10 limit we repeat the code in each of these routines.

###################################################################################
#
# T [n] [m]
#
define T
    if ($argc == 0)
	SO
    else
    	if ($argc == 1)
	    SO $arg0
	else
	    SO $arg0 $arg1
	end
    end
    
    #set $__lastcmd__ = 25
end
document T
T [n] [m] -- Trace n (or 1) instruction(s) and disassemble m (or 4) from pc (same as SO).
end

###################################################################################
#
# TD
#
#PowerPC Registers
#                        CR0  CR1  CR2  CR3  CR4  CR5  CR6  CR7
# PC  = 05AB2950     CR  0100 0010 0000 0000 0000 1000 0100 1000
# LR  = 05AB29A4         <>=O XEVO
# CTR = FFD6A848
# MSR = 00000000         SOC Compare Count
# Int = 0            XER 000   00     00                     MQ  = 00000000
#
# R0  = 00000000     R8  = 00000000      R16 = 05B0FD25      R24 = 05B0FC90
# SP  = 05BCDF00     R9  = 05B150A0      R17 = 05B0FCAC      R25 = 0032822A
# R1  = 05B0AB4B     R10 = 00000000      R18 = 05B0FC8C      R26 = 00000003
# R3  = 0053866F     R11 = 00538E7A      R19 = 05B10668      R27 = 00000000
# R4  = 00000000     R12 = 0002CEA4      R20 = 05B0FCA9      R28 = 05BCE206
# R5  = 05BCDEF8     R13 = 00000000      R21 = 05B0FCAF      R29 = 05B32AD0
# R6  = 05ABAEC4     R14 = 00000000      R22 = 0000001E      R30 = 00538670
# R7  = 05B32AD0     R15 = 00000000      R23 = 00000000      R31 = 05B0FE6C
#
define TD
    printf "PowerPC Registers\n"
    printf "                       CR0  CR1  CR2  CR3  CR4  CR5  CR6  CR7\n"
    printf " PC  = %.8X    CR  ", $pc
    __binary ($cr>>28)    4
    printf " "
    __binary ($cr>>24&15) 4
    printf " "
    __binary ($cr>>20&15) 4
    printf " "
    __binary ($cr>>16&15) 4
    printf " "
    __binary ($cr>>12&15) 4
    printf " "
    __binary ($cr>>8&15)  4
    printf " "
    __binary ($cr>>4&15)  4
    printf " "
    __binary ($cr&15)     4
    printf "\n"
    
    printf " LR  = %.8X        <>=O XEVO\n", $lr
    printf " CTR = %.8X\n", $ctr
    printf " MSR = %.8X        SOC Compare Count\n", $ps
    printf "                   XER "
    __binary ($xer>>29&7) 3
    printf "   %.2X     %.2X                     MQ  = %.8X\n", ($xer>>8&0xFF), ($xer&0x7F), $mq
    
    printf "\n"
    
    printf " R0 = %.8X     R8  = %.8X      R16 = %.8X      R24 = %.8X\n", $r0, $r8,  $r16, $r24
    printf " SP = %.8X     R9  = %.8X      R17 = %.8X      R25 = %.8X\n", $r1, $r9,  $r17, $r25
    printf " R2 = %.8X     R10 = %.8X      R18 = %.8X      R26 = %.8X\n", $r2, $r10, $r18, $r26
    printf " R3 = %.8X     R11 = %.8X      R19 = %.8X      R27 = %.8X\n", $r3, $r11, $r19, $r27
    printf " R4 = %.8X     R12 = %.8X      R20 = %.8X      R28 = %.8X\n", $r4, $r12, $r20, $r28
    printf " R5 = %.8X     R13 = %.8X      R21 = %.8X      R29 = %.8X\n", $r5, $r13, $r21, $r29
    printf " R6 = %.8X     R14 = %.8X      R22 = %.8X      R30 = %.8X\n", $r6, $r14, $r22, $r30
    printf " R7 = %.8X     R15 = %.8X      R23 = %.8X      R31 = %.8X\n", $r7, $r15, $r23, $r31
    
    set $__lastcmd__ = 26
end
document TD
TD -- Display integer and machine registers.
end

###################################################################################
#
# TF
#
#PowerPC FPU Registers
#                                                  S S
#          F           N I I Z I                   O Q C
# FPSCR  F E V O U Z X A S D D M V F F             F R V V O U Z X N
#        X X X X X X X N I I Z Z C R I C < > = ?   T T I E E E E E I RN
#        1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 00
#  
# FPR0  = FFF 8000082004000     -NAN(000) 
# FPR1  = 408 4700000000000      6.540000000000000e+2 
# - - -
# FPR30 = 000 0000000000000      0.000000000000000e+0 
# FPR31 = 000 0000000000000      0.000000000000000e+0
#
# There's no way to display the floating regs in hex like this.  So we'll
# just have to settle with what info registers $fN produces.  It's a
# pretty good approximation so it isn't too bad.
#
define TF
    printf "PowerPC Vector Registers\n"
    printf "                                                  S S\n"
    printf "          F           N I I Z I                   O Q C\n"
    printf " FPSCR  F E V O U Z X A S D D M V F F             F R V V O U Z X N\n"
    printf "        X X X X X X X N I I Z Z C R I C < > = ?   T T I E E E E E I RN\n"
    
    printf "        "
    set $i = 0
    set $r = $fpscr
    while ($i++ < 32)
    	printf "%1d", ($r >> (32-$i)) & 1
    	if ($i < 31)
    	    printf " "
    	end
    end
    printf "\n\n"
    
    info registers $f0
    info registers $f1
    info registers $f2
    info registers $f3
    info registers $f4
    info registers $f5
    info registers $f6
    info registers $f7
    info registers $f8
    info registers $f9
    info registers $f10
    info registers $f11
    info registers $f12
    info registers $f13
    info registers $f14
    info registers $f15
    info registers $f16
    info registers $f17
    info registers $f18
    info registers $f19
    info registers $f20
    info registers $f21
    info registers $f22
    info registers $f23
    info registers $f24
    info registers $f25
    info registers $f26
    info registers $f27
    info registers $f28
    info registers $f29
    info registers $f30
    info registers $f31
    
    set $__lastcmd__ = 27
end
document TF
TF -- Display the floating point registers.
end

###################################################################################
#
# TV
#
#PowerPC Vector Registers
#                                                                      S
# VRsave = 00000000                    N                               A
#                                      J                               T
# VSCR = 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
#   
# V0  = 00000000 00000000 00000000 00000000   0.0000e+0   0.0000e+0   0.0000e+0   0.0000e+0 
# V1  = 53706F74 20636865 636B206F 66207472   1.0327e+12  1.9262e-19  4.3373e+21  1.8943e+23 
# - - -
# V30 = 7FFFDEAD 7FFFDEAD 7FFFDEAD 7FFFDEAD   NAN(222)    NAN(222)    NAN(222)    NAN(222) 
# V31 = 7FFFDEAD 7FFFDEAD 7FFFDEAD 7FFFDEAD   NAN(222)    NAN(222)    NAN(222)    NAN(222)
#
define TV
    printf "PowerPC Vector Registers\n"
    printf "%c[31m", 0x1B
    printf " Not available - can't get or manipulate the vector registers yet! Sorry. Sigh :-(\n"
    printf "\n"
    printf "%c[0m\n", 0x1B
    info registers
    
    set $__lastcmd__ = 28
end
document TV
TV -- Display the vector registers (not yet supported).
end

###################################################################################
###################################################################################

#           ##########################################################
#           # Internal helper functions for the above user functions #
#           ##########################################################

# Because gdb doesn't have the concept of local function variables the convention
# here is to define all "locals" with a double underbar prefix to try to keep them
# distinct from their function's callers.  Indeed, we also follow the convention
# for all these private function names as well.  It makes this stuff almost
# unreadable but that's gdb for you.  Yuk!

#
# __binary value n
#
# Internal function to display $arg0 as $arg1 binary digits.  Only the right-
# most $arg2 binary bits are displayed.  No newline is output here.
#
define __binary
    set $__value = $arg0
    set $__n     = $arg1
    
    set $__i = 0
    while ($__i++ < $__n)
    	printf "%1d", ($__value >> ($__n-$__i)) & 1
    end
end
document __binary
For internal use only -- do not use.
end

###################################################################################
#
# __branch_taken - determine if a conditional branch at $pc will be taken
#
# Returns $branch_taken = 1  if conditional branch will be taken
#			= -1 if conditional branch will not be taken
#			= 0  if not conditional branch at $pc
#
# The algorithm here is based on what is described in the IBM PPC Architecture book.
# To paraphrase what's there in determining whether the branch is taken or not it
# basically says:
#
#   bc[l][a]  (primary = 16)
#   bclr[l]   (primary = 19, extend = 16)
#     cond_ok = BO[0] || (CR[BI] == BO[1])
#     if !BO[2] then CTR = CTR-1
#     ctr_ok = BO[2] || (CTR != 0) ^ BO[3]
#     if ctr_ok && cond_ok then "will branch"
#     else "will not branch"
#
#   bcctr[l]  (primary = 19, extend = 528)
#     cond_ok = BO[0] || (CR[BI] == BO[1])
#     if cond_ok then "will branch"
#     else "will not branch"
#
# where the notation X[i] is bit i in field X.
#
# The implementation of this below is "optimized" to read as:
#     cond_ok = BO[0] || (CR[BI] == BO[1])
#     if (cond_ok && !"bcctr[l]") then cond_ok = BO[2] || (CTR-1 != 0) ^ BO[3]
#     if cond_ok then "will branch"
#     else "will not branch"
#
# Note, for all these brances, of BO == 0x14 we have a "branch always" which are not
# classed as conditional branches for our purposes.
#
define __branch_taken
    # First decode the instruction to see if it's a conditional branch...
    set $__pri = *(unsigned long *)$pc >> 26
    if ($__pri == 19)
	set $__ext = (*(unsigned long *)$pc >> 1) & 0x3FF
	if ($__ext != 16 && $__ext != 528)
	    set $__pri = 0
	end
    else
	if ($__pri != 16)
	    set $__pri = 0
	else
	    set $__ext = 0	
	end
    end
    
    if (((*(unsigned long *)$pc >> 21) & 0x14) == 0x14)
    	set $__pri = 0
    end
    
    # If we have a conditional branch then check it out...
    
    if ($__pri)
	# cond_ok = BO[0] || (CR[BI] == BO[1])
	set $__cond_ok = ((*(unsigned long *)$pc & 0x02000000) != 0)
	if (!$__cond_ok)
	    set $__cond_ok = ((((unsigned long)$cr >> (31-((*(unsigned long *)$pc>>16) & 0x1f))) & 1) == \
			    (((*(unsigned long *)$pc & 0x01000000) >> 24) & 1))
	end
	
	if ($__cond_ok && ($__ext != 528))
	    # cond_ok = BO[2] || (CTR-1 != 0) ^ BO[3]
	    set $__cond_ok = ((*(unsigned long *)$pc & 0x00800000) != 0)
	    if (!$__cond_ok)
		set $__cond_ok = ($ctr-1 != 0) ^ ((*(unsigned long *)$pc & 0x00400000) >> 22)
	    end
	end
	
	if ($__cond_ok)
	    set $branch_taken = 1
	else
	    set $branch_taken = -1
	end
    else
    	set $branch_taken = 0
    end
end
document __branch_taken
For internal use only -- do not use.
end

###################################################################################
#
# __flag_asm_line loc flag color
#
# This is called when a disassembly line for the specified location (loc) is 
# output.  The cursor is positioned back to the start of the disassembly 
# (preceding) line and the location redisplayed to move the cursor to the
# space that follows it (so we don't have to know how long it was).  That space
# is then flagged with the specified flag character in the specified color.
#
# The color value is the standard xterm color value.
#
# Examples: color = 0  ==> normal
#                   1  ==> bold
#                   31 ==> red
#                   34 ==> blue
#
define __flag_asm_line
    printf "%c[1A", 0x1B
    printf "0x%x%c[%dm%c%c[0m\n", $arg0, 0x1B, $arg2, $arg1, 0x1B
end
document __flag_asm_line
For internal use only -- do not use.
end

###################################################################################
#
# __flag_pc - shorthand for __flag_asm_line $pc '*' 31
#
define __flag_pc
    __flag_asm_line $pc '*' 31
end
document __flag_pc
For internal use only -- do not use.
end

###################################################################################
#
# __flag_loc loc - shorthand for __flag_asm_line loc '*' 31
#
define __flag_loc
    set $__loc = $arg0
    __flag_asm_line $__loc '.' 34
end
document __flag_loc
For internal use only -- do not use.
end

###################################################################################
#
# __disasm1 loc flagloc
#
# Disassemble one instruction at loc.  If loc is equal to the flag_loc then flag
# the line with the pc flag if flag_loc == $pc or the non-pc loc flag if loc ==
# flag_loc.
#
define __disasm1
    set $__loc     = $arg0
    set $__flagloc = $arg1
    
    x/1i $__loc
    
    if ($__loc == $pc)
    	__flag_pc
    	__branch_taken
    else
    	if ($__loc == $__flagloc)
    	    __flag_loc $__flagloc
    	end
    end
end
document __disasm1
For internal use only -- do not use.
end

###################################################################################
#
# __disasmN addr n [flagloc]
#
# Disassemble n lines from addr and flag flagloc if it is specified.
#
define __disasmN
    set $__addr = $arg0
    set $__n    = $arg1
    
    if ($argc > 2)
    	set $__flagloc = $arg2
    else
     	set $__flagloc = -1
   end
    
    set $__i = 0
    set $branch_taken = 0
    
    while ($__i < $__n)
    	__disasm1 ((char*)$__addr+4*$__i++) $__flagloc
    end
    
    if ($branch_taken == 1)
    	printf "Will branch\n"
    else 
    	if ($branch_taken == -1)
    	    printf "Will not branch\n"
    	end
    end
    
    if ($__running__)
    	__display_registers_v
    end
end
document __disasmN
For internal use only -- do not use.
end

###################################################################################
#
# __hexdump [addr [n]] - dump n (default 16) bytes starting at addr (default pc)
#
define __hexdump
    if ($argc == 0)
    	set $__addr      = (unsigned char *)$pc
    	set $__addr1     = (unsigned char *)$pc + 16
    else
    	if ($argc == 1)
    	    set $__addr  = (unsigned char *)($arg0)
    	    set $__addr1 = (unsigned char *)$__addr + 16
    	else
    	    set $__addr  = (unsigned char *)($arg0)
   	    set $__addr1 = (unsigned char *)$__addr + ($arg1)
   	end
    end
    
    set $__prevaddr = (unsigned char *)$__addr
    set $__rep_count = 0
    
    while ($__addr < $__addr1)
    	set $__addr2 = $__addr
   	
   	# Only allow full ditto lines and never the last line
   	
    	if ((unsigned char *)$__addr + 16 < $__addr1)
    	    __repeated_dump_line $__prevaddr $__addr 16
    	else
    	    set $repeated = 0
    	end
    	set $__prevaddr = (unsigned char *)$__addr
     	
     	if ($repeated)
     	    if ($__rep_count++ == 0)
     		printf " %.8X: '''' '''' '''' ''''  '''' '''' '''' ''''  ''''''''''''''''\n", $__addr
     	    end
      	    set $__addr = (char *)$__addr + 16
     	else
     	    printf " %.8X: ", $__addr
     	    set $__rep_count = 0
      	    set $__i = 0
    	    while ($__i++ < 8)
      	    	set $__j = 0
    	    	while ($__j++ < 2)
     	    	    if ($__addr < $__addr1)
     	    	    	set $__x = *((unsigned char *)$__addr)++
 		    	printf "%1X%1X", ($__x >> 4) & 0x0F, $__x & 0x0F
 		    else
 		    	printf "  "
 		    end
     	    	end
     	    	printf " "
     	    	if ($__i == 4)
     	    	    printf " "
     	    	end
     	    end
  	    
  	    printf " "
  	    
      	    set $__i = 0
    	    while ($__i++ < 16)
  	    	if ($__addr2 < $__addr1)
    	    	    set $__x = *((unsigned char *)$__addr2)++
    	    	    if ($__x >= 0x20 && $__x <= 0x7F)
    	    	    	printf "%c", $__x
    	    	    else
    	    	    	printf "."
    	    	    end
 	    	else
    		    printf " "
 	    	end
     	    end
    	    printf "\n"
 	end
 	
    end
end
document __hexdump
For internal use only -- do not use.
end

###################################################################################
#
# __repeated_dump_line prev addr n - Check for repeated dump lines
#
# If the n bytes starting at the prev address is the same as the n bytes starting at addr then
# set $repeated to 1.  Otherwise set it to 0.
#				       
# This is used by __hexdump and DMA to control whether repeated lines are to be
# displayed.  This is further controlled by the MSET DITTO setting.
#
define __repeated_dump_line
    set $repeated = 0
    
    # Test $__ditto__ as a single operand just in case it is still undefined. Gdb
    # sets undefined convenience variables to void which tests as false.
    
    if ($__ditto__ && $arg0 < $arg1)
    	set $__p1 = (unsigned char *)$arg0
    	set $__p2 = (unsigned char *)$arg1
    	set $__k  = $arg2
    	
    	set $repeated = 1
     	
    	while ($repeated && $__k--)
    	    if (*((unsigned char *)$__p1)++ != *((unsigned char *)$__p2)++)
    	    	set $repeated = 0
    	    end
    	end
    else
    	set $repeated = 0
    end
end
document __repeated_dump_line
For internal use only -- do not use.
end

###################################################################################
#
# __print_char char [isString] - print a (possibly escaped) character
#
# If isString (actually any 2nd argument) is specified then this character is
# in the context of a "string" as opposed to a 'string' (i.e., the surrounding
# quotes on the string) so that a single quote do not need to be escaped.  On
# the other hand if this is the context of a double-quoted string then double
# quotes need to be escaped.
#
define __print_char
    set $__c = $arg0
    if ($__c <= 0xFF)
	if ($__c == '\n')
	    printf "\\n"
	else
	    if ($__c == '\r')
		printf "\\r"
	    else
		if ($__c == '\t')
		    printf "\\t"
		else 
		    if ($__c == '\a')
		    	printf "\\a"
		    else
		    	if ($__c == '\f')
		    	    printf "\\f"
		    	else
		    	    if ($__c == '\b')
		    	    	printf "\\b"
		    	    else
		    	    	if ($__c == '\v')
		    	    	    printf "\\v"
		    	    	else
		    	    	    if ($__c == '\'' && $argc == 1)
			    	    	printf "\\'"
		    	    	    else
		    	    	    	if ($__c == '"' && $argc > 1)
		    	    	    	    printf "\\\""
		    	    	    	else
			    	    	    if (($__c < 0x20) || ($__c >= 0x7f))
			    	    	    	# show escaped octals in bold
			    	    	    	printf "%c[1m\\%03o%c[0m", 0x1B, $__c, 0x1B
			    	    	    else
			    	    	    	printf "%c", $__c
			    	    	    end
			    	    	end
				    end
			    	end
			    end
			end
		    end
		end
	    end
	end
    end
end
document __print_char
For internal use only -- do not use.
end

###################################################################################
#
# __print_1 value
#
define __print_1
    set $__value = $arg0
    printf "'"
    __print_char ($__value&0xFF)
    printf "'"
end
document __print_1
For internal use only -- do not use.
end

###################################################################################
#
# __print_2 value
#
define __print_2
    set $__value = $arg0
    printf "'"
    __print_char ($__value>>8)&0xFF
    __print_char ($__value&0xFF)
    printf "'"
end
document __print_2
For internal use only -- do not use.
end

###################################################################################
#
# __print_4 value
#
define __print_4
    set $__value = $arg0
    printf "'"
    __print_char (($__value>>24)&0xFF)
    __print_char (($__value>>16)&0xFF)
    __print_char (($__value>>8)&0xFF)
    __print_char ($__value&0xFF)
    printf "'"
end
document __print_4
For internal use only -- do not use.
end

###################################################################################
#
# __strcmp s1 s2 - set $strcmp != 0 if strings match else 0
#
# We could test for the existence of the function strcmp() and use it instead of
# doing all this crap.  While the odds are that it would always be found (I think
# it's part of the System Framework which most everything links in, and I did
# always see it in my testing) having our own gdb strcmp is guaranteed and 100%
# safe.  While the probability is very low, it is not zero that the user defined
# his own strcmp() that doesn't do what the C/C++ strcmp() does.  Ok, I'm being
# overly paranoid.
#
define __strcmp
    set $__s1 = (unsigned char *)($arg0)
    set $__s2 = (unsigned char *)($arg1)
    
    set $strcmp = 1
    
    set $__c1 = *((unsigned char *)$__s1)++
    while ($strcmp && $__c1)
    	set $__c2 = *((unsigned char *)$__s2)++
	if ($__c1 == $__c2)
	    set $__c1 = *((unsigned char *)$__s1)++
	else
	    set $strcmp = 0
	end
    end
    
    set $strcmp &= (*(unsigned char *)$__s2 == 0)
end
document __strcmp
For internal use only -- do not use.
end

###################################################################################
#
# __strncmp s1 s2 n - set $strncmp != 0 if n characters of strings match else 0
#
# Similar to __strcmp except that this one's the equivalent to strncmp().
#
define __strncmp
    set $__s1 = (unsigned char *)($arg0)
    set $__s2 = (unsigned char *)($arg1)
    set $__n  = $arg2 + 1
    
    set $strncmp = 1
    
    while ($strncmp && --$__n)
    	set $__c1 = *((unsigned char *)$__s1)++
    	set $__c2 = *((unsigned char *)$__s2)++
    	
	if ($__c1 != $__c2)
	    set $strncmp = 0
	else
	    if ($__c1 == 0)
	    	set $__n = 1
	    end
	end
    end
end
document __strncmp
For internal use only -- do not use.
end

###################################################################################
#
# __strlen s - return the length of the string (argument) in $strlen
#
define __strlen
    set $strlen = -1
    set $__s = (char *)$arg0
    while ($__s[++$strlen])
    end
end
document __strlen
For internal use only -- do not use.
end

###################################################################################
#
# __memcpy s1 s2 n
#
define __memcpy
    set $__s1 = (unsigned char *)($arg0)
    set $__s2 = (unsigned char *)($arg1)
    set $__n  = $arg2 + 1
    
    while (--$__n)
    	set *((unsigned char *)$__s1)++ = *((unsigned char *)$__s2)++
    end
end
document __memcpy
For internal use only -- do not use.
end

###################################################################################
#
# __lower_case option_arg - lower case an option argument
#
# Returns $lower_case containing the lower cased copy of the option_arg.  The
# option_arg must be an ACTUAL $argN symbol from the caller, not a value set from it.
#
define __lower_case
    set $lower_case = (char *)"$arg0"
    set $__i = 0
    while ($lower_case[$__i])
	if ($lower_case[$__i] >= 'A' && $lower_case[$__i] <= 'Z')
	    set $lower_case[$__i] = 'a' + ($lower_case[$__i] - 'A')
	end
	set ++$__i
    end
end
document __lower_case
For internal use only -- do not use.
end

###################################################################################
#
# __is_string arg - determine if arg is a value or "string"
#
# Returns $string set to the a pointer to the string if arg is a string and $string
# is set to 0 if the arg is not a string.
#
# This function uses the fact (determined after much expirimentation) that assigning
# a value to a variable simply yields that value.  But assigning a string yields a
# new instance of the pointer to the string and thus the resultant pointer will not
# be the same as the original argument pointer.  If someone can figure out a simpler
# way of determining a double quoted "string" argument from a value in this dumb
# command language I'm open to it!
#
# Note, the arg must be an ACTUAL $argN symbol, not a value set from it.  A set
# assignment yields a pointer value.  We need the actual arg as written because
# actual arg substitution is a string substitution which we are assuming here when
# we do the (char *)$arg0 assignment.  We are actually doing (char *)"string" here
# when the arg really was a string which allows us to do what we do here.
#
define __is_string
    if ((long)$arg0 < 0)
    	# Negative values are assumed to be just that, values, and not strings.
    	set $string = 0
    else
    	# If value is not negative, get its value cast as a pointer...
        set $__p = (char *)$arg0
        
        # If original value is same as pointer value then it's a value. Otherwise
        # the set $__p created a new instance of the string (lucky for use) and
        # it won't be the same when it's a string.  What a kludge!  What a language!
        if ($__p == $arg0)
            set $string = 0
        else
            set $string = $__p
        end
    end
end
document __is_string
For internal use only -- do not use.
end

###################################################################################
#
# __save_all_regs_v - save current values of all registers
#
# This is called by __display_registers_v to remember the previous display.
# It is also called by __save_all_regs_h which saved additional registers.
#
define __save_all_regs_v
    set $__lr   = $lr
    set $__ctr  = $ctr
    set $__msr  = $ps
    set $__xer  = $xer
    set $__mq   = $mq
    
    set $__cr0  = ($cr>>28&15)
    set $__cr1  = ($cr>>24&15)
    set $__cr2  = ($cr>>20&15)
    set $__cr3  = ($cr>>16&15)
    set $__cr4  = ($cr>>12&15)
    set $__cr5  = ($cr>>8&15)
    set $__cr6  = ($cr>>4&15)
    set $__cr7  = ($cr&15)
    
    set $__r0  = $r0
    set $__sp  = $r1
    set $__r2  = $r2
    set $__r3  = $r3
    set $__r4  = $r4
    set $__r5  = $r5
    set $__r6  = $r6
    set $__r7  = $r7
    set $__r8  = $r8
    set $__r9  = $r9
    set $__r10 = $r10
    set $__r11 = $r11
    set $__r12 = $r12
    set $__r13 = $r13
    set $__r14 = $r14
    set $__r15 = $r15
    set $__r16 = $r16
    set $__r17 = $r17
    set $__r18 = $r18
    set $__r19 = $r19
    set $__r20 = $r20
    set $__r21 = $r21
    set $__r22 = $r22
    set $__r23 = $r23
    set $__r24 = $r24
    set $__r25 = $r25
    set $__r26 = $r26
    set $__r27 = $r27
    set $__r28 = $r28
    set $__r29 = $r29
    set $__r30 = $r30
    set $__r31 = $r31
end
document __save_all_regs_v
For internal use only -- do not use.
end

###################################################################################
#
# __save_all_regs_h - save current values of all registers
#
# This is called by __display_registers_h to remember the previous display.
#
define __save_all_regs_h
    __save_all_regs_v
    
    set $__so   = $xer>>31 & 1
    set $__ov   = $xer>>30 & 1
    set $__ca   = $xer>>29 & 1
    set $__xcmp = $xer>>8 & 0xFF
    set $__xcnt = $xer & 0x7F
    
    set $__cr00 = $__cr0>>3 & 1
    set $__cr01 = $__cr0>>2 & 1
    set $__cr02 = $__cr0>>1 & 1
    set $__cr03 = $__cr0    & 1
    
    set $__cr10 = $__cr1>>3 & 1
    set $__cr11 = $__cr1>>2 & 1
    set $__cr12 = $__cr1>>1 & 1
    set $__cr13 = $__cr1    & 1
    
    set $__cr20 = $__cr2>>3 & 1
    set $__cr21 = $__cr2>>2 & 1
    set $__cr22 = $__cr2>>1 & 1
    set $__cr23 = $__cr2    & 1
    
    set $__cr30 = $__cr3>>3 & 1
    set $__cr31 = $__cr3>>2 & 1
    set $__cr32 = $__cr3>>1 & 1
    set $__cr33 = $__cr3    & 1
    
    set $__cr40 = $__cr4>>3 & 1
    set $__cr41 = $__cr4>>2 & 1
    set $__cr42 = $__cr4>>1 & 1
    set $__cr43 = $__cr4    & 1
    
    set $__cr50 = $__cr5>>3 & 1
    set $__cr51 = $__cr5>>2 & 1
    set $__cr52 = $__cr5>>1 & 1
    set $__cr53 = $__cr5    & 1
    
    set $__cr60 = $__cr6>>3 & 1
    set $__cr61 = $__cr6>>2 & 1
    set $__cr62 = $__cr6>>1 & 1
    set $__cr63 = $__cr6    & 1
    
    set $__cr70 = $__cr7>>3 & 1
    set $__cr71 = $__cr7>>2 & 1
    set $__cr72 = $__cr7>>1 & 1
    set $__cr73 = $__cr7    & 1
end
document __save_all_regs_h
For internal use only -- do not use.
end

###################################################################################
#
# __color_change boolean-expression - set color to red or normal depending on
#				      whether expression is true (red) or false
#				      (0).
#
# This for coloring register value changes.  Once upon a time we used "%c[3%dm"
# as the print format, where "\e[31m" was red and "\e[30m" was black.  Thus we
# could use the boolean expresion directly in print statements and not need this
# routine.  However, it turns out that black on some terminal color schemes is
# not the same thing as normal/standard color which is "\e[0m".  Hence this more
# elaborate scheme.  Sigh! :-(
#
define __color_change
    if ($arg0)
    	printf "%c[31m", 0x1B
    else
    	printf "%c[0m", 0x1B
    end
end

###################################################################################
#
# __display_registers_v [col] - display all registers in a fixed position vertically
#				on the right side of the terminal window (or starting
#				in the specified 1-relative column)
#
# Any register which changes value from the previous display is shown in red.  The
# "previous" display is one for which any compatible command was previously used
# (e.g., so's, si's, il's, etc.).
#
define __display_registers_v
    # Assume we will display in the last 14 columns of a 132-width display starting
    # at the top of the window...
    
    set $screen_width = 132
    set $__row = 1
    
    # We'll generalize this a bit to specify a starting column which defaults to
    # the screen width minus 14.  We don't allow specifying the top row since
    # scrolling always moves the display up when a command is entered and this
    # display looks as best as we can when we start it on row 1.
     
    if ($argc == 1)
	set $__col = $arg0
    else
        set $__col = $screen_width - 14
    end
    
    # If the previous command wasn't one that displayed the registers then init
    # the previous values with the current values.  This also makes sure they 
    # are defined the first time we ever use them.
    
    # Check for ID, IL, IP, SI, and SO...
    if ($__lastcmd__ != 9  && \
        $__lastcmd__ != 11 && \
        $__lastcmd__ != 13 && \
        $__lastcmd__ != 16 && \
        $__lastcmd__ != 23)
	__save_all_regs_v
	set $__saved_regs = 1
    else
        set $__saved_regs = 0
    end
        
    # Finally print all these suckers.  We control the positioning for each registers
    # and make sure we preserve the cursor's original position so we leave it where
    # we found it.
    
    printf "%c7", 0x1B
    #set $__row += 0

    printf "%c[%d;%dH| PC  %.8X%c[0K", 0x1B, $__row+ 0, $__col, $pc, 0x1B
    printf "%c[%d;%dH| SP  %.8X%c[0K", 0x1B, $__row+ 1, $__col, $sp, 0x1B
    
    printf "%c[%d;%dH| %c[0K", 0x1B,         $__row+ 2, $__col, 0x1B

    printf "%c[%d;%dH%c[0m| LR  ", 0x1B, $__row+ 3, $__col, 0x1B
    __color_change ($__lr!=$lr)
    printf "%.8X%c[0K", $lr, 0x1B

    printf "%c[%d;%dH| CR  ", 0x1B,          $__row+ 4, $__col
    __color_change ($__cr0!=($cr>>28&15))
      printf "%.1X", ($cr>>28&15)
    __color_change ($__cr1!=($cr>>24&15))
      printf "%.1X", ($cr>>24&15)
    __color_change ($__cr2!=($cr>>20&15))
      printf "%.1X", ($cr>>20&15)
    __color_change ($__cr3!=($cr>>16&15))
      printf "%.1X", ($cr>>16&15)
    __color_change ($__cr4!=($cr>>12&15))
      printf "%.1X", ($cr>>12&15)
    __color_change ($__cr5!=($cr>>8&15))
      printf "%.1X", ($cr>>8&15)
    __color_change ($__cr6!=($cr>>4&15))
      printf "%.1X", ($cr>>4&15)
    __color_change ($__cr7!=($cr&15))
      printf "%.1X", ($cr&15)
    printf "%c[0K", 0x1B
    
    printf "%c[%d;%dH%c[0m|%c[0K", 0x1B, $__row+ 5, $__col, 0x1B, 0x1B
    
    printf "%c[%d;%dH%c[0m| CTR ", 0x1B, $__row+ 6, $__col, 0x1B
    __color_change ($__ctr!=$ctr)
    printf "%.8X%c[0K", $ctr, 0x1B
    
    printf "%c[%d;%dH%c[0m| MSR ", 0x1B, $__row+ 7, $__col, 0x1B
    __color_change ($__msr!=$ps)
    printf "%.8X%c[0K", $ps, 0x1B
    
    printf "%c[%d;%dH%c[0m| MQ  ", 0x1B, $__row+ 8, $__col, 0x1B
    __color_change ($__mq!=$mq)
    printf "%.8X%c[0K", $mq, 0x1B
    
    printf "%c[%d;%dH%c[0m| XER ", 0x1B, $__row+ 9, $__col, 0x1B
    __color_change (($__xer>>28&0xF)!=($xer>>28&0xF))
    printf "%.1X%c[0m%.3X", ($xer>>28&0xF), 0x1B, ($xer>>16&0xFFF)
    __color_change (($__xer>>8&0xFF)!=($xer>>8&0xFF))
    printf "%.2X", ($xer>>8&0xFF)
    __color_change (($__xer&0xFF)!=($xer&0xFF))
    printf "%2X%c[0K", ($xer&0xFF), 0x1B

    printf "%c[%d;%dH%c[0m|%c[0K", 0x1B, $__row+10, $__col, 0x1B, 0x1B
    
    set $__row += 11
    
    printf "%c[%d;%dH%c[0m| R0  ", 0x1B, $__row+ 0, $__col, 0x1B
    __color_change ($__r0!=$r0)
    printf "%.8X%c[0K", $r0, 0x1B
    
    printf "%c[%d;%dH%c[0m| SP  ", 0x1B, $__row+ 1, $__col, 0x1B
    __color_change ($__sp!=$r1)
    printf "%.8X%c[0K", $r1, 0x1B
    
    printf "%c[%d;%dH%c[0m| R2  ", 0x1B, $__row+ 2, $__col, 0x1B
    __color_change ($__r2!=$r2)
    printf "%.8X%c[0K", $r2, 0x1B

    printf "%c[%d;%dH%c[0m| R3  ", 0x1B, $__row+ 3, $__col, 0x1B
    __color_change ($__r3!=$r3)
    printf "%.8X%c[0K", $r3, 0x1B

    printf "%c[%d;%dH%c[0m| R4  ", 0x1B, $__row+ 4, $__col, 0x1B
    __color_change ($__r4!=$r4)
    printf "%.8X%c[0K", $r4, 0x1B

    printf "%c[%d;%dH%c[0m| R5  ", 0x1B, $__row+ 5, $__col, 0x1B
    __color_change ($__r5!=$r5)
    printf "%.8X%c[0K", $r5, 0x1B

    printf "%c[%d;%dH%c[0m| R6  ", 0x1B, $__row+ 6, $__col, 0x1B
    __color_change ($__r6!=$r6)
    printf "%.8X%c[0K", $r6, 0x1B

    printf "%c[%d;%dH%c[0m| R7  ", 0x1B, $__row+ 7, $__col, 0x1B
    __color_change ($__r7!=$r7)
    printf "%.8X%c[0K", $r7, 0x1B

    printf "%c[%d;%dH%c[0m| R8  ", 0x1B, $__row+ 8, $__col, 0x1B
    __color_change ($__r8!=$r8)
    printf "%.8X%c[0K", $r8, 0x1B

    printf "%c[%d;%dH%c[0m| R9  ", 0x1B, $__row+ 9, $__col, 0x1B
    __color_change ($__r9!=$r9)
    printf "%.8X%c[0K", $r9, 0x1B

    printf "%c[%d;%dH%c[0m| R10 ", 0x1B, $__row+10, $__col, 0x1B
    __color_change ($__r10!=$r10)
    printf "%.8X%c[0K", $r10, 0x1B
    
    printf "%c[%d;%dH%c[0m| R11 ", 0x1B, $__row+11, $__col, 0x1B
    __color_change ($__r11!=$r11)
    printf "%.8X%c[0K", $r11, 0x1B
    
    printf "%c[%d;%dH%c[0m| R12 ", 0x1B, $__row+12, $__col, 0x1B
    __color_change ($__r12!=$r12)
    printf "%.8X%c[0K", $r12, 0x1B

    printf "%c[%d;%dH%c[0m| R13 ", 0x1B, $__row+13, $__col, 0x1B
    __color_change ($__r13!=$r13)
    printf "%.8X%c[0K", $r13, 0x1B

    printf "%c[%d;%dH%c[0m| R14 ", 0x1B, $__row+14, $__col, 0x1B
    __color_change ($__r14!=$r14)
    printf "%.8X%c[0K", $r14, 0x1B

    printf "%c[%d;%dH%c[0m| R15 ", 0x1B, $__row+15, $__col, 0x1B
    __color_change ($__r15!=$r15)
    printf "%.8X%c[0K", $r15, 0x1B

    printf "%c[%d;%dH%c[0m| R16 ", 0x1B, $__row+16, $__col, 0x1B
    __color_change ($__r16!=$r16)
    printf "%.8X%c[0K", $r16, 0x1B

    printf "%c[%d;%dH%c[0m| R17 ", 0x1B, $__row+17, $__col, 0x1B
    __color_change ($__r17!=$r17)
    printf "%.8X%c[0K", $r17, 0x1B

    printf "%c[%d;%dH%c[0m| R18 ", 0x1B, $__row+18, $__col, 0x1B
    __color_change ($__r18!=$r18)
    printf "%.8X%c[0K", $r18, 0x1B

    printf "%c[%d;%dH%c[0m| R19 ", 0x1B, $__row+19, $__col, 0x1B
    __color_change ($__r19!=$r19)
    printf "%.8X%c[0K", $r19, 0x1B

    printf "%c[%d;%dH%c[0m| R20 ", 0x1B, $__row+20, $__col, 0x1B
    __color_change ($__r20!=$r20)
    printf "%.8X%c[0K", $r20, 0x1B
    
    printf "%c[%d;%dH%c[0m| R21 ", 0x1B, $__row+21, $__col, 0x1B
    __color_change ($__r21!=$r21)
    printf "%.8X%c[0K", $r21, 0x1B
    
    printf "%c[%d;%dH%c[0m| R22 ", 0x1B, $__row+22, $__col, 0x1B
    __color_change ($__r22!=$r22)
    printf "%.8X%c[0K", $r22, 0x1B

    printf "%c[%d;%dH%c[0m| R23 ", 0x1B, $__row+23, $__col, 0x1B
    __color_change ($__r23!=$r23)
    printf "%.8X%c[0K", $r23, 0x1B

    printf "%c[%d;%dH%c[0m| R24 ", 0x1B, $__row+24, $__col, 0x1B
    __color_change ($__r24!=$r24)
    printf "%.8X%c[0K", $r24, 0x1B

    printf "%c[%d;%dH%c[0m| R25 ", 0x1B, $__row+25, $__col, 0x1B
    __color_change ($__r25!=$r25)
    printf "%.8X%c[0K", $r25, 0x1B

    printf "%c[%d;%dH%c[0m| R26 ", 0x1B, $__row+26, $__col, 0x1B
    __color_change ($__r26!=$r26)
    printf "%.8X%c[0K", $r26, 0x1B

    printf "%c[%d;%dH%c[0m| R27 ", 0x1B, $__row+27, $__col, 0x1B
    __color_change ($__r27!=$r27)
    printf "%.8X%c[0K", $r27, 0x1B

    printf "%c[%d;%dH%c[0m| R28 ", 0x1B, $__row+28, $__col, 0x1B
    __color_change ($__r28!=$r28)
    printf "%.8X%c[0K", $r28, 0x1B

    printf "%c[%d;%dH%c[0m| R29 ", 0x1B, $__row+29, $__col, 0x1B
    __color_change ($__r29!=$r29)
    printf "%.8X%c[0K", $r29, 0x1B

    printf "%c[%d;%dH%c[0m| R30 ", 0x1B, $__row+30, $__col, 0x1B
    __color_change ($__r30!=$r30)
    printf "%.8X%c[0K", $r30, 0x1B
    
    printf "%c[%d;%dH%c[0m| R31 ", 0x1B, $__row+31, $__col, 0x1B
    __color_change ($__r31!=$r31)
    printf "%.8X%c[0K", $r31, 0x1B
    
    printf "%c[%d;%dH%c[0m+ÑÑÑÑÑÑÑÑÑÑÑÑÑ%c[0K", 0x1B, $__row+32, $__col, 0x1B, 0x1B
    printf "%c8", 0x1B
    
    # Now that we know what's changed, save the values for the next time
    # through here unless we already saved them.
    
    if (!$__saved_regs)
    	__save_all_regs_v
    end
end
document __display_registers_v
For internal use only -- do not use.
end

###################################################################################
#
# __display_registers_h - display all registers horizontally at the top of the
#			  screen
#
# Any register which changes value from the previous display is shown in red.  The
# "previous" display is one for which any compatible command was previously used
# (e.g., so's, si's, il's, etc.).
#
# PC  00001D18        CR0  CR1  CR2  CR3  CR4  CR5  CR6  CR7
# LR  00001D14    CR  1000 0010 0000 0000 0000 0000 0001 0100
# CTR 5ACE8160     
# MSR 0002D030    XER 000/00/00 (SOC/Compare/Count)
# 
# R0 00001C48     R8  00000000      R16 00000000      R24 00000000
# SP BFFFF170     R9  BFFFF378      R17 00000000      R25 00000000
# R2 00000000     R10 BFFFF3DF      R18 00000000      R26 BFFFF284
# R3 00000001     R11 BFFFFFFF      R19 00000000      R27 00000008
# R4 BFFFF288     R12 5ACE8160      R20 00000000      R28 00000001
# R5 BFFFF290     R13 00000000      R21 00000000      R29 BFFFF290
# R6 BFFFF370     R14 00000000      R22 00000000      R30 BFFFF170
# R7 0000000A     R15 00000000      R23 00000000      R31 00001D14
#
define __display_registers_h
    # If the previous command wasn't one that displayed the registers then init
    # the previous values with the current values.  This also makes sure they 
    # are defined the first time we ever use them.
    
    # Check for ID, IL, IP, SI, and SO...
    if ($__lastcmd__ != 9  && \
        $__lastcmd__ != 11 && \
        $__lastcmd__ != 13 && \
        $__lastcmd__ != 16 && \
        $__lastcmd__ != 23)
	__save_all_regs_h
	set $__saved_regs = 1
    else
        set $__saved_regs = 0
    end
    
    printf "%c7", 0x1B
    printf "%c[1;1H", 0x1B

    printf "PC  %.8X        CR0  CR1  CR2  CR3  CR4  CR5  CR6  CR7%c[0K\n", $pc, 0x1B
    
    printf "LR  "
    __color_change ($__lr!=$lr)
    printf "%.8X%c[0m    CR  ", $lr, 0x1B
    
    __color_change ($__cr00!=($cr>>31&1))
      printf "%.1X", ($cr>>31&1)
    __color_change ($__cr01!=($cr>>30&1))
      printf "%.1X", ($cr>>30&1)
    __color_change ($__cr02!=($cr>>29&1))
      printf "%.1X", ($cr>>29&1)
    __color_change ($__cr03!=($cr>>28&1))
      printf "%.1X", ($cr>>28&1)
    printf " "
    __color_change ($__cr10!=($cr>>27&1))
      printf "%.1X", ($cr>>27&1)
    __color_change ($__cr11!=($cr>>26&1))
      printf "%.1X", ($cr>>26&1)
    __color_change ($__cr12!=($cr>>25&1))
      printf "%.1X", ($cr>>25&1)
    __color_change ($__cr13!=($cr>>24&1))
      printf "%.1X", ($cr>>24&1)
    printf " "
    __color_change ($__cr20!=($cr>>23&1))
      printf "%.1X", ($cr>>23&1)
    __color_change ($__cr21!=($cr>>22&1))
      printf "%.1X", ($cr>>22&1)
    __color_change ($__cr21!=($cr>>21&1))
      printf "%.1X", ($cr>>21&1)
    __color_change ($__cr23!=($cr>>20&1))
      printf "%.1X", ($cr>>20&1)
    printf " "
    __color_change ($__cr30!=($cr>>19&1))
      printf "%.1X", ($cr>>19&1)
    __color_change ($__cr31!=($cr>>18&1))
      printf "%.1X", ($cr>>18&1)
    __color_change ($__cr32!=($cr>>17&1))
      printf "%.1X", ($cr>>17&1)
    __color_change ($__cr33!=($cr>>16&1))
      printf "%.1X", ($cr>>16&1)
    printf " "
    __color_change ($__cr40!=($cr>>15&1))
      printf "%.1X", ($cr>>15&1)
    __color_change ($__cr41!=($cr>>14&1))
      printf "%.1X", ($cr>>14&1)
    __color_change ($__cr42!=($cr>>13&1))
      printf "%.1X", ($cr>>13&1)
    __color_change ($__cr43!=($cr>>12&1))
      printf "%.1X", ($cr>>12&1)
    printf " "
    __color_change ($__cr50!=($cr>>11&1))
      printf "%.1X", ($cr>>11&1)
    __color_change ($__cr51!=($cr>>10&1))
      printf "%.1X", ($cr>>10&1)
    __color_change ($__cr52!=($cr>>9&1))
      printf "%.1X", ($cr>>9&1)
    __color_change ($__cr53!=($cr>>8&1))
      printf "%.1X", ($cr>>8&1)
    printf " "
    __color_change ($__cr60!=($cr>>7&1))
      printf "%.1X", ($cr>>7&1)
    __color_change ($__cr61!=($cr>>6&1))
      printf "%.1X", ($cr>>6&1)
    __color_change ($__cr62!=($cr>>5&1))
      printf "%.1X", ($cr>>5&1)
    __color_change ($__cr63!=($cr>>4&1))
      printf "%.1X", ($cr>>4&1)
    printf " "
    __color_change ($__cr70!=($cr>>3&1))
      printf "%.1X", ($cr>>3&1)
    __color_change ($__cr71!=($cr>>2&1))
      printf "%.1X", ($cr>>2&1)
    __color_change ($__cr72!=($cr>>1&1))
      printf "%.1X", ($cr>>1&1)
    __color_change ($__cr73!=($cr&1))
      printf "%.1X", ($cr&1)
    printf "%c[0m%c[0K\n", 0x1B, 0x1B

    printf "CTR "
    __color_change ($__ctr!=$ctr)
    printf "%.8X%c[0m%c[0K\n", $ctr, 0x1B, 0x1B

    printf "MSR "
    __color_change ($__msr!=$ps)
    printf "%.8X%c[0m    XER ", $ps, 0x1B
    
    __color_change ($__so!=($xer>>31&1))
      printf "%.1X", ($xer>>31&1)
    __color_change ($__ov!=($xer>>30&1))
      printf "%.1X", ($xer>>30&1)
    __color_change ($__ca!=($xer>>29&1))
      printf "%.1X%c[0m/", ($xer>>29&1), 0x1B
    __color_change ($__xcmp!=($xer>>8&0xFF))
      printf "%.2X%c[0m/", ($xer>>8&0xFF), 0x1B
    __color_change ($__xcnt!=($xer&0x7F))
      printf "%.2X%c[0m (SOC/Compare/Count)%c[0K\n", ($xer&0x7F), 0x1B, 0x1B

    printf "%c[0K\n", 0x1B
    
    printf "R0 "
      __color_change ($__r0!=$r0)
      printf "%.8X%c[0m     ", $r0, 0x1B
    printf "R8  "
      __color_change ($__r8!=$r8)
      printf "%.8X%c[0m     ", $r8, 0x1B
    printf "R16 "
      __color_change ($__r16!=$r16)
      printf "%.8X%c[0m     ", $r16, 0x1B
    printf "R24 "
      __color_change ($__r24!=$r24)
      printf "%.8X%c[0m%c[0K\n", $r24, 0x1B, 0x1B
    
    printf "SP "
      __color_change ($__sp!=$r1)
      printf "%.8X%c[0m     ", $r1, 0x1B
    printf "R9  "
      __color_change ($__r9!=$r9)
      printf "%.8X%c[0m     ", $r9, 0x1B
    printf "R17 "
      __color_change ($__r17!=$r17)
      printf "%.8X%c[0m     ", $r17, 0x1B
    printf "R25 "
      __color_change ($__r25!=$r25)
      printf "%.8X%c[0m%c[0K\n", $r25, 0x1B, 0x1B
    
    printf "R2 "
      __color_change ($__r2!=$r2)
      printf "%.8X%c[0m     ", $r2, 0x1B
    printf "R10 "
      __color_change ($__r10!=$r10)
      printf "%.8X%c[0m     ", $r10, 0x1B
    printf "R18 "
      __color_change ($__r18!=$r18)
      printf "%.8X%c[0m     ", $r18, 0x1B
    printf "R26 "
      __color_change ($__r26!=$r26)
      printf "%.8X%c[0m%c[0K\n", $r26, 0x1B, 0x1B
    
    printf "R3 "
      __color_change ($__r3!=$r3)
      printf "%.8X%c[0m     ", $r3, 0x1B
    printf "R11 "
      __color_change ($__r11!=$r11)
      printf "%.8X%c[0m     ", $r11, 0x1B
    printf "R19 "
      __color_change ($__r19!=$r19)
      printf "%.8X%c[0m     ", $r19, 0x1B
    printf "R27 "
      __color_change ($__r27!=$r27)
      printf "%.8X%c[0m%c[0K\n", $r27, 0x1B, 0x1B
    
    printf "R4 "
      __color_change ($__r4!=$r4)
      printf "%.8X%c[0m     ", $r4, 0x1B
    printf "R12 "
      __color_change ($__r12!=$r12)
      printf "%.8X%c[0m     ", $r12, 0x1B
    printf "R20 "
      __color_change ($__r20!=$r20)
      printf "%.8X%c[0m     ", $r20, 0x1B
    printf "R28 "
      __color_change ($__r28!=$r28)
      printf "%.8X%c[0m%c[0K\n", $r28, 0x1B, 0x1B
    
    printf "R5 "
      __color_change ($__r5!=$r5)
      printf "%.8X%c[0m     ", $r5, 0x1B
    printf "R13 "
      __color_change ($__r13!=$r13)
      printf "%.8X%c[0m     ", $r13, 0x1B
    printf "R21 "
      __color_change ($__r21!=$r21)
      printf "%.8X%c[0m     ", $r21, 0x1B
    printf "R29 "
      __color_change ($__r29!=$r29)
      printf "%.8X%c[0m%c[0K\n", $r29, 0x1B, 0x1B
    
    printf "R6 "
      __color_change ($__r6!=$r6)
      printf "%.8X%c[0m     ", $r6, 0x1B
    printf "R14 "
      __color_change ($__r14!=$r14)
      printf "%.8X%c[0m     ", $r14, 0x1B
    printf "R22 "
      __color_change ($__r22!=$r22)
      printf "%.8X%c[0m     ", $r22, 0x1B
    printf "R30 "
      __color_change ($__r30!=$r30)
      printf "%.8X%c[0m%c[0K\n", $r30, 0x1B, 0x1B
    
    printf "R7 "
      __color_change ($__r7!=$r7)
      printf "%.8X%c[0m     ", $r7, 0x1B
    printf "R15 "
      __color_change ($__r15!=$r15)
      printf "%.8X%c[0m     ", $r15, 0x1B
    printf "R23 "
      __color_change ($__r23!=$r23)
      printf "%.8X%c[0m     ", $r23, 0x1B
    printf "R31 "
      __color_change ($__r31!=$r31)
      printf "%.8X%c[0m%c[0K\n", $r31, 0x1B, 0x1B

    printf "ÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑ%c[0K", 0x1B
    printf "%c8", 0x1B
    
    # Now that we know what's changed, save the values for the next time
    # through here unless we already saved them.
    
    if (!$__saved_regs)
    	__save_all_regs_h
    end
end
document __display_registers_h
For internal use only -- do not use.
end

###################################################################################
#
# __scroll N - turn scrolling on (N > 0) or off (N < 0)
#
# If turned on, scrolling extends from line 15 through $arg0 to accomodate the
# 14-line register display done by __display_registers_h starting at line 1.  If
# scrolling is turned off, scrolling is set from line 1 through -$arg0
#
define __scroll
    #set $screen_height = 60

    set $__bottom = $arg0
    
    if ($__bottom > 0)
    	if ($__running__)
	    __display_registers_h
	else
    	    printf "%c[1;1HRegisters will be displayed here when program is running.", 0x1B
    	    printf "%c[0J", 0x1B 
	end
    	
    	printf "%c[14;1H", 0x1B
    	printf "ÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑ%c[0K%c8", 0x1B, 0x1B
    	printf "%c[15;%dr", 0x1B, $__bottom
    	printf "%c[15;1H", 0x1B
    	printf "%c[0J", 0x1B
    else
    	printf "%c7", 0x1B
    	printf "%c[1;%dr", 0x1B, -$__bottom
    	printf "%c8", 0x1B
    end
    
    
end
document __scroll
For internal use only -- do not use.
end

###################################################################################
#
# Intercept the RUN command to initialize our "global" convenience variables.  None
# of the Macsbug commands make sense anyway until the user does a RUN command.  This
# is fortunate since the only way to fire up execution is with a run command and
# there is NO OTHER WAY to initialize convenience variables!  Simply setting them in
# this script doesn't work since gdb wipes out the variables AFTER it runs the
# script.  They also get wiped out when a FILE command is done (and a hook-file is
# run before the variables are clobbered so that won't work either).
#
define hook-run
    set $dot            = 0
    set $__lastcmd__    = -1
    set $__next_addr__  = -1
    set $__prev_dm_n__  = 0
    set $__prev_dma_n__ = 0
    
    if ($__initialized__)
    	# When $__initialized__ is undefined it will test false.  We can only test
    	# undefined gdb convenience variables as shown (i.e., cannot mix with any
    	# operators).  So this path of this if remains empty once we initialize the
    	# state switches.  Of course a FILE command will uninialize everyting again.
    else
    	set $__unmangle__ = 0
    	set $__ditto__    = 0
    	set $__dx__       = 0
    	
    	set $__initialized__ = 1
    	set $__running__ = 1
    end
end

###################################################################################
