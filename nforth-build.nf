" core.nf" included
" asm.nf" included
" pecoff.nf" included

pecoff-init
create mark
" nforth-win.nf" included
" kernel.nf" included
" build\\abc.exe" pecoff-write
forget mark
" \"build\\abc.exe\" written. Total bytes: " type dec file-length @ . newline
pecoff-done

dec
mem-info
bye
