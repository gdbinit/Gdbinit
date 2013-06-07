#!/usr/bin/env bash

TARGET_DOUBLET=$(grep 'file type' /tmp/gdb_info_target |
                 sed 's/\.$//g' |
                 cut -d ' ' -f 4 |
                 uniq |
                 tr -d '\n')
OSABI=$(grep 'currently ' /tmp/gdb_info_target |
        sed 's/.*currently "\([^"]*\)".*/\1/' |
        tr -d '\n')
GDB_FILE="/tmp/gdb_target_arch.gdb"
rm -f "$GDB_FILE"

case "$TARGET_DOUBLET" in
    *-i386)
        echo "set \$X86 = 1" >> $GDB_FILE;
        ;;
    *-x86-64)
        echo "set \$X86_64 = 1" >> $GDB_FILE;
        echo "set \$64BITS = 1" >> $GDB_FILE;
        ;;
    *-arm*)
        echo "set \$ARM = 1" >> $GDB_FILE;
        ;;
    *-*mips*)
        echo "set \$MIPS = 1" >> $GDB_FILE;
        echo "set \$64BITS = 1" >> $GDB_FILE;
        ;;
    mach-o-*)
        if test "$OSABI" == "Darwin64"; then
            echo "set \$X86_64 = 1" >> $GDB_FILE;
            echo "set \$64BITS = 1" >> $GDB_FILE;
        elif test "$OSABI" == "Darwin"; then
            echo "set \$X86 = 1" >> $GDB_FILE;
        fi
        ;;
esac
