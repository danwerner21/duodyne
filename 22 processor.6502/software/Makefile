all:  	  scream.bin scrram.bin  rom.bin


scream.bin: scream.asm
	ca65 scream.asm -l scream.lst
	ld65 scream.o -m scream.map -C duo02.cfg -o scream.out
	srec_cat  scream.out -binary -offset 0xE000 -o  scream.hex -intel -address-length=2
	@rm scream.out
	@rm scream.o

scrram.bin: scrram.asm
	ca65 scrram.asm -l scrram.lst
	ld65 scrram.o -m scrram.map -C duo02.cfg -o scrram.out
	srec_cat  scrram.out -binary -offset 0xE000 -o  scrram.hex -intel -address-length=2
	@rm scrram.out
	@rm scrram.o

rom.bin: rom.asm supermon.asm
	ca65 rom.asm -l rom.lst
	ld65 rom.o -m rom.map -C duo02.cfg -o rom.out
	srec_cat  rom.out -binary -offset 0xE000  -o  rom.hex -intel -address-length=2
	@rm rom.out
	@rm rom.o

pretty:
	cp *.asm ./backup
	pretty6502 -p1 -a0 -du -mu -l ./backup/rom.asm rom.asm
	pretty6502 -p1 -a0 -du -mu -l ./backup/scream.asm scream.asm
	pretty6502 -p1 -a0 -du -mu -l ./backup/supermon.asm supermon.asm

clean:
	@rm -f *.bin
	@rm -f *.o
	@rm -f *.out
	@rm -f *.com
	@rm -f *.co6
	@rm -f *.map
	@rm -f *.lst
	@rm -f *.hex
	@rm -f *.s19
	@rm -f *.s

cleandust:
	@rm -f *.o
	@rm -f *.out
	@rm -f *.map
	@rm -f *.lst