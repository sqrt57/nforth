: create-code ( "--) create here 4 - to here here last-xt @ ! ;

24 constant oper-len
: create-operand ( "--) create oper-len allot ;
: oper-mem ( a--a) ; | Flag false->register true->memory
: oper-imm-type ( a--a) 4 + ; | See imm-*
: oper-base ( a--a) 8 + ;
: oper-index ( a--a) 12 + ;
: oper-scale ( a--a) 16 + ;
: oper-imm ( a--a) 20 + ;

create-operand operand-1
create-operand operand-2
defer cur-operand

1 enum{ #eax #ebx #ecx #edx #esp #ebp #esi #edi }enum drop

0 enum{ #imm-auto #imm-8 #imm-16 #imm-32 }enum drop

| Clears a memory cell and returns address of next cell
: clear ( a--a) 0 over ! 4 + ;
: clear-oper ( a--) clear clear clear clear clear clear drop ;

| Sets current operand
: set-oper ( a--) [is] cur-operand  cur-operand clear-oper ;
: oper-init ['] operand-1 set-oper ;
: asm: ( "--) oper-init  create-code ;
: ,, ( --) ['] operand-2 set-oper ; | Delimits instruction operands
: store-reg ( na--) dup oper-base @ if
    1 over oper-scale !  oper-index !
    else oper-base ! endif ;
: scale ( n--) cur-operand oper-scale ! ;
: imm-bits ( nn--) cur-operand oper-imm-type !
    cur-operand oper-imm ! ;
: imm ( n--) #imm-auto imm-bits ;
: imm-8 ( n--) #imm-8 imm-bits ;
: imm-16 ( n--) #imm-16 imm-bits ;
: imm-32 ( n--) #imm-32 imm-bits ;
: [] true cur-operand oper-mem ! ;
: reg: ( n"--) create , does> @ cur-operand store-reg ;

: imm: ( n"--) create , does> @ cur-operand oper-imm-type ! ;

#eax reg: eax
#ebx reg: ebx
#ecx reg: ecx
#edx reg: edx
#esp reg: esp
#ebp reg: ebp
#esi reg: esi
#edi reg: edi

: >reg32 ( u--ub) switch{
    #eax case{ 0 true }case
    #ecx case{ 1 true }case
    #edx case{ 2 true }case
    #ebx case{ 3 true }case
    #esp case{ 4 true }case
    #ebp case{ 5 true }case
    #esi case{ 6 true }case
    #edi case{ 7 true }case
    0 false
    }switch ;

: oper>reg ( a--ub)
    dup oper-mem @ cond{ drop 0 false }cond
    dup oper-imm-type @ cond{ drop 0 false }cond
    dup oper-index @ cond{ drop 0 false }cond
    dup oper-scale @ cond{ drop 0 false }cond
    dup oper-imm @ cond{ drop 0 false }cond
    oper-base @ >reg32 ;
: oper>reg-field ( a--ub) oper>reg swap 3 lshift swap ;
    
: oper>mr ( a--ub)
    dup oper>reg cond{ nip [ 3 6 lshift ] literal + true }cond
    drop drop 0 false ;

hex
: mov-mr-reg ( u--)
    operand-2 oper>reg-field if or 89 c, c,
    else 2drop " Bad mov reg operand.\n" type bye endif ;
: mov-reg-mr ( u--)
    operand-2 oper>mr if or 8b c, c,
    else 2drop " Bad mov mem/reg operand.\n" type bye endif ;
: mov ( --)
    operand-1 oper>reg-field cond{ mov-reg-mr oper-init }cond
    operand-1 oper>mr cond{ mov-mr-reg oper-init }cond
    " Bad mov operands.\n" type bye ;
