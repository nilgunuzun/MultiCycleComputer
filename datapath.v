module datapath(input reset, 
						input clk, output [31:0] fetchPC, output Z,
						input [3:0] debug_reg_select, output [31:0] debug_reg_out, output [31:0] Instr,
						input RegWrite,MemWrite,PCWrite, WDSrc,ALUSrcA, shifterSrc,IRWrite,AdrSrc,shSrc,
						input [3:0] ALUControl,
						input [2:0] RegSrc,
						input [1:0] ImmSrc,ALUSrcB, shamtSrc, ResultSrc
						);


wire [31:0] SrcA, SrcB, ALUResult, ALUOut, Result, ReadData, Data, Adr, WD;
wire [31:0] PC;  
wire [3:0] RA1, RA2,RA3;
wire [31:0] WriteData, A, RD1, RD2;
wire [31:0] ExtImm, shifterout, shifterSrcout;

wire CO,OVF,N, CI;
wire [4:0] shamtSrcin,shamtSrcout;
wire [1:0] sh;

assign fetchPC = PC;

Register_rsten #(32) PCreg(.clk(clk),.reset(reset),.we(PCWrite),.DATA(Result),.OUT(PC));

Mux_2to1 #(32) adrmux(.select(AdrSrc),.input_0(PC), .input_1(Result),.output_value(Adr));

ID_memory IDM(.clk(clk),.WE(MemWrite),.ADDR(Adr),.WD(WriteData),.RD(ReadData) );

Register_en #(32) InstrReg(.clk(clk),.en(IRWrite),.DATA(ReadData),.OUT(Instr));
Register_simple #(32) DataReg(.clk(clk),.DATA(ReadData),.OUT(Data));

Mux_2to1 #(4) RA1mux(.select(RegSrc[0]),.input_0(Instr[19:16]), .input_1(4'b1111),.output_value(RA1));
Mux_2to1 #(4) RA2mux(.select(RegSrc[1]),.input_0(Instr[3:0]), .input_1(Instr[15:12]),.output_value(RA2));
Mux_2to1 #(4) RA3mux(.select(RegSrc[2]),.input_0(Instr[15:12]), .input_1(4'b1110),.output_value(RA3));
Mux_2to1 #(32) WDmux(.select(WDSrc),.input_0(Result), .input_1(PC),.output_value(WD));

Register_file #(32) regfile (.clk(clk), .write_enable(RegWrite), .reset(reset),
.Source_select_0(RA1), .Source_select_1(RA2), .Debug_Source_select(debug_reg_select), 
.Destination_select(RA3),.DATA(WD), .Reg_15(Result),.out_0(RD1), .out_1(RD2), 
.Debug_out(debug_reg_out) );

Register_simple #(32) RD1Reg (.clk(clk),.DATA(RD1),.OUT(A));
Register_simple #(32) RD2Reg (.clk(clk),.DATA(RD2),.OUT(WriteData));

Extender extend(.Extended_data(ExtImm),.DATA(Instr[23:0]),.select(ImmSrc));

shifter #(5) shifterextra(.control(2'b00),.shamt(5'h1),.DATA({1'b0, Instr[11:8]}),.OUT(shamtSrcin));

Mux_4to1 #(5) shamtSrcmux(.select(shamtSrc),.input_0(Instr[11:7]), .input_1(shamtSrcin), .input_2(5'h0), .input_3(5'h0),
     .output_value(shamtSrcout));
	  
Mux_2to1 #(32) ALUSrcAmux(.select(ALUSrcA),.input_0(A), .input_1(PC),.output_value(SrcA));
Mux_2to1 #(32) shifterSrcmux(.select(shifterSrc),.input_0(WriteData), .input_1(ExtImm),.output_value(shifterSrcout));

Mux_2to1 #(2) shSrcmux(.select(shSrc),.input_0(Instr[6:5]), .input_1(2'b11),.output_value(sh));

shifter #(32) shifterr(.control(sh),.shamt(shamtSrcout),.DATA(shifterSrcout),.OUT(shifterout));

Mux_4to1 #(32) ALUSrcBmux(.select(ALUSrcB),.input_0(shifterout), .input_1(ExtImm), .input_2(32'h4), .input_3(32'h4),
     .output_value(SrcB));
	  
ALU #(32) aluu(.control(ALUControl),.CI(CI),.DATA_A(SrcA),.DATA_B(SrcB),.OUT(ALUResult),
	  .CO(CO),.OVF(OVF),.N(N), .Z(Z));
	  
Register_simple #(32) ALUOutReg (.clk(clk),.DATA(ALUResult),.OUT(ALUOut));

Mux_4to1 #(32) ResultSrcmux(.select(ResultSrc),.input_0(ALUOut), .input_1(Data), .input_2(ALUResult), .input_3(ALUResult),
     .output_value(Result));

endmodule