// file: ALU.v
// author: theprocyon

module aluavg72(
    input [71:0] in,      
    output [31:0] avg_out  
);

    wire [13:0] total_sum;

    
    assign total_sum = in[71:64] + in[63:56] + in[55:48] +
                       in[47:40] + in[39:32] + in[31:24] +
                       in[23:16] + in[15:8] + in[7:0];

    
    assign avg_out = (total_sum >> 4) + (total_sum >> 5) + (total_sum >> 6);

endmodule