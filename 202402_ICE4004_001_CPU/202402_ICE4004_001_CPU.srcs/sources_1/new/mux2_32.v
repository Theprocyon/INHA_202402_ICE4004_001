`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/05 23:27:26
// Design Name: 
// Module Name: mux2_32
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

module mux2_32 (
    input wire [31:0] in0,
    input wire [31:0] in1,
    input wire sel,
    output reg [31:0] out
);

    // Always block to determine output based on select signal
    always @(*) begin
        case (sel)
            1'b0: out = in0;  
            1'b1: out = in1;  
            default: out = 32'b0;
        endcase
    end

endmodule

