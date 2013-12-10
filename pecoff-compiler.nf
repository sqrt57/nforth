
before

| Saving normal creating words
: ocreate create ;
: ovariable variable ;
: o: : ;
: o; postpone ; ; immediate
: oconstant constant ;
: oimmediate immediate ;

o: create ( --) create-word do-var , 0 , o;
o: immediate ( --) 1 image-wordlist @ 4 + ! o;

after
