 `include "ahb_defines.v"
 module ahb_decoder(
    input HCLK,
    input HRST_N,
    input HREADY_i,
    input [31:0] HADDR_i,
    output [15:0] HSEL_o
 );
    reg [15:0] HSEL_new;
    reg [15:0] HSEL_old;

    assign HSEL_o = HSEL_old | HSEL_new;
    always_comb begin
        case (HADDR_i[31:28])
            0: HSEL_new = `SEL_SLAVE0;
            1: HSEL_new = `SEL_SLAVE1;
            2: HSEL_new = `SEL_SLAVE2;
            3: HSEL_new = `SEL_SLAVE3;
            4: HSEL_new = `SEL_SLAVE4;
            default: HSEL_new = `SEL_DUMMY_SLAVE;
        endcase
    end
    always_ff @(posedge HCLK or negedge HRST_N) begin
        if(!HRST_N) begin
            HSEL_old <= `SEL_DUMMY_SLAVE;
        end
        else if(HREADY_i) begin
            HSEL_old <= HSEL_new;
        end
    end

 endmodule