%ifndef GAMEPLAY_S
%define GAMEPLAY_S

%include "worldmap.s"
%include "launchsites.s"

end_sweep: dw 0x0

proc screen_gameplay
%stacksize small
%assign %$localsize 0
%local \
	saved_ax:word, \
    saved_bx:word, \
    saved_cx:word

    sub sp, %$localsize
    mov [saved_ax], ax
    mov [saved_bx], bx
    mov [saved_cx], cx

    call draw_worldmap

    xor ax, ax
    mov cx, launchsites
    .sites_loop:
        mov bx, cx
        mov al, byte [bx + 3]

        cmp byte [bx], COUNTRY_AMERICA
        jz .attack_moscow
        .attack_dc:
            push_args word [bx + 1], ax, \
                      120, 0, \
                      85, 100, \
                      3, \
                      0, word [end_sweep]
            call draw_bezier
            add sp, 2*9
            jmp .after_attack
        .attack_moscow:
            push_args word [bx + 1], ax, \
                      100, 0, \
                      188, 73, \
                      4, \
                      0, word [end_sweep]
            call draw_bezier
            add sp, 2*9
            jmp .after_attack

        .after_attack:
        add cx, 4
        cmp cx, launchsites + (4 * (n_launchsites - 1))
        jle .sites_loop

    cmp word [end_sweep], 0xf
    jl .inc_sweep

    mov word [end_sweep], 0x0
    jmp .end
    .inc_sweep:
        inc word [end_sweep]
    
    .end:

    mov cx, [saved_cx]
    mov bx, [saved_bx]
    mov ax, [saved_ax]
    add sp, %$localsize

endproc

proc draw_worldmap
%stacksize small
%assign %$localsize 0
%local \
    saved_ax:word, \
    saved_bx:word, \
    saved_cx:word, \
    saved_si:word

    sub sp, %$localsize
    mov [saved_ax], ax
    mov [saved_bx], bx
    mov [saved_cx], cx
    mov [saved_si], si

    xor si, si
    xor bx, bx
    .loop:
        mov ax, [worldmap + si + 0 * 2]
        mov bl, [worldmap + si + 1 * 2]

        push_args ax, bx, 0x1f
        call draw_pixel
        add sp, 6

        ; label for self-modifying code so we can nop this out
        .map_render_pixel_sleep_amount_begin:
        ; sleep a bit
        push ax
        mov cx, 0x0000
        mov dx, 0x04ff
        mov ah, 0x86
        int 0x15
        pop ax
        ; end label for self-modifying code
        .map_render_pixel_sleep_amount_end:

        add si, 2+1
        cmp si, (n_worldmap_pixels-1) * (2+1)
        jle .loop

    ; nop out the between-pixel sleep
    .nop_out_area_begin:
    mov si, .map_render_pixel_sleep_amount_begin
    .nop_out_pixel_sleep:
        mov byte [si], 0x90
        inc si
        cmp si, .map_render_pixel_sleep_amount_end
        jne .nop_out_pixel_sleep
    ; nop out the nop-outer, including this nop-outer nop-outer :)
    ; I don't know why i made this but I think it's beautiful
    mov cx, .nop_out_area_end - .nop_out_area_begin
    mov al, 0x90
    mov di, .nop_out_area_begin
    rep stosb
    .nop_out_area_end:

    mov ax, [saved_ax]
    mov bx, [saved_bx]
    mov cx, [saved_cx]
    mov si, [saved_si]
    add sp, %$localsize
endproc


%endif
