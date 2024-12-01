`timescale 1ns/1ps

module tb_alu32;

// Testbench signals
reg [31:0] x, y;
reg [3:0] f;
wire [31:0] s;
wire zero;

// Instantiate the ALU module
alu32 uut (
    .x(x),
    .y(y),
    .f(f),
    .s(s),
    .zero(zero)
);

// Test sequence
initial begin
    // Test ADD
    x = 32'h00000005; y = 32'h00000003; f = 4'b0000; #10;
    $display("ADD: x=%d, y=%d, s=%d, zero=%b", x, y, s, zero);

    // Test SUB
    x = 32'h00000005; y = 32'h00000005; f = 4'b0001; #10;
    $display("SUB: x=%d, y=%d, s=%d, zero=%b", x, y, s, zero);

    // Test SLL
    x = 32'h00000002; y = 32'h00000003; f = 4'b0010; #10;
    $display("SLL: x=%d, y=%d, s=%d, zero=%b", x, y, s, zero);

    // Test SRL
    x = 32'h00000001; y = 32'h00000008; f = 4'b0011; #10;
    $display("SRL: x=%d, y=%d, s=%d, zero=%b", x, y, s, zero);

    // Test MUL
    x = 32'h00000002; y = 32'h00000003; f = 4'b0100; #10;
    $display("MUL: x=%d, y=%d, s=%d, zero=%b", x, y, s, zero);

    // End simulation
    $finish;
end

endmodule