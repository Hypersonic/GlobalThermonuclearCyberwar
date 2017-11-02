%ifndef GAMEPLAY_S
%define GAMEPLAY_S

%include "worldmap.s"
%include "launchsites.s"

%define PHASE_SELECTLAUNCHSITE 0
%define PHASE_SELECTTARGET     0
%define PHASE_ENEMYMOVE        0

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

    mov si, missile_slots
    .loop:
        cmp byte [si + 12], 0 ; skip if not in_use
        je .skip

        ; render missile
        push_args word [si + 0], word [si + 2], \
                  word [si + 4], word [si + 6], \
                  word [si + 14], word [si + 8]
        call draw_trajectory
        add sp, 2*6

        ; advance ticks_until_move
        dec word [si + 10]
        cmp word [si + 10], 0
        jne .no_reset_ticks
        .reset_ticks:
            mov word [si + 10], TICKS_BETWEEN_MOVES
            ; increment end_sweep, unless we're at max
            cmp word [si + 8], 0xf
            jg .no_inc_sweep
            .inc_sweep:
                inc word [si + 8]
                jmp .after_sweep
            .no_inc_sweep:
                ; TODO: create explosion here
                mov word [si + 8], 0
            .after_sweep:
        .no_reset_ticks:
        
        add si, 16
        cmp si, end_missile_slots
        jl .loop
        jmp .after_loop
        .skip:
            add si, 16
            cmp si, end_missile_slots
            jl .loop
    .after_loop:

    .end:

    call blit_screen

    mov cx, [saved_cx]
    mov bx, [saved_bx]
    mov ax, [saved_ax]
    add sp, %$localsize
endproc

proc setup_demo_launches
%stacksize small
%assign %$localsize 0

    mov word [missile_slot_0 + 0], 70                   ; launch_x
    mov word [missile_slot_0 + 2], 77                   ; launch_y
    mov word [missile_slot_0 + 4], 200                  ; target_x
    mov word [missile_slot_0 + 6], 60                   ; target_y
    mov word [missile_slot_0 + 8], 0x0                  ; end_sweep
    mov word [missile_slot_0 + 10], TICKS_BETWEEN_MOVES ; ticks_until_move
    mov byte [missile_slot_0 + 12], 1                   ; in_use
    mov byte [missile_slot_0 + 13], COUNTRY_AMERICA     ; country
    mov byte [missile_slot_0 + 14], 0x2                 ; yield

    mov word [missile_slot_1 + 0], 73                   ; launch_x
    mov word [missile_slot_1 + 2], 84                   ; launch_y
    mov word [missile_slot_1 + 4], 180                  ; target_x
    mov word [missile_slot_1 + 6], 65                   ; target_y
    mov word [missile_slot_1 + 8], 0x4                  ; end_sweep
    mov word [missile_slot_1 + 10], TICKS_BETWEEN_MOVES ; ticks_until_move
    mov byte [missile_slot_1 + 12], 1                   ; in_use
    mov byte [missile_slot_1 + 13], COUNTRY_AMERICA     ; country
    mov byte [missile_slot_1 + 14], 0x3                 ; yield

    mov word [missile_slot_2 + 0], 65                   ; launch_x
    mov word [missile_slot_2 + 2], 75                   ; launch_y
    mov word [missile_slot_2 + 4], 210                  ; target_x
    mov word [missile_slot_2 + 6], 55                   ; target_y
    mov word [missile_slot_2 + 8], 0x8                  ; end_sweep
    mov word [missile_slot_2 + 10], TICKS_BETWEEN_MOVES ; ticks_until_move
    mov byte [missile_slot_2 + 12], 1                   ; in_use
    mov byte [missile_slot_2 + 13], COUNTRY_AMERICA     ; country
    mov byte [missile_slot_2 + 14], 0x4                 ; yield

    mov word [missile_slot_3 + 0], 60                   ; launch_x
    mov word [missile_slot_3 + 2], 79                   ; launch_y
    mov word [missile_slot_3 + 4], 180                  ; target_x
    mov word [missile_slot_3 + 6], 88                   ; target_y
    mov word [missile_slot_3 + 8], 0xc                  ; end_sweep
    mov word [missile_slot_3 + 10], TICKS_BETWEEN_MOVES ; ticks_until_move
    mov byte [missile_slot_3 + 12], 1                   ; in_use
    mov byte [missile_slot_3 + 13], COUNTRY_AMERICA     ; country
    mov byte [missile_slot_3 + 14], 0x5                 ; yield

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
; also chane intensity of shot (q/a)
proc move_target
%stacksize small
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

    test word [keys_set], KEYMASK_Q
    jz .no_q
    .q:
        inc word [target_strength]
        and word [target_strength], 0xff
    .no_q:

    test word [keys_set], KEYMASK_A
    jz .no_a
    .a:
        dec word [target_strength]
        and word [target_strength], 0xff
    .no_a:
endproc

; find a missile slot that is available, or return -1 if none
proc get_available_missile_slot
%stacksize small
%assign %$localsize 0
%local \
    saved_si:word

    sub sp, %$localsize
    mov [saved_si], si

    mov ax, 0
    .loop:
        ; if in_use != 0, end
        mov si, ax
        shl si, 4
        cmp byte [missile_slots + si + 12], 0
        jne .end

        inc ax
        cmp ax, MAX_MISSLES
        jl .loop

    .none_found: ; if we don't find any, return -1
        mov ax, -1

    .end:
    mov si, [saved_si]
    add sp, %$localsize
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
    push_args ax, bx, word [target_strength]
    call draw_pixel
    add sp, 2*3

    ;     
    ; +
    ;  +   
    inc ax
    inc bx
    push_args ax, bx, word [target_strength]
    call draw_pixel
    add sp, 2*3

    ;     
    ; + +
    ;  +   
    inc ax
    dec bx
    push_args ax, bx, word [target_strength]
    call draw_pixel
    add sp, 2*3

    ;  +
    ; + +
    ;  +   
    dec ax
    dec bx
    push_args ax, bx, word [target_strength]
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
        ;call blit_screen
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