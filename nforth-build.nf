" core.nf" included
" asm.nf" included
" kernel.nf" included
" pecoff.nf" included

pecoff-init
hex

" nforth-dll-imports.nf" included
newline
hex
" import-refs: " type newline
import-refs @ 40 dump
" import-names: " type newline
import-names @ 60 dump

" image = " type image @ . newline
" section-base = " type section-base @ . newline
" ilts-base = " type ilts-base @ . newline
" names-base = " type names-base @ . newline
" import-names = " type import-names @ . newline

" win-exit-process = " type win-exit-process . newline
" win-get-std-handle = " type win-get-std-handle . newline
" win-write-file = " type win-write-file . newline
" win-read-file = " type win-read-file . newline

" build\\abc.exe" pecoff-write
" \"build\\abc.exe\" written. Total bytes: " type dec image-length @ . newline
pecoff-done

dec
mem-info
bye
