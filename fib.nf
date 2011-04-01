: fib dup 1 <= if drop 1 exit else
    dup 1 - fib
    swap 2 - fib
    + endif ;

35 fib .
bye

