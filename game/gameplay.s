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
    call move_target
    call draw_target

    push_args 10, 100, word [target_x], word [target_y], 2, 0x10
    call draw_trajectory
    add sp, 2*6

    xor ax, ax
    mov cx, launchsites
    .sites_loop:
        mov bx, cx
        mov al, byte [bx + 3]

        cmp byte [bx], COUNTRY_AMERICA
        jz .attack_moscow
        .attack_dc:
            push_args word [bx + 1], ax, \
                      85, 100, \
                      3, word [end_sweep]
            call draw_trajectory
            add sp, 2*6
            jmp .after_attack
        .attack_moscow:
            push_args word [bx + 1], ax, \
                      188, 73, \
                      4, word [end_sweep]
            call draw_trajectory
            add sp, 2*6
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

    call blit_screen

    mov cx, [saved_cx]
    mov bx, [saved_bx]
    mov ax, [saved_ax]
    add sp, %$localsize
endproc

; draw_trajectory(start_x, start_y, end_x, end_y, color, end_sweep)
proc draw_trajectory
%stacksize small
%assign %$localsize 0
%$start_x arg
%$start_y arg
%$end_x arg
%$end_y arg
%$color arg
%$end_sweep arg
%local \
    saved_ax:word, \
    mid_x:word, \
    mid_y:word

    sub sp, %$localsize
    mov [saved_ax], ax

    ; mid_x = interpolate(start_x, end_x, 0xb)
    push_args word [bp + %$start_x], word [bp + %$end_x], 0xb
    call interpolate
    add sp, 2*3
    mov [mid_x], ax

    ; mid_y = min(start_y, end_y) - 100
    ; TODO: find a really volatile formula instead that gives them overwrite
    mov ax, [bp + %$start_y]
    cmp ax, [bp + %$end_y]
    jl .no_min
    .min:
        mov ax, [bp + %$end_y]
    .no_min:

    sub ax, 100
    mov [mid_y], ax

    push_args word [bp + %$start_x], word [bp + %$start_y], \
              word [mid_x], word [mid_y], \
              word [bp + %$end_x], word [bp + %$end_y], \
              word [bp + %$color], \
              0, word [bp + %$end_sweep]
    call draw_bezier
    add sp, 2*9

    mov ax, [saved_ax]
    add sp, %$localsize
endproc

; move the target around based on arrow keys
proc move_target
    test word [keys_set], KEYMASK_UP
    jz .no_up
    .up:
        dec word [target_y]
    .no_up:

    test word [keys_set], KEYMASK_DOWN
    jz .no_down
    .down:
        inc word [target_y]
    .no_down:

    test word [keys_set], KEYMASK_LEFT
    jz .no_left
    .left:
        dec word [target_x]
    .no_left:

    test word [keys_set], KEYMASK_RIGHT
    jz .no_right
    .right:
        inc word [target_x]
    .no_right:
endproc

proc draw_target
%stacksize small
%assign %$localsize 0
%local \
    saved_ax:word, \
    saved_bx:word, \
    x:word, \
    y:word

    sub sp, %$localsize
    mov [saved_ax], ax
    mov [saved_bx], bx

    ; Target looks like this:
    ;  +
    ; + +
    ;  +

    mov ax, [target_x]
    mov bx, [target_y]
    ;     
    ; +    
    ;     
    dec ax
    push_args ax, bx, 0xc
    call draw_pixel
    add sp, 2*3

    ;     
    ; +
    ;  +   
    inc ax
    inc bx
    push_args ax, bx, 0xc
    call draw_pixel
    add sp, 2*3

    ;     
    ; + +
    ;  +   
    inc ax
    dec bx
    push_args ax, bx, 0xc
    call draw_pixel
    add sp, 2*3

    ;  +
    ; + +
    ;  +   
    dec ax
    dec bx
    push_args ax, bx, 0xc
    call draw_pixel
    add sp, 2*3

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
        ;mov cx, 0x0000
        ;mov dx, 0x04ff
        ;mov ah, 0x86
        ;int 0x15
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
