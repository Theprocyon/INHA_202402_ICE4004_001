`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/01 19:13:02
// Design Name: 
// Module Name: regfile3i3o32b
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

module regfile3i3o32b (
    input wire clk,
    input wire reset,
    input wire [4:0] read_addr1,  // Read port 1 address
    input wire [4:0] read_addr2,  // Read port 2 address
    input wire [4:0] read_addr3,  // Read port 3 address
    input wire [4:0] write_addr1, // Write port 1 address
    input wire [4:0] write_addr2, // Write port 2 address
    input wire [4:0] write_addr3, // Write port 3 address
    input wire [31:0] write_data1, // Write port 1 data
    input wire [31:0] write_data2, // Write port 2 data
    input wire [31:0] write_data3, // Write port 3 data
    input wire write_enable1,      // Write enable for port 1
    input wire write_enable2,      // Write enable for port 2
    input wire write_enable3,      // Write enable for port 3
    output wire [31:0] read_data1, // Read port 1 data
    output wire [31:0] read_data2, // Read port 2 data
    output wire [31:0] read_data3  // Read port 3 data
);
    integer i;
    // 32 registers, each 32 bits wide
    reg [31:0] reg_file [31:0];

    // Read logic
    assign read_data1 = reg_file[read_addr1];
    assign read_data2 = reg_file[read_addr2];
    assign read_data3 = reg_file[read_addr3];

    // Write logic
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                reg_file[i] <= 32'b0; // Reset all registers to 0
            end
        end else begin
            if (write_enable1) begin
                reg_file[write_addr1] <= write_data1;
            end
            if (write_enable2) begin
                reg_file[write_addr2] <= write_data2;
            end
            if (write_enable3) begin
                reg_file[write_addr3] <= write_data3;
            end
        end
    end

endmodule
