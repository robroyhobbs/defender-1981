; Defender Hardware Definitions

; Memory Map
RAM_START    equ $0000      ; Start of RAM
RAM_END      equ $00FF      ; End of RAM
STACK_TOP    equ $00FF      ; Top of stack

; Video Hardware
VRAM_START   equ $4000      ; Start of video RAM
VRAM_END     equ $4FFF      ; End of video RAM
VSTAT        equ $5000      ; Video status register
VCMD         equ $5001      ; Video command register

; Sound Hardware
SOUND_DATA   equ $6000      ; Sound data register
SOUND_CTRL   equ $6001      ; Sound control register

; Input Hardware
P1_JOYSTICK  equ $7000      ; Player 1 joystick
P1_BUTTONS   equ $7001      ; Player 1 buttons
P2_JOYSTICK  equ $7002      ; Player 2 joystick
P2_BUTTONS   equ $7003      ; Player 2 buttons
DIP_SWITCHES equ $7004      ; DIP switches

; Joystick bit masks
JOY_UP       equ %00000001
JOY_DOWN     equ %00000010
JOY_LEFT     equ %00000100
JOY_RIGHT    equ %00001000
JOY_THRUST   equ %00010000
JOY_REVERSE  equ %00100000

; Button bit masks
BTN_FIRE     equ %00000001
BTN_SMART    equ %00000010
BTN_HYPER    equ %00000100
BTN_START    equ %00001000

; Video commands
VCMD_CLEAR   equ $00        ; Clear screen
VCMD_FLIP    equ $01        ; Flip buffers
VCMD_DRAW    equ $02        ; Draw sprite 