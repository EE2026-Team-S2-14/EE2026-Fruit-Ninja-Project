`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/18/2025 06:48:46 PM
// Design Name: 
// Module Name: flexible_clock_divider
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


module flexible_clock_divider(
    input basys_clock,
    input[31:0] count_up_to,
    output reg new_clock = 0
    );
    
    reg[31:0] count = 0;
    
    always @ (posedge basys_clock) 
    begin
        count <= count == count_up_to ? 0: count + 1;
        new_clock <= count == count_up_to ? ~new_clock : new_clock;
    end
    
endmodule
