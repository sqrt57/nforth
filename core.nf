: assert ( bau--) rot 0= if sys-print endif ;
: c, ( c--)  here c! here 1 + to here ;
: defer-error " Uninitialized deferred word used.\n" sys-print ;
: defer ( "--) create ['] defer-error , does> @ execute ;
: is ( x"--) ' 8 + ! ;

