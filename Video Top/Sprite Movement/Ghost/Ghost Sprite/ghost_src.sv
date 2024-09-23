`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/31/2024 06:48:41 PM
// Design Name: 
// Module Name: ghost_src
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


module ghost_src
#(parameter CD = 12,//colour depth
            ADDR = 10,//addr bits
            KEY_COLOR = 0//chroma key --> black
)
(
    input logic clk,
    input logic [10:0] x, y,//x and y coordinates from FC
    input logic [10:0] x0, y0,//origin of sprite
    input logic [3:0] ctrl,//control reg
    //pixel Output
    output logic [CD - 1: 0] sprite_rgb
);


//Localparams
localparam H_SIZE = 16;//sprite width
localparam V_SIZE = 16;//sprite depth

//Signal Declaration
logic [11: 0] x_relative, y_relative;//relative coordinates to sprite origin
logic in_region; //"pixel within sprite image" signal
logic [ADDR - 1: 0] addr_r;//read addr for RAM
logic [CD - 1: 0] full_rgb;// output of pixel RAM
logic [CD - 1: 0] out_rgb; // blender output
logic [CD - 1: 0] out_rgb_d1_reg;//1 clk delayed blender output
logic [CD - 1: 0] ghost_rgb; // the ghost body colour
logic [1:0] palette_code; //palette code, aka, the output of the RAM 

//Register control signals  
logic [1:0] sprite_orientation;//sprite sheet orientation (selector)
logic [1:0] gc_color_sel; //ghost body color select            
assign sprite_orientation = ctrl[1:0]; 
assign gc_color_sel = ctrl[3:2];


//Instantiate sprite RAM
ghost_ram #(.ADDR_WIDTH(ADDR), .DATA_WIDTH(2)) ram_unit 
(
    .clk(clk), 
    .we(0), //won't write to it
    .addr_w(), .din(),
    .addr_r(addr_r), .dout(palette_code)
);
assign addr_r = {sprite_orientation, y_relative[3:0], x_relative[3:0]};//RAM read addressing


//Ghost Color selector
always_comb 
begin
    case (gc_color_sel)
        2'b00:   ghost_rgb = 12'hf00;  // red 
        2'b01:   ghost_rgb = 12'hf8b;  // pink 
        2'b10:   ghost_rgb = 12'hfa0;  // orange
        default: ghost_rgb = 12'h0ff;  // cyan
    endcase    
end

//Palette encodings
always_comb
begin
    case (palette_code)
        2'b00:   full_rgb = 12'h000;   // chrome key
        2'b01:   full_rgb = 12'h111;   // dark gray 
        2'b10:   full_rgb = ghost_rgb; // ghost body color
        default: full_rgb = 12'hfff;   // white
    endcase
end


//Relative Coordinates
assign x_relative = $signed({1'b0, x}) - $signed({1'b0, x0});
assign y_relative = $signed({1'b0, y}) - $signed({1'b0, y0});

//In-Region Circuit
assign in_region = (0 <= x_relative) && (x_relative < H_SIZE) && (0 <= y_relative) && (y_relative < V_SIZE);
assign out_rgb = (in_region) ? (full_rgb) : (KEY_COLOR);// If in region, display RAM pixel, otherwise chroma-key.


//1 Cycle Delay
always_ff @(posedge clk) 
    out_rgb_d1_reg <= out_rgb;
//Output Logic
assign sprite_rgb = out_rgb_d1_reg;
endmodule
