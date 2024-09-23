`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/16/2024 10:47:37 PM
// Design Name: 
// Module Name: bullet_src
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


module bullet_src
#(parameter CD = 12,//colour depth
            ADDR = 6,//addr bits
            KEY_COLOR = 0//chroma key --> black
)
(
    input logic clk,
    input logic [10:0] x, y,//x and y coordinates from FC
    input logic [10:0] x0, y0,//origin of sprite
    //pixel Output
    output logic [CD - 1: 0] sprite_rgb
);


//Localparams
localparam H_SIZE = 8;//sprite width
localparam V_SIZE = 8;//sprite depth

//Signal Declaration
logic [11: 0] x_relative, y_relative;//relative coordinates to sprite origin
logic in_region; //"pixel within sprite image" signal
logic [ADDR - 1: 0] addr_r;//read addr for RAM
logic [CD - 1: 0] out_rgb; // blender output
logic [CD - 1: 0] output_delay_reg_1;//1 clk delayed blender output
logic [CD - 1: 0] ram_output; //The output of the RAM 


//Instantiate sprite RAM
bullet_ram #(.ADDR_WIDTH(ADDR), .DATA_WIDTH(CD)) ram_unit 
(
    .clk(clk), 
    .we(0), //won't write to it
    .addr_w(), .din(),
    .addr_r(addr_r), .dout(ram_output)
);
assign addr_r = {y_relative[2:0], x_relative[2:0]};//RAM read addressing


//Relative Coordinates
assign x_relative = $signed({1'b0, x}) - $signed({1'b0, x0});
assign y_relative = $signed({1'b0, y}) - $signed({1'b0, y0});

//In-Region Circuit
assign in_region = (0 <= x_relative) && (x_relative < H_SIZE) && (0 <= y_relative) && (y_relative < V_SIZE);
assign out_rgb = (in_region) ? (ram_output) : (KEY_COLOR);// If in region, display RAM pixel, otherwise chroma-key.


//1 Cycle Delay
always_ff @(posedge clk) 
    output_delay_reg_1 <= out_rgb;
//Output Logic
assign sprite_rgb = output_delay_reg_1;
endmodule
