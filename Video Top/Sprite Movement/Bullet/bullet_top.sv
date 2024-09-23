`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/17/2024 11:44:52 AM
// Design Name: 
// Module Name: bullet_top
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


module bullet_top
#(
    parameter KEY_COLOR = 0,
    ADDR_WIDTH = 8,
    DATA_WIDTH = 24
)
(
    input logic clk, reset,
    input logic fire,
    input logic [1:0] orientation,
    input logic [10:0] sprite_x, sprite_y,
    input logic [10:0] opponent_x, opponent_y,
    input logic [10:0] x, y,
    input logic [11:0] si_rgb,
    output logic [11:0] so_rgb
);

logic [10:0] bullet_x, bullet_y;
logic [10:0] sprite_x_out_fifo, sprite_y_out_fifo;
logic [1:0] orientation_out_fifo;

logic bullet_active, hit_opponent;

logic [DATA_WIDTH-1:0] fifo_data_out;
logic [DATA_WIDTH-1:0] fifo_data_in;
logic fifo_wr, fifo_rd;
logic fifo_full, fifo_empty;

logic [11:0] bullet_rgb;

// FIFO instantiation
fifo #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) bullet_fifo (
    .clk(clk),
    .reset(reset),
    .w_data(fifo_data_in),
    .r_data(fifo_data_out),
    .wr(fifo_wr),
    .rd(fifo_rd),
    .full(fifo_full),
    .empty(fifo_empty)
);

// FIFO write logic
assign fifo_data_in = {sprite_x, sprite_y, orientation};
assign fifo_wr = fire && !fifo_full;

// FIFO read logic
always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        fifo_rd <= 0;
    end else if (!fifo_empty) begin
        fifo_rd <= 1;
    end else begin
        fifo_rd <= 0;
    end
end

// Unpack FIFO data
assign {sprite_x_out_fifo, sprite_y_out_fifo, orientation_out_fifo} = fifo_data_out;

// Bullet movement controller
bullet_movement #(
    .SCREEN_WIDTH(640),
    .SCREEN_HEIGHT(480),
    .BULLET_SPEED(1)
) bullet_controller (
    .clk(clk),
    .reset(reset),
    .fire(fire),
    .orientation(orientation_out_fifo),
    .sprite_x(sprite_x_out_fifo),
    .sprite_y(sprite_y_out_fifo),
    .opponent_x(opponent_x),
    .opponent_y(opponent_y),
    .bullet_x(bullet_x),
    .bullet_y(bullet_y),
    .bullet_active(bullet_active),
    .hit_opponent(hit_opponent)
);

// Bullet sprite rendering
bullet_sprite_core #(
    .KEY_COLOR(KEY_COLOR)
) bullet_rendering (
    .clk(clk),
    .bullet_x(bullet_x),
    .bullet_y(bullet_y),
    .x(x),
    .y(y),
    .bullet_active(bullet_active),
    .so_rgb(bullet_rgb)
);

// VGA Output Logic
assign so_rgb = (bullet_active && (bullet_rgb != KEY_COLOR)) ? bullet_rgb : si_rgb;

endmodule
