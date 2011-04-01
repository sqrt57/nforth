: prompt prompt-str sys-print ;
: print-nums-to 0 begin dup . 1 +
    over over < if drop drop prompt exit endif again ;

20 dec print-nums-to dec
20 hex print-nums-to dec
20 oct print-nums-to dec
10 bin print-nums-to dec
10 3 base ! print-nums-to prompt dec

hex
: print-hex 0 . 1 . 2 . 3 . 4 . 5 . 6 . 7 . 8 . 9 .
    a . b . c . d . e . f . 10 . 11 . 12 . 13 . prompt ;
: print-hex-upper 0 . 1 . 2 . 3 . 4 . 5 . 6 . 7 . 8 . 9 .
    A . B . C . D . E . F . 10 . 11 . 12 . 13 . prompt ;
dec print-hex print-hex-upper

oct 9 dec .

