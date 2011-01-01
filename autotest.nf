: while-white begin tib >in @ + c@ white? 0= if exit endif 1 >in +! again ;
: while-word begin tib >in @ + c@ white? if exit endif 1 >in +! again ;
: read-word while-white tib >in @ + >in @ while-word >in @ swap - ;

: 8 [ 4 4 + ] literal ;
8 4 4 + = .b

variable str variable len
prompt-str len ! str !
str @ len @ sys-print

true-str constant len-c constant str-c
false-str value len-v value str-v
str-c len-c sys-print
str-v len-v sys-print

