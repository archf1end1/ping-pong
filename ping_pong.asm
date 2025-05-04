use16                                 ; use 16bit assembly for assebmling

org 0x7c00                            ; starts from 0x7c00 memory address because it is bootsector game
jmp start

;; Constants
VIDMEM equ 0xB800                     ; Memory address of text screen
ROWLEN equ 160                        ; 80 ROWS with 2 bytes each
PLAYERX equ 4                         ; Location of PLAYERX 
CPUX equ 154                          ; Location of CPUX
KEY_W equ 0x11
KEY_S equ 0x1f
KEY_C equ 0x2e
KEY_R equ 0x13
SCREENH equ 80
SCREENW equ 24
PADDLEHEIGHT equ 5
PLAYERBALLSTARTX equ 66
CPUBALLSTARTX equ 90
WINCOND equ 2
BALLSTARTY equ 7

;; Variables 
paddleColor: db 0xf0                    ; Color of back and forground
;;ballColor: dw 0x2000
playerY: dw 10                        ; Starting position of playery 10 rows down
cpuY: dw 10                           ; Starting position of cpuy 10 rows down
ballX: dw 64
ballY: dw 7
ballVelX: db -2
ballVelY: db 1
playerScore: db 0
cpuScore: db 0


start:
;; Set up the video mode
mov ax, 0x003
int 10h                               ; Call the interrupt 10h

;; Set up the memory address
mov ax, VIDMEM                        ; Text screen video memory resides at B800 
mov es, ax                              ; ES:DI --> B8000:00000  

;; game loop 
game_loop:
  
  ;; Clear the screen
  xor ax, ax                          ; Clear the AX register
  xor di, di                          ; Clear the DI register
  mov cx, 80*25                       ; Setting the size of windows
  rep stosw                           ; St

  ;; Draw straight line in middle of box
  mov ah, [paddleColor]                   ; Set the background and forground color
  mov di, 78                          ; Start at the middle of 80 characters 
  mov cx, 13                          ; 'Dashed line - only every other row'
  .draw_middle_line:
    stosw
    add di, 2*ROWLEN-2 
    loop .draw_middle_line            ; Loops CX n number of times 
  ;; Draw Player Paddle
  ;;draw_on_screen playerY, PLAYERX, ROWLEN

  imul di, [playerY], ROWLEN
  imul bx, [cpuY], ROWLEN
  mov cl, PADDLEHEIGHT
  .draw_paddle_line:
    mov [es:di+PLAYERX], ax
    mov [es:bx+CPUX], ax
    add di, ROWLEN
    add bx, ROWLEN
    loop .draw_paddle_line

  ;; Draw CPU Paddle

  ;; Draw Ball

  imul di, [ballY], ROWLEN
  add di, [ballX]
  mov word [es:di], 0x2020

  ;; Draw Scores

  ;; Draw player score
  mov di, ROWLEN+66
  mov bh, 0x0E
  mov bl, [playerScore]
  add bl, 0x30
  mov [es:di], bx

  ;; Draw cpu scores
  add di, 24
  mov bh, 0x0E
  mov bl, [cpuScore]
  add bl, 0x30
  mov [es:di], bx

  mov ah, 1
  int 0x16
  jz move_cpu_up

  cbw
  int 0x16

  cmp ah, KEY_W
  je w_pressed
  cmp ah, KEY_S
  je s_pressed
  cmp ah, KEY_R
  je r_pressed
  cmp ah, KEY_C
  je c_pressed

  w_pressed:
    dec word [playerY]
    jge move_cpu_up
    inc word [playerY]
    jmp move_cpu_up

  s_pressed:
    cmp word [playerY], SCREENW - PADDLEHEIGHT
    jg move_cpu_up
    inc word [playerY]
    jmp move_cpu_up

  r_pressed:
    int 0x19

  c_pressed:
    add byte [paddleColor], 0x10

  ;; move cpu
  move_cpu_up:
    mov bx, [cpuY]
    cmp bx, [ballY]
    jl move_cpu_down
    dec word [cpuY]
    dec word [cpuY]
    jge move_ball
    inc word [cpuY]
    jmp move_ball


  move_cpu_down:
    add bx, PADDLEHEIGHT
    cmp bx, [ballY]
    jg move_ball
    inc word [cpuY]
    cmp word [cpuY], 24
    jl move_ball
    dec word [cpuY]
    dec word [cpuY]

  move_ball:
    mov bl, [ballVelX]
    add [ballX], bl
    mov bl, [ballVelY]
    add [ballY], bl

  check_hit_top_or_bottom:
    mov cx, [ballY]
    jcxz reverse_ballY
    cmp cx, 24
    jne check_hit_player_paddle

  reverse_ballY:
    neg byte [ballVelY]

  check_hit_player_paddle:
    cmp word [ballX], PLAYERX+2
    jne check_hit_cpu_paddle
    mov bx, [playerY]
    cmp bx, [ballY]
    jg check_hit_cpu_paddle
    add bx, PADDLEHEIGHT
    cmp bx, [ballY]
    jl check_hit_cpu_paddle
    neg byte [ballVelX]
    jmp check_hit_left
    
  check_hit_cpu_paddle:
    cmp word [ballX], CPUX-2
    jne check_hit_left
    mov bx, [cpuY]
    cmp bx, [ballY]
    jg check_hit_left
    add bx, PADDLEHEIGHT
    cmp bx, [ballY]
    jl check_hit_left 
    neg byte [ballVelX]


  check_hit_left:
    cmp word [ballX], 0
    jg check_hit_right
    inc byte [cpuScore]
    mov word [ballX], CPUBALLSTARTX
    jmp reset_ball

  check_hit_right:
    cmp word [ballX], ROWLEN
    jl end_collison_check
    inc byte [playerScore]
    mov word [ballX], PLAYERBALLSTARTX
    
  reset_ball:
    mov word [ballY], BALLSTARTY
    cmp byte [cpuScore], WINCOND
    je game_over
    cmp byte [playerScore], WINCOND
    je game_over


    ;; Randomize the start position of ballX
;;    cbw
;;    int 0x1A
;;    mov ax, dx
;;    xor dx, dx
;;    mov cx, 10
;;    div cx                        ;; AX / CX , DX(DL) = remainder (0-9)
;;    shl dx, 1
;;    add bx, dx
;;    mov [ballX], bx
;;    mov word [ballY], BALLSTARTY

  end_collison_check:
  ;; Delay for sometime
  mov bx, [0x046c]
  inc bx
  inc bx
  .delay:
    cmp [0x046C], bx
    jl .delay

jmp game_loop

game_over:
cmp byte [playerScore], WINCOND
je game_won
jmp game_lost

game_won:
  mov dword [es:0000], 0x0F4F0F57
  mov dword [es:0004], 0x0F210F4E
  cli
  hlt

game_lost:
  mov dword [es:0000], 0x0F4F0F4C
  mov dword [es:0004], 0x0F450F53
  cli
  hlt

times 510-($-$$) db 0
dw 0xAA55
