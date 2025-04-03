`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/16/2025 02:49:16 PM
// Design Name: 
// Module Name: parabolic_motion
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



module parabolic_motion(
    input basys_clock, 
    input [15:0] delay, 
    input collision_flag, 
    input clk_15Hz, 
    input [6:0] x_coordinate, 
    input [6:0] y_coordinate, 
    input [7:0] random_num, 
    output reg [15:0] oled_data
);

    reg [6:0] x = 10; 
    reg [6:0] y = 63; 
    reg [6:0] t = 0;  
    reg signed [6:0] vx = 1;  // Horizontal velocity
    reg signed [6:0] vy = 10;  // Initial vertical velocity
    reg signed [6:0] g = 1;   // Gravity
    reg [6:0] random_x_position = 10;
    
    reg [15:0] delay_count = 0;
    reg active = 0;

    always @(posedge clk_15Hz) begin
        if (!active) begin
            // Waiting period
            if (delay_count < delay) begin
                delay_count <= delay_count + 1;
            end else begin
                // Launch fruit
                random_x_position <= (random_num % 56) + 20;
                vx <= (random_num % 4) - 2;
                y <= 63;
                t <= 0;
                active <= 1;
            end
        end else if (active) begin
            if (y > 0 && y < 65 && !collision_flag) begin
                t <= t + 1;
                x <= random_x_position + (vx * t);
                y <= 63 - ((vy * t) - ((g * t * t) >> 1));
            end else begin
                // Reset and wait for next launch
                active <= 0;
                delay_count <= 0;
            end
        end
    end

    always @(*) begin
        if (x_coordinate >= x && x_coordinate < x + 3 &&
            y_coordinate >= y && y_coordinate < y + 3 && (collision_flag != 1)) begin
            oled_data = 16'b11111_111000_00000; 
        end else begin
            oled_data = 16'b00000_000000_00000;
        end
    end

endmodule

