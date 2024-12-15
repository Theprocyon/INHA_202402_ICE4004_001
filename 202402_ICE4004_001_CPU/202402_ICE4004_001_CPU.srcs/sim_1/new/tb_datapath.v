`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: thep
// 
// Create Date: 2024/12/09 01:17:35
// Design Name: 
// Module Name: tb_datapath.v
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_datapath;

reg clk;
reg rst;

wire [4:0] state;

datapath CPU (
    .clk(clk),
    .rst(rst),
    .state(state) // state monitoring용
);

initial begin
    clk = 0;
    forever #5 clk = ~clk; 
end

initial begin

    rst = 0; //rst
    #15;
    rst = 1; 

    $monitor("Time: %0t | PC: %h | ALU_out: %h | ZReg_Out: %h | Refgile_to_rs1 : %h | RegInSrcMux_to_RegFileData : %h | RegDstMux_to_RegFileWriteAddr : %h | RegWriteMode : %h | State: %b", 
             $time, CPU.PC_to_MUX, CPU.ALU_out, CPU.ZReg_Out, CPU.RegFile_to_rs1, CPU.RegInSrcMux_to_RegFileData, CPU.RegDstMux_to_RegFileWriteAddr, CPU.RegWriteMode, state);
    $monitor("Time: %0t | opcode: %b | rs1: %b | rs2: %b | dest: %b | imm : %h | jta : %b", 
             $time, CPU.opcode, CPU.rs1, CPU.rs2,CPU.dest, CPU.imm, CPU.jta);
    



    #800;
    $finish; 
end

endmodule
