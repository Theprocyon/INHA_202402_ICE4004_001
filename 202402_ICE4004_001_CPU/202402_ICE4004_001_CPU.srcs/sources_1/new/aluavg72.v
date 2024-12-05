// file: ALU.v
// author: theprocyon

module aluavg72(
    input [71:0] in,        // 72-bit input
    output [31:0] avg_out   // 32-bit unsigned average output
);

    wire [13:0] total_sum;  // Final sum with enough width for 9 * 8-bit values

    // Step 1: Add all 9 values
    assign total_sum = in[71:64] + in[63:56] + in[55:48] +
                       in[47:40] + in[39:32] + in[31:24] +
                       in[23:16] + in[15:8] + in[7:0];

    // Step 2: Approximate divide by 9 using shift & add
    assign avg_out = (total_sum >> 4) + (total_sum >> 5) + (total_sum >> 6);

endmodule