" core.nf" included
" asm.nf" included

: test 3 do{ " Hello " type }do ;
' test 96 dump
hex
' r> . " r>\n" type
' >r . " >r\n" type
' - . " -\n" type
' dup . " dup\n" type
' type . " type\n" type
' 0= . " 0=\n" type
' drop . " drop\n" type
' lit . " lit\n" type
do-jump-if-not . " do-jump-if-not\n" type
do-enter . " do-enter\n" type

: test1 4 do{ test newline }do ;
test1

| asm: my-dup

| ' my-dup 64 dump
