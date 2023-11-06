`include "../defines.v"
`include "../bus/ahb_defines.v"
// ram module
module ram(
    input clk,
    input enable,
    input write,                   // write enable
    input [`AHB_BUS_WIDTH-1 : 0] addr_i,    // addr
    input [7:0] data_i,
    output reg[7:0] data_o,         // read data
    output reg write_okay
    );
    reg[7:0] ram_regs [`RAM_SIZE-1 : 0];
    reg [21:0] addr_buf; 
    always_ff @(posedge clk or negedge enable) begin
        if(!enable) begin
            write_okay <= 0;
        end
        else if (write == 1'b1) begin
            ram_regs[addr_i[23:2]] <= data_i;
            if(write_okay)
            begin
                write_okay <= 0;
            end
            else begin
                write_okay <= 1; 
            end
        end
    end

    always_comb begin
        if(!enable) begin
            data_o = 0;
        end
        else if (write == 1'b0) begin
            data_o = ram_regs[addr_i[23:2]];
        end else begin
            data_o = 8'h0;
        end
    end

endmodule
