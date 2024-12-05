`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/06 00:14:42
// Design Name: 
// Module Name: control
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
    // ADD: 6'b000000 (0)
    // SUB: 6'b000001 (1)
    // ADDI: 6'b011000 (24)
    // SUBI: 6'b011001 (25)
    // LOAD: 6'b011010 (26)
    // STORE: 6'b011011 (27)
    // MOVS: 6'b011100 (28)
    
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
    parameter s0 = 4'b0000; // Fetch
    parameter s1 = 4'b0001; // Decode
    parameter s2 = 4'b0010; // Execute ADD/SUB
    parameter s3 = 4'b0011; // Write Back ADD/SUB
    parameter s4 = 4'b0100; // Execute ADDI/SUBI
    parameter s5 = 4'b0101; // Write Back ADDI/SUBI
    parameter s6 = 4'b0110; // Execute STORE/LOAD
    parameter s7 = 4'b0111; // Memory Write (STORE)
    parameter s8 = 4'b1000; // Memory Read (LOAD)
    parameter s9 = 4'b1001; // Write Back (LOAD)
    parameter s10 = 4'b1010; // Execute MOVS
    parameter s11 = 4'b1011; // Write Back MOVS

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
