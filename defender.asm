; Defender (1981) ROM Assembly
; Main file

; Memory Map
RAM_START    equ $0000      ; Start of RAM
RAM_END      equ $00FF      ; End of RAM
STACK_TOP    equ $00FF      ; Top of stack

; Video Hardware
VRAM_START   equ $4000      ; Start of video RAM
VRAM_END     equ $4FFF      ; End of video RAM
VSTAT        equ $5000      ; Video status register
VCMD         equ $5001      ; Video command register
VDATA        equ $5002      ; Video data register
VADDR        equ $5003      ; Video address register

; Video Constants
SCREEN_WIDTH  equ 256       ; Screen width in pixels
SCREEN_HEIGHT equ 192       ; Screen height in pixels
SPRITE_WIDTH  equ 16        ; Sprite width in pixels
SPRITE_HEIGHT equ 16        ; Sprite height in pixels

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

; Player Ship State
PLAYER_X     equ $0010      ; Player X position (high byte)
PLAYER_XL    equ $0011      ; Player X position (low byte)
PLAYER_Y     equ $0012      ; Player Y position (high byte)
PLAYER_YL    equ $0013      ; Player Y position (low byte)
PLAYER_VX    equ $0014      ; Player X velocity (high byte)
PLAYER_VXL   equ $0015      ; Player X velocity (low byte)
PLAYER_VY    equ $0016      ; Player Y velocity (high byte)
PLAYER_VYL   equ $0017      ; Player Y velocity (low byte)
PLAYER_DIR   equ $0018      ; Player direction (0=right, 1=left)
PLAYER_STATE equ $0019      ; Player state (0=normal, 1=exploding, 2=hyperspace)

; Video Buffer Management
DRAW_BUFFER  equ $0020      ; Current draw buffer (0 or 1)
DISP_BUFFER  equ $0021      ; Current display buffer (0 or 1)

; Weapon Data (16 projectiles max)
WEAPON_COUNT equ $0023      ; Number of active projectiles
WEAPON_DATA  equ $0024      ; Start of weapon data block
WEAPON_SIZE  equ 6          ; Bytes per projectile
MAX_WEAPONS  equ 16         ; Maximum number of projectiles
FIRE_DELAY   equ $0025      ; Fire rate limiter
MAX_FIRE_DELAY equ 10       ; Frames between shots

; Weapon Data Structure (6 bytes per projectile)
; +0: X position (high byte)
; +1: X position (low byte)
; +2: Y position (high byte)
; +3: Y position (low byte)
; +4: Direction (0=right, 1=left)
; +5: Type (0=normal, 1=smart bomb)

; Enemy Data (8 enemies max)
ENEMY_COUNT  equ $0030      ; Number of active enemies
ENEMY_DATA   equ $0031      ; Start of enemy data block
ENEMY_SIZE   equ 8          ; Bytes per enemy
MAX_ENEMIES  equ 8          ; Maximum number of enemies

; Enemy Data Structure (8 bytes per enemy)
; +0: X position (high byte)
; +1: X position (low byte)
; +2: Y position (high byte)
; +3: Y position (low byte)
; +4: X velocity (high byte)
; +5: X velocity (low byte)
; +6: Type (0=lander, 1=mutant, 2=bomber)
; +7: State (0=active, 1=exploding)

; Constants
MAX_VELOCITY equ $03        ; Maximum velocity (high byte)
THRUST_ACC   equ $02        ; Thrust acceleration
GRAVITY_ACC  equ $01        ; Gravity acceleration
DRAG_FACTOR  equ $F0        ; Drag factor

; Enemy Constants
ENEMY_SPEED  equ $01        ; Base enemy speed
SPAWN_RATE   equ 100        ; Frames between enemy spawns
SPAWN_COUNT  equ $0022      ; Spawn counter

; Weapon Constants
PROJECTILE_SPEED equ $04    ; Projectile velocity
SMART_BOMB_RADIUS equ $20   ; Smart bomb blast radius

; Weapon Types
WEAPON_NORMAL   equ $00     ; Normal single shot
WEAPON_SPREAD   equ $01     ; Three-way spread shot
WEAPON_LASER    equ $02     ; Continuous laser beam
WEAPON_SMART    equ $03     ; Smart bomb

; Current weapon type
WEAPON_TYPE    equ $0026    ; Current weapon type
WEAPON_POWER   equ $0027    ; Weapon power level (1-3)

; Power-up Types
POWER_NONE    equ $00     ; No power-up
POWER_LEVEL   equ $01     ; Power level upgrade
POWER_SPREAD  equ $02     ; Spread shot power-up
POWER_LASER   equ $03     ; Laser power-up
POWER_SMART   equ $04     ; Smart bomb power-up

; Power-up Data
POWER_TYPE    equ $0028    ; Current power-up type
POWER_TIMER   equ $0029    ; Power-up duration timer
POWER_DURATION equ 300    ; Power-up duration in frames

; Sound Effects
SOUND_POWERUP equ $01     ; Power-up collect sound
SOUND_FIRE    equ $02     ; Weapon fire sound
SOUND_HIT     equ $03     ; Enemy hit sound

; Game States
STATE_TITLE   equ $00     ; Title screen
STATE_PLAYING equ $01     ; Game in progress
STATE_PAUSED  equ $02     ; Game paused
STATE_GAMEOVER equ $03    ; Game over screen

; Game State Data
GAME_STATE    equ $0030   ; Current game state
SCORE         equ $0031   ; Player score (4 bytes)
HIGH_SCORE    equ $0035   ; High score (4 bytes)
LEVEL         equ $0039   ; Current level
LIVES         equ $003A   ; Remaining lives
FLASH_COUNT   equ $003B   ; Visual effect counter

; Visual Effect Constants
FLASH_DURATION equ 10    ; Frames for flash effect
EXPLOSION_FRAMES equ 8   ; Number of explosion animation frames

; ROM organization
 org $0000

; Program entry point
START:
    ; Initialize hardware
    ldaa #$FF        ; Set up stack pointer
    staa STACK_TOP   ; at $00FF

    ; Initialize video
    jsr INIT_VIDEO

    ; Initialize player
    jsr INIT_PLAYER

    ; Initialize enemies
    jsr INIT_ENEMIES

    ; Initialize weapons
    jsr INIT_WEAPONS

    ; Initialize power-ups
    jsr INIT_POWERUPS

    ; Main game loop
MAIN_LOOP:
    ; Update game state
    jsr UPDATE_GAME
    
    ; Update game objects if playing
    ldaa GAME_STATE
    cmpa #STATE_PLAYING
    bne SKIP_UPDATES
    jsr UPDATE_PLAYER
    jsr UPDATE_ENEMIES
    jsr UPDATE_WEAPONS
    jsr UPDATE_POWERUPS
    jsr CHECK_COLLISIONS
    jsr CHECK_POWERUP_COLLISION
    jsr HANDLE_WEAPONS
    jsr SPAWN_ENEMIES
    ldaa SPAWN_COUNT
    anda #$3F
    beq SPAWN_POWERUP
SKIP_UPDATES:
    
    ; Clear screen
    jsr CLEAR_SCREEN
    
    ; Draw game state
    jsr DRAW_GAME
    
    ; Draw explosion if active
    jsr DRAW_EXPLOSION
    
    ; Flip buffers
    jsr FLIP_BUFFERS
    
    bra MAIN_LOOP   ; Loop forever

; Initialize video system
INIT_VIDEO:
    clr DRAW_BUFFER  ; Start with buffer 0
    clr DISP_BUFFER
    ; Clear both buffers
    jsr CLEAR_SCREEN
    ldaa #1
    staa DRAW_BUFFER
    jsr CLEAR_SCREEN
    clr DRAW_BUFFER
    rts

; Clear current draw buffer
CLEAR_SCREEN:
    ; Set video address to start of current buffer
    ldaa DRAW_BUFFER
    beq CLEAR_BUF0
    ldaa #$50        ; Buffer 1 starts at $5000
    bra CLEAR_START
CLEAR_BUF0:
    ldaa #$40        ; Buffer 0 starts at $4000
CLEAR_START:
    staa VADDR
    clra             ; Clear pattern
    ldab #$10        ; Counter for 4K bytes
CLEAR_LOOP:
    staa VDATA      ; Clear one byte
    decb
    bne CLEAR_LOOP
    rts

; Flip display buffers
FLIP_BUFFERS:
    ldaa DRAW_BUFFER
    staa DISP_BUFFER
    eora #1         ; Toggle buffer
    staa DRAW_BUFFER
    ; Tell video hardware to display new buffer
    ldaa #VCMD_FLIP
    staa VCMD
    rts

; Draw player sprite at current position
DRAW_PLAYER:
    ; Calculate screen position
    ldaa PLAYER_X
    ldab PLAYER_Y
    ; Set up video address
    adda DRAW_BUFFER  ; Add buffer offset
    staa VADDR
    ; Draw sprite
    ldx #PLAYER_SPRITE
    ldab #SPRITE_HEIGHT
DRAW_SPRITE_LOOP:
    ldaa 0,x         ; Get sprite data
    staa VDATA       ; Draw one line
    inx              ; Next sprite line
    decb
    bne DRAW_SPRITE_LOOP
    rts

; Player sprite data (16x16 pixels)
PLAYER_SPRITE:
    fcb %00011000    ; Basic ship shape
    fcb %00111100
    fcb %01111110
    fcb %11111111
    fcb %11111111
    fcb %01111110
    fcb %00111100
    fcb %00011000
    fcb %00011000
    fcb %00111100
    fcb %01111110
    fcb %11111111
    fcb %11111111
    fcb %01111110
    fcb %00111100
    fcb %00011000

; Initialize player
INIT_PLAYER:
    ; Set initial position (center of screen)
    ldaa #$80
    staa PLAYER_X
    clr PLAYER_XL
    staa PLAYER_Y
    clr PLAYER_YL
    ; Clear velocities
    clr PLAYER_VX
    clr PLAYER_VXL
    clr PLAYER_VY
    clr PLAYER_VYL
    ; Set initial direction and state
    clr PLAYER_DIR
    clr PLAYER_STATE
    rts

; Update player position and handle controls
UPDATE_PLAYER:
    ; Check if player is exploding
    ldaa PLAYER_STATE
    beq UPDATE_PLAYER_MOVE
    ; Handle explosion animation
    deca
    bne PLAYER_UPDATE_DONE
    ; Reset player after explosion
    jsr INIT_PLAYER
    bra PLAYER_UPDATE_DONE

UPDATE_PLAYER_MOVE:
    ; Read joystick
    ldaa P1_JOYSTICK
    
    ; Handle thrust
    bita #JOY_THRUST
    beq NO_THRUST
    ; Apply thrust in current direction
    ldaa PLAYER_DIR
    beq THRUST_RIGHT
    ; Thrust left
    ldaa PLAYER_VXL
    suba #THRUST_ACC
    staa PLAYER_VXL
    ldaa PLAYER_VX
    sbca #0
    staa PLAYER_VX
    bra THRUST_DONE
THRUST_RIGHT:
    ldaa PLAYER_VXL
    adda #THRUST_ACC
    staa PLAYER_VXL
    ldaa PLAYER_VX
    adca #0
    staa PLAYER_VX
THRUST_DONE:
NO_THRUST:

    ; Handle vertical movement
    ldaa P1_JOYSTICK
    bita #JOY_UP
    beq NO_UP
    ldaa PLAYER_VYL
    suba #THRUST_ACC
    staa PLAYER_VYL
    ldaa PLAYER_VY
    sbca #0
    staa PLAYER_VY
NO_UP:
    bita #JOY_DOWN
    beq NO_DOWN
    ldaa PLAYER_VYL
    adda #THRUST_ACC
    staa PLAYER_VYL
    ldaa PLAYER_VY
    adca #0
    staa PLAYER_VY
NO_DOWN:

    ; Apply gravity
    ldaa PLAYER_VYL
    adda #GRAVITY_ACC
    staa PLAYER_VYL
    ldaa PLAYER_VY
    adca #0
    staa PLAYER_VY

    ; Apply drag
    ldaa PLAYER_VXL
    asla            ; Multiply by 2
    eora #$FF      ; Negate
    anda #DRAG_FACTOR
    staa PLAYER_VXL
    ldaa PLAYER_VX
    asla
    eora #$FF
    anda #DRAG_FACTOR
    staa PLAYER_VX

    ldaa PLAYER_VYL
    asla
    eora #$FF
    anda #DRAG_FACTOR
    staa PLAYER_VYL
    ldaa PLAYER_VY
    asla
    eora #$FF
    anda #DRAG_FACTOR
    staa PLAYER_VY

    ; Update position
    ldaa PLAYER_XL
    adda PLAYER_VXL
    staa PLAYER_XL
    ldaa PLAYER_X
    adca PLAYER_VX
    staa PLAYER_X

    ldaa PLAYER_YL
    adda PLAYER_VYL
    staa PLAYER_YL
    ldaa PLAYER_Y
    adca PLAYER_VY
    staa PLAYER_Y

PLAYER_UPDATE_DONE:
    rts

; Initialize enemy system
INIT_ENEMIES:
    clr ENEMY_COUNT
    clr SPAWN_COUNT
    rts

; Update all active enemies
UPDATE_ENEMIES:
    ldab ENEMY_COUNT
    beq UPDATE_DONE    ; No enemies to update
    ldx #ENEMY_DATA
UPDATE_LOOP:
    ; Update enemy position based on velocity
    ldaa 4,x          ; Get X velocity (high)
    adda 0,x          ; Add to X position (high)
    staa 0,x
    ldaa 5,x          ; Get X velocity (low)
    adda 1,x          ; Add to X position (low)
    staa 1,x
    
    ; Simple AI: move toward player
    ldaa 0,x          ; Get enemy X
    suba PLAYER_X     ; Compare with player X
    bge MOVE_LEFT
    ; Move right
    ldaa 4,x
    adda #ENEMY_SPEED
    staa 4,x
    bra MOVE_DONE
MOVE_LEFT:
    ldaa 4,x
    suba #ENEMY_SPEED
    staa 4,x
MOVE_DONE:
    
    ; Next enemy
    ldaa #ENEMY_SIZE
    jsr ADD_X         ; X += ENEMY_SIZE
    decb
    bne UPDATE_LOOP
UPDATE_DONE:
    rts

; Spawn new enemies if needed
SPAWN_ENEMIES:
    ldaa SPAWN_COUNT
    inca
    cmpa #SPAWN_RATE
    bne SPAWN_WAIT
    ; Time to spawn
    clra
    ldab ENEMY_COUNT
    cmpb #MAX_ENEMIES
    beq SPAWN_WAIT    ; Max enemies reached
    ; Create new enemy
    ldx #ENEMY_DATA
    ldaa ENEMY_COUNT
    ldab #ENEMY_SIZE
    mul
    jsr ADD_X         ; X += A * ENEMY_SIZE
    ; Initialize enemy
    ldaa #$FF        ; Start at right edge
    staa 0,x
    clr 1,x
    ldaa #$80        ; Middle height
    staa 2,x
    clr 3,x
    ldaa #$FF        ; Move left
    staa 4,x
    clr 5,x
    clr 6,x          ; Type = lander
    clr 7,x          ; State = active
    ; Increment enemy count
    inc ENEMY_COUNT
SPAWN_WAIT:
    staa SPAWN_COUNT
    rts

; Initialize weapons system
INIT_WEAPONS:
    clr WEAPON_COUNT
    clr FIRE_DELAY
    clr WEAPON_TYPE   ; Start with normal weapon
    ldaa #1
    staa WEAPON_POWER ; Start at power level 1
    rts

; Play sound effect
PLAY_SOUND:
    staa SOUND_DATA
    rts

; Handle weapon firing
HANDLE_WEAPONS:
    ; Check fire delay
    ldaa FIRE_DELAY
    beq CAN_FIRE
    deca              ; Decrement delay
    staa FIRE_DELAY
    rts
CAN_FIRE:
    ; Check fire button
    ldaa P1_BUTTONS
    bita #BTN_FIRE
    beq NO_FIRE
    
    ; Play fire sound
    ldaa #SOUND_FIRE
    jsr PLAY_SOUND
    
    ; Check weapon type
    ldaa WEAPON_TYPE
    beq FIRE_NORMAL
    cmpa #WEAPON_SPREAD
    beq FIRE_SPREAD
    cmpa #WEAPON_LASER
    beq FIRE_LASER
    cmpa #WEAPON_SMART
    beq FIRE_SMART
    bra NO_FIRE

FIRE_NORMAL:
    ; Create single projectile
    jsr CREATE_PROJECTILE
    bra FIRE_DONE

FIRE_SPREAD:
    ; Create three projectiles at different angles
    jsr CREATE_PROJECTILE    ; Center shot
    ; Adjust Y position up for top shot
    ldaa PLAYER_Y
    suba #$10
    psha
    jsr CREATE_PROJECTILE
    pula
    staa PLAYER_Y
    ; Adjust Y position down for bottom shot
    ldaa PLAYER_Y
    adda #$10
    psha
    jsr CREATE_PROJECTILE
    pula
    staa PLAYER_Y
    bra FIRE_DONE

FIRE_LASER:
    ; Create long laser beam
    ldaa WEAPON_POWER   ; Laser width based on power
    ldab #3
    mul                 ; Width = power * 3
    stab WEAPON_SIZE    ; Temporarily increase projectile size
    jsr CREATE_PROJECTILE
    ldaa #6
    staa WEAPON_SIZE    ; Restore normal size
    bra FIRE_DONE

FIRE_SMART:
    ; Create smart bomb
    jsr CREATE_PROJECTILE
    ldx #WEAPON_DATA    ; Get last created projectile
    ldaa WEAPON_COUNT
    deca
    ldab #WEAPON_SIZE
    mul
    jsr ADD_X
    ldaa #WEAPON_SMART  ; Set type to smart bomb
    staa 5,x
    bra FIRE_DONE

FIRE_DONE:
    ; Reset fire delay based on weapon type
    ldaa WEAPON_TYPE
    beq NORMAL_DELAY
    cmpa #WEAPON_LASER
    beq FAST_DELAY
    ldaa #MAX_FIRE_DELAY
    bra SET_DELAY
NORMAL_DELAY:
    ldaa #MAX_FIRE_DELAY
    bra SET_DELAY
FAST_DELAY:
    ldaa #5            ; Laser fires faster
SET_DELAY:
    staa FIRE_DELAY
NO_FIRE:
    rts

; Create a new projectile (helper function)
CREATE_PROJECTILE:
    ; Check weapon limit
    ldaa WEAPON_COUNT
    cmpa #MAX_WEAPONS
    bhs CREATE_DONE
    ; Get projectile slot
    ldx #WEAPON_DATA
    ldab #WEAPON_SIZE
    mul
    jsr ADD_X
    ; Initialize projectile
    ldaa PLAYER_X     ; Start at player position
    staa 0,x
    ldaa PLAYER_XL
    staa 1,x
    ldaa PLAYER_Y
    staa 2,x
    ldaa PLAYER_YL
    staa 3,x
    ldaa PLAYER_DIR   ; Use player direction
    staa 4,x
    ldaa WEAPON_TYPE  ; Set weapon type
    staa 5,x
    ; Increment weapon count
    inc WEAPON_COUNT
CREATE_DONE:
    rts

; Update all active projectiles
UPDATE_WEAPONS:
    ldab WEAPON_COUNT
    beq WEAPONS_DONE  ; No weapons to update
    ldx #WEAPON_DATA
UPDATE_WEAPON_LOOP:
    ; Update position based on direction
    ldaa 4,x          ; Get direction
    beq MOVE_RIGHT
    ; Move left
    ldaa 0,x
    suba #PROJECTILE_SPEED
    staa 0,x
    bra MOVE_DONE
MOVE_RIGHT:
    ldaa 0,x
    adda #PROJECTILE_SPEED
    staa 0,x
MOVE_DONE:
    ; Check if off screen
    ldaa 0,x
    beq REMOVE_WEAPON
    cmpa #$FF
    beq REMOVE_WEAPON
    ; Next weapon
NEXT_WEAPON:
    ldaa #WEAPON_SIZE
    jsr ADD_X         ; X += WEAPON_SIZE
    decb
    bne UPDATE_WEAPON_LOOP
WEAPONS_DONE:
    rts

; Remove weapon (X points to weapon to remove)
REMOVE_WEAPON:
    ; Move last weapon to this slot
    ldaa WEAPON_COUNT
    deca
    beq LAST_WEAPON   ; Was last weapon
    ; Copy last weapon data
    ldab #WEAPON_SIZE
    pshs x            ; Save current position
    ldx #WEAPON_DATA
    jsr ADD_X         ; X += A * WEAPON_SIZE
    puls y            ; Y = destination
COPY_LOOP:
    ldaa 0,x
    staa 0,y
    inx
    iny
    decb
    bne COPY_LOOP
LAST_WEAPON:
    dec WEAPON_COUNT
    bra NEXT_WEAPON

; Draw all active projectiles
DRAW_WEAPONS:
    ldab WEAPON_COUNT
    beq DRAW_WEAPONS_DONE
    ldx #WEAPON_DATA
DRAW_WEAPON_LOOP:
    ; Check weapon type
    ldaa 5,x
    beq DRAW_NORMAL
    cmpa #WEAPON_SPREAD
    beq DRAW_NORMAL    ; Spread shots look like normal shots
    cmpa #WEAPON_LASER
    beq DRAW_LASER
    cmpa #WEAPON_SMART
    beq DRAW_SMART
    bra NEXT_WEAPON_DRAW

DRAW_NORMAL:
    ; Set up video address
    ldaa 0,x          ; Weapon X
    adda DRAW_BUFFER  ; Add buffer offset
    staa VADDR
    ; Draw normal projectile (2x2 pixel)
    ldaa #%11110000
    staa VDATA
    bra NEXT_WEAPON_DRAW

DRAW_LASER:
    ; Set up video address
    ldaa 0,x          ; Weapon X
    adda DRAW_BUFFER  ; Add buffer offset
    staa VADDR
    ; Draw laser beam (long rectangle)
    ldaa WEAPON_POWER ; Width based on power
    ldab #4
    mul              ; Length = power * 4
DRAW_LASER_LINE:
    ldaa #%11111111  ; Solid beam
    staa VDATA
    decb
    bne DRAW_LASER_LINE
    bra NEXT_WEAPON_DRAW

DRAW_SMART:
    ; Set up video address
    ldaa 0,x          ; Weapon X
    adda DRAW_BUFFER  ; Add buffer offset
    staa VADDR
    ; Draw smart bomb (pulsing circle)
    ldaa #%11111111
    staa VDATA
    ldaa #%10000001
    staa VDATA
    ldaa #%11111111
    staa VDATA

NEXT_WEAPON_DRAW:
    ldaa #WEAPON_SIZE
    jsr ADD_X         ; X += WEAPON_SIZE
    decb
    bne DRAW_WEAPON_LOOP
DRAW_WEAPONS_DONE:
    rts

; Check weapon collisions with enemies
CHECK_COLLISIONS:
    ; First check player-enemy collisions
    jsr CHECK_PLAYER_COLLISIONS
    ; Then check weapon-enemy collisions
    ldab WEAPON_COUNT
    beq CHECK_DONE
    ldx #WEAPON_DATA
CHECK_WEAPON_LOOP:
    pshs b,x          ; Save weapon counter and pointer
    jsr CHECK_WEAPON_HITS
    puls b,x          ; Restore weapon counter and pointer
    ldaa #WEAPON_SIZE
    jsr ADD_X         ; X += WEAPON_SIZE
    decb
    bne CHECK_WEAPON_LOOP
CHECK_DONE:
    rts

; Check if weapon at X hits any enemies
CHECK_WEAPON_HITS:
    ldab ENEMY_COUNT
    beq WEAPON_CHECK_DONE
    ldy #ENEMY_DATA
CHECK_ENEMY_LOOP:
    ; Check if enemy is already exploding
    ldaa 7,y
    bne NEXT_ENEMY
    ; Check X distance
    ldaa 0,x          ; Weapon X
    suba 0,y          ; Enemy X
    blt NEXT_ENEMY
    cmpa #SPRITE_WIDTH
    bgt NEXT_ENEMY
    ; Check Y distance
    ldaa 2,x          ; Weapon Y
    suba 2,y          ; Enemy Y
    blt NEXT_ENEMY
    cmpa #SPRITE_HEIGHT
    bgt NEXT_ENEMY
    ; Hit detected!
    ldaa #1
    staa 7,y          ; Set enemy to exploding
    ; Play hit sound
    ldaa #SOUND_HIT
    jsr PLAY_SOUND
    ; Remove weapon
    jsr REMOVE_WEAPON
    bra WEAPON_CHECK_DONE
NEXT_ENEMY:
    ldaa #ENEMY_SIZE
    leay a,y          ; Y += ENEMY_SIZE
    decb
    bne CHECK_ENEMY_LOOP
WEAPON_CHECK_DONE:
    rts

; Check player collisions with enemies
CHECK_PLAYER_COLLISIONS:
    ldab ENEMY_COUNT
    beq PLAYER_CHECK_DONE
    ldx #ENEMY_DATA
PLAYER_CHECK_LOOP:
    ; Check if enemy is already exploding
    ldaa 7,x
    bne NEXT_PLAYER_CHECK
    ; Check X distance
    ldaa 0,x          ; Enemy X
    suba PLAYER_X
    blt NEXT_PLAYER_CHECK
    cmpa #SPRITE_WIDTH
    bgt NEXT_PLAYER_CHECK
    ; Check Y distance
    ldaa 2,x          ; Enemy Y
    suba PLAYER_Y
    blt NEXT_PLAYER_CHECK
    cmpa #SPRITE_HEIGHT
    bgt NEXT_PLAYER_CHECK
    ; Collision detected!
    ldaa #1
    staa PLAYER_STATE ; Set player to exploding
    ; Play hit sound
    ldaa #SOUND_HIT
    jsr PLAY_SOUND
NEXT_PLAYER_CHECK:
    ldaa #ENEMY_SIZE
    jsr ADD_X         ; X += ENEMY_SIZE
    decb
    bne PLAYER_CHECK_LOOP
PLAYER_CHECK_DONE:
    rts

; Draw all active enemies
DRAW_ENEMIES:
    ldab ENEMY_COUNT
    beq DRAW_DONE     ; No enemies to draw
    ldx #ENEMY_DATA
DRAW_ENEMY_LOOP:
    ; Set up video address
    ldaa 0,x          ; Enemy X
    adda DRAW_BUFFER  ; Add buffer offset
    staa VADDR
    ; Draw enemy sprite
    pshs x            ; Save X
    ldx #ENEMY_SPRITE
    ldab #SPRITE_HEIGHT
DRAW_ENEMY_SPRITE:
    ldaa 0,x          ; Get sprite data
    staa VDATA        ; Draw one line
    inx               ; Next sprite line
    decb
    bne DRAW_ENEMY_SPRITE
    puls x            ; Restore X
    ; Next enemy
    ldaa #ENEMY_SIZE
    jsr ADD_X         ; X += ENEMY_SIZE
    ldab ENEMY_COUNT
    decb
    bne DRAW_ENEMY_LOOP
DRAW_DONE:
    rts

; Helper: Add A to X
ADD_X:
    psha
    tab
    abx
    pula
    rts

; Enemy sprite data (16x16 pixels)
ENEMY_SPRITE:
    fcb %01100110    ; Basic enemy shape
    fcb %01100110
    fcb %11111111
    fcb %11111111
    fcb %11111111
    fcb %01111110
    fcb %00111100
    fcb %00011000
    fcb %00011000
    fcb %00111100
    fcb %01111110
    fcb %11111111
    fcb %11111111
    fcb %11111111
    fcb %01100110
    fcb %01100110

; Interrupt handlers
NMI:    rti         ; Non-maskable interrupt
IRQ:    rti         ; Regular interrupt
SWI:    rti         ; Software interrupt

; ROM vectors
 org $FFFE
    fdb START       ; Reset vector 

; Initialize power-up system
INIT_POWERUPS:
    clr POWER_TYPE
    clr POWER_TIMER
    rts

; Update power-up system
UPDATE_POWERUPS:
    ldaa POWER_TYPE
    beq POWERUP_DONE
    ; Decrement timer
    ldaa POWER_TIMER
    beq POWERUP_EXPIRED
    deca
    staa POWER_TIMER
    bra POWERUP_DONE
POWERUP_EXPIRED:
    clr POWER_TYPE
    ; Reset to normal weapon
    clr WEAPON_TYPE
    ldaa #1
    staa WEAPON_POWER
POWERUP_DONE:
    rts

; Spawn power-up
SPAWN_POWERUP:
    ; Randomly choose power-up type (1-4)
    ldaa SPAWN_COUNT    ; Use spawn counter as random seed
    anda #$03          ; Mask to 0-3
    inca              ; Add 1 to get 1-4
    staa POWER_TYPE
    ; Set duration
    ldaa #POWER_DURATION
    staa POWER_TIMER
    ; Play sound
    ldaa #SOUND_POWERUP
    staa SOUND_DATA
    rts

; Check power-up collision with player
CHECK_POWERUP_COLLISION:
    ldaa POWER_TYPE
    beq POWERUP_CHECK_DONE
    ; Check X distance
    ldaa PLAYER_X
    suba #$80          ; Power-up X position
    blt POWERUP_CHECK_DONE
    cmpa #SPRITE_WIDTH
    bgt POWERUP_CHECK_DONE
    ; Check Y distance
    ldaa PLAYER_Y
    suba #$80          ; Power-up Y position
    blt POWERUP_CHECK_DONE
    cmpa #SPRITE_HEIGHT
    bgt POWERUP_CHECK_DONE
    ; Power-up collected!
    ldaa POWER_TYPE
    beq POWERUP_CHECK_DONE
    cmpa #POWER_LEVEL
    beq POWERUP_LEVEL
    staa WEAPON_TYPE   ; Set weapon type
    bra POWERUP_COLLECTED
POWERUP_LEVEL:
    ldaa WEAPON_POWER
    cmpa #3
    beq POWERUP_CHECK_DONE
    inca
    staa WEAPON_POWER
POWERUP_COLLECTED:
    clr POWER_TYPE
    ; Play sound
    ldaa #SOUND_POWERUP
    staa SOUND_DATA
POWERUP_CHECK_DONE:
    rts

; Draw power-up
DRAW_POWERUP:
    ldaa POWER_TYPE
    beq POWERUP_DRAW_DONE
    ; Set up video address
    ldaa #$80          ; Power-up X position
    adda DRAW_BUFFER
    staa VADDR
    ; Draw power-up sprite based on type
    ldaa POWER_TYPE
    cmpa #POWER_LEVEL
    beq DRAW_LEVEL
    cmpa #POWER_SPREAD
    beq DRAW_SPREAD
    cmpa #POWER_LASER
    beq DRAW_LASER
    cmpa #POWER_SMART
    beq DRAW_SMART
    bra POWERUP_DRAW_DONE

DRAW_LEVEL:
    ldaa #%11111111    ; Level up power-up sprite
    staa VDATA
    ldaa #%10000001
    staa VDATA
    ldaa #%11111111
    staa VDATA
    bra POWERUP_DRAW_DONE

DRAW_SPREAD:
    ldaa #%11111111    ; Spread shot power-up sprite
    staa VDATA
    ldaa #%11000011
    staa VDATA
    ldaa #%11111111
    staa VDATA
    bra POWERUP_DRAW_DONE

DRAW_LASER:
    ldaa #%11111111    ; Laser power-up sprite
    staa VDATA
    ldaa #%11100111
    staa VDATA
    ldaa #%11111111
    staa VDATA
    bra POWERUP_DRAW_DONE

DRAW_SMART:
    ldaa #%11111111    ; Smart bomb power-up sprite
    staa VDATA
    ldaa #%10111101
    staa VDATA
    ldaa #%11111111
    staa VDATA

POWERUP_DRAW_DONE:
    rts

; Update game state
UPDATE_GAME:
    ldaa GAME_STATE
    beq UPDATE_TITLE
    cmpa #STATE_PLAYING
    beq UPDATE_PLAYING
    cmpa #STATE_PAUSED
    beq UPDATE_PAUSED
    cmpa #STATE_GAMEOVER
    beq UPDATE_GAMEOVER
    rts

UPDATE_TITLE:
    ; Check for start button
    ldaa P1_BUTTONS
    bita #BTN_START
    beq TITLE_DONE
    ; Start game
    ldaa #STATE_PLAYING
    staa GAME_STATE
    jsr INIT_PLAYER
    jsr INIT_ENEMIES
    jsr INIT_WEAPONS
    jsr INIT_POWERUPS
TITLE_DONE:
    rts

UPDATE_PLAYING:
    ; Check for pause
    ldaa P1_BUTTONS
    bita #BTN_START
    beq PLAYING_DONE
    ldaa #STATE_PAUSED
    staa GAME_STATE
PLAYING_DONE:
    rts

UPDATE_PAUSED:
    ; Check for unpause
    ldaa P1_BUTTONS
    bita #BTN_START
    beq PAUSED_DONE
    ldaa #STATE_PLAYING
    staa GAME_STATE
PAUSED_DONE:
    rts

UPDATE_GAMEOVER:
    ; Check for restart
    ldaa P1_BUTTONS
    bita #BTN_START
    beq GAMEOVER_DONE
    jsr INIT_GAME
GAMEOVER_DONE:
    rts

; Draw game state
DRAW_GAME:
    ldaa GAME_STATE
    beq DRAW_TITLE
    cmpa #STATE_PLAYING
    beq DRAW_PLAYING
    cmpa #STATE_PAUSED
    beq DRAW_PAUSED
    cmpa #STATE_GAMEOVER
    beq DRAW_GAMEOVER
    rts

DRAW_TITLE:
    ; Draw title screen
    ldaa #$40        ; Center of screen
    staa VADDR
    ; Draw "DEFENDER"
    ldx #TITLE_TEXT
    ldab #8          ; Length of text
DRAW_TITLE_LOOP:
    ldaa 0,x
    staa VDATA
    inx
    decb
    bne DRAW_TITLE_LOOP
    ; Draw "PRESS START"
    ldaa #$60        ; Below title
    staa VADDR
    ldx #START_TEXT
    ldab #11         ; Length of text
DRAW_START_LOOP:
    ldaa 0,x
    staa VDATA
    inx
    decb
    bne DRAW_START_LOOP
    rts

DRAW_PLAYING:
    ; Draw HUD
    jsr DRAW_HUD
    ; Draw game objects
    jsr DRAW_PLAYER
    jsr DRAW_ENEMIES
    jsr DRAW_WEAPONS
    jsr DRAW_POWERUP
    rts

DRAW_PAUSED:
    jsr DRAW_PLAYING
    ; Draw "PAUSED"
    ldaa #$60        ; Center of screen
    staa VADDR
    ldx #PAUSE_TEXT
    ldab #6          ; Length of text
DRAW_PAUSE_LOOP:
    ldaa 0,x
    staa VDATA
    inx
    decb
    bne DRAW_PAUSE_LOOP
    rts

DRAW_GAMEOVER:
    ; Draw "GAME OVER"
    ldaa #$40        ; Center of screen
    staa VADDR
    ldx #GAMEOVER_TEXT
    ldab #9          ; Length of text
DRAW_GAMEOVER_LOOP:
    ldaa 0,x
    staa VDATA
    inx
    decb
    bne DRAW_GAMEOVER_LOOP
    ; Draw final score
    ldaa #$60        ; Below text
    staa VADDR
    jsr DRAW_SCORE
    rts

; Draw HUD (score, lives, level)
DRAW_HUD:
    ; Draw score
    ldaa #$00        ; Top-left corner
    staa VADDR
    jsr DRAW_SCORE
    ; Draw lives
    ldaa #$10        ; Top-right corner
    staa VADDR
    ldaa LIVES
    adda #$30        ; Convert to ASCII
    staa VDATA
    ; Draw level
    ldaa #$20        ; Top-center
    staa VADDR
    ldaa LEVEL
    adda #$30        ; Convert to ASCII
    staa VDATA
    rts

; Draw score value
DRAW_SCORE:
    ldx #SCORE
    ldab #4          ; 4 digits
DRAW_SCORE_LOOP:
    ldaa 0,x
    adda #$30        ; Convert to ASCII
    staa VDATA
    inx
    decb
    bne DRAW_SCORE_LOOP
    rts

; Text data
TITLE_TEXT:
    fcb "DEFENDER"
START_TEXT:
    fcb "PRESS START"
PAUSE_TEXT:
    fcb "PAUSED"
GAMEOVER_TEXT:
    fcb "GAME OVER"

; Enhanced visual effects
DRAW_EXPLOSION:
    ldaa FLASH_COUNT
    beq EXPLOSION_DONE
    ; Draw explosion animation
    ldaa #$80        ; Center of screen
    staa VADDR
    ldx #EXPLOSION_SPRITE
    ldab #SPRITE_HEIGHT
DRAW_EXPLOSION_LOOP:
    ldaa 0,x
    staa VDATA
    inx
    decb
    bne DRAW_EXPLOSION_LOOP
    dec FLASH_COUNT
EXPLOSION_DONE:
    rts

; Explosion sprite data (16x16 pixels)
EXPLOSION_SPRITE:
    fcb %00011000    ; Explosion shape
    fcb %00111100
    fcb %01111110
    fcb %11111111
    fcb %11111111
    fcb %11111111
    fcb %11111111
    fcb %11111111
    fcb %11111111
    fcb %11111111
    fcb %11111111
    fcb %11111111
    fcb %01111110
    fcb %00111100
    fcb %00011000
    fcb %00000000

; Update main game loop
MAIN_LOOP:
    ; Update game state
    jsr UPDATE_GAME
    
    ; Update game objects if playing
    ldaa GAME_STATE
    cmpa #STATE_PLAYING
    bne SKIP_UPDATES
    jsr UPDATE_PLAYER
    jsr UPDATE_ENEMIES
    jsr UPDATE_WEAPONS
    jsr UPDATE_POWERUPS
    jsr CHECK_COLLISIONS
    jsr CHECK_POWERUP_COLLISION
    jsr HANDLE_WEAPONS
    jsr SPAWN_ENEMIES
    ldaa SPAWN_COUNT
    anda #$3F
    beq SPAWN_POWERUP
SKIP_UPDATES:
    
    ; Clear screen
    jsr CLEAR_SCREEN
    
    ; Draw game state
    jsr DRAW_GAME
    
    ; Draw explosion if active
    jsr DRAW_EXPLOSION
    
    ; Flip buffers
    jsr FLIP_BUFFERS
    
    bra MAIN_LOOP   ; Loop forever 