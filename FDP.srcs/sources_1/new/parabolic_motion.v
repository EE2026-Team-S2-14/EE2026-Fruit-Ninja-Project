`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/18/2025 06:49:41 PM
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


module parabolic_motion( input clk_15Hz, input btn, input [6:0] x_coordinate, input [6:0] y_coordinate, 
output reg [15:0] oled_data);

    reg [6:0] x = 10; 
    reg [6:0] y = 10; 
    reg [6:0] t = 0;  
    reg signed [6:0] vx = 4;  // Horizontal velocity
    reg signed [6:0] vy = 10;  // Initial vertical velocity
    reg signed [6:0] g = 1;   // Gravity

    always @(posedge clk_15Hz) begin
        if (btn) begin
            x <= 10;
            y <= 10;
            t <= 0;
        end 
        else if (y < 63) begin
            t <= t + 1; 
            x <= 10 + (vx * t);
            y <= 10 + (vy * t) - ((g * t * t) >> 1);
        end
    end

    always @(*) begin
        if (x_coordinate >= x && x_coordinate < x + 3 &&
            y_coordinate >= y && y_coordinate < y + 3) begin
            oled_data = 16'b11111_000000_00000; 
        end 
        else begin
            oled_data = 16'b00000_000000_00000;
        end
    end

endmodule
