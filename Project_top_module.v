
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module Project_top_module(

	//////////// SEG7 //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	output		     [6:0]		HEX4,
	output		     [6:0]		HEX5,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// SW //////////
	input 		     [9:0]		SW
);

wire [31:0] reg_out, PC;
hexto7seg hex_0 (.hexn(HEX0),.hex(reg_out[3:0]));
hexto7seg hex_1 (.hexn(HEX1),.hex(reg_out[7:4]));

assign HEX2 = 7'b1111111;
assign HEX3 = 7'b1111111;

hexto7seg hex_4 (.hexn(HEX4),.hex(PC[3:0]));
hexto7seg hex_5 (.hexn(HEX5),.hex(PC[7:4]));

Multi_Cycle_Computer topmodule(.clk(~KEY[0]),.reset(~KEY[1]),.debug_reg_select(SW[3:0]),
.debug_reg_out(reg_out),.fetchPC(PC));

endmodule
