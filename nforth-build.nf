" core.nf" included
" asm.nf" included
" kernel.nf" included
" pecoff.nf" included

pecoff-init
" nforth-win.nf" included
" build\\abc.exe" pecoff-write
" \"build\\abc.exe\" written. Total bytes: " type dec file-length @ . newline
pecoff-done

dec
mem-info
bye
