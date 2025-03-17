; Player Ship Module

; Player ship state
PLAYER_X     equ $0010      ; Player X position (16-bit)
PLAYER_Y     equ $0012      ; Player Y position (16-bit)
PLAYER_VX    equ $0014      ; Player X velocity (16-bit)
PLAYER_VY    equ $0016      ; Player Y velocity (16-bit)
PLAYER_DIR   equ $0018      ; Player direction (0=right, 1=left)
PLAYER_STATE equ $0019      ; Player state (0=normal, 1=exploding, 2=hyperspace)

; Constants
MAX_VELOCITY equ $0300      ; Maximum velocity
THRUST_ACC   equ $0020      ; Thrust acceleration
GRAVITY_ACC  equ $0010      ; Gravity acceleration
DRAG_FACTOR  equ $FFF0      ; Drag factor (negative)

; Initialize player
INIT_PLAYER:
    ; Set initial position (center of screen)
    ldd #$8000
    std PLAYER_X
    std PLAYER_Y
    ; Clear velocities
    clr PLAYER_VX
    clr PLAYER_VX+1
    clr PLAYER_VY
    clr PLAYER_VY+1
    ; Set initial direction and state
    clr PLAYER_DIR
    clr PLAYER_STATE
    rts

; Update player position and handle controls
UPDATE_PLAYER:
    ; Read joystick
    ldaa P1_JOYSTICK
    
    ; Handle thrust
    bita #JOY_THRUST
    beq NO_THRUST
    ; Apply thrust in current direction
    ldaa PLAYER_DIR
    beq THRUST_RIGHT
    ; Thrust left
    ldd PLAYER_VX
    subd #THRUST_ACC
    std PLAYER_VX
    bra THRUST_DONE
THRUST_RIGHT:
    ldd PLAYER_VX
    addd #THRUST_ACC
    std PLAYER_VX
THRUST_DONE:
NO_THRUST:

    ; Handle vertical movement
    ldaa P1_JOYSTICK
    bita #JOY_UP
    beq NO_UP
    ldd PLAYER_VY
    subd #THRUST_ACC
    std PLAYER_VY
NO_UP:
    bita #JOY_DOWN
    beq NO_DOWN
    ldd PLAYER_VY
    addd #THRUST_ACC
    std PLAYER_VY
NO_DOWN:

    ; Apply gravity
    ldd PLAYER_VY
    addd #GRAVITY_ACC
    std PLAYER_VY

    ; Apply drag
    ldd PLAYER_VX
    asld            ; Multiply by 2
    eora #$FF      ; Negate
    anda #DRAG_FACTOR
    std PLAYER_VX
    ldd PLAYER_VY
    asld
    eora #$FF
    anda #DRAG_FACTOR
    std PLAYER_VY

    ; Update position
    ldd PLAYER_X
    addd PLAYER_VX
    std PLAYER_X
    ldd PLAYER_Y
    addd PLAYER_VY
    std PLAYER_Y

    ; Check for hyperspace
    ldaa P1_BUTTONS
    bita #BTN_HYPER
    beq NO_HYPER
    jsr HYPERSPACE
NO_HYPER:
    rts

; Hyperspace jump
HYPERSPACE:
    ldaa #2
    staa PLAYER_STATE
    ; TODO: Implement random position jump
    rts 