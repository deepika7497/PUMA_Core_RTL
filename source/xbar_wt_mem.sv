`include "../include/config.sv"

module xbar_wt_mem( input clk, reset,
                    weight_mem_bus.mem_mode mem_bus);

    integer j,k;
    logic [`wt_bits-1:0] xbar_wt_mem[0:`xbar_size*`xbar_size-1];

    always_ff @(posedge clk)
    begin
        if (reset)
    		xbar_wt_mem <= '{default : 0};	
        
        else if(mem_bus.prog_wt)
        begin
            for(j=0; j<`xbar_size*`xbar_size; j=j+1)
                xbar_wt_mem[j] <= mem_bus.wr_weight[j];
        end
        
    end
    
    always_comb
    begin
        for(k=0; k<`xbar_size; k=k+1)
            mem_bus.rd_weight_v[k] = xbar_wt_mem[mem_bus.rd_addr*`xbar_size+k];
    end
    
    endmodule
