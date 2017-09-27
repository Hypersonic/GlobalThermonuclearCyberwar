org 1000h

main:
    ; Set video mode
    ; 40x25 text mode
    mov ax, 0x0013
    int 0x10

    mov ax, 0x1300 ; draw string
    mov bh, 0
    mov bl, 0xf
    mov cx, end_hello_world - hello_world
    mov dx, 0x090c
    mov bp, hello_world
    int 0x10

    hlt

hello_world: db "Hello, World"
end_hello_world:
