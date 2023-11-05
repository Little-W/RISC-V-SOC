`include "defines.v"
module ahb_slave(
  input HCLK,
  input HRST_N,
  input HSEL,
  input [`AHB_BUS_WIDTH-1:0] HADDR_i,
  input [`AHB_BUS_WIDTH-1:0] HWDATA_i,
  input [1:0] HTRANS_i,
  input [2:0] HSIZE_i,
  input [2:0] HBURST_i,
  input [3:0] HPROT_i,
  input HWRITE_i,
  input HREADY_i,
  output reg [`AHB_BUS_WIDTH-1:0] HRDATA_o,
  output reg  HREADY_o,
  output reg  HRESP_o,
  output reg [15:0] HSPLIT_o
  );
  
  reg [7:0] data_i [3:0];
  wire [7:0] data_o [3:0];
  wire [3:0] write_okay;
  reg write_okay_top,read_okay_top;
  reg [3:0] sel;
  reg [`AHB_BUS_WIDTH:0] addr; 
  reg error,error_buf;
  reg HREADY_seq;

  reg [`AHB_BUS_WIDTH-1:0] HADDR_buf;
  reg [`AHB_BUS_WIDTH-1:0] HADDR_buf_sub [3:0];
  reg [`AHB_BUS_WIDTH-1:0] HWDATA_buf;
  reg [1:0] HTRANS_buf;
  reg [2:0] HSIZE_buf;
  reg [2:0] HBURST_buf;
  reg [3:0] HPROT_buf;
  reg HWRITE_buf;

  ram ram0(
    .clk(HCLK),
    .enable(sel[0]),
    .addr_i(HADDR_buf_sub[0]),
    .data_i(data_i[0]),
    .data_o(data_o[0]),
    .write(HWRITE_buf),
    .write_okay(write_okay[0])
  );
  ram ram1(
    .clk(HCLK),
    .enable(sel[1]),
    .addr_i(HADDR_buf_sub[1]),
    .data_i(data_i[1]),
    .data_o(data_o[1]),
    .write(HWRITE_buf),
    .write_okay(write_okay[1])
  );
  ram ram2(
    .clk(HCLK),
    .enable(sel[2]),
    .addr_i(HADDR_buf_sub[2]),
    .data_i(data_i[2]),
    .data_o(data_o[2]),
    .write(HWRITE_buf),
    .write_okay(write_okay[2])
  );
  ram ram3(
    .clk(HCLK),
    .enable(sel[3]),
    .addr_i(HADDR_buf_sub[3]),
    .data_i(data_i[3]),
    .data_o(data_o[3]),
    .write(HWRITE_buf),
    .write_okay(write_okay[3])
  );


  always_comb begin
    if(!HRST_N) begin
      HREADY_o = 1;
      sel = 0;
    end
    else if(HSEL) begin
      if(HTRANS_i == `TRANS_IDLE) begin
        HREADY_o = 1;
        sel = 0;
      end
      else if(!(error || error_buf)) begin
          if(HTRANS_i == `TRANS_NONESEQ && HTRANS_buf == `TRANS_IDLE) begin
            HREADY_o = 1;
          end
          else begin
            HREADY_o = (write_okay_top | read_okay_top) & HREADY_seq;
          end
          if( HTRANS_buf == `TRANS_SEQ || HTRANS_buf == `TRANS_NONESEQ) begin
            if(HWRITE_buf) begin
              read_okay_top = 0;
              case (HSIZE_buf)
                `SIZE_B: begin
                    case (HADDR_buf[1:0])
                      0: begin
                          sel = 4'b0001;
                          data_i[0] = HWDATA_i[7:0];
                          HADDR_buf_sub[0] = HADDR_buf;
                          write_okay_top = write_okay[0];
                      end
                      1: begin
                          sel = 4'b0010;
                          data_i[1] = HWDATA_i[7:0];
                          HADDR_buf_sub[1] = HADDR_buf;
                          write_okay_top = write_okay[1];
                      end
                      2: begin
                          sel = 4'b0100;
                          data_i[2] = HWDATA_i[7:0];
                          HADDR_buf_sub[2] = HADDR_buf;
                          write_okay_top = write_okay[2];
                      end
                      3: begin
                          sel = 4'b1000;
                          data_i[3] = HWDATA_i[7:0];
                          HADDR_buf_sub[3] = HADDR_buf;
                          write_okay_top = write_okay[3];
                      end
                      default: ;
                    endcase
                end
                `SIZE_HW: begin
                    case (HADDR_buf[1:0])
                      0: begin
                          sel = 4'b0011;
                          data_i[0] = HWDATA_i[7:0];
                          data_i[1] = HWDATA_i[15:8];
                          HADDR_buf_sub[0] = HADDR_buf;
                          HADDR_buf_sub[1] = HADDR_buf;
                          write_okay_top = write_okay[0] & write_okay[1];
                      end
                      1: begin
                          sel = 4'b0110;
                          data_i[1] = HWDATA_i[7:0];
                          data_i[2] = HWDATA_i[15:8];
                          HADDR_buf_sub[1] = HADDR_buf;
                          HADDR_buf_sub[2] = HADDR_buf;
                          write_okay_top = write_okay[1] & write_okay[2];
                      end
                      2: begin
                          sel = 4'b1100;
                          data_i[2] = HWDATA_i[7:0];
                          data_i[3] = HWDATA_i[15:8];
                          HADDR_buf_sub[2] = HADDR_buf;
                          HADDR_buf_sub[3] = HADDR_buf;
                          write_okay_top = write_okay[2] & write_okay[3];
                      end
                      3: begin
                          sel = 4'b1001;
                          data_i[3] = HWDATA_i[7:0];
                          data_i[0] = HWDATA_i[15:8];
                          HADDR_buf_sub[3] = HADDR_buf;
                          HADDR_buf_sub[0] = {HADDR_buf[31:2]+30'b1,2'b0};
                          write_okay_top = write_okay[3] & write_okay[0];
                      end
                      default: ;
                    endcase
                end
                `SIZE_W: begin
                    sel = 4'b1111;
                    case (HADDR_buf[1:0])
                      0: begin
                        data_i[0] = HWDATA_i[7:0];
                        data_i[1] = HWDATA_i[15:8];
                        data_i[2] = HWDATA_i[23:16];
                        data_i[3] = HWDATA_i[31:24];
                        HADDR_buf_sub[0] = HADDR_buf;
                        HADDR_buf_sub[1] = HADDR_buf;
                        HADDR_buf_sub[2] = HADDR_buf;
                        HADDR_buf_sub[3] = HADDR_buf;
                      end
                      1: begin
                        data_i[1] = HWDATA_i[7:0];
                        data_i[2] = HWDATA_i[15:8];
                        data_i[3] = HWDATA_i[23:16];
                        data_i[0] = HWDATA_i[31:24];
                        HADDR_buf_sub[0] = {HADDR_buf[31:2]+30'b1,2'b0};;
                        HADDR_buf_sub[1] = HADDR_buf;
                        HADDR_buf_sub[2] = HADDR_buf;
                        HADDR_buf_sub[3] = HADDR_buf;
                      end
                      2: begin
                        data_i[2] = HWDATA_i[7:0];
                        data_i[3] = HWDATA_i[15:8];
                        data_i[0] = HWDATA_i[23:16];
                        data_i[1] = HWDATA_i[31:24];
                        HADDR_buf_sub[0] = {HADDR_buf[31:2]+30'b1,2'b0};;
                        HADDR_buf_sub[1] = {HADDR_buf[31:2]+30'b1,2'b0};;
                        HADDR_buf_sub[2] = HADDR_buf;
                        HADDR_buf_sub[3] = HADDR_buf;
                      end
                      3: begin
                        data_i[3] = HWDATA_i[7:0];
                        data_i[0] = HWDATA_i[15:8];
                        data_i[1] = HWDATA_i[23:16];
                        data_i[2] = HWDATA_i[31:24];
                        HADDR_buf_sub[0] = {HADDR_buf[31:2]+30'b1,2'b0};;
                        HADDR_buf_sub[1] = {HADDR_buf[31:2]+30'b1,2'b0};;
                        HADDR_buf_sub[2] = {HADDR_buf[31:2]+30'b1,2'b0};;
                        HADDR_buf_sub[3] = HADDR_buf;
                      end
                      default: ;
                    endcase
                    write_okay_top = write_okay[0] & write_okay[1] & write_okay[2] & write_okay[3];
                  end
                default: ;
              endcase
            end
            else begin
              read_okay_top = 1;
              write_okay_top = 0;
              case (HSIZE_buf)
                `SIZE_B: begin
                    case (HADDR_buf[1:0])
                      0: begin
                          sel = 4'b0001;
                          HRDATA_o[7:0] = data_o[0];
                          HRDATA_o[31:8] = 24'b0;
                          HADDR_buf_sub[0] = HADDR_buf;
                          // write_okay_top = write_okay[0];
                      end
                      1: begin
                          sel = 4'b0010;
                          HRDATA_o[7:0] = data_o[1];
                          HRDATA_o[31:8] = 24'b0;
                          HADDR_buf_sub[1] = HADDR_buf;
                          // write_okay_top = write_okay[1];
                      end
                      2: begin
                          sel = 4'b0100;
                          HRDATA_o[7:0] = data_o[2];
                          HRDATA_o[31:8] = 24'b0;
                          HADDR_buf_sub[2] = HADDR_buf;
                          // write_okay_top = write_okay[2];
                      end
                      3: begin
                          sel = 4'b1000;
                          HRDATA_o[7:0] = data_o[3];
                          HRDATA_o[31:8] = 24'b0;
                          HADDR_buf_sub[3] = HADDR_buf;
                          // write_okay_top = write_okay[3];
                      end
                      default: ;
                    endcase
                end
                `SIZE_HW: begin
                    case (HADDR_buf[1:0])
                      0: begin
                          sel = 4'b0011;
                          HRDATA_o[7:0] = data_o[0];
                          HRDATA_o[15:8] = data_o[1];
                          HRDATA_o[31:16] = 16'b0;
                          HADDR_buf_sub[0] = HADDR_buf;
                          HADDR_buf_sub[1] = HADDR_buf;
                          // write_okay_top = write_okay[0] & write_okay[1];
                      end
                      1: begin
                          sel = 4'b0110;
                          HRDATA_o[7:0] = data_o[1];
                          HRDATA_o[15:8] = data_o[2];
                          HRDATA_o[31:16] = 16'b0;
                          HADDR_buf_sub[1] = HADDR_buf;
                          HADDR_buf_sub[2] = HADDR_buf;
                          // write_okay_top = write_okay[0] & write_okay[1];
                      end               
                      2: begin
                          sel = 4'b1100;
                          HRDATA_o[7:0] = data_o[2];
                          HRDATA_o[15:8] = data_o[3];
                          HRDATA_o[31:16] = 16'b0;
                          HADDR_buf_sub[2] = HADDR_buf;
                          HADDR_buf_sub[3] = HADDR_buf;
                          // write_okay_top = write_okay[2] & write_okay[3];
                      end
                      3: begin
                          sel = 4'b1001;
                          HRDATA_o[7:0] = data_o[3];
                          HRDATA_o[15:8] = data_o[0];
                          HRDATA_o[31:16] = 16'b0;
                          HADDR_buf_sub[3] = HADDR_buf;
                          HADDR_buf_sub[0] = {HADDR_buf[31:2]+30'b1,2'b0};
                          // write_okay_top = write_okay[2] & write_okay[3];
                      end
                      default: ;
                    endcase
                end
                `SIZE_W: begin
                      sel = 4'b1111;
                      case (HADDR_buf[1:0])
                        0: begin
                          HRDATA_o[7:0] = data_o[0];
                          HRDATA_o[15:8] = data_o[1];
                          HRDATA_o[23:16] = data_o[2];
                          HRDATA_o[31:24] = data_o[3];
                          HADDR_buf_sub[0] = HADDR_buf;
                          HADDR_buf_sub[1] = HADDR_buf;
                          HADDR_buf_sub[2] = HADDR_buf;
                          HADDR_buf_sub[3] = HADDR_buf;
                        end
                        1: begin
                          HRDATA_o[7:0] = data_o[1];
                          HRDATA_o[15:8] = data_o[2];
                          HRDATA_o[23:16] = data_o[3];
                          HRDATA_o[31:24] = data_o[0];
                          HADDR_buf_sub[0] = {HADDR_buf[31:2]+30'b1,2'b0};
                          HADDR_buf_sub[1] = HADDR_buf;
                          HADDR_buf_sub[2] = HADDR_buf;
                          HADDR_buf_sub[3] = HADDR_buf;
                        end
                        2: begin
                          HRDATA_o[7:0] = data_o[2];
                          HRDATA_o[15:8] = data_o[3];
                          HRDATA_o[23:16] = data_o[0];
                          HRDATA_o[31:24] = data_o[1];
                          HADDR_buf_sub[0] = {HADDR_buf[31:2]+30'b1,2'b0};
                          HADDR_buf_sub[1] = {HADDR_buf[31:2]+30'b1,2'b0};
                          HADDR_buf_sub[2] = HADDR_buf;
                          HADDR_buf_sub[3] = HADDR_buf;
                        end
                        3: begin
                          HRDATA_o[7:0] = data_o[3];
                          HRDATA_o[15:8] = data_o[0];
                          HRDATA_o[23:16] = data_o[1];
                          HRDATA_o[31:24] = data_o[2];
                          HADDR_buf_sub[0] = {HADDR_buf[31:2]+30'b1,2'b0};
                          HADDR_buf_sub[1] = {HADDR_buf[31:2]+30'b1,2'b0};
                          HADDR_buf_sub[2] = {HADDR_buf[31:2]+30'b1,2'b0};
                          HADDR_buf_sub[3] = HADDR_buf;
                        end
                        default: ;
                      endcase
                      // write_okay_top = write_okay[0] & write_okay[1] & write_okay[2] & write_okay[3];
                  end
                default: ;
              endcase
            end
          end
          else if(HTRANS_buf == `TRANS_BUSY) begin
            HREADY_o = 1;
            sel = 0;
          end
      end
      else begin
        HREADY_o = HREADY_seq;
      end
    end
    else begin
      sel = 0;
    end
  end

  always_ff @(posedge HCLK or negedge HRST_N) begin
    if(!HRST_N) begin
      HRESP_o <= `RESP_OKAY;
      HREADY_seq <= 1;
    end
    else if(HSEL) begin
      if(HTRANS_i != `TRANS_IDLE) begin
        if(HREADY_i) begin
          if(HADDR_i[27:0] <= `TOTAL_RAM_SIZE) begin
            if(!error) begin
              HRESP_o <= `RESP_OKAY;
              HREADY_seq <= 1;
              HADDR_buf <= HADDR_i;
              HSIZE_buf <= HSIZE_i;
              HWRITE_buf <= HWRITE_i;
              HTRANS_buf <= HTRANS_i;
              // HWDATA_buf <= HWDATA_i;
            end
          end
          else begin
            error <= 1;
            HRESP_o <= `RESP_ERROR;
            HREADY_seq <= 0;
          end
        end
      end
      if(error) begin
        HRESP_o <= `RESP_ERROR;
        error <= 0;
        error_buf <= 1;
        HREADY_seq <= 1;
      end
      if(error_buf) begin
        HRESP_o <= `RESP_OKAY;
        error_buf <= 0;
      end
    end

    if((HTRANS_i == `TRANS_IDLE && HREADY_i) || !HSEL) begin
      HTRANS_buf <= `TRANS_IDLE;
    end
  end

endmodule