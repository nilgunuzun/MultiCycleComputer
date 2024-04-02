module Multi_Cycle_Computer(input reset, 
						input clk, output [31:0] fetchPC, 
						input [3:0] debug_reg_select, output [31:0] debug_reg_out
						);


wire [31:0] Instr; 
wire RegWrite,MemWrite, MemtoReg, WDSrc, IRWrite, PCWrite, AdrSrc; 
wire [3:0] ALUControl;
wire [2:0] RegSrc;
wire [1:0] ImmSrc;
wire Z;
wire [1:0] ALUSrcB, shamtSrc, ResultSrc;
wire ALUSrcA, shifterSrc, shSrc;



controller control(.clk(clk), .Z(Z),.reset(reset),
.Cond(Instr[31:28]),		// Opcode Instr[31:28]
.Op(Instr[27:26]),			//	Opcode Instr[27:26]
.Funct(Instr[25:20]),		// Opcode Instr[25:20]

.RD(Instr[15:12]),

.RegWrite(RegWrite),
.MemWrite(MemWrite),
.PCWrite(PCWrite), 
.WDSrc(WDSrc),
.ALUSrcA(ALUSrcA), 
.shifterSrc(shifterSrc),
.IRWrite(IRWrite),
.AdrSrc(AdrSrc),.shSrc(shSrc),
.ALUControl(ALUControl),
.RegSrc(RegSrc),
.ImmSrc(ImmSrc),
.ALUSrcB(ALUSrcB), 
.shamtSrc(shamtSrc), 
.ResultSrc(ResultSrc));

datapath my_datapath(.reset(reset), 
						.clk(clk), .fetchPC(fetchPC), .debug_reg_select(debug_reg_select), .debug_reg_out(debug_reg_out),
						.Instr(Instr),		// Opcode Instr[31:28]

						.RegWrite(RegWrite),
						.MemWrite(MemWrite),
						.PCWrite(PCWrite), 
						.WDSrc(WDSrc),
						.ALUSrcA(ALUSrcA), 
						.shifterSrc(shifterSrc),
						.IRWrite(IRWrite),
						.AdrSrc(AdrSrc),.shSrc(shSrc),
						.ALUControl(ALUControl),
						.RegSrc(RegSrc),
						.ImmSrc(ImmSrc),
						.ALUSrcB(ALUSrcB), 
						.shamtSrc(shamtSrc), 
						.ResultSrc(ResultSrc),
						.Z(Z));

endmodule