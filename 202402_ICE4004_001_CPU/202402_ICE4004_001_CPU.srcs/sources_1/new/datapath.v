`timescale 1ns / 1ps

module datapath(
    input clk, 
    input rst,
    output [4:0] state
    );

    //Control Signals
    wire        PCWrite;
    wire [1:0]  InstData;
    wire [1:0]  DataSrcSel;
    wire        MemRead;
    wire        MemWrite;
    wire        IRWrite;
    wire [2:0]  RegDst;
    wire        RegInSrc;
    wire [1:0]  RegWriteMode;
    wire        GADDSUB;
    wire [1:0]  ALUSrcX;
    wire [1:0]  ALUSrcY;
    wire [3:0]  ALUFunc;
    wire [1:0]  ALUSel;
    wire        ZRegWrite;
    wire [1:0]  PCSrc;


    //flags

    wire zero;


    // PC
    wire [31:0] MUX_to_PC; //Data input of PC
    wire [31:0] PC_to_MUX; //Data output of PC
    
    reg32 PC(
        .clk(clk),
        .rst(rst),
        .we(PCWrite),
        .d(MUX_to_PC),
        .q(PC_to_MUX)
    );



    // InstDataMux
    wire [31:0] ZReg_Out;
    wire [31:0] ZReg_to_InstDataMUX_4;
    wire [31:0] ZReg_to_InstDataMUX_8;

    wire [31:0] InstDataMux_to_Cache;

    assign ZReg_to_InstDataMUX_4 = ZReg_Out      + 4; //for auto inc. load & store
    assign ZReg_to_InstDataMUX_8 = ZReg_to_InstDataMUX_4    + 4; //for auto inc. load & store


    mux4_32 MUX_InstData(
        .in0(PC_to_MUX),
        .in1(ZReg_Out),
        .in2(ZReg_to_InstDataMUX_4),
        .in3(ZReg_to_InstDataMUX_8),
        .sel(InstData),
        .out(InstDataMux_to_Cache)
    );



    // DataSrcSel Mux

    wire [31:0] rs0_Out;
    wire [31:0] rs1_Out;
    wire [31:0] rs2_Out;


    wire [31:0] DataSrcSelMUX_to_Cache;

    mux4_32 MUX_DataSrcSel(
    .in0(rs2_Out),
    .in1(rs1_Out),
    .in2(rs0_Out),
    .in3(32'h0000),
    .sel(DataSrcSel),
    .out(DataSrcSelMUX_to_Cache)
    );

    

    // I + D $ (Cache)

    wire [31:0] Cache_to_regs;

    cache IDCache(
    .clk(clk),
    .write_enable(MemWrite),
    .read_enable(MemRead),
    .address(InstDataMux_to_Cache),
    .write_data(DataSrcSelMUX_to_Cache),
    .read_data(Cache_to_regs)
    );


    // Inst reg

    wire [5:0] opcode;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] dest;
    wire [15:0] imm;
    wire [25:0] jta;

    wire [31:0] InstReg_Out;
    
    assign opcode   = InstReg_Out[31:26]; 
    assign rs1      = InstReg_Out[25:21]; 
    assign rs2      = InstReg_Out[20:16]; 
    assign dest     = InstReg_Out[4:0];
    assign imm      = InstReg_Out[15:0];
    assign jta      = InstReg_Out[25:0];

    reg32 InstReg(
        .clk(clk),
        .rst(rst),
        .we(IRWrite),
        .d(Cache_to_regs),
        .q(InstReg_Out)
    );



    // Data reg

    wire [31:0] DataReg_to_RegInSrcMux;

    reg32 DataReg(
        .clk(clk),
        .rst(rst),
        .we(1'b1),
        .d(Cache_to_regs),
        .q(DataReg_to_RegInSrcMux)
    );

    // RegDstMux
    

    wire [4:0] RegDstMux_to_RegFileWriteAddr;

    mux5_5 MUX_RegDst(
        .in0(rs2),
        .in1(dest),
        .in2(5'd0),
        .in3(5'd1),
        .in4(5'd2),
        .sel(RegDst),
        .out(RegDstMux_to_RegFileWriteAddr)
    );



    //RegInSRcMux

    wire [31:0] RegInSrcMux_to_RegFileData;

    mux2_32 MUX_RegInSrc (
        .in0(DataReg_to_RegInSrcMux),
        .in1(ZReg_Out),
        .sel(RegInSrc),
        .out(RegInSrcMux_to_RegFileData)
    );


    //RegFile

    wire [31:0] RegFile_to_rs0;
    wire [31:0] RegFile_to_rs1;
    wire [31:0] RegFile_to_rs2;
    
    
    wire [31:0] xreg_out;
    wire [31:0] yreg_out;
    
    regfile32 RegFile(
        .clk(clk),
        .reset(rst),
        .control(RegWriteMode),
        .input_data0(xreg_out),                                 //Greg
        .input_data1(yreg_out),                                 //Greg
        .input_data2(RegInSrcMux_to_RegFileData),       //General regfile write.port
        .input_addr2(RegDstMux_to_RegFileWriteAddr),    //General regfile write.port
        .output_addr1(rs1),
        .output_addr2(rs2),
        .output_data0(RegFile_to_rs0),
        .output_data1(RegFile_to_rs1),
        .output_data2(RegFile_to_rs2)
    );


    //rs0


    reg32 Reg_rs0 (
        .clk(clk),
        .rst(rst),
        .we(1'b1),
        .d(RegFile_to_rs0),
        .q(rs0_Out)
    );

    //rs1

    reg32 Reg_rs1 (
        .clk(clk),
        .rst(rst),
        .we(1'b1),
        .d(RegFile_to_rs1),
        .q(rs1_Out)
    );


    //rs2


    reg32 Reg_rs2 (
        .clk(clk),
        .rst(rst),
        .we(1'b1),
        .d(RegFile_to_rs2),
        .q(rs2_Out)
    );



    //9 * 8bit saturating adder, subtractor

    wire [71:0] alusat_a;
    wire [7:0]  imm_trunc8;

    assign alusat_a     = {rs0_Out, rs1_Out, rs2_Out[7:0]};
    assign imm_trunc8   = imm[7:0];


    wire [71:0] alusat_out;

    wire [31:0] alusat_out_x;
    wire [31:0] alusat_out_y;
    wire [31:0] alusat_out_z;

    assign alusat_out_x = alusat_out[71:40];
    assign alusat_out_y = alusat_out[39:8];
    assign alusat_out_z = {24'b0, alusat_out[7:0]};

        
    // initial begin
    //     $monitor("imm_trunc8 : %h", imm_trunc8);    
    // end

    alusat72 ALU_Sat72(
        .a(alusat_a),
        .b(imm_trunc8),
        .mode(GADDSUB),
        .result(alusat_out)
    );




    //9 * 8bit average calculator

    wire [31:0] aluavg_out;

    aluavg72 ALU_Avg72(
        .in(alusat_a),
        .avg_out(aluavg_out)
    );



    //ALUSrcX MUX

    wire [31:0] MUX_to_ALUX;

    mux4_32 MUX_ALUSrcX(
        .in0(PC_to_MUX),
        .in1(rs1_Out),
        .in2(32'd0),
        .in3(32'd0),
        .sel(ALUSrcX),
        .out(MUX_to_ALUX)
    );


    //ALUSrcY MUX

    wire [31:0] MUX_to_ALUY;
    
    wire [31:0] SE_imm; 
    wire [31:0] SE_imm_x4;

    assign SE_imm = {24'b0, imm};
    assign SE_imm_x4 = SE_imm << 2;
    
    mux4_32 MUX_ALUSrcY(
        .in0(32'd4),
        .in1(rs2_Out),
        .in2(SE_imm),
        .in3(SE_imm_x4),
        .sel(ALUSrcY),
        .out(MUX_to_ALUY)
    );


    //ALU32

    wire [31:0] ALU_out;

    alu32 alu32( 
        .x(MUX_to_ALUX),
        .y(MUX_to_ALUY),
        .f(ALUFunc),
        .s(ALU_out),
        .zero(zero)
    );



    //MUX_ALUSel

    wire [31:0] ALUSel_out;

    mux4_32 MUX_ALUSel(
        .in0(ALU_out),
        .in1(aluavg_out),
        .in2(alusat_out_z),
        .in3(32'd0),
        .sel(ALUSel),
        .out(ALUSel_out)
    );


    //x reg

    reg32 xreg(
        .clk(clk),
        .rst(rst),
        .we(1'b1),
        .d(alusat_out_x),
        .q(xreg_out)
    );


    //y reg

    reg32 yreg(
        .clk(clk),
        .rst(rst),
        .we(1'b1),
        .d(alusat_out_y),
        .q(yreg_out)
    );

    //z reg

    reg32 zreg(
        .clk(clk),
        .rst(rst),
        .we(ZRegWrite),
        .d(ALUSel_out),
        .q(ZReg_Out)
    );

    initial begin
        $monitor("outregs x : %h , y : %h , z : %h ", xreg_out, yreg_out, ZReg_Out);
    end


    //MUX_PCSrc
    wire PCSrc_jta;

    assign PCSrc_jta = {PC_to_MUX[31:28], jta, 2'b00};

    mux4_32 MUX_PCSrc(
        .in0(PCSrc_jta),
        .in1(rs1),
        .in2(ZReg_Out),
        .in3(ALUSel_out),
        .sel(PCSrc),
        .out(MUX_to_PC)
    );

    //control

    control multicycle_control(

        //inputs
        .clk(clk),
        .reset(rst),
        .opcode(opcode),
        .zero(zero),

        //outputs
        .DataSrcSel(DataSrcSel),
        .PCWrite(PCWrite),
        .InstData(InstData),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .IRWrite(IRWrite),
        .RegDst(RegDst),
        .RegInSrc(RegInSrc),
        .RegWriteMode(RegWriteMode),
        .ALUSrcX(ALUSrcX),
        .ALUSrcY(ALUSrcY),
        .ALUFunc(ALUFunc),
        .ALUSel(ALUSel),
        .GADDSUB(GADDSUB),
        .ZRegWrite(ZRegWrite),
        .PCSrc(PCSrc),
        
        .state(state)
    );


endmodule
