# Ghost Shooter FPGA Game

A 2-player shooter game implemented on the **Artix-7 FPGA (Nexys A7-100T)**. The game allows two players to control their ghost characters using joysticks, with the ability to move and rotate in real-time while *shooting bullets at each other. The game is rendered on a VGA display with a resolution of 640x480.

**Shooting Algorithm yet to be implemented*


---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Hardware Requirements](#hardware-requirements)
3. [Xilinx IPs Used](#xilinx-ips-used)
4. [Game Features](#game-features)
5. [Project Structure](#project-structure)
6. [Testing, Debugging, and Progress](#testing-debugging-and-progress)
7. [Usage Instructions](#usage-instructions)
8. [How to Customize](#how-to-customize)

---

## Project Overview

This project demonstrates a 2-player shooting game designed in **SystemVerilog** for an FPGA. The players control sprites that move and rotate based on **XADC** inputs from two joysticks, with shooting mechanics integrated using on-board buttons. The game is displayed on a VGA monitor, with synchronized graphics.

---

## Hardware Requirements

- **FPGA Board**: Nexys A7-100T
- **Joysticks**: 2 Analog Joysticks with built-in buttons, interfaced via the **XADC** pins
- **VGA Monitor and Cable**: For displaying game graphics
---

## Xilinx IPs Used

1. **XADC (Xilinx Analog-to-Digital Converter)**  
   Used to read analog signals from the two joysticks. The X and Y axes from each joystick control the movement of the players' sprites on the VGA screen.

2. **Dual-Clock BRAM FIFO**  
   Used for the Line Buffer to allow synchronization between system and VGA clock domains.

3. **Clock Management Circuit**  
   Used to generate more accurate and robust clocks for the system and the VGA.

---

## Game Features

- **Joystick Controls**: 
  - Each player moves their ghost using the X and Y inputs from an analog joystick.
  
- **Sprite Rotation**: 
  - Players can rotate their sprite 90 degrees clockwise by pressing down on the joystick (button). 
  - Each sprite has four orientations with corresponding images (sprite sheet).

- **Shooting Mechanism - Still in Progress**: 
  - Players shoot bullets using the onboard buttons.
  - Bullets move in the direction of the player's current orientation and vanish upon reaching the screen boundary or hitting the opponent.

- **Collision Detection - Still in Progress**: 
  - Bullet collision detection is implemented to determine if the opponent is hit.
  
- **VGA Output - Still in Progress**: 
  - The game is rendered on a VGA display with a 640x480 resolution.
  - Final score displayed on-screen using an OSD core at the end of the game.
  - Optional live score updates on the seven-segment display.

---

## Project Structure

```
To be Updates
```

---

## Testing, Debugging, and Progress

### Testing Joystick Inputs

1. **XADC <-> Joystick Calibration**:  
   Ensure that the XADC inputs are correctly calibrated and operates in unipolar mode (0.0V -> 1.0V input range).
   Use voltage dividers and current-limiting resistors to power joysticks and connect them to the XADC PMOD pins.
   
3. **Joystick Range**:  
   Confirm that the joystick movements provide valid 12-bit values for both X and Y channels. This range should map appropriately to the game coordinates on the screen.

4. **Signal Debugging**:  
   Use Vivado’s Integrated Logic Analyzer (ILA) to capture the XADC signals and verify their correctness. ILA cores can be inserted into the design to monitor real-time joystick input data during simulation or on the FPGA.

### VGA Output Testing

1. **VGA Sync**:  
   Verify the synchronization signals (HSYNC, VSYNC) using an oscilloscope to ensure correct timing for the 640x480 VGA resolution.
   
2. **Display Issues**:  
   If there are display glitches or misalignment, check the pixel clock and frame counter. Also, ensure that the 25 MHz clock (derived from the 100 MHz system clock) is correctly configured (refer to clock management circuit).

3. **Sprite Rendering**:  
   Confirm that sprites appear in the correct positions by simulating movement logic and VGA outputs.

### Progress 

- 

---

## Usage Instructions

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/S-Javaid17/Ghost_Shooter
   cd Ghost_Shooter
   ```

**To Be Updated**

---

## How to Customize

1. **Change Game Mechanics**:  
   Modify `___.sv` to adjust bullet speed, sprite size, or shooting frequency.

2. **Change the Images**:  
   You can add new images by changing the respective sprite RAMs and their top-files to adjust dimensions.
      Keep sprite dimensions to powers of 2, for easy addressing.

4. **Modify VGA Resolution**:  
   The VGA output can be configured for different resolutions by adjusting the timing parameters in the VGA controller.
      Modify the clock management circuit's outputs accordingly
