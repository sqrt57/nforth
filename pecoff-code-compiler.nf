| Saving normal creating words
: ocreate-code create-code ;

variable image-wordlist  0 image-wordlist !

: before update-image-here restore-here ;
: after save-here update-here ;
: create-image-here ( --) before create image-here rva , after ;
: next-word ( --) here image-wordlist @ rva , image-wordlist ! ;
: flags ( --) 0 , ;
: last-length ( --u) word-list @ 8 + @ ;
: name-length ( --) last-length , ;
: name-data ( --) word-list @ 0c + here last-length cmove ;
: update-here ( --) last-length allot ;
: name ( --) name-length name-data update-here align ;
: store-xt ( --) here last-xt ! ;
: create-word ( --) align create-image-here next-word flags name store-xt ;
: create-code ( --) create-word here 4 + rva , ;

after
