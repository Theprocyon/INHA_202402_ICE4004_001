`timescale 1ns / 1ps

module tb_cache;

    // Inputs
    reg clk;
    reg write_enable;
    reg read_enable;
    reg [7:0] address;
    reg [31:0] write_data;

    // Outputs
    wire [31:0] read_data;

    // Instantiate the Unit Under Test (UUT)
    cache uut (
        .clk(clk),
        .write_enable(write_enable),
        .read_enable(read_enable),
        .address(address),
        .write_data(write_data),
        .read_data(read_data)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns clock period
    end

    // Test sequence
    initial begin
        // Initialize inputs
        write_enable = 0;
        read_enable = 0;
        address = 0;
        write_data = 0;

        // Wait for reset
        #10;
        
        write_enable = 1;
        address = 0;
        write_data = 32'd14;
        #10;
        write_enable = 0;

        // Sequential read of memory
        $display("Reading memory contents sequentially:");
        for (address = 0; address < 64; address = address + 1) begin
            read_enable = 1;
            #10;  // Wait for read to complete
            $display("Address %0d: Data = %h", address, read_data);
        end
        read_enable = 0;

        // End simulation
        $finish;
    end

endmodule
