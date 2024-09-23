`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/05/2024 08:48:37 AM
// Design Name: 
// Module Name: udl_counter
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

//loads in parallel as well
module udl_counter
#(parameter BITS = 4)    
    (
        input clk,
        input reset,
        input load,
        input enable, // If low, hold on to value
        input up,// If low, count down
        input [BITS - 1: 0] D,//number to be loaded
        output [BITS - 1: 0] Q
    );
    
    reg [BITS - 1: 0] Q_reg, Q_next;
       
                                                         //register logic  
                                                         
    always@(posedge clk, posedge reset)
    begin
            if (reset)
                Q_reg <= 'b0;
            else if (enable)
                Q_reg <= Q_next;
            else   
                Q_reg <= Q_reg;
    end
    
                                                        //next state logic
                                                        
    always @(*)//verilog fills it in for you
    begin
    Q_next = Q_reg;//default
        casex({load, up})// concatenate to turn it into a 2 bit selector, functionally, if load ==1, we don't care about up
           2'b00: Q_next = Q_reg - 1;
           2'b01: Q_next = Q_reg + 1;
           2'b1x: Q_next = D;
           default: Q_next = Q_reg;
        endcase
    end        
    
                                                        //output logic
                                                        
    assign Q = Q_reg;        
endmodule
