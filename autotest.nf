" core.nf" included
" asm.nf" included

defer message
: say message type ;
: hello " Hello!\n" ;
: goodbye " Goodbye!\n" ;

' hello is message  say
message type
' goodbye is message  say
message type

: set-message ' [is] message ;

set-message hello  say
set-message goodbye  say
