
`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//  STUDENT A NAME: 
//  STUDENT B NAME:
//  STUDENT C NAME: 
//  STUDENT D NAME:  
//
//////////////////////////////////////////////////////////////////////////////////


module Top_Student(input basys_clock, input btnC, inout PS2Clk, inout PS2Data, output [7:0] JB, output [15:0] led);

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
    
    wire [7:0] random_num;
    reg [7:0] random_nums[0:9];
    integer i;
    
    
    random_number_generator r1 (.basys_clock(basys_clock), .out(random_num));
    
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
    
    //wire btn;
    wire [15:0] oled_fruit[0:9];
    wire [15:0] oled_mouse;
    reg collision_flag[0:9];
    reg [6:0] count = 0;
    assign led = count;
    reg [5:0] delay_flag = 0;
    reg [15:0] delay_array[0:9];
    
    initial begin
        delay_array[0] = 100;
        delay_array[1] = 200;
        delay_array[2] = 300;
        delay_array[3] = 400;
        delay_array[4] = 500;
        delay_array[5] = 600;
        delay_array[6] = 700;
        delay_array[7] = 800;
        delay_array[8] = 900;
        delay_array[9] = 1000;
    end

    
    always @(posedge clk_15Hz) begin
            if (btnC) begin
                random_nums[0] <= random_num;
                delay_flag <= 1;
            end else if (delay_flag == 1) begin
                random_nums[1] <= random_num;
                delay_flag <= 2;
            end else if (delay_flag == 2) begin
                random_nums[2] <= random_num;
                delay_flag <= 3;
            end else if (delay_flag == 3) begin
                random_nums[3] <= random_num;
                delay_flag <= 4;
            end else if (delay_flag == 4) begin
                random_nums[4] <= random_num;
                delay_flag <= 5;
            end else if (delay_flag == 5) begin
                random_nums[5] <= random_num;
                delay_flag <= 6;
            end else if (delay_flag == 6) begin
                random_nums[6] <= random_num;
                delay_flag <= 7;
            end else if (delay_flag == 7) begin
                random_nums[7] <= random_num;
                delay_flag <= 8;
            end else if (delay_flag == 8) begin
                random_nums[8] <= random_num;
                delay_flag <= 9;
            end else if (delay_flag == 9) begin
                random_nums[9] <= random_num;
                delay_flag <= 0;
            end
        end

    
    //debounce_c debouncer (.clk_1kHz(clk_1KHz), .btnC(btn));
    
    generate
        genvar idx;
        for (idx = 0; idx < 10; idx = idx + 1) begin : fruit_gen
            parabolic_motion fruit (
                .basys_clock(basys_clock),
                .delay(delay_array[idx]),
                .collision_flag(collision_flag[idx]),
                .clk_15Hz(clk_15Hz),
                .x_coordinate(x_coordinate),
                .y_coordinate(y_coordinate),
                .random_num(random_nums[idx]),
                .oled_data(oled_fruit[idx])
            );
        end
    endgenerate

        
    Mouse mouse (.basys_clock(basys_clock), .x_coordinate(x_coordinate), .y_coordinate(y_coordinate), 
    .PS2Clk(PS2Clk), .PS2Data(PS2Data), .oled_colour(oled_mouse));
            
    always @(posedge clk_25MHz) begin
        for (i = 0; i < 10; i = i + 1) begin
        if ((oled_mouse == 16'hF800) && (oled_fruit[i] == 16'b11111_111000_00000)) begin
            collision_flag[i] <= (count == 30) ? 1 : 0;
            count <= count + 1;
        end
    end

        if (oled_mouse == 16'hF800 || oled_mouse == 16'h0000) begin
            oled_colour <= oled_mouse;
        end else begin
            oled_colour <= 16'hFFFF;
            for (i = 0; i < 10; i = i + 1) begin
                if (oled_fruit[i] == 16'b11111_111000_00000) begin
                    oled_colour <= oled_fruit[i];
                end
            end
        end

       if (btnC) begin
            for (i = 0; i < 10; i = i + 1) begin
                collision_flag[i] <= 0;
            end
            count <= 0;
        end
    end
endmodule
