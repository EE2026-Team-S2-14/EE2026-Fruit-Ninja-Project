`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/30/2025 10:15:27 PM
// Design Name: 
// Module Name: random_number_generator
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


module random_number_generator (input basys_clock, output reg [7:0] out);
    wire feedback;
    reg [7:0] cycle_count = 8'd0;

    assign feedback = out[7] ^ out[5] ^ out[4] ^ out[3];

    always @(posedge basys_clock) begin
        out <= (cycle_count == 8'd255) ? 8'b10000001 : {out[6:0], feedback};
    end
    
    always @(posedge basys_clock) begin
        cycle_count <= (cycle_count == 8'd255) ? 8'd0 : cycle_count + 1;
    end

endmodule
