`timescale 1ns/1ps

module tb_aluavg72;

    // Testbench signals
    reg [71:0] in;          // 72-bit input for the module
    wire [31:0] avg_out;    // 32-bit average output from the module

    // Instantiate the DUT (Device Under Test)
    aluavg72 uut (
        .in(in),
        .avg_out(avg_out)
    );

    // Testbench logic
    initial begin
        $display("Starting aluavg72 Testbench...");
        
        // Test case 1
        in = {8'd10, 8'd20, 8'd30, 8'd40, 8'd50, 8'd60, 8'd70, 8'd80, 8'd90}; // Sum = 450, Avg = 450/9 = 50
        #10; // Wait for output to stabilize
        $display("Input: %h | Expected Avg: 50 | Calculated Avg: %d", in, avg_out);

        // Test case 2
        in = {8'd100, 8'd110, 8'd120, 8'd130, 8'd140, 8'd150, 8'd160, 8'd170, 8'd180}; // Sum = 1260, Avg = 1260/9 = 140
        #10;
        $display("Input: %h | Expected Avg: 140 | Calculated Avg: %d", in, avg_out);

        // Test case 3
        in = {8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0}; // Sum = 0, Avg = 0/9 = 0
        #10;
        $display("Input: %h | Expected Avg: 0 | Calculated Avg: %d", in, avg_out);

        // Test case 4
        in = {8'd255, 8'd255, 8'd255, 8'd255, 8'd255, 8'd255, 8'd255, 8'd255, 8'd255}; // Sum = 2295, Avg = 2295/9 = 255
        #10;
        $display("Input: %h | Expected Avg: 255 | Calculated Avg: %d", in, avg_out);

        // Test case 5 (Random values)
        in = {8'd12, 8'd34, 8'd56, 8'd78, 8'd90, 8'd123, 8'd145, 8'd167, 8'd189}; // Custom input
        #10;
        $display("Input: %h | Expected Avg: Manual Calculation | Calculated Avg: %d", in, avg_out);

        $display("aluavg72 Testbench Completed.");
        $stop;
    end
endmodule