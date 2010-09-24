tutforth : tutforth.o

%.o : %.asm
	nasm -f elf -g -F stabs $< -o $@

clean :
	rm *.o

% : %.o
	ld -o $@ $^

.PHONY : clean

