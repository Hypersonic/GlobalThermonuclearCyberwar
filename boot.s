org 7C00h


; wow, it's a bootloader


%define LOAD_ADDR 0x1000 


_start:
	cli

; clear segment registers
    mov ax, 0        ; Reset segment registers to 0.
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Set video mode
    ; VGA (chunky mode) 320×200
    mov ax, 0x0013
    int 0x10
    
    ; setup stack
    mov esp, 0xF000
    mov ebp, esp

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


; A little note in the spare bootloader space
%macro credits_line 1
align 16
db %1
%endmacro

credits_line "CSAW FINALS 2017"
credits_line "REGIONS:        "
credits_line " EUROPE, INDIA, "
credits_line " ISRAEL, MENA,  "
credits_line " NORTH AMERICA  "

hello_world: db "Hello, World"
end_hello_world:

times 0200h - 2 - ($ - $$)  db 0    ;zerofill up to 510 bytes
dw 0AA55h       ;Boot Sector signature

