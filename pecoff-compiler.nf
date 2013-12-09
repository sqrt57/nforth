| Saving normal creating words
: before update-image-here restore-here ;
: after save-here update-here ;
: ocreate create ;
: ovariable variable ;
: asm: before : ;
: asm; postpone ; after ; immediate
: o: : ;
: oconstant constant ;
: o; postpone ; ; immediate
: oimmediate immediate ;

ovariable image-wordlist  0 image-wordlist !
o: create-image-here ( --) update-image-here restore-here ocreate image-here
    rva , save-here update-here o;
o: next-word ( --) here image-wordlist @ rva , image-wordlist ! o;
o: flags ( --) 0 , o;
o: last-length ( --u) word-list @ 8 + @ o;
o: name-length ( --) last-length , o;
o: name-data ( --) word-list @ 0c + here last-length cmove o;
o: update-here ( --) last-length allot o;
o: name ( --) name-length name-data update-here ( 0 c, ) align o;
o: create-word ( --) align create-image-here next-word flags name o;
o: create ( --) create-word 0 , 0 , o;
o: create-code ( --) create-word here 4 + rva , o;
