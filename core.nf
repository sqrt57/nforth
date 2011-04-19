: 2dup over over ;
: 2drop drop drop ;
: type ( au--) sys-print ;
: assert ( bau--) rot if drop drop else type bye endif ;
: c, ( c--)  here c! here 1 + to here ;
: defer-error " Uninitialized deferred word used.\n" type bye ;
: defer ( "--) create ['] defer-error , does> @ execute ;
: is ( x"--) ' 8 + ! ;
: allot ( n--) here + to here ;
: b. ( b--) if " True " type else " False " type endif ;
: newline " \n" type ;
: add-word ( au--) align
    here  word-list @ ,  word-list !
    0 ,  dup ,  dup >r
    here swap cmove
    r> here + aligned to here
    here last-xt !
    do-var ,  0 , ;
: }enum ;
| : enum{ begin get-word find [ " }enum" find ] literal = if exit endif again ;
: enum{ ( n--n) begin get-word 2dup find [ " }enum" find ] literal = if
    2drop exit else
    add-word  do-const last-xt @ !
    dup , 1 + endif again ;

