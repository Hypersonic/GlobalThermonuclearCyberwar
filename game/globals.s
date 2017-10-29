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

hello_world: db "Hello, World"
end_hello_world:

; mask to get what keys are pressed. See input.s for the mask constants
keys_set: dw 0x0

; screen state. see screens.s for possible values
current_screen: dw 0x0

%define VMEM_BASE 0xA0000
%define SCREEN_WIDTH 320
%define SCREEN_HEIGHT 200

; screen selector constants
%define SCREEN_MENU 0
%define SCREEN_GAMEPLAY 1


; ==== STRINGS ====

select_country: db "SELECT YOUR COUNTRY:"
end_select_country:

select_usa: db "USA"
end_select_usa:

select_ussr: db "USSR"
end_select_ussr:

country_cursor: db ">"
end_country_cursor:

%endif
