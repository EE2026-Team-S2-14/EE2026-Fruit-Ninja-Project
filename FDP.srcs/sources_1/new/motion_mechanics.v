`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/18/2025 06:50:27 PM
// Design Name: 
// Module Name: motion_mechanics
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


module motion_mechanics(input basys_clock, input btnC, output [7:0] JB);

    wire fb;
    wire [12:0] pixel_index;
    wire [6:0] x_coordinate, y_coordinate;
    wire sending_pixels;
    wire sample_pixel;
    reg [15:0] oled_colour = 16'b11111_000000_00000;

    wire clk_45Hz;
    wire clk_15Hz;
    wire clk_25MHz;
    wire clk_1KHz;
    wire clk_6p25MHz;
    
    reg [31:0] m_45Hz = 1111110;
    reg [31:0] m_15Hz = 3333332;
    reg [31:0] m_25MHz = 1;
    reg [31:0] m_1KHz = 49999;
    reg [31:0] m_6p25MHz = 7;
    
    assign x_coordinate = pixel_index % 96;
    assign y_coordinate = pixel_index / 96;
    
    flexible_clock_divider unit_45Hz_clock(.basys_clock(basys_clock), .count_up_to(m_45Hz), .new_clock(clk_45Hz));
    flexible_clock_divider unit_6p25MHz_clock(.basys_clock(basys_clock), .count_up_to(m_6p25MHz), .new_clock(clk_6p25MHz));
    flexible_clock_divider unit_15Hz_clock(.basys_clock(basys_clock), .count_up_to(m_15Hz), .new_clock(clk_15Hz));
    flexible_clock_divider unit_25MHz_clock(.basys_clock(basys_clock), .count_up_to(m_25MHz), .new_clock(clk_25MHz));
    flexible_clock_divider unit_1KHz_clock(.basys_clock(basys_clock), .count_up_to(m_1KHz), .new_clock(clk_1KHz));
    
    Oled_Display oled_A(
    .clk(clk_6p25MHz), .reset(0), .frame_begin(fb), .sending_pixels(sending_pixels), 
    .sample_pixel(sample_pixel), .pixel_index(pixel_index), .pixel_data(oled_colour), 
    .cs(JB[0]), .sdin(JB[1]), .sclk(JB[3]), .d_cn(JB[4]), .resn(JB[5]), .vccen(JB[6]), .pmoden(JB[7])
    );
    
    wire btn;
    wire [15:0] oled1;
    
    debounce_c debouncer (.clk_1kHz(clk_1KHz), .btnC(btnC), .btn(btn));
    
//    vertical_motion unit_1 (.clk_45Hz(clk_45Hz), .clk_25MHz(clk_25MHz), .startflag(startflag), .x_coordinate(x_coordinate), .y_coordinate(y_coordinate), 
//    .oled_data(oled1));
    parabolic_motion unit_1( .clk_15Hz(clk_15Hz), .btn(btn), .x_coordinate(x_coordinate), .y_coordinate(y_coordinate), 
    .oled_data(oled1));
    
//    always @ (posedge basys_clock) begin
//        if (btn) begin
//            startflag <= 1;
//            end
//        else if (endflag == 1) begin
//            startflag <=  0;
//            end
//        end
            
    always @(posedge clk_6p25MHz) begin
        oled_colour <= oled1;
        end
        
endmodule


module debounce_c (input clk_1kHz, btnC, output reg btn);

    always @ (posedge clk_1kHz) begin
        btn <= btnC;
    end

endmodule
