`timescale 1ns/1ps

`include "../source/config.sv"
`default_nettype none

module tb_mvm;
logic clk;
logic reset;
logic reset_wt;
// logic unsigned [`n_size-1:0] n;
logic mvm_start;
logic mvm_done;
logic prog_wt;
logic [`xbar_in_bits-1:0] xbar_input[0:`xbar_size-1];
logic [`xbar_out_bits-1:0] xbar_output[0: `xbar_size-1];
logic [`wt_bits-1:0] xbar_weights[0:`xbar_size*`xbar_size-1];
// mvm_tb_bus tb_if();

mvm mvm1(
    .reset (reset),
    .reset_wt (reset_wt),
    .clk (clk),
    // .n(n),
    .mvm_start(mvm_start),
    .prog_wt(prog_wt),
    .mvm_done(mvm_done),
    .xbar_input(xbar_input),
    .xbar_output(xbar_output),
    .wr_weight(xbar_weights)
);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2)  clk = ~clk;

initial begin
    #1  reset<=1'bx; reset_wt<=1'bx; clk<=0; mvm_start<=0; prog_wt<=0;
    $display("Loading xbar_wt_memory");
    // $readmemb("memfiles/xbar_all1.mem", xbar_weights);
    $readmemb("memfiles/xbar_weights_real.mem", xbar_weights);
    $display("Loading xbar Input Memory");
    $readmemb("memfiles/xbar_in_v2_half1.mem", xbar_input, 0);

    #1  reset<=1'b1; reset_wt<=1'b1; clk<=0; mvm_start<=0;
    #(CLK_PERIOD)  reset<=1; reset_wt<=1'b0;
    #(CLK_PERIOD)  reset<=0;
    #(CLK_PERIOD)  prog_wt<=1;
    #(CLK_PERIOD);
    #(CLK_PERIOD)  prog_wt<=0;
    #(CLK_PERIOD)  reset<=0;  mvm_start<=1;  //n<=7;
   
    # 500;  reset<=1;
    # 550;  reset<=0;  prog_wt<=1;  mvm_start<=0; // n<=4;
    # 20;  prog_wt<=0;  mvm_start<=1; 
    # 20;  mvm_start<=0;
    # 700 ;
    # 50;  reset<=0;  mvm_start<=1;  //n<=8;
    # 100;  mvm_start<=0;
    # 500 $stop;
end

endmodule
`default_nettype wire

