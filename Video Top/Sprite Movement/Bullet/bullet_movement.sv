`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/16/2024 10:50:00 PM
// Design Name: 
// Module Name: bullet_movement
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

//Contains the bullet movement FSM
module bullet_movement
#(parameter SCREEN_WIDTH = 640,
            SCREEN_HEIGHT = 480,
            BULLET_SPEED = 1//adjust as necessary
)
(
    input logic clk, reset,
    input logic fire, //comes from FIFO, indicates firing
    input logic [1:0] orientation, // also attached to button,  // 2-bit orientation of the sprite (00 -> right, 01 -> down, 10 -> left, 11 -> up)
    input logic [10:0] sprite_x, sprite_y,//current location of sprite, from joystick interface
    input logic [10:0] opponent_x, opponent_y,//location of opponent's sprite (also from joystick interface)
    output logic [10:0] bullet_x, bullet_y,//bullet coordinates
    output logic bullet_active,// bullet is active
    output logic hit_opponent //collision indicator
);

localparam SPRITE_WIDTH = 8;
localparam SPRITE_HEIGHT = 8;

//Define States
typedef enum logic [1:0] { idle, moving, hit, out_of_bounds } state_type;
state_type state_reg, state_next;

//Internal Signals and Registers
logic [10:0] bullet_x_reg, bullet_y_reg;
logic [10:0] bullet_x_next, bullet_y_next;

logic [10:0] diff_x, diff_y;

//Register Logic 

always_ff @( posedge clk, posedge reset ) 
begin
    if (reset)
        state_reg <= idle;
    else
        state_reg <= state_next;
end

always_ff @( posedge clk ) 
begin
    if (reset)//asynch reset
        begin
            bullet_x_reg <= 0;
            bullet_y_reg <= 0; 
        end
    else
        begin
            bullet_x_reg <= bullet_x_next;
            bullet_y_reg <= bullet_y_next;
        end 
end


//Next State Logic

// Calculate absolute difference
assign diff_x = (bullet_x_reg > opponent_x) ? (bullet_x_reg - opponent_x) : (opponent_x - bullet_x_reg);
assign diff_y = (bullet_y_reg > opponent_y) ? (bullet_y_reg - opponent_y) : (opponent_y - bullet_y_reg);

always_comb 
begin
// add default values here
bullet_x_next = bullet_x_reg;
bullet_y_next = bullet_y_reg;
state_next = idle;

    case (state_reg)
        idle:
            begin
                bullet_active = 0;
                hit_opponent = 0;
                if(fire)//bullet is fired (from button input)
                begin
                    bullet_x_next = sprite_x;
                    bullet_y_next = sprite_y;
                    state_next = moving;
                end
                else
                    state_next = idle;
            end
        moving: 
            begin
                bullet_active = 1;
                hit_opponent = 0;
                case (orientation)//this is for moving the bullet in the direction of the sprite
                    2'b00: bullet_x_next = bullet_x_reg + BULLET_SPEED; // shoot right
                    2'b01: bullet_y_next = bullet_y_reg + BULLET_SPEED; // shoot down
                    2'b10: bullet_x_next = bullet_x_reg - BULLET_SPEED; // shoot left
                    2'b11: bullet_y_next = bullet_y_reg - BULLET_SPEED; // shoot up
                endcase
                if ((diff_x < SPRITE_WIDTH) && (diff_y < SPRITE_HEIGHT))//if the bullet coordinates are the same as the ones for the opponent's sprite, there's a collision
                    state_next = hit;
                else if ((bullet_x_reg >= SCREEN_WIDTH) || (bullet_y_reg >= SCREEN_HEIGHT))
                    state_next = out_of_bounds;
                else
                    state_next = moving;
            end
        hit:
            begin
                bullet_active = 0;//stops the bullet in this case
                hit_opponent = 1;//bullet has hit the other sprite  
                state_next = idle;//if it hits the sprite, terminate the bullet, aka default state
            end
        out_of_bounds:
            begin
                bullet_active = 0;
                hit_opponent = 0;
                state_next = idle;//if the bullet is out of bounds, reset to default state
            end
        default:
            begin
                bullet_active = 0;
                hit_opponent = 0;
                state_next = idle;
            end
    endcase    
end

//Output Logic
assign bullet_x = bullet_x_reg;
assign bullet_y = bullet_y_reg;
endmodule