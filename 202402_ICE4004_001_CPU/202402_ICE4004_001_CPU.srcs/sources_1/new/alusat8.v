// 8-bit Unsigned Saturating Add/Sub Module
`timescale 1ns/1ps

module alusat8(
    input [7:0] a,       // First operand
    input [7:0] b,       // Second operand
    input mode,          // Mode: 0 for addition, 1 for subtraction
    output reg [7:0] result // Saturated result
);wire [8:0] sum = {1'b0, a} + {1'b0, b};

always @(*) begin
    if (mode == 1'b0) begin
        // Unsigned Addition
        if (sum > 9'h0FF) 
            result = 8'hFF; // Saturate to 255
        else 
            result = sum[7:0];
    end else begin
        // Unsigned Subtraction
        if (a < b)
            result = 8'h00; // Saturate to 0
        else 
            result = a - b;
    end
end

endmodule