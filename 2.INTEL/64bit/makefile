CC=g++
ASMBIN=nasm

all : asm cc link
asm : 
	$(ASMBIN) -o filter.o -f elf64 -l filter.lst filter.asm
cc :
	$(CC) -c -g -O0 main.cc &> errors.txt
link :
	$(CC) -o test -lstdc++ main.o filter.o
clean :
	rm errors.txt	
	rm filter.lst
	rm *.o
	rm test
