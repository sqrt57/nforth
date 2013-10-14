" nforth-build.nf" included

dec

newline " swap" type newline
' swap 4 + 16 dump-short
2' swap 4 + 16 dump-short

newline " drop" type newline
' drop 4 + 16 dump-short
2' drop 4 + 16 dump-short

newline " dup" type newline
' dup 4 + 16 dump-short
2' dup 4 + 16 dump-short

newline " over" type newline
' over 4 + 16 dump-short
2' over 4 + 16 dump-short

newline " over2" type newline
' over2 4 + 16 dump-short
2' over2 4 + 16 dump-short

newline " rot" type newline
' rot 4 + 16 dump-short
2' rot 4 + 16 dump-short

newline " >r" type newline
' >r 4 + 16 dump-short
2' >r 4 + 16 dump-short

newline " r>" type newline
' r> 4 + 16 dump-short
2' r> 4 + 16 dump-short

newline " r@" type newline
' r@ 4 + 16 dump-short
2' r@ 4 + 16 dump-short

newline " @" type newline
' @ 4 + 16 dump-short
2' @ 4 + 16 dump-short

newline " !" type newline
' ! 4 + 16 dump-short
2' ! 4 + 16 dump-short

newline " c@" type newline
' c@ 4 + 16 dump-short
2' c@ 4 + 16 dump-short

newline " c!" type newline
' c! 4 + 16 dump-short
2' c! 4 + 16 dump-short

newline " w@" type newline
' w@ 4 + 16 dump-short
2' w@ 4 + 16 dump-short

newline " w!" type newline
' w! 4 + 16 dump-short
2' w! 4 + 16 dump-short

newline " lit" type newline
' lit 4 + 16 dump-short
2' lit 4 + 16 dump-short

newline " jump" type newline
' jump 4 + 16 dump-short
2' jump 4 + 16 dump-short

newline " jump-if-not" type newline
' jump-if-not 4 + 16 dump-short
2' jump-if-not 4 + 16 dump-short

newline " execute" type newline
' execute 4 + 16 dump-short
2' execute 4 + 16 dump-short

newline " and" type newline
' and 4 + 16 dump-short
2' and 4 + 16 dump-short

newline " or" type newline
' or 4 + 16 dump-short
2' or 4 + 16 dump-short

newline " not" type newline
' not 4 + 16 dump-short
2' not 4 + 16 dump-short

newline " 0=" type newline
' 0= 4 + 16 dump-short
2' 0= 4 + 16 dump-short

newline " =" type newline
' = 4 + 16 dump-short
2' = 4 + 16 dump-short

newline " <" type newline
' < 4 + 16 dump-short
2' < 4 + 16 dump-short

newline " >" type newline
' > 4 + 16 dump-short
2' > 4 + 16 dump-short

newline " <=" type newline
' <= 4 + 16 dump-short
2' <= 4 + 16 dump-short

newline " >=" type newline
' >= 4 + 16 dump-short
2' >= 4 + 16 dump-short

newline " negate" type newline
' negate 4 + 16 dump-short
2' negate 4 + 16 dump-short

newline " +" type newline
' + 4 + 16 dump-short
2' + 4 + 16 dump-short

newline " -" type newline
' - 4 + 16 dump-short
2' - 4 + 16 dump-short

newline " *" type newline
' * 4 + 16 dump-short
2' * 4 + 16 dump-short

newline " u*" type newline
' u* 4 + 16 dump-short
2' u* 4 + 16 dump-short

newline " /mod" type newline
' /mod 4 + 16 dump-short
2' /mod 4 + 16 dump-short

newline " u/mod" type newline
' u/mod 4 + 16 dump-short
2' u/mod 4 + 16 dump-short

newline " lshift" type newline
' lshift 4 + 16 dump-short
2' lshift 4 + 16 dump-short

newline " rshift" type newline
' rshift 4 + 16 dump-short
2' rshift 4 + 16 dump-short

newline " do-enter" type newline
' do-enter 8 + @ 16 dump-short
2' do-enter 8 + @ 16 dump-short

newline " do-var" type newline
' do-var 8 + @ 16 dump-short
2' do-var 8 + @ 16 dump-short

newline " do-const" type newline
' do-const 8 + @ 16 dump-short
2' do-const 8 + @ 16 dump-short

newline " do-does" type newline
' do-does 8 + @ 16 dump-short
2' do-does 8 + @ 16 dump-short

here
    |<-b
    eax ebx movd-reg-reg
    jz <-|b
    |<-d
    [eax] ebx movd-mem-reg
    jz <-|d
32 dump