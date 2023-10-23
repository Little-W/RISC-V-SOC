 `include "bus_define.v"
 
 module ahb_arbiter (
    input rst_n,
    input HCLK,
    input [15:0] HBUSREQ_i,
    input [15:0] HLOCKREQ_i,
    output reg [15:0] HGRANT_o,
    input [15:0] HSPLIT_i,
    output reg HBUSLOCK_o,
    output reg use_default_master
 );
    reg [3:0] roll_bits;
    reg [15:0] prior_master;
    initial begin
        prior_master = DEFAULT_MSTAER;
    end

    assign HGRANT_extended = {HBUSREQ_i,HBUSREQ_i} & ~({HBUSREQ_i,HBUSREQ_i} - prior_master);
    assign HGRANT_o = HGRANT_extended[31:16] | HGRANT_extended[15:0] | HLOCKREQ_i;

    always @(posedge HCLK) begin
        if(!HRST_N) begin
            if(!HGRANT_o && |BUSREQ_i) begin
                prior_master <= {HGRANT_o[14:0],HGRANT_o[15]};
                HBUSLOCK_o <= 1;
                use_default_master <= 0;
            end
            else if(HGRANT_o) begin
                prior_master <= prior_master;
                HBUSLOCK_o <= 1;
                use_default_master <= 0;
            end
            else begin
                HBUSLOCK_o <= 0;
                use_default_master <= 1;
            end
        end
        else begin
            HLOCK_o <= 0;
            prior_master <= DEFAULT_MSTAER;
        end
    end

 endmodule
