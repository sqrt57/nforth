" core.nf" included
" asm.nf" included
" pecoff.nf" included

pecoff-init
create mark
" nforth-win-imports.nf" included
import-done
" pecoff-code-compiler.nf" included
" kernel.nf" included
" pecoff-compiler.nf" included
" nforth-win.nf" included
" build\\abc.exe" pecoff-write
forget mark
" \"build\\abc.exe\" written. Total bytes: " type dec file-length @ . newline
pecoff-done

dec
mem-info
bye
