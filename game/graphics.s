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
%local delta_x:word, delta_y:word, D:word, y:word
	sub sp, %$localsize
endproc


%endif
