`timescale 1ns / 1ps

module top(
    output logic [7:0] sseg,  // output to seven segment display
    output logic [7:0] en,    // enable for each seg of 7 segment display
    input logic  rstn,        // master reset
    input logic  clk,         // 100Mhz clock
    input logic  start,       // start, pause clock
    output logic led          // led to follow seconds counter
);

localparam int TIMER_DIV_RATIO    = 100_000_000;
localparam int BLINKER_DIV_RATIO  =  50_000_000;
localparam int DISP_MUX_DIV_RATIO =  10_000;

logic [3:0] sec0_bin, sec1_bin, min0_bin, min1_bin, hr0_bin, hr1_bin;
logic [7:0] sec0_sseg, sec1_sseg, min0_sseg, min1_sseg, hr0_sseg, hr1_sseg;
logic       mux_clken, ctrl_clken, blink_clken;

clkgen clkgen0 (.rstn(rstn), .clkin(clk), .clken(ctrl_clken),  .rat(TIMER_DIV_RATIO));
clkgen clkgen2 (.rstn(rstn), .clkin(clk), .clken(blink_clken), .rat(BLINKER_DIV_RATIO));
clkgen clkgen1 (.rstn(rstn), .clkin(clk), .clken(mux_clken),   .rat(DISP_MUX_DIV_RATIO));

assign en[7:6] = '1;

timer_control ctrl (
    .clk        (clk),
    .clken      (ctrl_clken),
    .blink_en   (blink_clken),
    .led        (led),
    .rstn       (rstn),
    .start      (start),
    .sec0       (sec0_bin),
    .sec1       (sec1_bin),
    .min0       (min0_bin),
    .min1       (min1_bin),
    .hr0        (hr0_bin),
    .hr1        (hr1_bin)
);

sseg_time_mux disp_mux (
    .clk     (clk),
    .clken   (mux_clken),
    .rstn    (rstn),
    .disp_en (en[5:0]),
    .sseg    (sseg),
    .sec0    (sec0_sseg),
    .sec1    (sec1_sseg),
    .min0    (min0_sseg),
    .min1    (min1_sseg),
    .hr0     (hr0_sseg),
    .hr1     (hr1_sseg)
);

hex_to_sseg sec0_seg_ctrl (
    .sseg (sec0_sseg),
    .dp (1),
    .hex (sec0_bin)
);

hex_to_sseg sec1_seg_ctrl (
    .sseg (sec1_sseg),
    .dp (1),
    .hex (sec1_bin)
);

hex_to_sseg min0_seg_ctrl (
    .sseg (min0_sseg),
    .dp (0),
    .hex (min0_bin)
);

hex_to_sseg min1_seg_ctrl (
    .sseg (min1_sseg),
    .dp (1),
    .hex (min1_bin)
);

hex_to_sseg hr0_seg_ctrl (
    .sseg (hr0_sseg),
    .dp (0),
    .hex (hr0_bin)
);

hex_to_sseg hr1_seg_ctrl (
    .sseg (hr1_sseg),
    .dp (1),
    .hex (hr1_bin)
);

endmodule
