main.bin: boot.s game.bin
	$(eval num_sectors := $(shell BLOCKSIZE=512 du game.bin | cut -f1))
	nasm -D NUM_SECTORS=$(num_sectors) -f bin -o load.bin boot.s
	dd bs=512 if=load.bin of=main.bin
	dd bs=512 seek=1 if=game.bin of=main.bin

game.bin: game/*
	nasm -i game/ -f bin -o game.bin game/main.s

run: main.bin
	$(eval num_kb := $(shell du -k main.bin | cut -f1))
	@echo "Binary is $(num_kb) KB long"
	qemu-system-i386 -serial stdio -drive format=raw,file=main.bin

dbg: main.bin
	qemu-system-i386 -S -s -drive format=raw,file=main.bin
