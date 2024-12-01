`timescale 1ns/1ps

module alusat72(
    input [71:0] a,        // First 72-bit operand
    input [71:0] b,        // Second 72-bit operand
    input mode,            // Mode: 0 for addition, 1 for subtraction
    output [71:0] result   // 72-bit Saturated result
);

    // Intermediate 8-bit results
    wire [7:0] res[8:0];

    // Instantiate 9 saturating_add_sub modules
    genvar i;
    generate
        for (i = 0; i < 9; i = i + 1) begin : saturating_units
            alusat8 u_saturating_add_sub (
                .a(a[i*8 +: 8]),     // Extract 8-bit chunk from 'a'
                .b(b[i*8 +: 8]),     // Extract 8-bit chunk from 'b'
                .mode(mode),         // Operation mode
                .result(res[i])      // 8-bit result
            );
        end
    endgenerate

    // Concatenate results to form 72-bit output
    assign result = {res[0], res[1], res[2], res[3], res[4], res[5], res[6], res[7], res[8]};

endmodule
