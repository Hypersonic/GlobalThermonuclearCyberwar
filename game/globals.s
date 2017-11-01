; Global variables, etc
%ifndef GLOBALS_S
%define GLOBALS_S

%include "c16.mac"

; Dispatch macro to find sizes of registers (in bytes)... very hacky but w/e
%define sizeof(reg) __sizeof__ %+ reg
; 2-byte registers
%assign __sizeof__ax 2
%assign __sizeof__bx 2
%assign __sizeof__cx 2
%assign __sizeof__dx 2
%assign __sizeof__si 2
%assign __sizeof__di 2
%assign __sizeof__bp 2
%assign __sizeof__sp 2

%macro push_args 1-* 
  %rep  %0 
  %rotate -1 
        push %1 
  %endrep 
%endmacro

selected_country: db 0

; mask to get what keys are pressed. See input.s for the mask constants
keys_set: dw 0x0

; screen state. see screens.s for possible values
current_screen: dw 0x0

%define FRAMEBUFFER_BASE 0x10000
%define VMEM_BASE 0xA0000
%define SCREEN_WIDTH 320
%define SCREEN_HEIGHT 200

; screen selector constants
%define SCREEN_MENU 0
%define SCREEN_GAMEPLAY 1

; targetting
target_x: dw 10
target_y: dw 100

%define TICKS_BETWEEN_MOVES 5


%define MAX_MISSLES 0x20
; missiles in flight
; we _could_ use nasm's struct abstraction here, but i'm lazy
missile_slots:
%assign i 0
%rep MAX_MISSLES

missile_slot_ %+ i:
.launch_x: dw 0           ; +0
.launch_y: dw 0           ; +2
.target_x: dw 0           ; +4
.target_y: dw 0           ; +6
.end_sweep: dw 0          ; +8
.ticks_until_move: dw 0   ; +10
.in_use: db 0             ; +12
.country: db 0            ; +13
.color: dw 0              ; +14

%assign i i+1
%endrep
end_missile_slots:


; ==== STRINGS ====

select_country: db "SELECT YOUR COUNTRY:"
end_select_country:

select_usa: db "USA"
end_select_usa:

select_ussr: db "USSR"
end_select_ussr:

country_cursor: db ">"
end_country_cursor:

country_clear: db " "
end_country_clear:

%endif
