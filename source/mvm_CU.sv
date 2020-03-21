`include "config.sv"

module mvm_CU(  input   logic   clk,
                input   logic   reset,
                input   logic   mvm_start,
                input   logic   prog_wt,
                output  logic   mvm_done,
                        mvm_bus.cu_mode cu_bus);

typedef enum logic [2:0] {Prog, Wait, Ready, Fetch_ip, Fetch_wt, Calc_pro, Update_sum, Output} states; //without pipelining
states ps, ns;

//Finite State Machine for MVM
always_ff @(posedge clk)
if(reset)
    ps <= #`p Wait;
else
    ps <= #`p ns;

always_comb //To compute next states
begin
    case(ps)
        Prog:       ns = Wait;
        Wait:       ns = prog_wt? Prog : (mvm_start ? Ready : Wait);
        Ready:      ns = cu_bus.counter<`n ? Fetch_ip : Output;
        Fetch_ip:   ns = cu_bus.skip ? (cu_bus.counter<(`n-1) ?Fetch_ip: Output) : Fetch_wt;
        Fetch_wt:   ns = Calc_pro;
        Calc_pro:   ns = Update_sum;
        Update_sum: ns = cu_bus.counter<`n ? Fetch_ip : Output;
        Output:     ns = Wait;
        default:    ns = Wait;
    endcase                
end

always_comb // Generate Control Signals in particular states
begin
    case(ps)

        Prog: begin
            cu_bus.prog_wt = 1'b1;
            
            cu_bus.waiting = 1'b0;
            cu_bus.get_ready=1'b0;
            cu_bus.fetch=1'b0;
            cu_bus.calc = 1'b0;
            cu_bus.rd_en = 1'b0;
            cu_bus.up_sum=1'b0;
            mvm_done = 1'b0;
        end

        Wait: begin
            cu_bus.prog_wt = 1'b0;
            cu_bus.waiting = 1'b1;

            cu_bus.get_ready=1'b0;
            cu_bus.fetch=1'b0;
            cu_bus.calc = 1'b0;
            cu_bus.rd_en = 1'b0;
            cu_bus.up_sum=1'b0;
            mvm_done = 1'b0;
        end

        Ready: begin
            cu_bus.get_ready=1'b1;
            cu_bus.waiting = 1'b0;

            cu_bus.prog_wt=1'b0;
            cu_bus.fetch=1'b0;
            cu_bus.calc = 1'b0;
            cu_bus.rd_en = 1'b0;
            cu_bus.up_sum=1'b0;
            mvm_done = 1'b0;
        end

        Fetch_ip: begin
            cu_bus.get_ready = 1'b0;
            cu_bus.fetch = 1'b1;

            cu_bus.prog_wt = 1'b0;
            cu_bus.waiting = 1'b0;
            cu_bus.calc = 1'b0;
            cu_bus.rd_en = 1'b0;
            cu_bus.up_sum=1'b0;
            mvm_done = 1'b0;
        end

        Fetch_wt: begin
            cu_bus.fetch = 1'b0;
            cu_bus.rd_en = 1'b1;

            cu_bus.prog_wt = 1'b0;                
            cu_bus.waiting = 1'b0;
            cu_bus.get_ready=1'b0;
            cu_bus.calc = 1'b0;
            cu_bus.up_sum=1'b0;
            mvm_done = 1'b0;
        end

        Calc_pro: begin
            cu_bus.rd_en = 1'b0;
            cu_bus.calc = 1'b1;

            cu_bus.prog_wt = 1'b0;
            cu_bus.waiting = 1'b0;
            cu_bus.get_ready=1'b0;
            cu_bus.fetch=1'b0;
            cu_bus.up_sum=1'b0;
            mvm_done = 1'b0;
        end

        Update_sum: begin
            cu_bus.up_sum = 1'b1;
            cu_bus.calc = 1'b0;

            cu_bus.prog_wt = 1'b0;                
            cu_bus.waiting = 1'b0;
            cu_bus.get_ready=1'b0;
            cu_bus.rd_en = 1'b0;
            cu_bus.fetch=1'b0;
            mvm_done = 1'b0;
        end

        Output: begin
            mvm_done = 1'b1;

            cu_bus.prog_wt = 1'b0;
            cu_bus.waiting = 1'b0;
            cu_bus.get_ready=1'b0;
            cu_bus.fetch=1'b0;
            cu_bus.calc = 1'b0;
            cu_bus.rd_en = 1'b0;
            cu_bus.up_sum=1'b0;
        end

    endcase                
end

always_ff @(posedge clk)
begin
    case (ps)
        Wait:       cu_bus.counter <= #`p '0;
        Fetch_ip:   cu_bus.counter <= #`p cu_bus.counter+`n_size'b1;
        Output:     cu_bus.counter <= #`p `n_size'b0;
    endcase
end


endmodule


