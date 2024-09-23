`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/06/2024 03:06:07 AM
// Design Name: 
// Module Name: timer_parameter
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

//  [FINAL_VALUE (inclusive)]*[10 ns --->clk period of board] = desired duration length for timer
//same as mod counter, but we don't care about its contents, just when its done counting
module timer_parameter
#(parameter FINAL_VALUE = 255)//counter value
    (
    input clk,
    input reset_n,
    input enable,
    //the ticker will be high for 1 clk cycle to indicate timer
    output done //the ticker which tells us counter is done, aka timer length reached
    );
 
    localparam BITS = $clog2(FINAL_VALUE);//number of bits aka t-FFs
    reg [BITS - 1: 0] Q_reg, Q_next;
                                              // Register Logic
    always@(posedge clk, negedge reset_n)
    begin
            if (~reset_n)
                Q_reg <= 'b0;
            else if (enable)
                Q_reg <= Q_next;    
            else
                Q_reg <= Q_reg; 
    end
    
                                                //Next State Logic
    assign done = Q_reg == FINAL_VALUE;
    always @(*)
        Q_next = done? 'b0 : Q_reg + 1;// reset to 0 if done, otherwise add one
    
endmodule   
