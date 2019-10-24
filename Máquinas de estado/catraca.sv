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

  enum logic [0:0] {TRAVADA, LIBERADA} estado;

  logic reset, passe1, passe2, catraca;
   
  logic[1:0] carrega1, carrega2;

  logic [2:0] conta, cartao1, cartao2;

  
  always_comb begin 
    reset <= SWI[6];
    passe1 <= SWI[0];
    passe2 <= SWI[1];
    carrega1 <= SWI[3:2];
    carrega2 <= SWI[5:4];

  end

  always_ff @(posedge clk_2 or posedge reset) begin

    if(reset) begin
      catraca <= 0;
      conta <= 0;
      estado <= TRAVADA;
    end else begin

      if((carrega1 + cartao1) > 5) cartao1 <= 5;
      else cartao1 <= cartao1 + carrega1;

      if((carrega2 + cartao2) > 5) cartao2 <= 5;
      else cartao2 <= cartao2 + carrega2;

      unique case(estado) 

        TRAVADA: begin

          catraca <= 0;
          conta <= 0;

          if(passe1 && passe2) estado <= TRAVADA;

          else if(passe1) begin
            if(cartao1 > 0) begin
              cartao1 <= cartao1 - 1;
              estado <= LIBERADA;
            end
          end 
          else if(passe2) begin
            if(cartao2 > 0) begin
              cartao2 <= cartao2 - 1;
              estado <= LIBERADA;
            end
          end

        end

        LIBERADA: begin
          catraca <= 1;
          estado <= TRAVADA;
        end

     endcase
    end    
  end
    
  

  always_comb begin
    SEG[7] <= clk_2;
    LED[0] <= catraca;

    if(passe1) conta <= cartao1;
    else if(passe2) conta <= cartao2;

    unique case (conta)
      0: SEG[6:0] <= 7'b0111111;
      1: SEG[6:0] <= 7'b0000110;
      2: SEG[6:0] <= 7'b1011011;
      3: SEG[6:0] <= 7'b1001111;
      4: SEG[6:0] <= 7'b1100110;
      5: SEG[6:0] <= 7'b1101101;
    endcase
  end

endmodule
