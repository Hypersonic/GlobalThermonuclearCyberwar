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

; draw_line(x0, y0, x1, y1, color)
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
%$color arg
%local \
    saved_ax:word, \
    saved_bx:word, \
    octant:word, \
    delta_x:word, \
    delta_y:word, \
    D:word, \
    y:word, \
    tmp:word


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

    ; get octant
	push word [delta_y]
	push word [delta_x]
	call get_octant
	mov [octant], ax
    add sp, 2 * 2

    ; normalize first coord pair
    push word [bp + %$y0]
    push word [bp + %$x0]
    push word [octant]
    call normalize_to_octant
    add sp, 2 * 3
    mov [bp + %$x0], ax
    mov [bp + %$y0], bx

    ; normalize second coord pair
    push word [bp + %$y1]
    push word [bp + %$x1]
    push word [octant]
    call normalize_to_octant
    add sp, 2 * 3
    mov [bp + %$x1], ax
    mov [bp + %$y1], bx

    ; recompute deltas for normalized values

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
        mov [tmp], ax

        ; denormalize values for drawing
        push word [y]      ; y
        push ax            ; x
        push word [octant] ; octant
        call denormalize_from_octant
        add sp, 2 * 3

        ; draw_pixel(denorm(x), denorm(y), RED)
        push word [bp + %$color] ; color
        push bx       ; y 
        push ax       ; x
        call draw_pixel
        add sp, 2 * 3

        mov ax, [tmp]

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
        jle .loop

    mov ax, [saved_ax]
    mov bx, [saved_bx]
    add sp, %$localsize
endproc


;short get_octant(short x, short y) {
;    short lut[8] = {0, 1, 3, 2, 7, 6, 4, 5};
;    short flags = 0;
;    short a, b, c;
;    a = y < 0;
;    b = x < 0;
;    c = abs(x) < abs(y);
;
;    if (a) flags |= (1 << 2);
;    if (b) flags |= (1 << 1);
;    if (c) flags |= (1 << 0);
;
;    return lut[flags];
;}
; Find what octant (x, y) lies in, as a number
; Returns into ax (and clobbers the old thing)
proc get_octant
%stacksize small
%assign %$localsize 0
%$x arg
%$y arg
%local \
	flags:word

    sub sp, %$localsize

;    short flags = 0;
    mov word [flags], 0

;    a = y < 0;
;    if (a) flags |= (1 << 2);
    cmp word [bp + %$y], 0
    jge .unset_a
    .set_a:
        or word [flags], 1 << 2
    .unset_a:

;    b = x < 0;
;    if (b) flags |= (1 << 1);
    cmp word [bp + %$x], 0
    jge .unset_b
    .set_b:
        or word [flags], 1 << 1
    .unset_b:

; TODO: We can compute abs here *much* more efficiently!!!
;    x = abs(x)
    cmp word [bp + %$x], 0
    jge .noneg_x
    .neg_x:
        neg word [bp + %$x]
    .noneg_x:
;    y = abs(y)
    cmp word [bp + %$y], 0
    jge .noneg_y
    .neg_y:
        neg word [bp + %$y]
    .noneg_y:
;    c = x < y;
;    if (c) flags |= (1 << 0);
    mov ax, [bp + %$x]
    cmp ax, [bp + %$y]
    jge .unset_c
    .set_c:
        or word [flags], 1
    .unset_c:

;    return lut[flags];
    mov bx, word [flags]
    shl bx, 1
    mov ax, word [octant_lut + bx]
    add sp, %$localsize
endproc

octant_lut:
    dw 0x0000 
    dw 0x0001
    dw 0x0003
    dw 0x0002
    dw 0x0007 
    dw 0x0006
    dw 0x0004
    dw 0x0005

; (short, short) normalize_to_octant(octant, x, y) 
;   switch(octant)  
;     case 0: return (x, y)
;     case 1: return (y, x)
;     case 2: return (y, -x)
;     case 3: return (-x, y)
;     case 4: return (-x, -y)
;     case 5: return (-y, -x)
;     case 6: return (-y, x)
;     case 7: return (x, -y)
; returns norm(x) in ax, norm(y) in bx
proc normalize_to_octant
%stacksize small
%assign %$localsize 0
%$octant arg
%$x arg
%$y arg
%local \
    saved_si:word

	sub sp, %$localsize
    mov [saved_si], si

    ; load up ax and bx
    mov ax, [bp + %$x]
    mov bx, [bp + %$y]

    ; jump table because fuck 'em
	mov si, word [bp + %$octant]
    shl si, 1
	jmp [si + .jump_table]

	.jump_table:
		dw .octant_0
		dw .octant_1
		dw .octant_2
		dw .octant_3
		dw .octant_4
		dw .octant_5
		dw .octant_6
		dw .octant_7

  	; case 0: return (x, y)
	.octant_0:
		jmp .ret
    ; case 1: return (y, x)
	.octant_1:
		xchg ax, bx
		jmp .ret
    ; case 2: return (y, -x)
	.octant_2:
        neg ax
		xchg ax, bx
		jmp .ret
    ; case 3: return (-x, y)
	.octant_3:
        neg ax
		jmp .ret
    ; case 4: return (-x, -y)
	.octant_4:
        neg ax
        neg bx
		jmp .ret
    ; case 5: return (-y, -x)
	.octant_5:
        neg ax
        neg bx
        xchg ax, bx
		jmp .ret
    ; case 6: return (-y, x)
	.octant_6:
        neg bx
        xchg ax, bx
		jmp .ret
    ; case 7: return (x, -y)
	.octant_7:
        neg bx
		jmp .ret

	.ret:
    mov si, [saved_si]
	add sp, %$localsize
endproc

; (short, short) denormalize_from_octant(octant, x, y) 
;   switch(octant)  
;     case 0: return (x, y)
;     case 1: return (y, x)
;     case 2: return (-y, x)
;     case 3: return (-x, y)
;     case 4: return (-x, -y)
;     case 5: return (-y, -x)
;     case 6: return (y, -x)
;     case 7: return (x, -y)
; returns denorm(x) in ax, denorm(y) in bx
proc denormalize_from_octant
%stacksize small
%assign %$localsize 0
%$octant arg
%$x arg
%$y arg
%local \
    saved_si:word

	sub sp, %$localsize
    mov [saved_si], si

    ; load up ax and bx
    mov ax, [bp + %$x]
    mov bx, [bp + %$y]

    ; jump table because fuck 'em
	mov si, word [bp + %$octant]
    shl si, 1
	jmp [si + .jump_table]

	.jump_table:
		dw .octant_0
		dw .octant_1
		dw .octant_2
		dw .octant_3
		dw .octant_4
		dw .octant_5
		dw .octant_6
		dw .octant_7

  	; case 0: return (x, y)
	.octant_0:
		jmp .ret
    ; case 1: return (y, x)
	.octant_1:
		xchg ax, bx
		jmp .ret
    ; case 2: return (-y, x)
	.octant_2:
        neg bx
        xchg ax, bx
		jmp .ret
    ; case 3: return (-x, y)
	.octant_3:
        neg ax
		jmp .ret
    ; case 4: return (-x, -y)
	.octant_4:
        neg ax
        neg bx
		jmp .ret
    ; case 5: return (-y, -x)
	.octant_5:
        neg ax
        neg bx
        xchg ax, bx
		jmp .ret
    ; case 6: return (y, -x)
	.octant_6:
        neg ax
		xchg ax, bx
		jmp .ret
    ; case 7: return (x, -y)
	.octant_7:
        neg bx
		jmp .ret

	.ret:
    mov si, [saved_si]
	add sp, %$localsize
endproc


%endif
