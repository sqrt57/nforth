: while-white begin tib >in @ + c@ white? 0= if exit endif 1 >in +! again ;
: while-word begin tib >in @ + c@ white? if exit endif 1 >in +! again ;
: read-word while-white tib >in @ + >in @ while-word >in @ swap - ;
read-word 23423 sys-print prompt-str sys-print
