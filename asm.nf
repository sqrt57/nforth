: create-code ( "--) create here 4 - to here here last-xt @ ! ;

20 constant oper-len
: create-operand ( "--) create oper-len allot ;
: oper-flags ( a--a) ;
: oper-base ( a--a) 4 + ;
: oper-index ( a--a) 8 + ;
: oper-scale ( a--a) 12 + ;
: oper-imm ( a--a) 16 + ;

hex
01 constant oper-flag-base
02 constant oper-flag-index
04 constant oper-flag-imm
08 constant oper-flag-mem
dec

: oper-flag@ ( au--u) swap oper-flags @ and ;
: oper-flag+ ( au--) swap oper-flags dup @ rot or swap ! ;
: oper-flag- ( au--) swap oper-flags dup @ rot not and swap ! ;

create-operand operand-1
create-operand operand-2
defer cur-operand

1 enum{ #eax #ebx #ecx #edx #esp #ebp #esi #edi }enum drop

| : asm ['] operand-1 is cur-operand ;
| : reg: ( n"--) create , does> @ cur-operand oper-base ! ;

(
#eax reg: eax
#ebx reg: ebx
#ecx reg: ecx
#edx reg: ecx
#esp reg: esp
#ebp reg: ebp
#esi reg: esi
#edi reg: edi
)
