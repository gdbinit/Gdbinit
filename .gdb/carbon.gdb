define print-char
	if ($arg0 > 0xff)
		print "not a character"
		""
	else
		if ($arg0 == '\n')
			printf "\\n"
		else
			if ($arg0 == '\t')
				printf "\\t"
			else
				if ($arg0 == '\r')
					printf "\\r"
				else
					if ($arg0 == '\'')
						printf "\\'"
					else
						if (($arg0 < 0x20) || ($arg0 >= 0x7f))
							printf "\\%03o", $arg0
						else
							printf "%c", $arg0
						end
					end
				end
			end
		end
	end
end
document print-char
Print a single character in a readable fashion.
end

define print-ostype
	set $tmp0 = ($arg0)
	printf "'"
	set $tmp1 = (($tmp0 & 0xff000000) >> 24)
	print-char $tmp1
	set $tmp1 = (($tmp0 & 0x00ff0000) >> 16)
	print-char $tmp1
	set $tmp1 = (($tmp0 & 0x0000ff00) >> 8)
	print-char $tmp1
	set $tmp1 = (($tmp0 & 0x000000ff) >> 0)
	print-char $tmp1
	printf "'"
	printf "\n"
end
document print-ostype
Print a value as an OSType (four-byte character string).
end
