`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/15/2024 06:31:58 PM
// Design Name: 
// Module Name: video_top
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


module video_top
#(
   parameter CD = 12,            // color depth
   parameter BRAM_DATA_WIDTH = 12 // frame buffer data width
)
(
   input logic clk,
   input logic reset_sys,
   // to vga monitor  
   output logic vsync, hsync,
   output logic [11:0] rgb,
   //Adc and switch
    input  logic [3:0] adc_p,//adc_p0 --> vaux3, adc_p1 --> vaux10, adc_p2 --> vaux2, adc_p3 --> vaux11
    input  logic [3:0] adc_n,
    input logic [1:0] button_j,//2 buttons from joystick, 0-->R, 1-->L 
    input logic [1:0] button_b,//buttons for shooting
    input logic [1:0] colour_select_r,//to switches
    input logic [1:0] colour_select_l//to switches
);

logic reset_active_high = ~reset_sys;

    logic clk_100M;
    logic clk_25M;
   mmcm_fpro clk_mmcm_unit ( 
      // clock in ports
      .clk_in_100M(clk),
      // clock out ports  
      .clk_100M(clk_100M),
      .clk_25M(clk_25M),
      .clk_40M(),
      .clk_67M(),
      // status and control signals                
      .reset(0),
      .locked(locked)
   );

   // constant declaration
   localparam KEY_COLOR = 0;

   // signal declaration
   // video data stream
   logic [CD-1:0] bar_rgb7, ghost_rgb3;
   logic [CD:0] line_data_in;

   // frame counter
   logic inc, frame_start;
   logic [10:0] x, y;

   // delay line
   logic rame_start_d4_reg;
   logic inc_d4_reg;

//    // 2-stage delay line for start signal
//    always_ff @(posedge clk_100M) begin
//       frame_start_d1_reg <= frame_start;
//       frame_start_d4_reg <= frame_start_d1_reg;
//       inc_d1_reg <= inc;
//       inc_d4_reg <= inc_d1_reg;
//    end

   // Instantiate frame counter (same as before)
   frame_counter #(.HMAX(640), .VMAX(480)) frame_counter_unit
      (.clk(clk_100M), .reset(reset_active_high), 
       .sync_clr(0), .inc(inc), .hcount(x), .vcount(y), 
       .frame_start(frame_start), .frame_end());

synchronizer #(.STAGES(4)) delay_frame_start//number of FFs
(
    .clk(clk_100M), .reset(reset_active_high),
    .D(frame_start),
    .Q(frame_start_d4_reg)
);
synchronizer #(.STAGES(4)) delay_inc//number of FFs
(
    .clk(clk_100M), .reset(reset_active_high),
    .D(inc),
    .Q(inc_d4_reg)
);

   // Instantiate bar generator
   vga_bar_core pattern_generator (
      .clk(clk_100M),
      .reset(reset_active_high),
      .x(x),
      .y(y),
      .si_rgb(12'h000),
      .so_rgb(bar_rgb7)
   );

//    // Instantiate ghost sprite
//    vga_sprite_ghost_core #(.CD(CD), .ADDR_WIDTH(10), .KEY_COLOR(KEY_COLOR)) 
//    v3_ghost_unit (
//       .clk(clk_100M),
//       .reset(reset_active_high),
//       .x(x),
//       .y(y),
//       .si_rgb(bar_rgb7),
//       .so_rgb(ghost_rgb3)
//    );

   sprite_movement u_sprite_movement (
    .clk(clk_100M),               // Clock input
    .reset(reset_active_high),           // Reset input
    
    // Frame counter inputs
    .x(x),                   // X-coordinate (11 bits)
    .y(y),                   // Y-coordinate (11 bits)
    
    // Stream interface
    .si_rgb(bar_rgb7),         // Input RGB stream (12 bits)
    .so_rgb(ghost_rgb3),         // Output RGB stream (12 bits)

    // Joystick ADC inputs
    .adc_p(adc_p),           // ADC positive inputs (4 bits)
    .adc_n(adc_n),           // ADC negative inputs (4 bits)
    .colour_select_r(colour_select_r),
    .colour_select_l(colour_select_l),           // Color select (2 bits) from switches

    // Joystick button input
    .button_j(button_j),      // Joystick button input (1 bit)
    .button_b(button_b)
);

   // Merge start signal to RGB data stream
   assign line_data_in = {ghost_rgb3, frame_start_d4_reg};

   // Instantiate sync_core
   vga_sync_core #(.CD(CD)) v0_vga_sync_unit (
      .clk_sys(clk_100M),
      .clk_25M(clk_25M),
      .reset(reset_active_high),
      .si_data(line_data_in),
      .si_valid(inc_d4_reg),
      .si_ready(inc),
      .hsync(hsync),
      .vsync(vsync),
      .rgb(rgb)
   );
endmodule
