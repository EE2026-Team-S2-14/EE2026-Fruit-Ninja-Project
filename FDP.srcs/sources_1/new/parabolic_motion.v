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



module parabolic_motion( input basys_clock, input collision_flag, input clk_15Hz, input btnC, input [6:0] x_coordinate, input [6:0] y_coordinate, 
output reg [15:0] oled_data);

    wire [7:0] rand_num;
    random_number_generator r1 (.basys_clock(basys_clock), .out(rand_num));

    reg [6:0] x = 10; 
    reg [6:0] y = 63; 
    reg [6:0] t = 0;  
    reg signed [6:0] vx = 1;  // Horizontal velocity
    reg signed [6:0] vy = 10;  // Initial vertical velocity
    reg signed [6:0] g = 1;   // Gravity
    reg [6:0] random_x_position = 10;

    always @(posedge clk_15Hz) begin
        if (btnC) begin
            random_x_position <= (rand_num % 56) + 20;
            vx <= (rand_num % 4) - 2;
            y <= 64;
            t <= 0;
        end 
        else if (y > 0 && y < 65) begin
            t <= t + 1; 
            x <= random_x_position + (vx * t);
            y <= 64 - ((vy * t) - ((g * t * t) >> 1));
        end
    end

    always @(*) begin
//        if (collision_flag == 1) begin
//            oled_data <= 16'b00000_000000_00000;
//        end else
        if (x_coordinate >= x && x_coordinate < x + 15 &&
            y_coordinate >= y && y_coordinate < y + 15 && (collision_flag != 1)) begin
            oled_data = 16'b11111_111000_00000; 
        end 
        else begin
            oled_data = 16'b00000_000000_00000;
        end
    end

endmodule
