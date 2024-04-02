module controller(input clk, Z,reset,
input [3:0] Cond,
input [1:0] Op,
input [5:0] Funct,
input [3:0] RD,
output reg RegWrite,MemWrite,PCWrite, WDSrc,ALUSrcA, shifterSrc,IRWrite,AdrSrc,shSrc,
output reg [3:0] ALUControl,
output reg [2:0] RegSrc,
output reg [1:0] ImmSrc,ALUSrcB, shamtSrc, ResultSrc);

reg Condition;
wire Condition_current;
reg FlagWrite;
wire ZFlagReg;
wire [3:0] State_current; 
reg [3:0] State_next;


initial begin
	State_next <= 4'h0;
	Condition <= 1;
	FlagWrite <= 0;
end	

Register_en #(1) flags_Z (.clk(clk),.en(FlagWrite),.DATA(Z),.OUT(ZFlagReg));
Register_simple #(4) StateReg(.clk(clk),.DATA(State_next),.OUT(State_current));
Register_simple #(1) CondReg(.clk(clk),.DATA(Condition),.OUT(Condition_current));

// Conditional Logic

always @(*) begin
Condition <= 1;



	case(Cond)
		// EQ
		4'b0000: 
					if(ZFlagReg == 1)
						Condition <= 1;
					else
						Condition <= 0;
		// NE
		4'b0001:	
					if(ZFlagReg == 0)
						Condition <= 1;
					else 
						Condition <= 0;
		// AL
		4'b1110:  
					Condition <= 1;
		
		default: Condition <= 1;		
	endcase		
end

//next state determination
always @(negedge clk) begin
if(reset)
	State_next <= 4'h0;
else	
	case(State_current)
		//S0:fetch
		4'b0000:
				State_next <= 4'b0001;	
						
		//S1:decode
		4'h1: 
				case({Op,Funct[5]}) //data reg, BX, data imm, or Brach operations
				
					3'b000: begin //add sub and orr mov cmp BX (BX olmamalı burda)
						
						if(Funct[4:0] != 5'b10010) 
							State_next <= 4'b0110;	//S6 Execute R	(data reg)
						
						else //BX is here I created a state as S10
							State_next <= 4'b1010;
					end	
					3'b001: //mov imm
						State_next <= 4'h7;
							
					3'b010: //memory imm
						State_next <= 4'b0010; //S2 MemAdr
						
					3'b101: // B and BL
					
						if(Funct[4]) //BL
							State_next <= 4'b1011;	//BL is here I created a state as S11
						else //Branch is here
							State_next <= 4'b1001; //S9 is B
														
					default:
							State_next <= 4'h0;
					
				endcase
				
		//S2:MemAdr
		4'h2: 
				if(Funct[0]) 	//LDR
					State_next <= 4'h3;	
				else 				//STR
					State_next <= 4'h5;
	
		//S3:MemRead
		4'h3: 
					State_next <= 4'h4;
					
		4'h4: 
					State_next <= 4'h0;
					
		4'h5: 
					State_next <= 4'h0;
					
		4'h6: 
					State_next <= 4'h8;
		4'h7: 
					State_next <= 4'h8;
		4'h8: 
					State_next <= 4'h0;
		4'h9: 
					State_next <= 4'h0;
		4'b1010: //S10
					State_next <= 4'h0;
		4'b1011: //S11
					State_next <= 4'h0;
					
		default: 
					State_next <= 4'h0;
				
	endcase


end


always @(*) begin

RegWrite = 0;
MemWrite = 0;
PCWrite = 0;
WDSrc = 0;
ALUSrcA = 0; 

shifterSrc = 0;
IRWrite = 0;
AdrSrc= 0;
shSrc= 0;
ALUControl = 4'b0100; //add

RegSrc = 3'b000;
ImmSrc = 2'b00;
ALUSrcB= 2'b00;
shamtSrc= 2'b00;
ResultSrc= 2'b00;
FlagWrite = 0;

		case(State_current)
		
		//S0:fetch
		4'b0000: begin
						AdrSrc = 0;
						ALUSrcA = 1;
						ALUSrcB = 2'b10;
						ALUControl = 4'b0100; //ADD for PC+4
						ResultSrc = 2'b10;
						IRWrite = 1;
						PCWrite = 1; //nextpc=1
						
						RegWrite = 0;
						MemWrite = 0;
						WDSrc = 0;
						shifterSrc= 0;
						shSrc= 0;
						ImmSrc = 2'b00;
						shamtSrc= 2'b00;
						RegSrc = 3'b000;
		end
		//S1:decode
		4'h1: begin
						
						ALUSrcA = 1;
						ALUSrcB = 2'b10;
						ALUControl = 4'b0100; //add
						ResultSrc = 2'b10;
						case(Op)
								2'b00: begin
									RegSrc		= 3'b000; //same for BX
											
								end
								2'b01: begin
									RegSrc		= 3'b010;
								end
								
								2'b10: begin
										case(Funct[4]) 
												2'b0: 			// B
													begin
													RegSrc		= 3'b001; 
													end

												2'b1: 			// BL
													begin													
													RegSrc		= 3'b101; 
													end
												
												default:
													begin
													RegSrc		= 3'b000; 
													end
													
											endcase
								end						
								default: begin
										RegSrc		= 3'b000;
								end
						endcase
		
		end							
		//S2:MemAdr
		4'h2: begin
						ALUSrcA = 0;
						ALUSrcB = 2'b01;
						ImmSrc = 2'b01;
						ALUControl	= 4'b0100; //add
						RegSrc[1] = 1;//??
						shifterSrc = 1; //not neccesarry due to alusrcb select but ok
						shamtSrc = 2'b10; //not neccesarry but ok
		
		end
		//S3:MemRead LDR
		4'h3: begin
						
						
						ResultSrc = 2'b00;
						AdrSrc = 1;
		
		end	
			//S4 MemWB
		4'h4: begin
						RegWrite = Condition_current ? 1 : 0;
						ResultSrc = 2'b01;
						WDSrc = 0;
						RegSrc[2] = 0;
						
		end		
			//S5 MemWrite STR
		4'h5: begin
						
						ResultSrc = 2'b00;
						AdrSrc = 1;
						MemWrite = Condition_current ? 1 : 0;
		
		end			
		4'h6: begin
						ALUSrcA = 0;
						ALUSrcB = 2'b00;
						ALUControl = (Funct[4:1] != 4'b1010) ? Funct[4:1] : 4'b0010;
						FlagWrite = (Funct[4:1] == 4'b1010) ? 1 : 0;
						shamtSrc = 2'b00;
						shifterSrc = 0;
						
		end
		4'h7: begin
						ALUSrcA = 0;
						ALUSrcB = 2'b00;
						ALUControl = (Funct[4:1] != 4'b1010) ? Funct[4:1] : 4'b0010;
						shamtSrc = 2'b01;
						ImmSrc = 2'b00;
						shifterSrc = 1;
						shSrc = 1;
												
						RegWrite = 0;
						MemWrite = 0;
						PCWrite = 0;
						WDSrc = 0;
						IRWrite= 0;
						AdrSrc= 0;
						RegSrc = 3'b000;
						ResultSrc= 2'b00;
						
		end
		4'h8: begin
						ResultSrc = 2'b00;
						WDSrc = 0;
						RegWrite = Condition_current ? 1 :0; //// condition check kaldırdım şimdilik
						
						PCWrite = (RD == 4'b1111) & Condition ? 1 : 0;
						
						
						
						MemWrite = 0;
						
						ALUSrcA = 0; 

						shifterSrc= 0;
						IRWrite= 0;
						AdrSrc= 0;
						shSrc= 0;
						ALUControl = 4'b0100; //add

						RegSrc = 3'b000;
						ImmSrc = 2'b00;
						ALUSrcB= 2'b00;
						shamtSrc= 2'b00;
						
		end
		4'h9: begin	//B	
						ImmSrc= 2'b10;
						ALUSrcA = 0;
						ALUSrcB = 2'b01;
						ResultSrc = 2'b10;
						ALUControl	= 4'b0100; //add
						PCWrite = Condition_current ? 1 : 0;
					
		end		
		4'b1010: begin//S10 BX
						shamtSrc = 2'b10;
						shifterSrc = 0;
						ALUSrcB= 2'b00;
						ALUControl	= 4'b1101; //mov
						ResultSrc = 2'b10;
						PCWrite = Condition_current ? 1 : 0;
						
						//?????? Rmi tek cycleda PCye çekmem lazım ama çıkışta reg var
						//ekstra cycle kullanmak yasak
						//mux eklenebilir PC girişine
						//input 0 result olur, input 1 RD2 olur
						//onun eklendiği senaryoda shamtSrcMux'ı 2to1 dönüşebilir
		
		end			
		
		4'b1011: begin //S11 BL
						ALUSrcA = 0;
						ALUSrcB = 2'b01;
						ImmSrc= 2'b10;
						ResultSrc = 2'b10;
						ALUControl	= 4'b0100; //add
						PCWrite = Condition_current ? 1 : 0;
						
						WDSrc = 1;
						RegSrc[2] = 1;
						RegWrite = Condition_current ? 1 : 0;
		
		end
		
		default: 	begin
		
						RegWrite = 0;
						MemWrite = 0;
						PCWrite = 0;
						WDSrc = 0;
						ALUSrcA = 0; 
						shifterSrc= 0;
						IRWrite= 0;
						AdrSrc= 0;
						shSrc= 0;
						ALUControl = 4'b0100; //add
						RegSrc = 3'b000;
						ImmSrc = 2'b00;
						ALUSrcB= 2'b00;
						shamtSrc= 2'b00;
						ResultSrc= 2'b00;
		
		end





	
	
	endcase

end




endmodule