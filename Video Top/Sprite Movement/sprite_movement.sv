`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/15/2024 09:37:56 PM
// Design Name: 
// Module Name: sprite_movement
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sprite_movement
(
    input logic clk, reset,
    //Sprite

    // frame counter
    input logic [10:0] x, y,
    input logic [1:0] colour_select_r,//to switches
    input logic [1:0] colour_select_l,//to switches
    // stream interface
    input logic [11:0] si_rgb,
    output logic [11:0] so_rgb,

    //Joystick
    input  logic [3:0] adc_p,//adc_p0 --> vaux3, adc_p1 --> vaux10, adc_p2 --> vaux2, adc_p3 --> vaux11
    input  logic [3:0] adc_n,
    input logic [1:0] button_j,//2 buttons from joystick, 0-->R, 1-->L
    input logic [1:0] button_b//two buttons on board for shooting
);

    //Selectors
logic [10:0] scaled_x1;//vaux3 output
logic [10:0] scaled_y1;//vaux10 output
logic [10:0] scaled_x2;//vaux2 output
logic [10:0] scaled_y2;//vaux11 output

logic [1:0] r_db_button_j;//2 bit wide output from counter
logic [1:0] l_db_button_j;//^ output from counter

logic r_db_button_b;//debounced shoot button
logic l_db_button_b;//^


logic [11:0] ghost2ghost; //output of one sprite to input of the other
logic [11:0] ghost2bullet; 
logic [11:0] bullet2bullet; 

joystick_interface u_joystick_interface (
    .clk(clk),               // Clock input
    .reset(reset),           // Reset input

    // Joystick ADC inputs
    .adc_p(adc_p),           // ADC positive inputs (4 bits)
    .adc_n(adc_n),           // ADC negative inputs (4 bits)
    
    // Scaled output
    .scaled_x1(scaled_x1),   // Scaled X1 output (11 bits)
    .scaled_y1(scaled_y1),   // Scaled Y1 output (11 bits)
    .scaled_x2(scaled_x2),   // Scaled X2 output (11 bits)
    .scaled_y2(scaled_y2),   // Scaled Y2 output (11 bits)

    // Joystick button inputs
    .button_j(button_j),     // Joystick button inputs (2 bits)
    .r_db_button_j(r_db_button_j), // Debounced button J (2 bits)
    .l_db_button_j(l_db_button_j), // Debounced button J (2 bits)
    
    // On-board button inputs
    .button_b(button_b),     // On-board button inputs (2 bits)
    .r_db_button_b(r_db_button_b), // Debounced button B (1 bits)
    .l_db_button_b(l_db_button_b)  // Debounced button B (1 bits)
);




vga_sprite_ghost_core #(
    .CD(12),                 // Color depth parameter
    .ADDR_WIDTH(10),         // Address width parameter
    .KEY_COLOR(0)            // Key color parameter
) u_vga_sprite_ghost_core1 
(
    .clk(clk),               // Clock input
    .reset(reset),           // Reset input
    
    // Frame counter inputs
    .x(x),                   // X-coordinate (11 bits)
    .y(y),                   // Y-coordinate (11 bits)
    .analog_x(scaled_x1),   // Analog X input (11 bits)
    .analog_y(scaled_y1),   // Analog Y input (11 bits)
    
    // Selectors
    .sprite_orientation(r_db_button_j), // Sprite orientation (2 bits)
    .colour_select(colour_select_r),           // Color select (2 bits)
    
    // Stream interface
    .si_rgb(si_rgb),           // Input RGB stream (12 bits)
    .so_rgb(ghost2ghost)            // Output RGB stream (12 bits)
);






vga_sprite_ghost_core #(
    .CD(12),                 // Color depth parameter
    .ADDR_WIDTH(10),         // Address width parameter
    .KEY_COLOR(0)            // Key color parameter
) u_vga_sprite_ghost_core2 
(
    .clk(clk),               // Clock input
    .reset(reset),           // Reset input
    
    // Frame counter inputs
    .x(x),                   // X-coordinate (11 bits)
    .y(y),                   // Y-coordinate (11 bits)
    .analog_x(scaled_x2),   // Analog X input (11 bits)
    .analog_y(scaled_y2),   // Analog Y input (11 bits)
    
    // Selectors
    .sprite_orientation(l_db_button_j), // Sprite orientation (2 bits)
    .colour_select(colour_select_l),           // Color select (2 bits)
    
    // Stream interface
    .si_rgb(ghost2ghost),           // Input RGB stream (12 bits)
    .so_rgb(ghost2bullet)            // Output RGB stream (12 bits)
);



// Instantiate bullet_top module 1
bullet_top #(.KEY_COLOR(0),.ADDR_WIDTH(8), .DATA_WIDTH(24)) bullet1//right
(
    .clk(clk), // Clock signal
    .reset(reset),  // Reset signal
    .fire(r_db_button_b),       // Fire button signal (from board button)
    .orientation(r_db_button_j),// Sprite direction (joystick button input)
    .sprite_x(scaled_x1),   // X coordinate of the character sprite
    .sprite_y(scaled_y1),   // Y coordinate of the character sprite
    .opponent_x(scaled_x2), // X coordinate of the opponent sprite
    .opponent_y(scaled_y2), // Y coordinate of the opponent sprite
    .x(x),// Frame counter X position
    .y(y), // Frame counter Y position
    .si_rgb(ghost2bullet),
    .so_rgb(bullet2bullet) // VGA output signal (12-bit RGB)
);



// Instantiate bullet_top module 2
// Instantiate bullet_top module 1
bullet_top #(.KEY_COLOR(0),.ADDR_WIDTH(8), .DATA_WIDTH(24)) bullet2//left
(
    .clk(clk), // Clock signal
    .reset(reset),  // Reset signal
    .fire(l_db_button_b),       // Fire button signal (from board button)
    .orientation(l_db_button_j),// Sprite direction (joystick button input)
    .sprite_x(scaled_x2),   // X coordinate of the character sprite
    .sprite_y(scaled_y2),   // Y coordinate of the character sprite
    .opponent_x(scaled_x1), // X coordinate of the opponent sprite
    .opponent_y(scaled_y1), // Y coordinate of the opponent sprite
    .x(x),// Frame counter X position
    .y(y), // Frame counter Y position
    .si_rgb(bullet2bullet),
    .so_rgb(so_rgb) // VGA output signal (12-bit RGB)
);
endmodule


