; Graphics routines
%ifndef GRAPHICS_S
%define GRAPHICS_S

%include "globals.s"

; void draw_pixel(uint16_t x, uint16_t y, uint8_t vga_color)
proc draw_pixel
%$x arg
%$y arg
%$color arg
    ; save regs
    push ecx
    push esi
    push edx

    ; dl = vga_color
    mov dx, [bp + %$color]
    ; cx = y
    mov cx, [bp + %$y]
    ; si = x
    mov si, [bp + %$x]

    imul cx, SCREEN_WIDTH
    mov byte [VMEM_BASE + ecx + esi], dl

    ; restore regs
    pop edx
    pop esi
    pop ecx
endproc

; draw_line(x0, y0, x1, y1)
;   dx = x1 - x0
;   dy = y1 - y0
;   D = 2*dy - dx
;   y = y0
; 
;   for x from x0 to x1
;     draw_pixel(x, y, RED)
;     if D > 0
;        y = y + 1
;        D = D - 2*dx
;     end if
;     D = D + 2*dy
proc draw_line
%stacksize small
%assign %$localsize 0
%$x0 arg
%$y0 arg
%$x1 arg
%$y1 arg
%local \
    saved_ax:word, \
    saved_bx:word, \
    delta_x:word, \
    delta_y:word, \
    D:word, \
    y:word

	sub sp, %$localsize
    ; save regs
    mov [saved_ax], ax
    mov [saved_bx], bx

    ; dx = x1 - x0
    mov ax, [bp + %$x1]
    sub ax, [bp + %$x0]
    mov [delta_x], ax

    ; dy = y1 - y0
    mov ax, [bp + %$y1]
    sub ax, [bp + %$y0]
    mov [delta_y], ax

    ; D = 2*dy - dx
    mov ax, [delta_y]
    shl ax, 1 ; dy * 2
    sub ax, [delta_x] ; - dx
    mov [D], ax

    ; y = y0
    mov ax, [bp + %$y0]
    mov [y], ax

; for x from x0 to x1
    mov ax, [bp + %$x0] ; x = ax
    .loop:
        ; draw_pixel(x, y, RED)
        push word 0x4 ; red, TODO: make a parameter
        push word [y] ; y 
        push ax       ; x
        call draw_pixel
        add sp, 2*3

        ; if D > 0
        mov bx, [D]
        cmp bx, 0
        jle .end_if
           ; y = y + 1
           inc word [y]
           ; D = D - 2*dx
           sub bx, [delta_x]
           sub bx, [delta_x]
        .end_if:
        ; D = D + 2*dy
        add bx, [delta_y]
        add bx, [delta_y]
        mov [D], bx

        ; check at end of loop
        inc ax
        cmp ax, [bp + %$x1]
        jl .loop

    mov ax, [saved_ax]
    mov bx, [saved_bx]
    add sp, %$localsize
endproc


%endif
