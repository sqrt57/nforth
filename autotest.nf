" core.nf" included
" asm.nf" included

defer message
: say message sys-print ;
: hello " Hello!\n" ;
: goodbye " Goodbye!\n" ;

' hello is message  say
message sys-print
' goodbye is message  say
message sys-print
