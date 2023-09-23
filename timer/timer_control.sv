`timescale 1ns / 1ps

module timer_control(
        input logic rstn,
        input logic clk,
        input logic clken,
        input logic blink_en,
        input logic start,
        output logic [3:0] sec0,
        output logic [3:0] sec1,
        output logic [3:0] min0,
        output logic [3:0] min1,
        output logic [3:0] hr0,
        output logic [3:0] hr1,
        output logic led
    );
    
    logic [3:0] sec0_nxt, sec1_nxt;
    logic [3:0] min0_nxt, min1_nxt;
    logic [3:0] hr0_nxt, hr1_nxt;
    
    logic [3:0] sec0p1, sec1p1, min0p1, min1p1, hr0p1, hr1p1;
    
    logic sec0_eq9, sec1_eq5;
    logic min0_eq9, min1_eq5;
    logic hr0_eq9,  hr1_eq9;
    logic sec59, min59;
    
    // counter trigger conditions
    always_comb begin
        sec0_eq9 = (sec0 == 4'd9);
        sec1_eq5 = (sec1 == 4'd5);
        min0_eq9 = (min0 == 4'd9);
        min1_eq5 = (min1 == 4'd5);
        hr0_eq9  = (hr0  == 4'd9);
        hr1_eq9  = (hr1  == 4'd9);
        
        sec59    = (sec1_eq5 & sec0_eq9);
        min59    = (min1_eq5 & min0_eq9);        
        
        sec0p1 = sec0 + 4'd1;
        sec1p1 = sec1 + 4'd1;
        min0p1 = min0 + 4'd1;
        min1p1 = min1 + 4'd1;
        hr0p1  = hr0  + 4'd1;
        hr1p1  = hr1  + 4'd1;
    end
    
    always @(posedge clk or negedge rstn)
        if (!rstn)
            led <= 0;
        else if (start && blink_en)
            led <= !led;
    
    //seconds control
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn)
            {sec0, sec1, min0, min1, hr0, hr1} <= '0;
        else if (start && clken) begin
            sec0 <= sec0_nxt;
            sec1 <= sec1_nxt;
            min0 <= min0_nxt;
            min1 <= min1_nxt;
            hr0  <= hr0_nxt;
            hr1  <= hr1_nxt;
        end
    end
    
    always_comb begin : SEG_NXT_STATE
        // sec0_next
        if (sec0_eq9)
            sec0_nxt = '0;
        else
            sec0_nxt = sec0p1;
        
        // sec1_nxt
        if (sec0_eq9)
            if (sec1_eq5)
                sec1_nxt = '0;
            else
                sec1_nxt = sec1p1;
        else
            sec1_nxt = sec1;
        
        // min0_nxt
        if (sec59)
            if (min0_eq9)
                min0_nxt = '0;
            else
                min0_nxt = min0p1;
        else
            min0_nxt = min0;
            
        // min1_nxt
        if (sec59 & min0_eq9)
             if (min1_eq5)
                min1_nxt = '0;
            else
                min1_nxt = min1p1;
        else
            min1_nxt = min1;
        
        // hr0_nxt
        if (sec59 & min59)
            if (hr0_eq9)
                hr0_nxt = '0;
            else
                hr0_nxt = hr0p1;
        else
            hr0_nxt = hr0;
            
         // hr1_nxt
        if (sec59 & min59 & hr0_eq9)
            if (hr1_eq9)
                hr1_nxt = '0;
            else
                hr1_nxt = hr1p1;
        else
            hr1_nxt = hr1;    
                
    end : SEG_NXT_STATE
    
endmodule
