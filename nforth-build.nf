" core.nf" included
" asm.nf" included
" pecoff.nf" included

pecoff-init
create mark
" nforth-win-imports.nf" included
import-done
: o! ! ;
" kernel-code-fields.nf" included
" pecoff-compiler.nf" included
" kernel.nf" included
exit exit-xt o!
" nforth-win.nf" included
" build\\abc.exe" pecoff-write

forget mark
newline
" \"build\\abc.exe\" written. Total bytes: " type dec file-length @ . newline
pecoff-done

dec
mem-info
bye
