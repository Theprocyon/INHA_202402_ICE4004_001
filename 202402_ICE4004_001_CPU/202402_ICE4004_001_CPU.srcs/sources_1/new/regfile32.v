`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
//  0 : idle (아무것도 안함. 출력은 하나, write 하지 않음)
//  1 : 0번 input 포트의 write enable
//  2 : 1번, 2번 출력 포트의 read address 는 각각 1번, 2번 레지스터를 가리킴.
//  3 : 모든 포트의 write enable
//
// 
//////////////////////////////////////////////////////////////////////////////////

module regfile32 (
    input wire clk,
    input wire reset,
    input wire [1:0] control,       // 2-bit control signal
    input wire [31:0] input_data0,  // Input data for port 0
    input wire [4:0] input_addr0,  // Input data for port 0
    input wire [31:0] input_data1,  // Input data for port 1
    input wire [31:0] input_data2,  // Input data for port 2
    input wire [4:0] output_addr1,  // output addr 1
    input wire [4:0] output_addr2,  // output addr 2
    output wire [31:0] output_data0, // Output data for port 0
    output wire [31:0] output_data1, // Output data for port 1
    output wire [31:0] output_data2  // Output data for port 2
);

    // Internal signals for reg_file instance
    wire [4:0] read_addr1, read_addr2, read_addr3;
    wire [4:0] write_addr1, write_addr2, write_addr3;
    wire [31:0] write_data1, write_data2, write_data3;
    wire write_enable1, write_enable2, write_enable3;

    // Address mapping
    assign read_addr1 = 5'd0;       
    assign read_addr2 = (control == 2'd2) ? 5'd1 : output_addr1; 
    assign read_addr3 = (control == 2'd2) ? 5'd2 : output_addr2; 

    assign write_addr1 = (control == 2'd1) ? input_addr0 : 5'd0;  
    assign write_addr2 = 5'd1;     
    assign write_addr3 = 5'd2;     

    // Data mapping
    assign write_data1 = input_data0; 
    assign write_data2 = input_data1; 
    assign write_data3 = input_data2; 

    // Write enable logic
    assign write_enable1 = (control == 2'd1) || (control == 2'd3);
    assign write_enable2 = (control == 2'd3);                     
    assign write_enable3 = (control == 2'd3);                     

    // Instantiate reg_file
    regfile3i3o32b u_reg_file (
        .clk(clk),
        .reset(reset),
        .read_addr1(read_addr1),
        .read_addr2(read_addr2),
        .read_addr3(read_addr3),
        .write_addr1(write_addr1),
        .write_addr2(write_addr2),
        .write_addr3(write_addr3),
        .write_data1(write_data1),
        .write_data2(write_data2),
        .write_data3(write_data3),
        .write_enable1(write_enable1),
        .write_enable2(write_enable2),
        .write_enable3(write_enable3),
        .read_data1(output_data0),
        .read_data2(output_data1),
        .read_data3(output_data2)
    );

endmodule