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

    $monitor("Time: %0t | PC: %h | ALU_out: %h | ZReg_Out: %h | State: %b", 
             $time, CPU.PC_to_MUX, CPU.ALU_out, CPU.ZReg_Out, state);

    rst = 1; //rst
    #15;
    rst = 0; 

    #200;
    $finish; 
end

endmodule
