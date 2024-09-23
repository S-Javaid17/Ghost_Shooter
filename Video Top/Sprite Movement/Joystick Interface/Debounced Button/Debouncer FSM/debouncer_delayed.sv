`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/09/2024 12:23:27 PM
// Design Name: 
// Module Name: debouncer_delayed
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

//This one actually has a timer attached to the debouncer, and we can control the time
module debouncer_delayed(
    input clk,
    input reset,
    input noisy,
    output debounced
    );
    
    wire timer_done, timer_reset;
    
    debounce_delayed_fsm FSM0 
    (
        .clk(clk),
        .reset(reset),
        .noisy(noisy),
        .timer_done(timer_done),
        .timer_reset(timer_reset),
        .debounced(debounced)
    );
    
    timer_parameter #(.FINAL_VALUE(1_999_999)) T0 //a 20ms timer, (0->1,999,999 is 2 million counts, multiplied by a 10ns system clock)
    (
        .clk(clk),
        .reset(timer_reset),//because timer_reset is a high signal, while reset_n is low enable
        .enable(~timer_reset),//basically disable if the timer_reset is high, aka it says to reset the 20ms timer
        .done(timer_done)//tells us 20ms has passsed
    );
endmodule
