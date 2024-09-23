`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/31/2024 06:39:52 PM
// Design Name: 
// Module Name: vga_sprite_ghost_core
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


module vga_sprite_ghost_core
#(
    parameter CD = 12,       // color depth
    parameter ADDR_WIDTH = 10,
    parameter KEY_COLOR = 0
)
(
    input logic clk, 
    input logic reset,
    // frame counter
    input logic [10:0] x, y,
    input logic [10:0] analog_x, analog_y,
    //Selectors
    input logic [1:0] sprite_orientation,// to joystick button counter output
    input logic [1:0] colour_select,//to switches
    // stream interface
    input logic [11:0] si_rgb,
    output logic [11:0] so_rgb
);

    // Declaration
    logic [CD-1:0] sprite_rgb, chrom_rgb;
    logic [10:0] x0_reg, y0_reg;

    logic [3:0] ctrl_reg;
    assign ctrl_reg = {colour_select, sprite_orientation};

    // Instantiate sprite generator
    ghost_src #(.CD(CD), .KEY_COLOR(KEY_COLOR)) ghost_src_unit (
        .clk(clk), 
        .x(x), 
        .y(y), 
        .x0(x0_reg), 
        .y0(y0_reg),
        .ctrl(ctrl_reg), 
        .sprite_rgb(sprite_rgb)
    );

    // Register
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            x0_reg <= 0;
            y0_reg <= 0;
        end   
        else begin
            x0_reg <= analog_x;
            y0_reg <= analog_y;
        end      
    end

    // Chrome-key blending and multiplexing
    assign chrom_rgb = (sprite_rgb != KEY_COLOR) ? sprite_rgb : si_rgb;
    assign so_rgb = chrom_rgb;

endmodule
   