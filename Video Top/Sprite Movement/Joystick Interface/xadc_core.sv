`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/30/2024 12:57:30 AM
// Design Name: 
// Module Name: xadc_core
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


module xadc_core
    (
        input  logic clk,
        input  logic reset,
        // External signals
        input  logic [3:0] adc_p,//adc_p0 --> vaux3, adc_p1 --> vaux10, adc_p2 --> vaux2, adc_p3 --> vaux11
        input  logic [3:0] adc_n, // connected to GND, since we configured for unipolar mode
        
        // Outputs for ADC data
        output logic [11:0] adc0_out,//vaux3 output
        output logic [11:0] adc1_out,//vaux10 output
        output logic [11:0] adc2_out,//vaux2 output
        output logic [11:0] adc3_out//vaux11 output
    );

    // Signal Declarations
    logic [4:0] channel;        // Output from XADC
    logic [6:0] daddr_in;
    logic eoc;                  // End of Conversion
    logic rdy;                  // Read Data Ready
    logic [15:0] adc_data;      // Data from XADC

    // Instantiate XADC
    xadc_fpro xadc_unit (
        // Clk and reset
            .dclk_in(clk),          // input 
            .reset_in(reset),        // input 
        // DRP Interface
            .di_in(16'h0000),              // input wire [15 : 0], data in for dynamic reconfiguration
            .daddr_in(daddr_in),        // input wire [6 : 0], Control and Status register addresses go here
            .den_in(eoc),            // input, register enable (for reading)
            .dwe_in(1'b0),            // input, write enable
            .drdy_out(rdy),        // output, data out is retrieved and ready 
            .do_out(adc_data),            // output wire [15 : 0], data out, read from active reg
        // Dedicated analog input channel (not used)
            .vp_in(1'b0),              // input 
            .vn_in(1'b0),              // input
        // Auxilliary analog input channels
            .vauxp2(adc_p[2]),     // input logic vauxp2
            .vauxn2(adc_n[2]),     // input logic vauxn2
            .vauxp3(adc_p[0]),     // input logic vauxp3
            .vauxn3(adc_n[0]),     // input logic vauxn3
            .vauxp10(adc_p[1]),    // input logic vauxp10
            .vauxn10(adc_n[1]),    // input logic vauxn10
            .vauxp11(adc_p[3]),    // input logic vauxp11
            .vauxn11(adc_n[3]),    // input logic vauxn11
        // Conversion status signals
            .channel_out(channel),  // output wire [4 : 0], the current channel number, which is the same as the 5 LSb of daddr_in 
            .eoc_out(eoc),          // output, end of conversion
            .eos_out(),             // output, end of sequence
            .busy_out(),           // output, high during an ADC conversion
        // Alarm output (not used)
            .alarm_out()      // output, logic OR of alarms
    );
    
    assign daddr_in = {2'b00, channel}; // Channel address for XADC

    // Registers to hold ADC data
    logic [15:0] adc0_out_reg, adc1_out_reg, adc2_out_reg, adc3_out_reg;
    
    always_ff @(posedge clk, posedge reset) 
    begin
        if (reset) 
        begin
            adc0_out_reg <= 16'h0000;
            adc1_out_reg <= 16'h0000;
            adc2_out_reg <= 16'h0000;
            adc3_out_reg <= 16'h0000;
        end 
        else 
        begin
            if (rdy) 
            begin
                case (channel)
                    5'b10011: adc0_out_reg <= adc_data; // vaux3
                    5'b11010: adc1_out_reg <= adc_data; // vaux10
                    5'b10010: adc2_out_reg <= adc_data; // vaux2
                    5'b11011: adc3_out_reg <= adc_data; // vaux11
                endcase
            end
        end
    end

    // Assign ADC outputs
    assign adc0_out = adc0_out_reg[15 : 4];//12 bit ADC, left-aligned
    assign adc1_out = adc1_out_reg[15 : 4];
    assign adc2_out = adc2_out_reg[15 : 4];
    assign adc3_out = adc3_out_reg[15 : 4];
endmodule
