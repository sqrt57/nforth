: fib dup 1 <= if drop 1 exit else
    dup 1 - recurse
    swap 2 - recurse
    + endif ;

35 fib .
bye

