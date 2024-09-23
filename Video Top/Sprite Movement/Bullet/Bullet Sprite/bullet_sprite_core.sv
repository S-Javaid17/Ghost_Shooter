`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/17/2024 12:04:29 PM
// Design Name: 
// Module Name: bullet_sprite_core
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


module bullet_sprite_core
#(parameter KEY_COLOR = 0)
(
    input logic clk,
    input logic [10:0] bullet_x, bullet_y, // bullet position
    input logic [10:0] x, y, // frame counter coordinates
    input logic bullet_active,     
    output logic [11:0] so_rgb
);

logic [11:0] bullet_rgb; // bullet color output

    // Instantiate bullet sprite generation (reusing bullet_src)
    bullet_src bullet_sprite (
        .clk(clk),
        .x(x), .y(y), // Frame counter coordinates
        .x0(bullet_x), .y0(bullet_y), // Bullet origin coordinates
        .sprite_rgb(bullet_rgb) // Bullet output color
    );

//Output logic
assign so_rgb = (bullet_active) ? bullet_rgb : KEY_COLOR;
endmodule
