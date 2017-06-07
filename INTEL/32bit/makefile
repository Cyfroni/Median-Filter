CC=g++
CFLAGS=-m32

ASM=nasm
AFLAGS=-f elf32

all:result

main.o: main.cc
	$(CC) $(CFLAGS) -c main.cc
filter.o: filter.asm
	$(ASM) $(AFLAGS) filter.asm
result: main.o filter.o
	$(CC) $(CFLAGS) main.o filter.o -o result -lpthread -lX11
clean: 
	rm *.o
	rm result
