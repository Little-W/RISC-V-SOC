`include "ahb_defines.v"
module ahb_write_mux(
  input HCLK,
  input HRST_N,
  input [`AHB_BUS_WIDTH-1:0] HADDR_i [15:0],
  input [`AHB_BUS_WIDTH-1:0] HWDATA_i [15:0],
  input [1:0] HTRANS_i [15:0],
  input [2:0] HSIZE_i [15:0],
  input [2:0] HBURST_i [15:0],
  input [3:0] HPROT_i [15:0],
  input [15:0] HWRITE_i,
  input [3:0] HMASTER_i,
  input [15:0] HGRANT_i,
  input HREADY_i,
  output reg  [`AHB_BUS_WIDTH-1:0] HADDR_o,
  output reg  [`AHB_BUS_WIDTH-1:0] HWDATA_o,
  output reg  [1:0] HTRANS_o,
  output reg  [2:0] HSIZE_o,
  output reg  [2:0] HBURST_o,
  output reg  [3:0] HPROT_o,
  output reg  HWRITE_o
);
  reg [3:0] HMASTER_buf;

  always_ff @(posedge HCLK or negedge HRST_N) begin
      if(!HRST_N) begin
          HMASTER_buf <= 0;
      end
      else if(HREADY_i == 1) begin
          HMASTER_buf <= HMASTER_i;
      end
  end

  always_comb begin
    case (HMASTER_i)
      4'b0000: 
        begin
          HADDR_o = HADDR_i[0];
          HTRANS_o = HTRANS_i[0];
          HSIZE_o = HSIZE_i[0];
          HBURST_o = HBURST_i[0];
          HPROT_o = HPROT_i[0];
          HWRITE_o = HWRITE_i[0];
        end
      4'b0001:  
        begin
          HADDR_o = HADDR_i[1];
          HTRANS_o = HTRANS_i[1];
          HSIZE_o = HSIZE_i[1];
          HBURST_o = HBURST_i[1];
          HPROT_o = HPROT_i[1];
          HWRITE_o = HWRITE_i[1];
        end
      4'b0010: 
        begin
          HADDR_o = HADDR_i[2];
          HTRANS_o = HTRANS_i[2];
          HSIZE_o = HSIZE_i[2];
          HBURST_o = HBURST_i[2];
          HPROT_o = HPROT_i[2];
          HWRITE_o = HWRITE_i[2];
        end
      4'b0011: 
        begin
          HADDR_o = HADDR_i[3];
          HTRANS_o = HTRANS_i[3];
          HSIZE_o = HSIZE_i[3];
          HBURST_o = HBURST_i[3];
          HPROT_o = HPROT_i[3];
          HWRITE_o = HWRITE_i[3];
        end
      4'b0100:  
        begin
          HADDR_o = HADDR_i[4];
          HTRANS_o = HTRANS_i[4];
          HSIZE_o = HSIZE_i[4];
          HBURST_o = HBURST_i[4];
          HPROT_o = HPROT_i[4];
          HWRITE_o = HWRITE_i[4];
        end
      4'b0101:  
        begin
          HADDR_o = HADDR_i[5];
          HTRANS_o = HTRANS_i[5];
          HSIZE_o = HSIZE_i[5];
          HBURST_o = HBURST_i[5];
          HPROT_o = HPROT_i[5];
          HWRITE_o = HWRITE_i[5];
        end
      4'b0110:  
        begin
          HADDR_o = HADDR_i[6];
          HTRANS_o = HTRANS_i[6];
          HSIZE_o = HSIZE_i[6];
          HBURST_o = HBURST_i[6];
          HPROT_o = HPROT_i[6];
          HWRITE_o = HWRITE_i[6];
        end
      4'b0111: 
        begin
          HADDR_o = HADDR_i[7];
          HTRANS_o = HTRANS_i[7];
          HSIZE_o = HSIZE_i[7];
          HBURST_o = HBURST_i[7];
          HPROT_o = HPROT_i[7];
          HWRITE_o = HWRITE_i[7];
        end
      4'b1000: 
        begin
          HADDR_o = HADDR_i[8];
          HTRANS_o = HTRANS_i[8];
          HSIZE_o = HSIZE_i[8];
          HBURST_o = HBURST_i[8];
          HPROT_o = HPROT_i[8];
          HWRITE_o = HWRITE_i[8];
        end
      4'b1001: 
        begin
          HADDR_o = HADDR_i[9];
          HTRANS_o = HTRANS_i[9];
          HSIZE_o = HSIZE_i[9];
          HBURST_o = HBURST_i[9];
          HPROT_o = HPROT_i[9];
          HWRITE_o = HWRITE_i[9];
        end
      4'b1010:  
        begin
          HADDR_o = HADDR_i[10];
          HTRANS_o = HTRANS_i[10];
          HSIZE_o = HSIZE_i[10];
          HBURST_o = HBURST_i[10];
          HPROT_o = HPROT_i[10];
          HWRITE_o = HWRITE_i[10];
        end
      4'b1011: 
        begin
          HADDR_o = HADDR_i[11];
          HTRANS_o = HTRANS_i[11];
          HSIZE_o = HSIZE_i[11];
          HBURST_o = HBURST_i[11];
          HPROT_o = HPROT_i[11];
          HWRITE_o = HWRITE_i[11];
        end
      4'b1100:  
        begin
          HADDR_o = HADDR_i[12];
          HTRANS_o = HTRANS_i[12];
          HSIZE_o = HSIZE_i[12];
          HBURST_o = HBURST_i[12];
          HPROT_o = HPROT_i[12];
          HWRITE_o = HWRITE_i[12];
        end
      4'b1101: 
        begin
          HADDR_o = HADDR_i[13];
          HTRANS_o = HTRANS_i[13];
          HSIZE_o = HSIZE_i[13];
          HBURST_o = HBURST_i[13];
          HPROT_o = HPROT_i[13];
          HWRITE_o = HWRITE_i[13];
        end
      4'b1110: 
        begin
          HADDR_o = HADDR_i[14];
          HTRANS_o = HTRANS_i[14];
          HSIZE_o = HSIZE_i[14];
          HBURST_o = HBURST_i[14];
          HPROT_o = HPROT_i[14];
          HWRITE_o = HWRITE_i[14];
        end
      4'b1111: 
        begin
          HADDR_o = HADDR_i[15];
          HTRANS_o = HTRANS_i[15];
          HSIZE_o = HSIZE_i[15];
          HBURST_o = HBURST_i[15];
          HPROT_o = HPROT_i[15];
          HWRITE_o = HWRITE_i[15];
        end
      default: ;
    endcase
  end

  always_comb begin
    case (HMASTER_buf) //数据相位打一拍
      4'b0000: 
      begin
        HWDATA_o = HWDATA_i[0];
      end
      4'b0001:  
      begin
        HWDATA_o = HWDATA_i[1];
      end
      4'b0010:  
      begin
        HWDATA_o = HWDATA_i[2];
      end
      4'b0011:  
      begin
        HWDATA_o = HWDATA_i[3];
      end
      4'b0100:  
      begin
        HWDATA_o = HWDATA_i[4];
      end
      4'b0101:  
      begin
        HWDATA_o = HWDATA_i[5];
      end
      4'b0110:  
      begin
        HWDATA_o = HWDATA_i[6];
      end
      4'b0111:  
      begin
        HWDATA_o = HWDATA_i[7];
      end
      4'b1000: 
      begin
        HWDATA_o = HWDATA_i[8];
      end
      4'b1001:  
      begin
        HWDATA_o = HWDATA_i[9];
      end
      4'b1010:  
      begin
        HWDATA_o = HWDATA_i[10];
      end
      4'b1011: 
      begin
        HWDATA_o = HWDATA_i[11];
      end
      4'b1100:  
      begin
        HWDATA_o = HWDATA_i[12];
      end
      4'b1101:  
      begin
        HWDATA_o = HWDATA_i[13];
      end
      4'b1110:  
      begin
        HWDATA_o = HWDATA_i[14];
      end
      4'b1111:  
      begin
        HWDATA_o = HWDATA_i[15];
      end
      default: ;
    endcase
  end

endmodule 