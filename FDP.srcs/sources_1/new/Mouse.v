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


module Mouse (
input basys_clock, input [6:0] x_coordinate, input [6:0] y_coordinate,
inout PS2Clk, inout PS2Data, output reg [15:0] oled_colour
);

    parameter MAX_MOUSE_XPOS = 960;
    parameter MAX_MOUSE_YPOS = 640;
    parameter OLED_WIDTH = 95;
    parameter OLED_HEIGHT = 63;
    parameter TOTAL_PIXELS = 6144;

    wire clk_25MHz;
    wire clk_6p25MHz;
    wire clk_10KHz;
    
    reg [31:0] counter_25MHz = 1;
    reg [31:0] counter_6p25MHz = 7;
    reg [31:0] counter_10KHz = 4999;
    
    wire fb;
    wire [12:0] pixel_index;
    //wire [6:0] x_coordinate, y_coordinate;
    
    wire [11:0] mouse_xpos, mouse_ypos;
    wire [6:0] oled_mouse_xpos, oled_mouse_ypos;
    wire [3:0] mouse_zpos;
    wire mouse_left_click, mouse_middle_click, mouse_right_click, mouse_new_event;
    
//    assign led = mouse_ypos;
    assign oled_mouse_xpos = (mouse_xpos * OLED_WIDTH) / MAX_MOUSE_XPOS;
    assign oled_mouse_ypos = (mouse_ypos * OLED_HEIGHT) / MAX_MOUSE_YPOS;
    
    reg trace_bitmap [0:TOTAL_PIXELS-1];
    
    flexible_clock_divider unit_25MHz_clock(.basys_clock(basys_clock), .count_up_to(counter_25MHz), .new_clock(clk_25MHz));
    flexible_clock_divider unit_6p25MHz_clock(.basys_clock(basys_clock), .count_up_to(counter_6p25MHz), .new_clock(clk_6p25MHz));
    flexible_clock_divider unit_10KHz_clock(.basys_clock(basys_clock), .count_up_to(counter_10KHz), .new_clock(clk_10KHz));
    
    MouseCtl MouseCtl_inst (
    .clk(basys_clock), .rst(0), .xpos(mouse_xpos), .ypos(mouse_ypos), .zpos(mouse_zpos),
    .left(mouse_left_click), .middle(mouse_middle_click), .right(mouse_right_click), 
    .new_event(mouse_new_event), .value(12'd0), .setx(1'b0), .sety(1'b0), 
    .setmax_x(1'b0), .setmax_y(1'b0), .ps2_clk(PS2Clk), .ps2_data(PS2Data)
    );
    
    reg [6:0] old_x, old_y;
    reg [6:0] dx, dy;
    reg [6:0] steps;
    reg [6:0] interp_counter;
    reg [6:0] px, py;
    reg drawing_line;
    // Declare clearing control registers
    reg clearing; // Indicates that sequential clearing is active
    reg [6:0] clear_row, clear_col;
    
    always @(posedge clk_10KHz) 
    begin
        if (mouse_left_click)
        // Only update trace if left click is pressed. 
        begin
            if (oled_mouse_xpos != old_x || oled_mouse_ypos != old_y)
            // New mouse event while left is pressed:
            begin
                // Compute differences using the current x position and the stored old x position.
                if (oled_mouse_xpos > old_x)
                begin
                    dx <= oled_mouse_xpos - old_x;
                end
                else
                begin
                    dx <= old_x - oled_mouse_xpos;
                end
                
                // Compute differences using the current y position and the stored old y position.
                if (oled_mouse_ypos > old_y)
                begin
                    dy <= oled_mouse_ypos - old_y;
                end
                else
                begin
                    dy <= old_y - oled_mouse_ypos;
                end
                
                // Determine steps = max(|dx|,|dy|)
                if (dx > dy)
                begin
                    steps <= dx;
                end else
                        begin
                            steps <= dy;
                        end
                        interp_counter <= 0;
                        drawing_line <= 1;
                        
                        // Update old coordinates to the new position.
                        old_x <= oled_mouse_xpos;
                        old_y <= oled_mouse_ypos;
                    end 
                    else if (drawing_line) 
                    begin
                        if (interp_counter <= steps) 
                        begin
                            // Compute the interpolated pixel position.
                            // Using (steps==0 ? 1 : steps) to avoid division by zero.
                            px <= old_x + ((dx * interp_counter) / (steps == 0 ? 1 : steps));
                            py <= old_y + ((dy * interp_counter) / (steps == 0 ? 1 : steps));
                            trace_bitmap[py * (OLED_WIDTH+1) + px] <= 1'b1;
                            interp_counter <= interp_counter + 1;
                        end 
                        else 
                        begin
                            drawing_line <= 0;
                        end
                    end
                end 
                else
                begin
                    // If left click is not pressed, clear the trace bitmap.
                    // Start clearing if not already in progress
                    if (!clearing) 
                    begin
                        clearing   <= 1'b1;
                        clear_row  <= 0;
                        clear_col  <= 0;
                    end 
                    else 
                    begin
                        // Clear one pixel per clock cycle:
                        trace_bitmap[clear_row * (OLED_WIDTH+1) + clear_col] <= 1'b0;
                        // Increment column counter
                        if (clear_col == OLED_WIDTH - 1) 
                        begin
                            clear_col <= 0;
                            // Move to next row
                            if (clear_row == OLED_HEIGHT - 1) 
                            begin
                                // Finished clearing entire array
                                clear_row <= 0;
                                clearing  <= 1'b0;
                            end 
                            else begin
                                clear_row <= clear_row + 1;
                            end
                        end 
                        else 
                        begin
                            clear_col <= clear_col + 1;
                        end
                    end
                end
            end
        
            always @ (posedge clk_6p25MHz) 
            begin
                if ((x_coordinate == oled_mouse_xpos) && (y_coordinate == oled_mouse_ypos))
                begin
                    oled_colour = 16'h0000;  
                end 
                        else if (trace_bitmap[y_coordinate * (OLED_WIDTH+1) + x_coordinate])
                        begin
                            oled_colour = 16'hF800;  // Red
                        end
                        else 
                        begin
                            oled_colour = 16'hFFFF;  
                        end
                    end
                
                endmodule