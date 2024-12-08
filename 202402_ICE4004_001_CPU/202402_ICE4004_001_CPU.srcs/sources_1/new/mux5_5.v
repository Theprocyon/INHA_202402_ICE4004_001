`timescale 1ns / 1ps

module mux5_5 (
    input wire [4:0] in0,
    input wire [4:0] in1,
    input wire [4:0] in2,
    input wire [4:0] in3,
    input wire [4:0] in4,
    input wire [2:0] sel,
    output reg [4:0] out
);

    // Always block to determine output based on select signal
    always @(*) begin
        case (sel)
            3'b000: out = in0;
            3'b001: out = in1;
            3'b010: out = in2;
            3'b011: out = in3;
            3'b100: out = in4;
            default: out = 5'b0; // Default output is 0
        endcase
    end

endmodule
