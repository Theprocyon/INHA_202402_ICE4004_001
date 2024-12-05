`timescale 1ns / 1ps


module reg32 (
    input wire clk,
    input wire rst,
    input wire we,          // Write enable signal
    input wire [31:0] d,
    output reg [31:0] q
);

    // Always block to update register value on the positive edge of clock
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            q <= 32'b0;  // Reset the register value to 0
        end else if (we) begin
            q <= d;      // Load the input value into the register if write enable is high
        end
    end

endmodule
