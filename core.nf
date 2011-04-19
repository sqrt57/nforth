: type ( au--) sys-print ;
: assert ( bau--) rot if drop drop else type bye endif ;
: c, ( c--)  here c! here 1 + to here ;
: defer-error " Uninitialized deferred word used.\n" type bye ;
: defer ( "--) create ['] defer-error , does> @ execute ;
: is ( x"--) ' 8 + ! ;
: allot ( n--) here + to here ;
: b. ( b--) if " True " type else " False " type endif ;
: newline " \n" type ;
