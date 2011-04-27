" core.nf" included

: pr-c ( c--) dup 2hex. safe-emit "  " type ;
: pr 0 begin dup 255 = if drop exit endif 1 + dup pr-c again ;
pr newline
bye
