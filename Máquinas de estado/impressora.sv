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

  enum logic [1:0] {INICIO, COPIANDO, ENTUPIDA, SEM_PAPEL} estado_atual;

  logic ligar, papel, fora, tampa, reset;

  logic copiando, falta, entupida;

  logic [1:0] quantidade;

  always_comb begin
    reset <= SWI[7];
    ligar <= SWI[0];
    quantidade <= SWI[2:1];
    papel <= SWI[4];
    fora <= SWI[5];
    tampa <= SWI[6];
    estado_atual <= INICIO;
    copiando <= 0;
    falta <= 0;
    entupida <= 0;
  end

  always_ff @(posedge clk_2 or posedge reset) begin
    if(reset) begin 
        estado_atual = INICIO;
    end 
    else begin 
        unique case(estado_atual)
            INICIO: begin
                if(ligar && quantidade > 0) begin
                    estado_atual = COPIANDO;
                end
            end

            COPIANDO: begin
                if(quantidade > 0) begin
                    copiando = 1;
                    
                    if(!papel) begin
                        copiando = 0;
                        falta = 1;
                        estado_atual = SEM_PAPEL;
                    end else if (fora) begin
                        copiando = 0;
                        entupida = 1;
                        estado_atual = ENTUPIDA;
                    end else if (!tampa) begin
                        quantidade = quantidade - 1;
                    end
                end else if(quantidade == 0) begin
                 copiando = 0;
                end
            end

            ENTUPIDA: begin
                if(tampa && !fora) begin
                    entupida = 0;
                    copiando = 1;
                    estado_atual = COPIANDO;
                    
                end
            end

            SEM_PAPEL: begin 
                if(papel) begin
                    copiando = 1;
                    falta = 0;
                    estado_atual = COPIANDO;
                end
            end
        endcase
    end
  end

  always_comb begin
    LED[7] <= clk_2;

    LED[0] <= copiando;
    LED[1] <= falta;
    LED[2] <= entupida;

    unique case(estado_atual)
      INICIO: SEG[6:0] <= 7'b0111111;
      COPIANDO: SEG[6:0] <= 7'b0000110;
      ENTUPIDA: SEG[6:0] <= 7'b1011011;
      SEM_PAPEL: SEG[6:0] <= 7'b1001111;
    endcase
  end


endmodule
