org 1000h
; Entry point, put includes after this, please!
jmp main


%include "globals.s"
%include "macros.s"
%include "input.s"
%include "screen.s"
%include "graphics.s"

main:
    mov word [current_screen], SCREEN_GAMEPLAY
    .forever:
        call get_keys
        call clear_screen
        call do_current_screen
        call draw_keypress_pixels


        ; sleep a bit
        mov cx, 0x0000
        mov dx, 0xffff
        mov ah, 0x86
        int 0x15

        jmp .forever

    hlt

; draw keypress pixels on screen for debugging purposes
proc draw_keypress_pixels
    test word [keys_set], KEYMASK_UP
    jz .no_up_pressed
    .up_pressed:
        push_args 10, 9, 0x6
        call draw_pixel
        add sp, 2*3
    .no_up_pressed:

    test word [keys_set], KEYMASK_DOWN
    jz .no_down_pressed
    .down_pressed:
        push_args 10, 10, 0x5
        call draw_pixel
        add sp, 2*3
    .no_down_pressed:
    
    test word [keys_set], KEYMASK_LEFT
    jz .no_left_pressed
    .left_pressed:
        push_args 9, 10, 0x3
        call draw_pixel
        add sp, 2*3
    .no_left_pressed:

    test word [keys_set], KEYMASK_RIGHT
    jz .no_right_pressed
    .right_pressed:
        push_args 11, 10, 0x4
        call draw_pixel
        add sp, 2*3
    .no_right_pressed:
endproc

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
