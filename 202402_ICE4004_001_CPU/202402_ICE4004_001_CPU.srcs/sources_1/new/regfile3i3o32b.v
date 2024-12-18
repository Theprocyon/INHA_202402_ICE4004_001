`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/01 19:13:02
// Design Name: 
// Module Name: regfile3i3o32b
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

module regfile3i3o32b (
    input wire clk,
    input wire reset,
    input wire [4:0] read_addr1,  // Read port 1 address
    input wire [4:0] read_addr2,  // Read port 2 address
    input wire [4:0] read_addr3,  // Read port 3 address
    input wire [4:0] write_addr1, // Write port 1 address
    input wire [4:0] write_addr2, // Write port 2 address
    input wire [4:0] write_addr3, // Write port 3 address
    input wire [31:0] write_data1, // Write port 1 data
    input wire [31:0] write_data2, // Write port 2 data
    input wire [31:0] write_data3, // Write port 3 data
    input wire write_enable1,      // Write enable for port 1
    input wire write_enable2,      // Write enable for port 2
    input wire write_enable3,      // Write enable for port 3
    output wire [31:0] read_data1, // Read port 1 data
    output wire [31:0] read_data2, // Read port 2 data
    output wire [31:0] read_data3  // Read port 3 data
);
    integer i;
    // 32 registers, each 32 bits wide
    reg [31:0] reg_file [31:0];
    
    integer j; // 루프 변수
    integer logfile; // 파일 핸들

    // 값이 변경될 때마다 모든 레지스터 값을 파일에 기록
    always @(reg_file) begin
        for (j = 0; j < 16; j = j + 1) begin
            $fdisplay(logfile, "%0d : %h", j, reg_file[j]); // 레지스터 번호와 16진수 값 기록
        end
        $fdisplay(logfile, ""); // 줄 바꿈
    end

    // 테스트 및 초기화
    initial begin
        // 로그 파일 열기 (파일 이름: reg_file_log.txt, 쓰기 모드)
        logfile = $fopen("reg_file_log.txt", "w");
        if (logfile == 0) begin
            $display("Error: Failed to open file.");
            $stop;
        end
    end
    
    // Read logic
    assign read_data1 = reg_file[read_addr1];
    assign read_data2 = reg_file[read_addr2];
    assign read_data3 = reg_file[read_addr3];

    // Write logic
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                reg_file[i] <= 32'b0; // Reset all registers to 0
            end
        end else begin
            if (write_enable1) begin
                reg_file[write_addr1] <= write_data1;
            end
            if (write_enable2) begin
                reg_file[write_addr2] <= write_data2;
            end
            if (write_enable3) begin
                reg_file[write_addr3] <= write_data3;
            end
        end
    end

endmodule
