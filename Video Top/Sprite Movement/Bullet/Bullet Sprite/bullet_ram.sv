`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/16/2024 10:47:19 PM
// Design Name: 
// Module Name: bullet_ram
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


module bullet_ram
#(parameter DATA_WIDTH = 12,//encoded colour depth
            ADDR_WIDTH = 6//2^6 addresses
)
(
    input logic clk,
    input logic we,
    input logic [ADDR_WIDTH - 1: 0] addr_r,
    input logic [ADDR_WIDTH - 1: 0] addr_w,
    input logic [DATA_WIDTH - 1: 0] din,
    output logic [DATA_WIDTH - 1: 0] dout
);

//Ram Declaration

logic [DATA_WIDTH - 1: 0] ram [0: 2**ADDR_WIDTH - 1];//first element describes the width
logic [DATA_WIDTH - 1: 0] data_reg;

initial
    $readmemh("bullet_bitmap.txt", ram);// read the binary data in the file and store/initialize the ram with it

always_ff @(posedge clk) 
begin
    if (we)
        ram[addr_w] <= din;//write
    data_reg <= ram[addr_r];//read
end

assign dout = data_reg;
endmodule
