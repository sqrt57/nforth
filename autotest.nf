string: newline 10 +c
: print-args begin
    dup @ 0 = if drop exit endif
    dup @ dup length sys-print
    newline sys-print
    4 + again ;
argv 4 + print-args

bye
