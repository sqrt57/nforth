nforth : nforth.o
	ld -o nforth nforth.o

nforth.o : nforth.asm
	nasm -f elf -g -F stabs nforth.asm -o nforth.o

clean :
	rm -f *.o *.lst

.PHONY : clean

