org 7C00h


; wow, it's a bootloader


%define LOAD_ADDR 0x1000 


_start:
    mov si, daps ; disk packet address
    mov ah, 0x42 ; al unused
    mov dl, 0x80 ; what to copy
    int 0x13     ; do it

    jmp LOAD_ADDR ; start it up :D


align 16

daps: ; disk address packet structure
.size: db 0x10
db 0 ; always 0
.num_sectors: dw NUM_SECTORS ; this value come from the environment, see the makefile
.transfer_buffer: dd LOAD_ADDR
.lba_lower: dd 0x1
.lba_upper: dd 0x0


times 0200h - 2 - ($ - $$)  db 0    ;Zerofill up to 510 bytes
dw 0AA55h       ;Boot Sector signature

