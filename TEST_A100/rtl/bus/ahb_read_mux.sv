 `include "ahb_defines.v"
 module ahb_read_mux(
   input HCLK,
   input HRST_N,
   input [15:0] HREADY_i,
   input [`AHB_BUS_WIDTH-1:0] HRDATA_i [15:0],
   input HRESP_i [15:0],
   input [`AHB_BUS_WIDTH-1:0] HADDR_i,
   output reg [`AHB_BUS_WIDTH-1:0] HRDATA_o,
   output reg  HREADY_o,
   output reg  HRESP_o
 );
   reg [`AHB_BUS_WIDTH-1:0] addr_buf;

   always_ff @(posedge HCLK or negedge HRST_N) begin
      if(!HRST_N) begin
         addr_buf <= 0;
      end
      else if(HREADY_o) begin
         addr_buf <= HADDR_i;
      end
   end
   always_comb begin
      case (addr_buf[31:28])  //数总线交接晚一拍
         4'b0000: begin
            HRDATA_o = HRDATA_i[0];
            HREADY_o = HREADY_i[0];
            HRESP_o = HRESP_i[0];
            HREADY_o = HREADY_i[0];
         end
         4'b0001: begin
            HRDATA_o = HRDATA_i[1];
            HREADY_o = HREADY_i[1];
            HRESP_o = HRESP_i[1];
            HREADY_o = HREADY_i[1];
         end
         4'b0010: begin
            HRDATA_o = HRDATA_i[2];
            HREADY_o = HREADY_i[2];
            HRESP_o = HRESP_i[2];
            HREADY_o = HREADY_i[2];
         end
         4'b0011: begin
            HRDATA_o = HRDATA_i[3];
            HREADY_o = HREADY_i[3];
            HRESP_o = HRESP_i[3];
            HREADY_o = HREADY_i[3];
         end
         4'b0100: begin
            HRDATA_o = HRDATA_i[4];
            HREADY_o = HREADY_i[4];
            HRESP_o = HRESP_i[4];
            HREADY_o = HREADY_i[4];
         end
         4'b0101: begin
            HRDATA_o = HRDATA_i[5];
            HREADY_o = HREADY_i[5];
            HRESP_o = HRESP_i[5];
            HREADY_o = HREADY_i[5];
         end
         4'b0110: begin
            HRDATA_o = HRDATA_i[6];
            HREADY_o = HREADY_i[6];
            HRESP_o = HRESP_i[6];
            HREADY_o = HREADY_i[6];
         end
         4'b0111: begin
            HRDATA_o = HRDATA_i[7];
            HREADY_o = HREADY_i[7];
            HRESP_o = HRESP_i[7];
            HREADY_o = HREADY_i[7];
         end
         4'b1000: begin
            HRDATA_o = HRDATA_i[8];
            HREADY_o = HREADY_i[8];
            HRESP_o = HRESP_i[8];
            HREADY_o = HREADY_i[8];
         end
         4'b1001: begin
            HRDATA_o = HRDATA_i[9];
            HREADY_o = HREADY_i[9];
            HRESP_o = HRESP_i[9];
            HREADY_o = HREADY_i[9];
         end
         4'b1010: begin
            HRDATA_o = HRDATA_i[10];
            HREADY_o = HREADY_i[10];
            HRESP_o = HRESP_i[10];
            HREADY_o = HREADY_i[10];
         end
         4'b1011: begin
            HRDATA_o = HRDATA_i[11];
            HREADY_o = HREADY_i[11];
            HRESP_o = HRESP_i[11];
            HREADY_o = HREADY_i[11];
         end
         4'b1100: begin
            HRDATA_o = HRDATA_i[12];
            HREADY_o = HREADY_i[12];
            HRESP_o = HRESP_i[12];
            HREADY_o = HREADY_i[12];
         end
         4'b1101: begin
            HRDATA_o = HRDATA_i[13];
            HREADY_o = HREADY_i[13];
            HRESP_o = HRESP_i[13];
            HREADY_o = HREADY_i[13];
         end
         4'b1110: begin
            HRDATA_o = HRDATA_i[14];
            HREADY_o = HREADY_i[14];
            HRESP_o = HRESP_i[14];
            HREADY_o = HREADY_i[14];
         end
         4'b1111: begin
            HRDATA_o = HRDATA_i[15];
            HREADY_o = HREADY_i[15];
            HRESP_o = HRESP_i[15];
            HREADY_o = HREADY_i[15];
         end
         default:  ;
      endcase
   end



 endmodule