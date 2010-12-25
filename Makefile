nforth : nforth.o
	ld -o nforth nforth.o

nforth.o : nforth.asm
	nasm -f elf -g -F stabs nforth.asm -o nforth.o -l nforth.lst

clean :
	rm -f *.o *.lst

.PHONY : clean

