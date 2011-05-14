: 2dup over over ;
: 2drop drop drop ;
: type ( au--) sys-print ;
: assert ( bau--) rot if drop drop else type bye endif ;
: c, ( c--)  here c! here 1 + to here ;
: defer-error " Uninitialized deferred word used.\n" type bye ;
: defer ( "--) create ['] defer-error , does> @ execute ;
: do-is ( xx--) 8 + ! ;
: is ( x"--) ' do-is ;
: [is] ( C:"-- R:x--) lit lit , ' , ['] do-is , ; immediate
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
: enum{ ( n--n) begin get-word 2dup find [ " }enum" find ] literal = if
    2drop exit else
    add-word  do-const last-xt @ !
    dup , 1 + endif again ;
hex
: to-skip ( a--u) 03 and ;
: dig>char ( u--c) dup 9 <= if [c'] 0 + else a - [c'] A + endif ;
: hex. ( u--) 0f and dig>char emit ;
: 2hex. ( u--) dup 4 rshift 0f and hex. 0f and hex. ;
: aligned< ( u--u) 3 - aligned ;
: 8hex. ( u--) dup 18 rshift 0ff and 2hex.
    dup 10 rshift 0ff and 2hex.
    dup 08 rshift 0ff and 2hex.
                  0ff and 2hex. ;
: safe-emit ( c--) dup 20 7F within if emit else drop " ." type endif ;
dec
| Helpers for dumping
: dh-intro "          " type ;
: dh-hcell ( a--a) "   " type dup hex. 1 + ;
: dh-hblk ( a--a) dh-hcell dh-hcell dh-hcell dh-hcell "  " type ;
: dh-hex ( a--) dh-hblk dh-hblk dh-hblk dh-hblk drop ;
: dh-sep " |" type ;
: dh-dcell ( a--a) dup hex. 1 + ;
: dh-dblk ( a--a) dh-dcell dh-dcell dh-dcell dh-dcell ;
: dh-data ( a--) dh-dblk dh-dblk dh-dblk dh-dblk drop ;
: dump-header ( a--) dh-intro dup dh-hex dh-sep dh-data newline ;
: dl-intro ( a--) 8hex. " :" type ;
: dump-cnext ( au--au) 1 - swap 1 + swap ;
: dl-hcell ( au--au) dup if over c@ 2hex. dump-cnext "  " type
    else "    " type endif ;
: dl-hblk ( au--au) "  " type dl-hcell dl-hcell dl-hcell dl-hcell ;
: dl-hex ( au--) dl-hblk dl-hblk dl-hblk dl-hblk 2drop ;
: dl-sep " |" type ;
: dl-dcell ( au--au) dup if over c@ safe-emit dump-cnext endif ;
: dl-dblk ( au--au) dl-dcell dl-dcell dl-dcell dl-dcell ;
: dl-data ( au--) dl-dblk dl-dblk dl-dblk dl-dblk 2drop ;
: dump-line ( au--) over dl-intro 2dup dl-hex dl-sep dl-data newline ;
: dump-next ( au--au) 16 - swap 16 + swap ;
: dump-data ( au--) begin 2dup dump-line
    dup 16 <= if 2drop exit endif
    dump-next again ;
: dump ( au--) over dump-header dump-data ;

| Counted loop
: do{ ( C:--a; R:u--) here ['] >r , ; immediate
: }do ( C:a--; R:--)
    ['] r> ,
    lit lit ,
    1 ,
    ['] - ,
    ['] dup ,
    ['] 0= ,
    do-jump-if-not ,  ,
    ['] drop , ; immediate

| Switch control statement
: switch{ ( C:--n; R:x--) 0 ['] >r , ; immediate
: }switch ( C:n*an--; R:--) do{ postpone endif }do
    ['] r> , ['] drop , ; immediate
: case{ ( C:n--an;R:x--) >r ['] r@ , ['] = , postpone if r> 1 + ; immediate
: }case ( C:an--an;R:--) >r postpone else r> ; immediate
