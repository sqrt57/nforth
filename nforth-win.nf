" kernel32.dll" import-dll
" ExitProcess" import-symbol: win-exit-process
" GetStdHandle" import-symbol: win-get-std-handle
" WriteFile" import-symbol: win-write-file
" ReadFile" import-symbol: win-read-file
import-done

here set-code-entry
0 pushd-immb
win-exit-process [d] call-near-mem
