`include "../include/config.sv"

module mvm( input clk, reset, reset_wt, mvm_start, prog_wt,
            input logic [`xbar_in_bits-1:0] xbar_input[0:`xbar_size-1],
            input logic [`wt_bits-1:0] wr_weight[0:`xbar_size*`xbar_size-1],
            output mvm_done,
            output logic [`xbar_out_bits-1:0] xbar_output[0: `xbar_size-1]);

mvm_bus dp_cu_connection();

mvm_DP dp(clk, reset, reset_wt, xbar_input, wr_weight, mvm_done, xbar_output, dp_cu_connection);
mvm_CU cu(clk, reset, mvm_start, prog_wt, mvm_done, dp_cu_connection);


endmodule

