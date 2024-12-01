`timescale 1ns/1ps

module tb_alusat72;

// Testbench signals
reg [71:0] a, b;    // 9개의 8-bit 입력을 병합한 72-bit 입력
reg mode;           // 0: 덧셈, 1: 뺄셈
wire [71:0] result; // 9개의 8-bit 연산 결과를 병합한 72-bit 출력

// Instantiate the saturating_add_sub_72bit module
alusat72 uut (
    .a(a),
    .b(b),
    .mode(mode),
    .result(result)
);

integer i;

initial begin
    // Test case 1: Addition without overflow
    a = {8'd10, 8'd20, 8'd30, 8'd40, 8'd50, 8'd60, 8'd70, 8'd80, 8'd90};
    b = {8'd1,  8'd2,  8'd3,  8'd4,  8'd5,  8'd6,  8'd7,  8'd8,  8'd9};
    mode = 0; #10;
    $display("Test 1: ADD");
    for (i = 0; i < 9; i = i + 1) begin
        $display("Result[%0d]: %0d (unsigned)", i, result[i*8 +: 8]);
    end

    // Test case 2: Addition with overflow
    a = {8'd250, 8'd251, 8'd252, 8'd253, 8'd254, 8'd255, 8'd100, 8'd101, 8'd102};
    b = {8'd10,  8'd10,  8'd10,  8'd10,  8'd10,  8'd10,  8'd200, 8'd200, 8'd200};
    mode = 0; #10;
    $display("Test 2: ADD with Overflow");
    for (i = 0; i < 9; i = i + 1) begin
        $display("Result[%0d]: %0d (unsigned)", i, result[i*8 +: 8]);
    end

    // Test case 3: Subtraction without underflow
    a = {8'd50, 8'd60, 8'd70, 8'd80, 8'd90, 8'd100, 8'd110, 8'd120, 8'd130};
    b = {8'd1,  8'd2,  8'd3,  8'd4,  8'd5,  8'd6,   8'd7,   8'd8,   8'd9};
    mode = 1; #10;
    $display("Test 3: SUB");
    for (i = 0; i < 9; i = i + 1) begin
        $display("Result[%0d]: %0d (unsigned)", i, result[i*8 +: 8]);
    end

    // Test case 4: Subtraction with underflow
    a = {8'd10, 8'd20, 8'd30, 8'd40, 8'd50, 8'd60, 8'd70, 8'd80, 8'd90};
    b = {8'd15, 8'd25, 8'd35, 8'd45, 8'd55, 8'd65, 8'd75, 8'd85, 8'd95};
    mode = 1; #10;
    $display("Test 4: SUB with Underflow");
    for (i = 0; i < 9; i = i + 1) begin
        $display("Result[%0d]: %0d (unsigned)", i, result[i*8 +: 8]);
    end

    // End simulation
    $finish;
end

endmodule
