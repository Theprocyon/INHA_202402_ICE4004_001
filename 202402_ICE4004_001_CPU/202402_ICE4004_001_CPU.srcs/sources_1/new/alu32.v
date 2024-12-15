// file: ALU.v
// author: theprocyon

`timescale 1ns/1ps

module alu32( input [31:0] x, 
            input [31:0] y,
            input [3:0] f,
            output reg [31:0] s, 
            output reg zero);

always @ (*) begin
    case (f)
        4'b0000: s = x + y;                             // ADD
        4'b0001: s = x - y;                             // SUB
        4'b0010: s = x << (y & 32'h0000001F);           // SLL
        4'b0011: s = x >> (y & 32'h0000001F);           // SRL
        4'b0100: s = (x * y) & 32'hFFFFFFFF;            // MUL
    endcase
         zero = (s==8'b0);
     end
endmodule