" core.nf" included
" asm.nf" included

asm: qwerty
eax ebx ,, edi
operand-1 oper>reg-field . .
operand-2 oper>reg-field . .
newline

operand-1 oper>mr . .
operand-2 oper>mr . .
newline

asm: asdf
123 imm ,, 57 imm-32
operand-1 oper-imm @ .
operand-1 oper-imm-type @ .
operand-2 oper-imm @ .
operand-2 oper-imm-type @ .
newline

dec

asm: zxcv
eax ,, ebx mov
ecx ,, edx mov
' zxcv 16 dump
