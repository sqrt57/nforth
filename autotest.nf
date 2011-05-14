" core.nf" included
" asm.nf" included

: test ( n--) switch{
    0 case{ " zero " }case
    1 case{ " one " }case
    2 case{ " two " }case
    " unknown "
    }switch type ;

0 test  1 test  2 test  3 test 2 test  newline

| asm: my-dup

| ' my-dup 64 dump
