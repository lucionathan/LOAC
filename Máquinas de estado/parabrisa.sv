// DESCRIPTION: Verilator: Systemverilog example module
// with interface to switch buttons, LEDs, LCD and register display

parameter NINSTR_BITS = 32;
parameter NBITS_TOP = 8, NREGS_TOP = 32, NBITS_LCD = 64;
module top(input  logic clk_2,
           input  logic [NBITS_TOP-1:0] SWI,
           output logic [NBITS_TOP-1:0] LED,
           output logic [NBITS_TOP-1:0] SEG,
           output logic [NBITS_LCD-1:0] lcd_a, lcd_b,
           output logic [NINSTR_BITS-1:0] lcd_instruction,
           output logic [NBITS_TOP-1:0] lcd_registrador [0:NREGS_TOP-1],
           output logic [NBITS_TOP-1:0] lcd_pc, lcd_SrcA, lcd_SrcB,
             lcd_ALUResult, lcd_Result, lcd_WriteData, lcd_ReadData, 
           output logic lcd_MemWrite, lcd_Branch, lcd_MemtoReg, lcd_RegWrite);

  always_comb begin
    // LED <= SWI | clk_2;
    SEG <= SWI;
    lcd_WriteData <= SWI;
    lcd_pc <= 'h12;
    lcd_instruction <= 'h34567890;
    lcd_SrcA <= 'hab;
    lcd_SrcB <= 'hcd;
    lcd_ALUResult <= 'hef;
    lcd_Result <= 'h11;
    lcd_ReadData <= 'h33;
    lcd_MemWrite <= SWI[0];
    lcd_Branch <= SWI[1];
    lcd_MemtoReg <= SWI[2];
    lcd_RegWrite <= SWI[3];
    for(int i=0; i<NREGS_TOP; i++) lcd_registrador[i] <= i+i*16;
    lcd_a <= {56'h1234567890ABCD, SWI};
    lcd_b <= {SWI, 56'hFEDCBA09876543};
  end

  logic [2:0] num_gotas;

  logic [6:0] chuva;

	logic [1:0] conta_3;

	logic [1:0] conta_5;

  logic reset, clk_3;

  enum logic [1:0] {desligados, baixa_velocidade, alta_velocidade} estado;

  always_ff @(posedge clk_2) begin
    clk_3 <= !clk_3;
  end
  
  always_comb begin
		reset <= SWI[7];
		chuva <= SWI[6:0]; 
    num_gotas <= 0;
		num_gotas <= num_gotas + chuva[0] + chuva[1] + chuva[2] 
								+ chuva[3] + chuva[4] + chuva[5] + chuva[6];
  end

  always_ff @(posedge clk_3 or posedge reset) begin
		if(reset) begin
			estado <= desligados;
			conta_3 <= 0;
			conta_5 <= 0;
		end
		else begin
			unique case(estado)

				desligados: begin
					if(num_gotas > 3 && num_gotas <= 5) begin
						if(conta_3 < 2) conta_3 <= conta_3 + 1;
						else if(conta_3 == 2) begin
							conta_3 <= 0;
							estado <= baixa_velocidade;		
						end
					end
					else if(num_gotas > 5) begin
						if(conta_5 < 1) conta_5 <= conta_5 + 1;
						else if(conta_5 == 1) begin 
							conta_5 <= 0;
							estado <= alta_velocidade;		
						end
					end
				end

				baixa_velocidade: begin
					if(num_gotas > 5) begin
						if(conta_5 < 1) conta_5 <= conta_5 + 1;
						else if(conta_5 == 1) begin 
							conta_5 <= 0;
							estado <= alta_velocidade;		
						end
					end
					else if(num_gotas < 3) estado <= desligados;
				end

				alta_velocidade: begin
					if(num_gotas > 3 && num_gotas <= 5) estado <= baixa_velocidade;
					else if(num_gotas < 3) estado <= desligados;					
				end

			endcase
		end
  end

  always_comb begin
    LED[1:0] <= estado;
    LED[7] <= clk_3;
  end

endmodule
