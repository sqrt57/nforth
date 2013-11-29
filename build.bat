mkdir build
fasm\fasm nforth-win.asm build\nforth.exe
fasm\fasm nforth-linux.asm build\nforth
build\nforth.exe nforth-build.nf
pedump\pedump.exe build\abc.exe >build\abc.txt
build\abc.exe