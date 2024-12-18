`timescale 1ns / 1ps

module cache (
    input wire clk,
    input wire write_enable,
    input wire read_enable,
    input wire [31:0] address,  // 32-bit address for 256 registers
    input wire [31:0] write_data,
    output reg [31:0] read_data
);

    wire [29:0] address_trunc; //Get 8bit LSB from addr
    assign address_trunc = address >> 2;

    // Declare the register file
    reg [31:0] registers [255:0];  // 256 x 32-bit registers

    initial begin
        $readmemb("Insts.mem", registers);
    end
    
    always @(posedge clk) begin
        if (write_enable) begin
            registers[address_trunc] <= write_data;  // Write operation
        end
    end

    always @(*) begin
        if (read_enable) begin
            read_data = registers[address_trunc];  // Read operation
        end else begin
            read_data = 32'b0;  // Default value when read is disabled
        end
    end

endmodule
