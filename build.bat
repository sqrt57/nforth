mkdir build
fasm\fasm nforth-win.asm build\nforth.exe
fasm\fasm nforth-linux.asm build\nforth
build\nforth.exe nforth-build.nf
