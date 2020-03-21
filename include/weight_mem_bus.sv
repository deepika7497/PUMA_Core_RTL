`include "config.sv"

interface weight_mem_bus;  

    logic rd_en;
    logic unsigned [`n_size-1:0] rd_addr;
    logic [`wt_bits-1:0] rd_weight_v[0:`xbar_size-1];
    logic prog_wt;  
    logic [`wt_bits-1:0] wr_weight[0:`xbar_size*`xbar_size-1];

    modport mem_mode (input rd_en, rd_addr, prog_wt, wr_weight,
                        output rd_weight_v);

endinterface //weight_mem_bus
