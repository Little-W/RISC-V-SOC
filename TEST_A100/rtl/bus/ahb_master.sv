`include "defines.v"
  module ahb_master(
    input HCLK,//总线时钟
    input HRST_N,//总线复位
    input start,
    input HGRANT_i,
    input [`AHB_BUS_WIDTH-1:0] din,//top--->master，输入数据
    input [`AHB_BUS_WIDTH-1:0] tgt_addr,
    input HREADY_i,
    input [`AHB_BUS_WIDTH-1:0] HRDATA_i,
    input HRESP_i,
    output reg [`AHB_BUS_WIDTH-1:0] HADDR_o,
    output reg HWRITE_o,
    output reg [`AHB_BUS_WIDTH-1:0] HWDATA_o,
    output reg [2:0] HSIZE_o,
    output reg [1:0] HTRANS_o,
    output reg [2:0] HBURST_o,
    output reg [2:0] HPROT_o,
    output reg HLOCK_o,
    output reg HBUSREQ_o,
    output reg okay,
    output reg [7:0] receive [511:0]
    // output reg [`AHB_BUS_WIDTH-1:0] dout//master--->top 将从slave读入的数据输出 
    );

  // assign HWDATA_o = en_hwdata ? HWDATA : 'bz;
  // assign HADDR_o = en_haddr ? HADDR : 'bz;
  // assign HWRITE_o = en_hwrite ? HWRITE : 'bz;
  // assign HSIZE_o = en_hsize ? HSIZE : 'bz;

  // reg [`AHB_BUS_WIDTH-1:0] HADDR;
  // reg [`AHB_BUS_WIDTH-1:0] HWDATA;
  // reg HWRITE;
  // reg [2:0] HSIZE;
  // reg en_hwdata,en_haddr,en_hwrite,en_hsize;

  reg [7:0] storage [511:0];
  reg [8:0] storage_pointer;
  // reg [7:0] receive [511:0];

  reg [`AHB_BUS_WIDTH-1:0] addr;
  reg [2:0] test_step;
  reg [8:0] cnt;
  reg [3:0] cnt_2;
  reg [2:0] busy_cnt;
  reg [`AHB_BUS_WIDTH-1:0] addr_buf_1,addr_buf_2;
  reg HGRANT_buf_1;
  reg read_data_from_slave,write_data_to_slave;
  reg [`AHB_BUS_WIDTH-1:0] error_resp_test_addr;
  reg error_handle,error_resp_tested; //error响应测试
  reg write_test_en;
  reg read_test_en;

  always @(posedge HCLK or negedge HRST_N) begin
    if(!HRST_N) begin
      HADDR_o <= 32'h0000_0000;
      // en_hwdata <= 1'b0;
      // en_haddr <= 1'b0;
      // en_hwrite <= 1'b0;
      // en_hsize <= 1'b0;
      HWDATA_o <= 32'h0000_0000;
      HTRANS_o <= `TRANS_IDLE;
      write_test_en <= 1;
      read_test_en <= 0;
    end
    else begin
      if(!start) begin
        addr <= tgt_addr;
        error_resp_test_addr <= (tgt_addr | `TOTAL_RAM_SIZE) + 1;
        storage[storage_pointer] <= din[7:0];
        storage[storage_pointer+1] <= din[15:8];
        storage[storage_pointer+2] <= din[23:16];
        storage[storage_pointer+3] <= din[31:24];
        if(din[31:24]) begin
          storage_pointer <= storage_pointer + 4;
        end
        else if(din[23:16]) begin
          storage_pointer <= storage_pointer + 3;
        end
        else if(din[15:8]) begin
          storage_pointer <= storage_pointer + 2;
        end
        else if(din[7:0]) begin
          storage_pointer <= storage_pointer + 1;
        end
        else begin
          storage_pointer <= storage_pointer;
        end
      end
      else begin
        if(write_test_en) begin //write data to slave
            HWRITE_o <= 1;
            if(HGRANT_i | HGRANT_buf_1) begin
              if(HREADY_i && (HRESP_i == `RESP_OKAY || (!HGRANT_buf_1))) begin
                // HRESP_i == `RESP_OKAY || !HGRANT_buf_1 error response结束后切换的新主机应不受影响
                case (test_step)
                  0: begin  //INCR4 + 32位写入
                        cnt <= cnt + 1;
                        if(cnt <= 3) begin
                          addr <= addr + 4;
                          HADDR_o <= addr;
                        end
                        HBURST_o <= `BURST_INCR4;
                        HSIZE_o <= `SIZE_W;
                        if(cnt == 0) begin
                          HTRANS_o <= `TRANS_NONESEQ;
                          write_data_to_slave <= 1;
                        end
                        else begin
                          if(cnt <= 3) HTRANS_o <= `TRANS_SEQ;
                          else begin
                            test_step <= 1;
                            cnt <= 0;
                            HTRANS_o <= `TRANS_IDLE;
                            write_data_to_slave <= 0;
                          end
                          end
                      end
                  1: begin   //INCR4 + 16位写入
                        if(cnt <= 3) begin
                          addr <= addr + 2;
                          HADDR_o <= addr;
                        end
                        cnt <= cnt + 1;
                        HBURST_o <= `BURST_INCR4;
                        HSIZE_o <= `SIZE_HW;
                        if(cnt == 0) begin
                          HTRANS_o <= `TRANS_NONESEQ;
                          write_data_to_slave <= 1;
                        end
                        else begin
                          if(cnt <= 3) HTRANS_o <= `TRANS_SEQ;
                          else begin
                            test_step <= 2;
                            cnt <= 0;
                            HTRANS_o <= `TRANS_IDLE;
                            write_data_to_slave <= 0;
                          end
                        end
                      end
                  2: begin     //INCR16 + 8位写入
                        HADDR_o <= addr;
                        HBURST_o <= `BURST_INCR16;
                        HSIZE_o <= `SIZE_B;
                        if(cnt_2 == 4) begin
                          HTRANS_o <= `TRANS_BUSY;
                          write_data_to_slave <= 0;
                          cnt_2 <= 0;
                        end
                        else begin
                          if(cnt == 15) begin
                            test_step <= 3;
                            cnt <= 0;
                          end
                          else begin
                            cnt <= cnt + 1;
                          end
                          cnt_2 <= cnt_2 + 1;
                          addr <= addr + 1;
                          write_data_to_slave <= 1;
                          if(cnt == 0) begin
                            HTRANS_o <= `TRANS_NONESEQ;
                          end
                          else begin
                            HTRANS_o <= `TRANS_SEQ;
                          end
                        end
                    end
                  3: begin
                        cnt <= cnt + 1;
                        HADDR_o <= addr;
                        HBURST_o <= `BURST_INCR;
                        HSIZE_o <= `SIZE_HW;
                        if(cnt_2 == 4) begin  //按照固定间隔插入busy传输周期
                          HTRANS_o <= `TRANS_BUSY;
                          write_data_to_slave <= 0;
                          cnt_2 <= 0;
                          if(cnt > 10) begin
                            test_step <= 4;
                            cnt <= 0;
                          end
                        end
                        else begin
                          addr <= addr + 2;
                          write_data_to_slave <= 1;
                          cnt_2 <= cnt_2 + 1; //连续seq传输计数器
                          if(cnt == 0) begin
                            HTRANS_o <= `TRANS_NONESEQ;
                          end
                          else begin
                            HTRANS_o <= `TRANS_SEQ;
                          end
                        end
                    end
                  4: begin
                        cnt <= cnt + 1;
                        HADDR_o <= addr;
                        HBURST_o <= `BURST_INCR;
                        HSIZE_o <= `SIZE_W;
                        if(cnt_2 == busy_cnt + 2) begin
                          HTRANS_o <= `TRANS_BUSY;
                          cnt_2 <= 0;
                          busy_cnt <= busy_cnt + 1;
                          write_data_to_slave <= 0;
                        end
                        else begin
                          cnt_2 <= cnt_2 + 1;
                          if(HGRANT_i) begin
                            addr <= addr + 4;
                            write_data_to_slave <= 1;
                          end
                          if(cnt == 0) begin
                            HTRANS_o <= `TRANS_NONESEQ;
                          end
                          else begin
                            HTRANS_o <= `TRANS_SEQ;
                          end
                        end
                    end
                  default: ;
                endcase
              end
            end
        end
        if(read_test_en) begin //read data from slave
          if(HGRANT_i | HGRANT_buf_1) begin
            if(HREADY_i) begin
              if(test_step == 4) begin
                  cnt <= 0;
                  cnt_2 <= 0;
                  addr <= tgt_addr;
                  test_step <= test_step + 1;
                  write_data_to_slave <= 0;
                  HTRANS_o <= `TRANS_BUSY;
              end
              if(test_step == 5) begin
                  if(HGRANT_i) begin
                    cnt <= cnt + 1;
                    if(cnt == 20 && !error_resp_tested) begin
                      addr <= addr;
                    end
                    else begin
                      addr <= addr + 4;
                    end
                  end
                  if(cnt == 20 && !error_resp_tested) begin
                    HADDR_o <= error_resp_test_addr;
                  end
                  else begin
                    HADDR_o <= addr;
                  end
                  HBURST_o <= `BURST_INCR;
                  HSIZE_o <= `SIZE_W;
                  if(cnt == 0) begin
                    HTRANS_o <= `TRANS_NONESEQ;
                    HWRITE_o <= 0;
                    read_data_from_slave <= 1;
                  end
                  else begin
                    if(HRESP_i != `RESP_ERROR) begin
                      HTRANS_o <= `TRANS_SEQ;
                    end
                  end
                end
            end
          end
        end
      end

      if(addr_buf_1 > tgt_addr + storage_pointer && write_test_en) begin
        write_test_en <= 0;
        addr <= tgt_addr;
        addr_buf_1 <= 0;
        addr_buf_2 <= 0;
        read_test_en <= 1;
      end
      if(addr_buf_1 > tgt_addr + storage_pointer && read_test_en) begin
        read_test_en <= 0;
        read_data_from_slave <= 0;
      end
    end
  end

  always @(posedge HCLK or negedge HRST_N) begin

    if(!HRST_N) begin
        error_resp_tested <= 0;
    end
    else begin
      if(HRESP_i == `RESP_ERROR && HTRANS_o == `TRANS_IDLE) begin
        addr <= addr_buf_2;
        HBUSREQ_o <= 1;
        // error_handle <= 0;
        error_resp_tested <= 1;
      end
      if(HGRANT_buf_1 && HRESP_i == `RESP_ERROR && HTRANS_o != `TRANS_IDLE) begin
          HBUSREQ_o <= 0;
          HTRANS_o <= `TRANS_IDLE;
          write_data_to_slave <= 0;
          read_data_from_slave <= 0;
          // error_handle <= 1;
          cnt <= 0;
          cnt_2 <= 0;
        end
        else if(start) begin
          if(write_test_en || read_test_en) begin
              HBUSREQ_o <= 1;
          end
          else begin
            write_data_to_slave <= 0;
            read_data_from_slave <= 0;
            HBUSREQ_o <= 0;
            okay <= 1;
            if(HREADY_i) begin
              HTRANS_o <= `TRANS_IDLE;
            end
          end
        end
      if(HREADY_i) begin
        HGRANT_buf_1 <= HGRANT_i;
        if(!(HGRANT_i && HGRANT_buf_1)) begin
          if(!(HGRANT_buf_1 | HGRANT_i)) begin
            read_data_from_slave <= 0; //读数据要打两拍，第一拍slave发送数据，第二拍master储存数据。
            cnt <= 0;
            cnt_2 <= 0;
          end
          if(!HGRANT_i) begin
            write_data_to_slave <= 0; //写数据只要打一拍
          end
        end
        if(HRESP_i == `RESP_OKAY) begin
          if(read_data_from_slave) begin
            addr_buf_1 <= addr;
            addr_buf_2 <= addr_buf_1; //打两拍
            case (HSIZE_o)
              `SIZE_B:  
                  receive[addr_buf_2] <= HRDATA_i[7:0];
              `SIZE_HW: begin
                  receive[addr_buf_2] <= HRDATA_i[7:0];
                  receive[addr_buf_2+1] <= HRDATA_i[15:8];
              end
              `SIZE_W: begin
                  receive[addr_buf_2] <= HRDATA_i[7:0];
                  receive[addr_buf_2+1] <= HRDATA_i[15:8];
                  receive[addr_buf_2+2] <= HRDATA_i[23:16];
                  receive[addr_buf_2+3] <= HRDATA_i[31:24];
                end
              default: ;
            endcase
          end
          if(write_data_to_slave) begin
            addr_buf_1 <= addr;
            addr_buf_2 <= addr_buf_1; 
            case (HSIZE_o)
              `SIZE_B: begin
                  HWDATA_o <= {24'b0,storage[addr_buf_1]};
                end
              `SIZE_HW: begin
                  HWDATA_o <= {16'b0,storage[addr_buf_1+1],storage[addr_buf_1]};
              end 
              `SIZE_W: begin
                  HWDATA_o <= {storage[addr_buf_1+3],storage[addr_buf_1+2],storage[addr_buf_1+1],storage[addr_buf_1]};
              end
              default: ;
            endcase
          end
        end
      end
    end
  end
endmodule