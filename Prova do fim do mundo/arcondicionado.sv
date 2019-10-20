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

  logic reset, aumentar, diminuir, pingando;

  enum logic [1:0] {ESTAVEL, SUBINDO, DESCENDO} estado;

  logic [2:0] REAL, DESEJADA, PARAR_PINGAR;

  logic [1:0] CONTADOR;

  logic [3:0] CONTADOR_PINGAR;

  always_comb begin 
    reset <= SWI[7];
    aumentar <= SWI[1];
    diminuir <= SWI[0];
  end

  always_ff @(posedge clk_2 or posedge reset) begin
    if(reset) begin
      REAL <= 0;
      DESEJADA <= 0;
      pingando <= 0;
      CONTADOR <= 0;
      CONTADOR_PINGAR <= 0;
      PARAR_PINGAR <= 0;
      estado <= ESTAVEL; 
    end 

    else begin
      if(CONTADOR_PINGAR < 10) CONTADOR_PINGAR <= CONTADOR_PINGAR + 1;
      if(CONTADOR_PINGAR == 9) pingando <= 1;
    
      if(aumentar && DESEJADA < 7) DESEJADA <= DESEJADA + 1;
      if(diminuir && DESEJADA > 0) DESEJADA <= DESEJADA - 1;
      if(PARAR_PINGAR == 3) begin 
        pingando <= 0;
        CONTADOR_PINGAR <= 11;
      end

      unique case(estado) 
        ESTAVEL: begin
            if(REAL == 7 && pingando) PARAR_PINGAR <= PARAR_PINGAR + 1;
            if(aumentar  && DESEJADA < 7) begin
                PARAR_PINGAR <= 0;
                DESEJADA <= DESEJADA + 1;
                estado <= SUBINDO;
            end else if(diminuir  && DESEJADA > 0) begin
                PARAR_PINGAR <= 0;
                DESEJADA <= DESEJADA - 1;
                estado <= DESCENDO;
            end
        end
        SUBINDO: begin
            if(DESEJADA == REAL) begin
                estado <= ESTAVEL;
            end else begin
                CONTADOR <= CONTADOR + 1;

                if(CONTADOR == 1) begin
                    REAL <= REAL + 1;
                    CONTADOR <= 0;
                end
            end

        end
        DESCENDO: begin
            if(DESEJADA == REAL) begin
                estado <= ESTAVEL;
            end else begin
                CONTADOR <= CONTADOR + 1;

                if(CONTADOR == 1) begin
                    REAL <= REAL - 1;
                    CONTADOR <= 0;
                end
            end
        end
      endcase
    end
  end
    
  

  always_comb begin
    LED[7] <= clk_2;
    LED[6:4] <= REAL;
    LED[2:0] <= DESEJADA;
    LED[3] <= pingando;
  end

endmodule
