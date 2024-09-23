`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/09/2024 04:47:35 PM
// Design Name: 
// Module Name: button
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

//Edge detector with debouncer and synchronizer
//make sure to double check parameter vs localparam,  stage numbers in a fsm should be parameter
module button(
    input clk, reset,
    input noisy,
    output debounced,
    output p_edge, n_edge, _edge
    );
    
    synchronizer #(.STAGES(2))SYNCH0(
        .clk(clk),
        .reset(reset),
        .D(noisy),
        .Q(synch_noisy)
    );
    
    debouncer_delayed DD0(
        .clk(clk),
        .reset(reset),
        .noisy(synch_noisy),
        .debounced(debounced)
    );
    
    edge_detector ED0(
        .clk(clk),
        .reset(reset),
        .level(debounced),
        .p_edge(p_edge),
        .n_edge(n_edge),
        ._edge(_edge)
    );
    
endmodule