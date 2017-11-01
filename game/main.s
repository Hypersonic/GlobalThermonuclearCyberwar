org 1000h
; Entry point, put includes after this, please!
jmp main


%include "globals.s"
%include "macros.s"
%include "input.s"
%include "screen.s"
%include "graphics.s"

main:
    call setup_demo_launches ; for testing :)
    mov word [current_screen], SCREEN_GAMEPLAY
    .forever:
        call get_keys
        call clear_framebuffer
        call draw_keypress_pixels
        call do_current_screen

        ; sleep a bit
        mov cx, 0x0000
        mov dx, 0x8fff
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

    test word [keys_set], KEYMASK_ENTER
    jz .no_enter_pressed
    .enter_pressed:
        push_args 12, 9, 0x7
        call draw_pixel
        add sp, 2*3
    .no_enter_pressed:
endproc
