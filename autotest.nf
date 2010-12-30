: .b if true-str else false-str endif sys-print ;
0 .b
1 .b
: hello
    dup 0 <
        if true-str
        else 4 < if prompt-str else false-str endif endif
    sys-print ;
0 1 - hello
0 hello
1 hello
4 1 + hello
