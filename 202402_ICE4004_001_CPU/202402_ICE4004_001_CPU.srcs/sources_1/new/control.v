`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/05 14:42:35
// Design Name: 
// Module Name: FSM_processor
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


module control (
    input clk,           // Clock signal
    input reset,         // Reset signal
    input [5:0] opcode,  // 6bit Operation code (e.g., ADD, SUB, LOAD, STORE, MOVS)
    
    //k// ADD           : 6'b000000 (0)     implemented
    //k// SUB           : 6'b000001 (1)     implemented
    //p// CMP           : 6'b000010 (2)     .
    //p// MUL           : 6'b000011 (3)     .
    //p// BN            : 6'b010000 (16)    .
    //p// BEQ           : 6'b010001 (17)    .
    //k// ADDI          : 6'b011000 (24)    implemented
    //k// SUBI          : 6'b011001 (25)    implemented
    //k// LOAD          : 6'b011010 (26)    implemented
    //k// STORE         : 6'b011011 (27)    implemented
    //k// MOVS          : 6'b011100 (28)    implemented
    //p// LSL           : 6'b011101 (29)    .
    //p// RSL           : 6'b011110 (30)    .
    //p// MULI          : 6'b011111 (31)    .
    //s// GADD9B        : 6'b100000 (32)    .
    //s// GSUB9B        : 6'b100001 (33)    .
    //s// GSTORE9B      : 6'b100010 (34)    .
    //s// GLOAD9B       : 6'b100011 (35)    .
    //s// GAVG9B        : 6'b100100 (36)    .


    
    output reg [1:0] DataSrcSel, // 00 01 10
    output reg PCWrite,
    output reg [1:0] InstData, // 00(Inst) 01(Data) 10 11
    output reg MemRead,
    output reg MemWrite,
    output reg IRWrite,
    output reg [2:0] RegDst, // 000 001 010 011 100
    output reg [1:0] RegInSrc, // 00 01
    output reg [1:0] RegWriteMode, // 00 01 10 11
    output reg [1:0] ALUSrcX, // 00 01 10
    output reg [1:0] ALUSrcY, // 00 01 10 11
    output reg [3:0] ALUFunc, // 0(+) 1(-)
    output reg [1:0] ALUSel, // 00 01 10
    output reg GADDSUB,
    output reg ZRegWrite,
    output reg [1:0] PCSrc // 00 01 10 11
);

    // Define FSM states
    localparam s0  = 4'b00000; // Fetch                     //k//
    localparam s1  = 4'b00001; // Decode                    //k//
    localparam s2  = 4'b00010; // Execute ADD/SUB           //k//
    localparam s3  = 4'b00011; // Write Back ADD/SUB        //k//
    localparam s4  = 4'b00100; // Execute ADDI/SUBI         //k//
    localparam s5  = 4'b00101; // Write Back ADDI/SUBI      //k//
    localparam s6  = 4'b00110; // Execute STORE/LOAD        //k//
    localparam s7  = 4'b00111; // Memory Write (STORE)      //k//
    localparam s8  = 4'b01000; // Memory Read (LOAD)        //k//
    localparam s9  = 4'b01001; // Write Back (LOAD)         //k//
    localparam s10 = 4'b01010; // Execute MOVS              //k//
    localparam s11 = 4'b01011; // Write Back MOVS           //k//
    localparam s12 = 4'b01100; // Shift                     //p//
    localparam s13 = 4'b01101; // UXTB                      //p//
    localparam s14 = 4'b01110; // CPY                       //p//
    localparam s15 = 4'b01111; // MULI                      //p//
    localparam s16 = 4'b10000; // BN                        //p//
    localparam s17 = 4'b10001; // (WB)                      //p//
    localparam s18 = 4'b10010; // BN_TRUE                   //p//
    localparam s19 = 4'b10011; // BN_FALSE                  //p//

    reg [3:0] current_state, next_state;

    // State transition logic
    always @(posedge clk or posedge reset) begin
        if (reset) 
            current_state <= s0; // reset to Fetch state
        else 
            current_state <= next_state;
    end

    // Output and next state logic
    always @(*) begin
        // Default signal values
        DataSrcSel = 2'b00;
        PCWrite = 0;
        InstData = 2'b00;
        MemRead = 0;
        MemWrite = 0;
        IRWrite = 0;
        RegDst = 3'b000;
        RegInSrc = 2'b00;
        RegWriteMode = 2'b00;
        ALUSrcX = 2'b00;
        ALUSrcY = 2'b00;
        ALUFunc = 2'b00;
        ALUSel = 2'b00;
        GADDSUB = 0;
        ZRegWrite = 0;
        PCSrc = 2'b00;

        case (current_state)
            s0: begin // Fetch
                InstData = 2'b00; // 00(Inst)
                MemRead = 1;
                IRWrite = 1;
                ALUSrcX = 2'b00;
                ALUSrcY = 2'b00;
                ALUFunc = 2'b00; // 00(+)
                PCSrc = 2'b11;
                PCWrite = 1;
                ALUSel = 2'b00;
                next_state = s1; //Decode
             end

            s1: begin // Decode
                ALUSrcX = 2'b00;
                ALUSrcY = 2'b00;
                ALUFunc = 2'b00; // 00(+)
                RegWriteMode = 2'b00;
                // ADD: 6'b000000 (0)
                // SUB: 6'b000001 (1)
                // ADDI: 6'b011000 (24)
                // SUBI: 6'b011001 (25)
                // LOAD: 6'b011010 (26)
                // STORE: 6'b011011 (27)
                // MOVS: 6'b011100 (28)
                next_state = (opcode == 6'b000000 | opcode == 6'b000001) ? s2 : // Execute ADD/SUB
                             (opcode == 6'b011000 | opcode == 6'b011001) ? s4 : // Execute ADDI/SUBI
                             (opcode == 6'b011010 | opcode == 6'b011011) ? s6 : // Execute STORE/LOAD 
                             (opcode == 6'b011100) ? s10 : s0; // Execute MOVS, default: FETCH
            end

            s2: begin // Execute ADD/SUB
                ALUSrcX = 2'b01;
                ALUSrcY = 2'b01;
                ALUFunc = (opcode == 6'b000000) ? 2'b00 : 2'b01; // 6'b000000: ADD, ADD(00) SUB(01)
                next_state = s3;
            end

            s3: begin // Write Back ADD/SUB
                RegDst = 3'b001;
                RegInSrc = 2'b01;
                RegWriteMode = 2'b01;
                next_state = s0;
            end

            s4: begin // Execute ADDI/SUBI
                ALUSrcX = 2'b01;
                ALUSrcY = 2'b10;
                ALUFunc = (opcode == 6'b011000) ? 2'b00 : 2'b01; // 6'b011000: ADDI, ADD(00) SUB(01)
                next_state = s5;
            end

            s5: begin // Write Back ADDI/SUBI
                RegDst = 3'b000;
                RegInSrc = 2'b01;
                RegWriteMode = 2'b01;
                next_state = s0;
            end

            s6: begin // Execute STORE/LOAD
                ALUSrcX = 2'b01;
                ALUSrcY = 2'b10;
                ALUFunc = 2'b00; // ADD(00)
                ALUSel = 2'b00;
                ZRegWrite = 1;
                next_state = (opcode == 6'b011010) ? s7 : s8; // 6'b011010: STORE
            end

            s7: begin // Memory Write (STORE)
                InstData = 2'b01;
                MemWrite = 1;
                DataSrcSel = 2'b00;
                next_state = s0;
            end

            s8: begin // Memory Read (LOAD)
                InstData = 2'b01;
                MemWrite = 1;
                next_state = s9;
            end

            s9: begin // Write Back (LOAD)
                RegDst = 3'b000;
                RegInSrc = 2'b00;
                RegWriteMode = 2'b01;
                next_state = s0;
            end

            s10: begin // Execute MOVS
                ALUSrcX = 2'b10;
                ALUSrcY = 2'b10;
                ALUFunc = 2'b00; // ADD(00)
                ALUSel = 2'b00;
                ZRegWrite = 1;
                next_state = s11;
            end
            
            s11: begin // Write Back MOVS
                RegDst = 3'b001;
                RegInSrc = 2'b01;
                RegWriteMode = 2'b01;
                next_state = s0;
            end

            default: begin
                next_state = s0;
            end
        endcase
    end
endmodule
