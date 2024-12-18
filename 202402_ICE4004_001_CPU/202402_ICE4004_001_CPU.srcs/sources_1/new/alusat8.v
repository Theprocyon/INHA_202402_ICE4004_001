`timescale 1ns/1ps

module alusat8(
    input [7:0] a,       
    input [7:0] b,       
    input mode,          // Mode: 0 for addition, 1 for subtraction
    output reg [7:0] result 
);


wire [8:0] sum = {1'b0, a} + {1'b0, b};

always @(*) begin
    if (mode == 1'b0) begin
        
        if (sum > 9'h0FF) 
            result = 8'hFF; 
        else 
            result = sum[7:0];
    end else begin
        
        if (a < b)
            result = 8'h00;
        else 
            result = a - b;
    end
end

endmodule