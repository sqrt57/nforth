: create-code ( "--) create here 4 - to here here last-xt @ ! ;

24 constant oper-len
: create-operand ( "--) create oper-len allot ;
: oper-mem ( a--a) ;
: oper-base ( a--a) 4 + ;
: oper-index ( a--a) 8 + ;
: oper-scale ( a--a) 12 + ;
: oper-imm ( a--a) 16 + ;

create-operand operand-1
create-operand operand-2
defer cur-operand

1 enum{ #eax #ebx #ecx #edx #esp #ebp #esi #edi }enum drop

| Clears a memory cell and returns address of next cell
: clear ( a--a) 0 over ! 4 + ;
: clear-oper ( a--) clear clear clear clear clear clear drop ;

| Sets current operand
: set-oper ( a--) [is] cur-operand  cur-operand clear-oper ;
: asm: ( "--) ['] operand-1 set-oper create-code ;
: ,, ( --) ['] operand-2 set-oper ; | Delimits instruction operands
: store-reg ( na--) dup oper-base @ if
    dup oper-index !  1 swap oper-scale !
    else oper-base ! endif ;
: scale ( n--) cur-operand oper-scale ! ;
: immed ( n--) cur-operand oper-imm ! ;
: [] 1 cur-operand oper-mem ! ;
: reg: ( n"--) create , does> @ cur-operand store-reg ;

#eax reg: eax
#ebx reg: ebx
#ecx reg: ecx
#edx reg: edx
#esp reg: esp
#ebp reg: ebp
#esi reg: esi
#edi reg: edi


: >reg32 ;
