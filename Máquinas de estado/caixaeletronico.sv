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

  enum logic [2:0] {INICIAL, VALOR1, VALOR2, VALOR3, VALIDA_SENHA, SAI_DINHEIRO, DESTROI_CARTAO} estado;

  logic reset, cartao, dinheiro, destroi, entra;

  logic [2:0] cod, val1, val2, val3;

  logic [1:0] contador_erro;
  
  always_comb begin 
    reset <= SWI[0];
    cartao <=  SWI[1];
    entra <= SWI[2];
    cod <= SWI[6:4];  
  end

  always_ff @(posedge clk_2 or posedge reset) begin
    if(reset) begin
      destroi <= 0;
      dinheiro <= 0;
      estado <= INICIAL;
    end 


     else begin 
      unique case(estado) 
        INICIAL: begin
          val1 <= 0;
          val2 <= 0;
          val3 <= 0;

          if(cartao && cod == 0) estado <= VALOR1;
        end

        VALOR1: begin
          if(cod != 0 && entra) begin
            val1 <= cod;
            estado <= VALOR2;
          end
        end

        VALOR2: begin
          if(cod != 0 && entra) begin
            val2 <= cod;
            estado <= VALOR3;
          end
        end

        VALOR3: begin
          if(cod != 0 && entra) begin
            val3 <= cod;
            estado <= VALIDA_SENHA;
          end
        end

        VALIDA_SENHA: begin
          if(val1 == 1 && val2 == 3 && val3 == 7) estado <=SAI_DINHEIRO; 
          else begin
            contador_erro <= contador_erro + 1;
            if(contador_erro == 3) estado <= DESTROI_CARTAO;
            else estado <= INICIAL;
          end     
        end

        SAI_DINHEIRO: dinheiro <= 1;

        DESTROI_CARTAO: destroi <= 1;

      endcase
    end
    
  end
    
  

  always_comb begin
    LED[7] <= clk_2;
    LED[1] <= destroi;
    LED[0] <= dinheiro;
    LED[6:4] <= cod;

    unique case (estado)
        0: SEG <= 8'b00111111;
        1: SEG <= 8'b00000110;
        2: SEG <= 8'b01011011;
        3: SEG <= 8'b01001111;
        4: SEG <= 8'b01100110;
        5: SEG <= 8'b01101101;
        6: SEG <= 8'b01111101;
    endcase
  end

endmodule
