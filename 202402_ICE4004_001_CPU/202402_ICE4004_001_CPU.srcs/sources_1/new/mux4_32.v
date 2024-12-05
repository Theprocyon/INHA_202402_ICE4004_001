`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/05 23:25:53
// Design Name: 
// Module Name: mux4_32
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

module mux4_32 (
    input wire [31:0] in0,
    input wire [31:0] in1,
    input wire [31:0] in2,
    input wire [31:0] in3,
    input wire [1:0] sel,
    output reg [31:0] out
);

    // Always block to determine output based on select signal
    always @(*) begin
        case (sel)
            2'b00: out = in0;  // Select input 0
            2'b01: out = in1;  // Select input 1
            2'b10: out = in2;  // Select input 2
            2'b11: out = in3;  // Select input 3
            default: out = 32'b0; // Default output is 0
        endcase
    end

endmodule
