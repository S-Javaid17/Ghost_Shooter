`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/09/2024 12:01:23 PM
// Design Name: 
// Module Name: debounce_delayed_fsm
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


module debounce_delayed_fsm(
    input clk,
    input reset,
    input noisy,// (uncleaned) button signal
    input timer_done, //indicates 20ms, for us, or any other time
    output timer_reset,//a reset signal from fsm to timer
    output debounced//indicates debounceed button signal
    );
                                                            //state register logic
    
    reg [1:0] state_reg, state_next ; //two state registers, 2^n (moore) states  
    parameter s0 = 0, s1 = 1, s2 = 2, s3 = 3;//the different number states are a signed a [binary] digit (just written in decimal)
    
    always@ (posedge clk, posedge reset)
    begin
            if (reset)
                state_reg <= 0;//go to state 0 if reset is asserted
            else
                state_reg <= state_next;
    end                                            
                                                            //next state logic
    //here we describe the state diagram
    always @(*)
    begin
        state_next = state_reg;//default
        case(state_reg)
            s0: if (~noisy)
                    state_next = s0;
                else if (noisy)
                    state_next = s1;
            s1: if (~noisy)
                    state_next = s0;
                else if (noisy & ~timer_done)
                    state_next = s1;
                else if (noisy & timer_done)
                    state_next = s2;
            s2: if (~noisy)
                    state_next = s3;
                else if (noisy)
                    state_next = s2;
            s3: if (noisy)
                    state_next = s2;
                else if (~noisy & ~timer_done)
                    state_next = s3;
                else if (~noisy & timer_done)
                    state_next = s0;
            default: state_next = s0;                                            
        endcase
    end                                                    
                                                            //output logic
    assign debounced = (state_reg == s2) | (state_reg == s3);// if in state 2 or 3, the input is debounced
    assign timer_reset = (state_reg == s0) | (state_reg == s2);//indicates to reset timer if in state 0 or 2                                           
endmodule