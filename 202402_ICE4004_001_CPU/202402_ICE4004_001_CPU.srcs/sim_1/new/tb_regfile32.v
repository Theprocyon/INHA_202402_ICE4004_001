`timescale 1ns / 1ps

module tb_regfile32;

    reg clk;
    reg reset;
    reg [1:0] control;
    reg [31:0] input_data0, input_data1, input_data2;
    reg [4:0] input_addr2, output_addr1, output_addr2;
    wire [31:0] output_data0, output_data1, output_data2;


    regfile32 uut (
        .clk(clk),
        .reset(reset),
        .control(control),
        .input_data0(input_data0),
        .input_data1(input_data1),
        .input_data2(input_data2),
        .input_addr2(input_addr2),
        .output_addr1(output_addr1),
        .output_addr2(output_addr2),
        .output_data0(output_data0),
        .output_data1(output_data1),
        .output_data2(output_data2)
    );


    always #5 clk = ~clk;

    initial begin
        // Monitor all signals
        $monitor("Time=%0t | reset=%b | control=%b | input_data0=%h, input_data1=%h, input_data2=%h | input_addr2=%h, output_addr1=%h, output_addr2=%h | output_data0=%h, output_data1=%h, output_data2=%h",
            $time, reset, control, input_data0, input_data1, input_data2, input_addr2, output_addr1, output_addr2, output_data0, output_data1, output_data2);
        
        // Initialize signals
        clk = 0;
        reset = 1;
        control = 0;
        input_data0 = 32'd0;
        input_data1 = 32'd0;
        input_data2 = 32'd0;
        input_addr2 = 5'd0;
        output_addr1 = 5'd1;
        output_addr2 = 5'd1;

        // Reset Refgile
        #10 reset = 0;
        #10 reset = 1;

        // Test Case 1: control = 1 (idle)
        
        output_addr1 = 5'd1;
        output_addr2 = 5'd1;
        
        control = 2'd1;
        input_data2 = 32'hDEAD_BEEF;
        input_addr2 = 5'd1;
        #10;

        control = 2'd0;
        output_addr1 = 5'd1;
        output_addr2 = 5'd0;
        #10;

        // Test Case 3: control = 2 (read specific registers)
        control = 2'd2;
        #10;

        // Test Case 4: control = 3 (write enable for all ports)
        control = 2'd3;
        input_data0 = 32'h1234_5678;
        input_data1 = 32'h8765_4321;
        input_data2 = 32'h5555_5555;
        #10;

       // Test Case 5:
        control = 2'd2;
        #10;

        // Return to idle
        control = 2'd0;
        #10;

        // Finish simulation
        $stop;
    end

endmodule

