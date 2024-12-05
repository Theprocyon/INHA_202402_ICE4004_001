`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/05 23:15:31
// Design Name: 
// Module Name: cache
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

module cache (
    input wire clk,
    input wire write_enable,
    input wire read_enable,
    input wire [7:0] address,  // 8-bit address for 256 registers
    input wire [31:0] write_data,
    output reg [31:0] read_data
);

    // Declare the register file
    reg [31:0] registers [255:0];  // 256 x 32-bit registers

    always @(posedge clk) begin
        if (write_enable) begin
            registers[address] <= write_data;  // Write operation
        end
    end

    always @(*) begin
        if (read_enable) begin
            read_data = registers[address];  // Read operation
        end else begin
            read_data = 32'b0;  // Default value when read is disabled
        end
    end

endmodule
