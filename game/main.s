org 1000h
; Entry point, put includes after this, please!
jmp main


%include "globals.s"
%include "macros.s"
%include "graphics.s"
%include "worldmap.s"

main:
    .forever:
        mov si, 0x0
        call clear_screen
        .loop:
            mov ax, [worldmap + si + 0 * 2]
            xor bx, bx
            mov bl, [worldmap + si + 1 * 2]

            push_args ax, bx, 0x1f
            call draw_pixel
            add sp, 6

            ; sleep a bit
            push cx
            push dx
            push ax

            mov cx, 0x0000
            mov dx, 0x04ff
            mov ah, 0x86
            int 0x15

            pop ax
            pop dx
            pop cx

            add si, 2+1
            cmp si, (n_worldmap_pixels-1) * (2+1)
            jle .loop

        ; sleep a bit
        push cx
        push dx
		push ax

        mov cx, 0x0000
        mov dx, 0xffff
        mov ah, 0x86
        int 0x15

		pop ax
        pop dx
        pop cx

        jmp .forever

    hlt

proc draw_hello_world
    push ax
    push bx
    push cx
    push dx
    push bp

    mov ax, 0x1300 ; draw string
    mov bh, 0
    mov bl, 0xf
    mov cx, end_hello_world - hello_world
    mov dx, 0x090c
    mov bp, hello_world
    int 0x10

    pop bp
    pop dx
    pop cx
    pop bx
    pop ax
endproc
