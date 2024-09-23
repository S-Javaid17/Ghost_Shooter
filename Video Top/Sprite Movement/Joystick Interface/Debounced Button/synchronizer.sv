`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/10/2024 09:30:41 AM
// Design Name: 
// Module Name: synchronizer
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


module synchronizer
#(parameter STAGES = 2)//number of FFs
    (
        input clk, reset,
        input D,
        output Q
    );
    
    reg [STAGES - 1: 0] Q_reg;//there is no next state logic
    always @(posedge clk, posedge reset)
    begin
        if(reset)
            Q_reg <= 'b0;
        else
            Q_reg <= {D, Q_reg[STAGES - 1: 1]};//right shift register basically
    end
    
    assign Q = Q_reg[0];//the LSB of the shift register (the one with D shifted in), as such, stage 0 or thee first FF will be the output
endmodule
