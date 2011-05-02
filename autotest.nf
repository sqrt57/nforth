" core.nf" included
" asm.nf" included

" --- Must be all zeros.\n" type
operand-1 20 dump
operand-2 20 dump
asm: my-dup
ecx ,, edx
" --- Must be 3 and 4.\n" type
operand-1 20 dump
operand-2 20 dump

asm: qwerty
,,
" --- Must be all zeros.\n" type
operand-1 20 dump
operand-2 20 dump

newline
| ' my-dup 64 dump

