# Ping Pong Game (FASM Assembly)

This is a classic Ping Pong game implemented entirely in 16-bit FASM (Flat Assembler) for the x86 architecture. It's designed to run as a boot sector game, meaning it can be written directly to a floppy disk or a virtual disk image and booted from.

## Features

* **Boot Sector Game:** Designed to run directly from the boot sector, providing a low-level, self-contained experience.
* **Text Mode Graphics:** Utilizes BIOS interrupt `0x10` (video services) to draw paddles, a ball, and scores in text mode.
* **Player Control:** Player 1 (left paddle) is controlled using 'W' (up) and 'S' (down) keys.
* **Basic CPU AI:** The right paddle (CPU) attempts to track and follow the ball's vertical position.
* **Ball Physics:** Simple collision detection with paddles and screen boundaries (top/bottom).
* **Scoring System:** Tracks scores for both player and CPU. The first to reach a score of 2 wins.
* **Game Over Screen:** Displays "WON!" or "LOST!" upon game conclusion.
* **Paddle Color Change:** Pressing 'C' changes the player paddle's background color.
* **Reboot Option:** Pressing 'R' triggers a system reboot.

## Prerequisites

* **FASM (Flat Assembler):** You need FASM installed on your system to assemble the code. You can download it from [http://flatassembler.net/](http://flatassembler.net/).
* **Emulator/Virtual Machine:** To run this boot sector game, you'll need a virtual machine (like QEMU, VirtualBox, or VMware) or a physical machine capable of booting from a raw disk image.
* **Disk Image Creator:** A utility to write the assembled binary to a floppy or hard disk image (e.g., `dd` on Linux/macOS, or specific tools for Windows).

## How to Play

1.  **Save the code:** Save the provided assembly code into a file named `pong.asm`.

2.  **Assemble the code:** Open your terminal or command prompt and navigate to the directory where you saved `pong.asm`. Then, use FASM to assemble it:

    ```bash
    fasm pong.asm -o pong.img
    ```
    This command will assemble `pong.asm` and output a raw binary file named `pong.img`. This `pong.img` file is your boot sector image.

3.  **Run in an emulator (Recommended):**
    * **QEMU:** The easiest way to test is with QEMU:
        ```bash
        qemu-system-i386 -fda pong.img
        ```
        (If `qemu-system-i386` doesn't work, try `qemu-system-x86_64` or `qemu-system-i386w` depending on your QEMU installation.)

    * **VirtualBox/VMware:** Create a new virtual machine, and attach `pong.img` as a floppy disk image. Configure the VM to boot from the floppy drive.

4.  **Controls:**
    * **W:** Move Player 1 paddle up.
    * **S:** Move Player 1 paddle down.
    * **C:** Change Player 1 paddle color.
    * **R:** Reboot the system (useful for restarting the game).

## Game Mechanics

* The game is played on an 80x25 character screen.
* The player controls the left paddle, and the CPU controls the right paddle.
* The ball bounces off the top and bottom walls, and off the paddles.
* If the ball goes past a paddle, the opposing player scores a point.
* The game ends when either the player or the CPU reaches a score of 2.

## Code Structure Overview

* **`use16` and `org 0x7c00`:** Specifies 16-bit assembly and sets the origin address for boot sector execution.
* **Constants:** Defines memory addresses, screen dimensions, paddle heights, key codes, and starting positions.
* **Variables:** Stores game state such as paddle Y positions, ball X/Y coordinates, ball velocities, and scores.
* **`start` Routine:**
    * Sets the video mode to 80x25 text mode (`mov ax, 0x003; int 10h`).
    * Sets up `ES` register to point to video memory (`0xB800`).
* **`game_loop`:** The main game loop, which continuously:
    * Clears the screen.
    * Draws the middle dashed line.
    * Draws the player and CPU paddles.
    * Draws the ball.
    * Draws the current scores.
    * **Input Handling:** Checks for keyboard input (`int 0x16`) and updates the player paddle's position based on 'W' or 'S' keys. Handles 'C' for color change and 'R' for reboot.
    * **CPU AI:** Adjusts the CPU paddle's `cpuY` to follow the ball's `ballY`.
    * **Ball Movement:** Updates `ballX` and `ballY` based on `ballVelX` and `ballVelY`.
    * **Collision Detection:**
        * Checks for collisions with the top and bottom screen boundaries.
        * Checks for collisions with the player's paddle.
        * Checks for collisions with the CPU's paddle.
        * If a collision occurs, `ballVelX` or `ballVelY` is negated to reverse direction.
    * **Scoring:** If the ball passes a paddle, the opposing player's score is incremented.
    * **Game Over Check:** Checks if either player's score has reached `WINCOND` (2).
    * **Ball Reset:** If a point is scored, the ball's position is reset.
    * **Delay:** Includes a simple delay loop to control game speed.
* **`game_over`:** Jumps to `game_won` or `game_lost` based on scores.
* **`game_won` / `game_lost`:** Displays a "WON!" or "LOST!" message on the screen, disables interrupts (`cli`), and halts the CPU (`hlt`).
* **Boot Sector Signature:** `times 510-($-$$) db 0` fills the remaining bytes with zeros, and `dw 0xAA55` adds the boot sector signature at the end.

## Important Notes

* **16-bit Real Mode:** This game runs in 16-bit real mode, which is the environment available to boot sectors.
* **No Sound:** This version does not include any sound effects.
* **Basic AI:** The CPU AI is very simple and predictable.
* **Direct Hardware Access:** The game directly accesses video memory (`0xB800`) for drawing, which is typical for boot sector programs.
* **No Operating System:** This code runs without an operating system.
* **Debugging:** Debugging boot sector assembly can be challenging. Emulators like QEMU often provide debugging features.
