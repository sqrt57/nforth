
| Saving normal creating words
: o: : ;
: o; postpone ; ; immediate
: oconstant constant ;
: ocreate-code create-code ;
: ovariable variable ;
: oimmediate immediate ;

variable image-wordlist  0 image-wordlist !
variable exit-xt

: doer ( --) does> @ , ;
: create-image-here ( -- addr) before create here 0 , doer immediate after ;
: fill-image-here ( addr --) here rva swap ! ;
: next-word ( --) image-wordlist @ rva image-wordlist ! ;
: flags ( --) 0 , ;
: last-length ( --u) word-list @ 8 + @ ;
: name-length ( --) last-length , ;
: name-data ( --) word-list @ 0c + here last-length cmove ;
: update-here ( --) last-length allot ;
: name ( --) name-length name-data update-here align ;
: store-xt ( --) here last-xt ! ;
: create-word ( --) align create-image-here next-word flags name
    store-xt fill-image-here ;
: create-code ( --) create-word here 4 + rva , ;

o: create ( "word" --) create-word do-var rva , 0 , o;
o: variable ( "word" --) create 0 , o;
o: constant ( x "word" --) create-word do-const rva , 0 , , o;
o: immediate ( --) 1 image-wordlist @ 4 + ! o;
o: : ( "word" --) create-word do-enter rva , 0 , ] o;
o: ; ( --) exit-xt @ , postpone [ o; oimmediate

after
