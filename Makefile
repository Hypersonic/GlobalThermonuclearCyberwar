main.bin: boot.s game.bin
	$(eval num_sectors := $(shell BLOCKSIZE=512 du game.bin | cut -f1))
	nasm -D NUM_SECTORS=$(num_sectors) -f bin -o load.bin boot.s
	dd bs=512 if=load.bin of=main.bin
	dd bs=512 seek=1 if=game.bin of=main.bin

game.bin: generated_files game/*
	nasm -g -i game/ -f bin -o game.bin game/main.s

game/worldmap.s: generate_map_asm.py world.png
	python3 generate_map_asm.py > game/worldmap.s

generated_files: game/worldmap.s

run: main.bin
	$(eval num_kb := $(shell du -k main.bin | cut -f1))
	@echo "Binary is $(num_kb) KB long"
	qemu-system-i386 -serial stdio -d guest_errors -drive format=raw,file=main.bin

dbg: main.bin
	qemu-system-i386 -S -s -drive format=raw,file=main.bin
