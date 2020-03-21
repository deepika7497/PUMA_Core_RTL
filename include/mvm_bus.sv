`include "config.sv"

interface mvm_bus;
    logic [`n_size-1:0] counter;
    logic waiting;
    logic get_ready;
    logic rd_en;
    logic calc;
    logic fetch;
    logic prog_wt;
    logic up_sum;
    logic skip;

    modport dp_mode (input counter, waiting, get_ready, rd_en, calc, fetch, prog_wt, up_sum,
                        output skip);

    modport cu_mode (output counter, waiting, get_ready, rd_en, calc, fetch, prog_wt, up_sum,
                        input skip);

endinterface //mvm_bus
