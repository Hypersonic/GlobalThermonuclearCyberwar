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


hello_world: db "Hello, World"
end_hello_world:


%define VMEM_BASE 0xA0000
%define SCREEN_WIDTH 320
%define SCREEN_HEIGHT 200

%endif
