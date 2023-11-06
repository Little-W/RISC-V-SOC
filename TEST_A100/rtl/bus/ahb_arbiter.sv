 `include "ahb_defines.v"
 
 module ahb_arbiter (
    input HRST_N,
    input HCLK,
    input [`AHB_BUS_WIDTH-1:0] HADDR_i,
    input [15:0] HBUSREQ_i,
    input [15:0] HLOCK_i,
    input HREADY_i,
    input HRESP_i,
    input [2:0] HBURST_i,
    input [1:0] HTRANS_i,
    output reg [15:0] HGRANT_o,
    output reg HLOCKMASTER_o,
    output reg [3:0] HMASTER_o
 );
    reg [3:0] roll_bits;
    reg [15:0] prior_master;
    reg burst_over;
    reg [15:0] burst_cnt;
    reg [15:0] HGRANT_o_buf;
    initial begin
        prior_master = `DEFAULT_MASTER;
        burst_over = 0;
        burst_cnt = 0;
    end
    wire [31:0] HGRANT_extended;
    assign HGRANT_extended = {HBUSREQ_i,HBUSREQ_i} & ~({HBUSREQ_i,HBUSREQ_i} - prior_master);
    
    always_comb begin

        if(HADDR_i[10:0] == 0 && HADDR_i && HTRANS_i == `TRANS_SEQ) begin
            HGRANT_o = `DUMMY_MASTER;
        end
        else if(!HLOCKMASTER_o && (HBURST_i == `BUSRT_SINGLE || burst_over)) begin
            if(HGRANT_extended ) begin
                HGRANT_o = HGRANT_extended[31:16] | HGRANT_extended[15:0];
            end
            else begin
                HGRANT_o = `DEFAULT_MASTER;
            end
        end
        else begin //burst中不允许更改master
            HGRANT_o = HGRANT_o_buf;
        end
    end

    always @(posedge HCLK or negedge HRST_N) begin
        if(!HRST_N) begin
            prior_master <= `DEFAULT_MASTER;
            HGRANT_o_buf <= `DEFAULT_MASTER;
            HMASTER_o <= `DEFAULT_MASTER_ID;
        end
        else begin
            HGRANT_o_buf <= HGRANT_o;
            if(burst_over) burst_over <= 0;
            if(HGRANT_o) begin
                if(HREADY_i) begin
                    if(HLOCK_i == HGRANT_o)
                    begin
                        HLOCKMASTER_o <= 1;
                    end
                
                    case (HGRANT_o)
                        `GRANT_MASTER0: HMASTER_o <= 0;
                        `GRANT_MASTER1: HMASTER_o <= 1;
                        `GRANT_MASTER2: HMASTER_o <= 2;
                        `GRANT_MASTER3: HMASTER_o <= 3;
                        `GRANT_MASTER4: HMASTER_o <= 4;
                        default: ;
                    endcase
                end 
                else begin
                    HMASTER_o <= HMASTER_o;
                end
            end
            if(HGRANT_extended) begin 
                prior_master <= {HGRANT_o[14:0],HGRANT_o[15]};
            end
            else begin
                prior_master <= `DEFAULT_MASTER;
            end
            if((!(HGRANT_o_buf & HBUSREQ_i) && HBUSREQ_i || HRESP_i ==`RESP_ERROR) && !burst_over) begin
                burst_over <= 1;
            end
            if(HREADY_i) begin
                if(HTRANS_i == `TRANS_NONESEQ) begin
                    burst_cnt <= 2;
                end
                else if(HTRANS_i != `TRANS_IDLE) begin 
                    if(HTRANS_i == `TRANS_SEQ && (HBURST_i == `BURST_INCR4 || HBURST_i == `BURST_WRAP4) && burst_cnt == 3) begin
                        burst_over <= 1;
                        burst_cnt <= 0;
                    end
                    else if(HTRANS_i == `TRANS_SEQ && (HBURST_i == `BURST_INCR8 || HBURST_i == `BURST_WRAP8) && burst_cnt == 7) begin
                        burst_over <= 1;
                        burst_cnt <= 0;
                    end
                    else if(HTRANS_i == `TRANS_SEQ && (HBURST_i == `BURST_INCR16 || HBURST_i == `BURST_WRAP16) && burst_cnt == 15) begin
                        burst_over <= 1;
                        burst_cnt <= 0;
                    end
                    else if(HTRANS_i == `TRANS_SEQ && (HBURST_i == `BURST_INCR) && burst_cnt == `INCR_LIMIT) begin
                        burst_over <= 1;
                        burst_cnt <= 0;
                    end
                    else if(HREADY_i) begin
                        if(HTRANS_i == `TRANS_SEQ || (HTRANS_i == `TRANS_BUSY && HBURST_i == `BURST_INCR))
                        begin
                            burst_cnt <= burst_cnt + 1;
                        end
                    end
                end
            end
        end
    end
 endmodule
