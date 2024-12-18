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
    input zero,          // Zero for beq
    //k// ADD           : 6'b000000 (0)     implemented
    //k// SUB           : 6'b000001 (1)     implemented
    //p// CMP           : 6'b000010 (2)     .
    //p// MUL           : 6'b000011 (3)     implemented
    //p// BN            : 6'b010000 (16)    .
    //p// BEQ           : 6'b010001 (17)    .
    //k// ADDI          : 6'b011000 (24)    implemented
    //k// SUBI          : 6'b011001 (25)    implemented
    //k// LOAD          : 6'b011010 (26)    .
    //k// STORE         : 6'b011011 (27)    .
    //k// MOVS          : 6'b011100 (28)    .
    //p// LSL           : 6'b011101 (29)    implemented
    //p// RSL           : 6'b011110 (30)    implemented
    //p// MULI          : 6'b011111 (31)    implemented
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
    output reg       RegInSrc, // 0 1
    output reg [1:0] RegWriteMode, // 00 01 10 11
    output reg [1:0] ALUSrcX, // 00 01 10
    output reg [1:0] ALUSrcY, // 00 01 10 11
    output reg [3:0] ALUFunc, // 0(+) 1(-)
    //4'b0000:// ADD
    //4'b0001:// SUB
    //4'b0010:// SLL
    //4'b0011:// SRL
    //4'b0100:// MUL
    output reg [1:0] ALUSel, // 00 01 10
    output reg GADDSUB,
    output reg ZRegWrite,
    output reg [1:0] PCSrc, // 00 01 10 11
    
    output [4:0] state
);

    // Define FSM states
    localparam s0  = 5'b00000; // Fetch                     //k//
    localparam s1  = 5'b00001; // Decode                    //k//
    localparam s2  = 5'b00010; // Execute ADD/SUB           //k//
    localparam s3  = 5'b00011; // Write Back ADD/SUB        //k//
    localparam s4  = 5'b00100; // Execute ADDI/SUBI         //k//
    localparam s5  = 5'b00101; // Write Back ADDI/SUBI      //k//
    localparam s6  = 5'b00110; // Execute STORE/LOAD        //k//
    localparam s7  = 5'b00111; // Memory Write (STORE)      //k//
    localparam s8  = 5'b01000; // Memory Read (LOAD)        //k//
    localparam s9  = 5'b01001; // Write Back2 (LOAD)        //k//
    localparam s10 = 5'b01010; // Execute MOVS              //k//
    localparam s11 = 5'b01011; // Write Back MOVS           //k//
    localparam s12 = 5'b01100; // Shift                     //p//
    localparam s14 = 5'b01110; // CPY                       //p//
    localparam s15 = 5'b01111; // MULI                      //p//
    localparam s16 = 5'b10000; // BN                        //p//
    localparam s17 = 5'b10001; // (WB)                      //p//
    localparam s18 = 5'b10010; // BN_TRUE                   //p//
    localparam s19 = 5'b10011; // BN_FALSE                  //p//
    localparam s20 = 5'b10100; // Write Back1 (LOAD)        //s//
    localparam s21 = 5'b10101; // GADD9B,GSUB9B,GAVG9B      //s//
    localparam s22 = 5'b10110; // GADD9B,GSUB9B Ex          //s//
    localparam s23 = 5'b10111; // GADD9B,GSUB9B Wb          //s//
    localparam s24 = 5'b11000; // GAVG9B Ex                 //s//
    localparam s25 = 5'b11001; // GAVG9B Wb                 //s//
    localparam s26 = 5'b11010; // GLOAD, GSTORE F           //s//  unused
    localparam s27 = 5'b11011; //                           //s//
    localparam s28 = 5'b11100; //                           //s//
    localparam s29 = 5'b11101; //                           //s//
    localparam s30 = 5'b11110; //                           //s//

    reg [4:0] current_state, next_state;

    // State transition logic
    always @(posedge clk or negedge reset) begin
        if (!reset) 
            current_state <= s0; // reset to Fetch state
        else 
            current_state <= next_state;
    end
    
    assign state = current_state;

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
        RegInSrc = 1'b0;
        RegWriteMode = 2'b00;
        ALUSrcX = 2'b00;
        ALUSrcY = 2'b00;
        ALUFunc = 2'b00;
        ALUSel = 2'b00;
        GADDSUB = 0;
        ZRegWrite = 0;
        PCSrc = 2'b00;
        $display("Current controller state : %d", current_state);

        case (current_state)
            s0: begin // Fetch
                InstData = 2'b00; // 00(Inst)
                MemRead = 1;
                IRWrite = 1;
                ALUSrcX = 2'b00;
                ALUSrcY = 2'b00;
                ALUFunc = 4'b0000; // 00(+)    //4'b0000:// ADD
                PCSrc = 2'b11;
                PCWrite = 1;
                ALUSel = 2'b00;
                next_state = s1; //Decode
             end

            s1: begin // Decode
                IRWrite = 0;
                // ADD: 6'b000000 (0)
                // SUB: 6'b000001 (1)
                // ADDI: 6'b011000 (24)
                // SUBI: 6'b011001 (25)
                // LOAD: 6'b011010 (26)
                // STORE: 6'b011011 (27)
                // MOVS: 6'b011100 (28)
                case (opcode)
                    6'b000000, 6'b000001            : next_state = s2;  // Execute ADD/SUB
                    6'b011000, 6'b011001            : next_state = s4;  // Execute ADDI/SUBI
                    6'b011010, 6'b011011            : next_state = s6;  // Execute STORE/LOAD
                    6'b011101, 6'b011110            : next_state = s12; // LSL, LSR
                    6'b011111                       : next_state = s15; // MULI
                    6'b000011                       : next_state = s17; // MUL
                    6'b011100                       : next_state = s10; // Execute MOVS
                    6'b011010                       : next_state = s6;
                    6'b100000, 6'b100001, 6'b100100 : begin             // GADD9B, GSUB9B, GAVG9B
                        RegWriteMode = 2'b10;
                        next_state = (opcode == 6'b100100) ? s24: s22;
                    end
                    6'b100010, 6'b100011            : next_state = s27;
                    default: next_state = s0;                           // Default: FETCH
                endcase
            end

            s2: begin // Execute ADD/SUB
                ALUSel = 2'b00;
                ALUSrcX = 2'b01;
                ALUSrcY = 2'b01;
                ALUFunc = (opcode == 6'b000000) ? 4'b0000 : 4'b0001; // 6'b000000: ADD, ADD(00) SUB(01)
                ZRegWrite = 1;
                next_state = s3;
            end

            s3: begin // Write Back Reg ALU Inst
                RegDst = 3'b001;
                RegInSrc = 1'b1;
                RegWriteMode = 2'b01;
                next_state = s0;
            end

            s4: begin // Execute ADDI/SUBI
                ALUSel = 2'b00;
                ALUSrcX = 2'b01;
                ALUSrcY = 2'b10;
                ALUFunc = (opcode == 6'b011000) ? 4'b0000 : 4'b0001; // 6'b011000: ADDI, ADD(00) SUB(01)
                ZRegWrite = 1;
                next_state = s5;
            end

            s5: begin // Write Back Imm ALU Inst.
                RegDst = 3'b000;
                RegInSrc = 1'b1;
                RegWriteMode = 2'b01;
                next_state = s0;
            end

            s6: begin // Execute STORE/LOAD 241218 shs
                ALUFunc = 4'b0000; // ADD(00)
                ALUSel = 2'b00;
                ALUSrcX = 2'b01;
                ALUSrcY = 2'b10;
                ZRegWrite = 1;
                next_state = (opcode == 6'b011011) ? s7 : s8; // 6'b011011: STORE
            end

            s7: begin // Memory Write (STORE)
                InstData = 2'b01;
                MemWrite = 1'b1;
                DataSrcSel = 2'b00;
                next_state = s0;
            end

            s8: begin // Memory Read (LOAD)
                InstData = 2'b01;
                MemRead = 1;
                next_state = s9;
            end

            s20: begin //Write Back1 (LOAD)
                next_state = s9;
            end

            s9: begin // Write Back2 (LOAD)
                RegDst = 3'b000;
                RegInSrc = 1'b0;
                RegWriteMode = 2'b01;
                next_state = s0;
            end

            s10: begin // Execute MOVS
                // ALUSrcX = 2'b10;
                // ALUSrcY = 2'b10;
                // ALUFunc = 2'b00; // ADD(00)
                // ALUSel = 2'b00;
                // ZRegWrite = 1;
                next_state = s11;
            end
            
            s11: begin // Write Back MOVS
                // RegDst = 3'b001;
                // RegInSrc = 2'b01;
                // RegWriteMode = 2'b01;
                next_state = s0;
            end

            s12: begin // Shift
                ALUSel = 2'b00;
                ALUSrcX = 2'b01;
                ALUSrcY = 2'b10;
                ALUFunc = (opcode == 6'b011110) ? 4'b0011 : 4'b0010; // rsl lsl

                ZRegWrite = 1;
                next_state = s5;
            end
            s14: begin // CPY     
                // ALUFunc = 'NOP, pass the source reg';
                // ALUSrcX = 1;
                // AluSel = 0;
                // ZRegWrite = 1;
                next_state = s0;
            end
            s15: begin // MULI
                ALUSel  = 2'b00;
                ALUSrcX = 2'b01;
                ALUSrcY = 2'b10;
                ALUFunc = 4'b0100; // Multiply
                ZRegWrite = 1;
                next_state = s5;
            end
            s16: begin // BN      
                next_state = s0;
            end
            s17: begin // MUL  
                ALUSel = 2'b00;
                ALUSrcX = 2'b01;
                ALUSrcY = 2'b01;
                ALUFunc = 4'b0100; // Multiply
                ZRegWrite = 1;
                next_state = s3;
            end
            s18: begin // BN_TRUE 
                next_state = s0;
            end
            s19: begin // BN_FALSE
                next_state = s0;
            end

            s21: begin// GADD9B,GSUB9B,GAVG9B unused
                next_state = s0;                
            end 
            s22: begin// GADD9B,GSUB9B Ex    
                GADDSUB = (opcode == 6'b100000) ? 1'b0 : 1'b1;
                ZRegWrite = 1'b1;
                ALUSel = 2'b10;
                next_state = s23;
            end 
            s23: begin// GADD9B,GSUB9B Wb  
                RegWriteMode = 2'b11;
                RegInSrc = 1'b1;
                next_state = s0;
            end 
            s24: begin// GAVG9B Ex       
                ALUSel = 2'b01;
                ZRegWrite = 1'b1;
                next_state = s25;
            end 
            s25: begin// GAVG9B Wb
                RegWriteMode = 2'b01;
                RegInSrc = 1'b1;
                RegDst = 1'b1; //rd
                next_state = s0;
            end 
            s26: begin// GLOAD, GSTORE F     
                next_state = s0;
            end 
            s27:begin
                next_state = s0;
            end
            s28:begin
                next_state = s0;
            end
            s29:begin
                next_state = s0;
            end
            s30:begin
                next_state = s0;
            end
            default: begin
                next_state = s0;
            end
        endcase
    end
endmodule
