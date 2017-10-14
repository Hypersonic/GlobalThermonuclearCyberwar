org 1000h
; Entry point, put includes after this, please!
jmp main


%include "globals.s"
%include "macros.s"
%include "graphics.s"

main:
    .forever:
        mov dh, 6 ; number of iterations per color
        mov dl, 0x20 ; color code
        mov ecx, 0
        .outer:
            mov si, SCREEN_WIDTH
            .loop:
                dec si

				push dx ; color
				push cx ; y
				push si ; x
                call draw_pixel
                add sp, sizeof(dx) + sizeof(cx) + sizeof(si)

                test si, si
                jnz .loop
            
            call draw_hello_world

            dec dh
            test dh, dh
            jnz .dont_change_line
                mov dh, 6
                inc dl

            .dont_change_line:
            inc cx
            cmp cx, SCREEN_HEIGHT
            jne .outer

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
