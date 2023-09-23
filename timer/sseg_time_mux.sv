`timescale 1ns / 1ps

module sseg_time_mux(
        output logic [5:0] disp_en,
        output logic [7:0] sseg,
        input  logic       clk,
        input  logic       rstn,
        input  logic       clken,
        input  logic [7:0] sec0,
        input  logic [7:0] sec1,
        input  logic [7:0] min0, 
        input  logic [7:0] min1, 
        input  logic [7:0] hr0, 
        input  logic [7:0] hr1
    );
   
    logic [2:0] en_cntr;
    
    // enable cycler
    always_ff @(posedge clk or negedge rstn)
        if (!rstn)
            en_cntr <= 0;
        else 
            if (clken)
                en_cntr <= (en_cntr == 6'd5) ? '0 : (en_cntr + 1'b1);
     
    // convert en cnt val to one hot display en
    always_comb begin
        case (en_cntr)
            0 : begin
                disp_en     = 6'b111_110;
                sseg = sec0;
            end
            
            1 : begin
                disp_en     = 6'b111_101;
                sseg = sec1; 
            end
            
            2 : begin
                disp_en = 6'b111_011;
                sseg = min0;
            end
            
            3 : begin
                disp_en = 6'b110_111;
                sseg = min1;
            end
            
            4 : begin
                disp_en = 6'b101_111;
                sseg = hr0;
            end
            
            5 : begin
                disp_en = 6'b011_111;
                sseg = hr1;
            end
            
            default : begin
                disp_en = 6'b011_111;
                sseg = hr1;
            end      
        endcase
    end
    
endmodule
