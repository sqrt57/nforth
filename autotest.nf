: while-white begin tib >in @ + c@ white? 0= if exit endif 1 >in +! again ;
: while-word begin tib >in @ + c@ white? if exit endif 1 >in +! again ;
: read-word while-white tib >in @ + >in @ while-word >in @ swap - ;

4 4 4 4 4 u* u* u* u* u.
get-word 12345 str>int
get-word -6 str>int
b. . b. .
bye

