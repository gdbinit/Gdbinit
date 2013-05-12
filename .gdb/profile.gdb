set $rusage = 0
set $rusagebuffer = 0

define getrusage
	if ($rusagebuffer == 0)
		set $rusagebuffer = (unsigned long *) malloc (1024)
	end
	call (void) getrusage (0, $rusagebuffer)
	set $rusage = (($rusagebuffer[0] * 1000) + ($rusagebuffer[1] / 1000))
end

define mark
	getrusage
	set $rusagemark = $rusage
	printf "Timer started; total elapsed CPU time is %lu ms.\n", $rusagemark 
end
document mark
Start a counter representing the elapsed CPU time since 'mark' was called.
To determine the amount of CPU time used since 'mark' was called, use the
'cur' command.
end

define cur
	if ($rusagebuffer == 0)
		printf "No timer has been started.\n"
	else
		getrusage
		printf "Elapsed CPU time since last mark is %lu ms.\n", ($rusage - $rusagemark)
	end
end
document cur
Display the amount of CPU time used since the last 'mark' command.
end