" core.nf" included
" asm.nf" included

: dmp operand-1 @ .
    operand-1 oper-flag-base oper-flag@ b.
    operand-1 oper-flag-imm oper-flag@ b.
    newline ;

hex
dmp
operand-1 oper-flag-base oper-flag+
dmp
operand-1 oper-flag-imm oper-flag+
dmp
operand-1 oper-flag-imm oper-flag-
dmp
