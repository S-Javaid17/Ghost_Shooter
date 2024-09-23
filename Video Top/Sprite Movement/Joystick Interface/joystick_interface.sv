`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/15/2024 04:03:33 PM
// Design Name: 
// Module Name: joystick_interface
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


module joystick_interface
(
    input logic clk, reset,

    //Joystick
    input  logic [3:0] adc_p,//adc_p0 --> vaux3, adc_p1 --> vaux10, adc_p2 --> vaux2, adc_p3 --> vaux11
    input  logic [3:0] adc_n,
    output logic [10:0] scaled_x1,//vaux3 output
    output logic [10:0] scaled_y1,//vaux10 output
    output logic [10:0] scaled_x2,//vaux2 output
    output logic [10:0] scaled_y2,//vaux11 output

    input logic [1:0] button_j,//2 buttons from joystick, 0-->R, 1-->L
    output logic [1:0] r_db_button_j,//2 bit wide output from counter
    output logic [1:0] l_db_button_j,//^ output from counter
    
    //On Board
    input logic [1:0] button_b, //2 buttons on board, 0-->R, 1-->L
    output logic r_db_button_b,//1 bit output from shooting counter
    output logic l_db_button_b//1 bit output from shooting counter

);

// Internal Signals
logic [11:0] adc0_out, adc1_out, adc2_out, adc3_out;
logic [11:0] shifted_x1_stage1, shifted_x1_stage2;
logic [11:0] shifted_x2_stage1, shifted_x2_stage2;
logic [11:0] shifted_y1_stage1, shifted_y1_stage2;
logic [11:0] shifted_y2_stage1, shifted_y2_stage2;
logic [20:0] shifted_x1, shifted_y1, shifted_x2, shifted_y2;

//Joystick Button Signals
logic [1:0] j_debounced_tick;//debounced button output
logic [1:0] j_Q_debounced [1:0];//counts from 0 to 3, 2 bit counter output

//On-Board Button Signals
logic [1:0] b_debounced_tick;//debounced button output
//Debouncer and Counter for Joystick

genvar i;
generate
for (i = 0; i < 2; i = i + 1) begin : Joystick_button
    button DEBOUNCED_BUTTON 
    (
        .clk(clk),
        .reset(reset),
        .noisy(button_j[i]),
        .debounced(),
        .p_edge(j_debounced_tick[i]),//really all I need in the final implementation
        .n_edge(),
        ._edge()
    );

    udl_counter #(.BITS(2)) DEBOUNCED_BUTTON_COUNTER 
    (
            .clk(clk),
            .reset(reset),
            .enable(j_debounced_tick[i]),
            .up(1'b1),
            .load(),
            .D(),
            .Q(j_Q_debounced[i])
    );
end
endgenerate
assign r_db_button_j = j_Q_debounced[0];
assign l_db_button_j = j_Q_debounced[1];



//Debouncer and Counter on Board (Shooting)

genvar j;
generate
for (j = 0; j < 2; j = j + 1) begin : OnBoard_Button
    button DEBOUNCED_BUTTON 
    (
        .clk(clk),
        .reset(reset),
        .noisy(button_b[j]),
        .debounced(),
        .p_edge(b_debounced_tick[j]),//really all I need in the final implementation
        .n_edge(),
        ._edge()
    );
end
endgenerate
assign r_db_button_b = b_debounced_tick[0];
assign l_db_button_b = b_debounced_tick[1];

xadc_core ADC
(
    .clk(clk),
    .reset(reset),
    .adc_p(adc_p),
    .adc_n(adc_n),
    .adc0_out(adc0_out),
    .adc1_out(adc1_out),
    .adc2_out(adc2_out),
    .adc3_out(adc3_out)
);
 
// Pipeline Stage 1: Perform shifting
always_ff @(posedge clk) begin
    shifted_x1_stage1 <= adc0_out >> 5;
    shifted_x1_stage2 <= adc0_out >> 3;
    shifted_x2_stage1 <= adc2_out >> 5;
    shifted_x2_stage2 <= adc2_out >> 3;

    shifted_y1_stage1 <= adc1_out >> 3;
    shifted_y1_stage2 <= adc1_out >> 7;
    shifted_y2_stage1 <= adc3_out >> 3;
    shifted_y2_stage2 <= adc3_out >> 7;
end

// Pipeline Stage 2: Perform adding/subtracting
always_ff @(posedge clk) begin
    shifted_x1 <= shifted_x1_stage1 + shifted_x1_stage2;
    shifted_x2 <= shifted_x2_stage1 + shifted_x2_stage2;
    shifted_y1 <= shifted_y1_stage1 - shifted_y1_stage2;
    shifted_y2 <= shifted_y2_stage1 - shifted_y2_stage2;
end

// Final Scaling Assignment
always_ff @(posedge clk or posedge reset) begin
    if (reset) 
        begin
            scaled_x1 <= 0;
            scaled_y1 <= 0;
            scaled_x2 <= 0;
            scaled_y2 <= 0;
        end 
    else 
        begin
            scaled_x1 <= shifted_x1[10:0];
            scaled_y1 <= shifted_y1[10:0];
            scaled_x2 <= shifted_x2[10:0];
            scaled_y2 <= shifted_y2[10:0];
        end
end

endmodule