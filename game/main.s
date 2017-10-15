org 1000h
; Entry point, put includes after this, please!
jmp main


%include "globals.s"
%include "macros.s"
%include "graphics.s"

main:
    mov ax, 0x0
    .forever:
        cmp ax, 0xcf
        jge .after

        ; draw_line(x0, y0, x1, y1)
        push 0x4 ; color
        push ax ;y1 
        push word 0x60 ;x1 
        push word 0x40 ;y0 
        push word 0x20 ;x0 
        call draw_line
        add sp, 2 * 4

        push 0x5 ; color
        push ax ;y1 
        push word 0x60 ;x1 
        push word 0x20 ;y0 
        push word 0x80 ;x0 
        call draw_line

        add ax, 0x9
        .after:


        call draw_hello_world

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
