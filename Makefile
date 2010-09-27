tutforth : tutforth.o
	ld -o tutforth tutforth.o

tutforth.o : tutforth.asm
	nasm -f elf -g -F stabs tutforth.asm -o tutforth.o -l tutforth.lst

clean :
	rm *.o

.PHONY : clean

