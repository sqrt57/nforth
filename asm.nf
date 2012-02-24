| --- List of operand types
1 constant reg
2 constant m/r
3 constant m/r+sib
4 constant immed

| --- Register codes
0 constant #eax
1 constant #ecx
2 constant #edx
3 constant #ebx
4 constant #esp
5 constant #ebp
6 constant #esi
7 constant #edi

| --- Parser state
defer do-reg
defer do-const

| --- mem data
create regs  16 allot  | reg1 scale1 reg2 scale2
variable >op
variable immed
variable immed-size
: regs-check  ( --) >op @ 16 >= if
    " Too many registers in memory reference.\n" type bye endif ;
: 8aligned ( n--n) 7 +  3 rshift  3 lshift ;
: reg-check ( --) >op @ 8aligned >op !  regs-check ;
: scale-check ( --) >op @ 8 /mod drop 0 = if
    " Scale specified but no register found.\n" type bye endif ;
: op ( n--) regs >op @ + ;
: op, ( n--) op !  4 >op +! ;
: op# ( n--a) 3 lshift  regs + ;
| - Public words
: mem-reg, ( n--) reg-check  op,  0 op ! ;
: scale, ( n--) scale-check  op, ;
: regs-reset ( --) 0 >op ! ;
: regs-num ( --n) >op @  7 +  3 rshift ;
: mem-reg@ ( n--n) op# @ ;
: scale@ ( n--n) op# 4 + @ ;

| --- Operands
| - Public
: type ( --a) ;
: modrm ( --a) ;
: sib ( --a) ;
: immed ( --a) ;
: immed-size ( --a) ;
: operand-size ( --a) ;
: ops-reset ( --) ;
: ops-append ( --) ;
: ops-next ( --) ;
: ops# ( --n) ;

| --- m/r writer

| --- reg writer
: rcheck ( n--) drop ;
| - Public
: reg, ( n--) ops-append  dup rcheck
    3 lshift modrm !  reg type ! ;

| --- Register list

| --- Operand matchers

| --- Instructions

