
`include "config.sv"

module mvm_DP(  input   bit     clk,
                input   bit     reset,
                input   bit     reset_wt,
                input logic [`xbar_in_bits-1:0] xbar_in_mem[0:`xbar_size-1],
                input logic [`wt_bits-1:0] wr_weight[0:`xbar_size*`xbar_size-1],
                input   bit     mvm_done,
                output logic [`xbar_out_bits-1:0] xbar_out_mem[0: `xbar_size-1],
                        mvm_bus.dp_mode dp_bus);

logic [`mult_size-1:0] products[0:`xbar_size-1] = '{default : 0};
logic [`activation_bits+`wt_bits-1:0] temp[0:`xbar_size-1] = '{default : 0};
logic [`activation_bits-1:0] activation='{default : 0};
logic [`activation_bits-1:0] activation_reg='{default : 0};
logic [`wt_bits-1:0] rd_weight_v_reg[0:`xbar_size-1];
logic [`acc_size-1:0] sum[0:`xbar_size-1]= '{default : 0};
logic [`n_size-1:0] wt_addr= '{default : 0};
integer k,l,m,i;
weight_mem_bus mem_if();
xbar_wt_mem wt_mem(clk, reset_wt, mem_if.mem_mode);

always_comb
begin
    mem_if.rd_en = dp_bus.rd_en;
    mem_if.rd_addr = wt_addr;
    mem_if.prog_wt = dp_bus.prog_wt;
    mem_if.wr_weight = wr_weight;
end

always_comb
begin
    activation = dp_bus.fetch? xbar_in_mem[dp_bus.counter][`xbar_in_bits-1:0]: '0;
    dp_bus.skip = (activation ==`xbar_in_bits'd0) ? 1'b1 : 1'b0;
    for(i=0;i<`xbar_size;i=i+1)
    begin
        temp[i] = dp_bus.calc? activation_reg*rd_weight_v_reg[i]: '0;
    end
end

always_ff @(posedge clk)
begin

    priority if (dp_bus.get_ready)
        begin
            wt_addr <= #`p -1;
            activation_reg <= #`p'0;
            for(m=0;m<`xbar_size;m=m+1)
            begin
                // temp[m] <= #`p '0;
                products[m] <= #`p '0;
                sum[m] <= #`p '0;
            end
        end
    
    else if (dp_bus.fetch)
        begin
            activation_reg <= #`p activation;
            wt_addr <= #`p wt_addr + `n_size'd1;
        end

    else if (dp_bus.rd_en)
    begin
        for(m=0;m<`xbar_size;m=m+1)
            rd_weight_v_reg[m] <= #`p mem_if.rd_weight_v[m];
    end

    else if(dp_bus.calc)
    begin
        for(m=0;m<`xbar_size;m=m+1)
        begin
            // temp[m] <= #`p activation_reg*rd_weight_v_reg[m];
            products[m] <= #`p temp[m][`activation_bits+ `wt_bits-1:`activation_bits+ `wt_bits-`mult_size];
        end
    end

    else if(dp_bus.up_sum)
    begin
        for(l=0;l<`xbar_size;l=l+1)
        begin
            sum[l] <= #`p sum[l] + products[l];
        end
    end
                 
    else if(mvm_done) 
    begin
        for(k=0;k<`xbar_size;k=k+1)
            xbar_out_mem[k] <= #`p sum[k];
        wt_addr <= #`p '0;
        activation_reg <= #`p'0;
    end 
        
end

endmodule