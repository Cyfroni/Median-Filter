CC=g++
ASMBIN=nasm

all : asm cc link
asm : 
	$(ASMBIN) -o filter.o -f elf -l filter.lst filter.asm
cc :
	$(CC) -m32 -c -g -O0 main.cc &> errors.txt
link :
	$(CC) -m32 -o test -lstdc++ main.o filter.o
clean :
	rm errors.txt	
	rm filter.lst
	rm *.o
	rm test
