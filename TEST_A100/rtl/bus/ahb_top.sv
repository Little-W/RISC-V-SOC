 `include "ahb_defines.v"

module ahb_top(
    input master_start [15:0],
    input [`AHB_BUS_WIDTH-1:0] master_din [15:0],
    input clk,
    input rst_n,
    output wire master_okay [15:0],
    output wire [7:0] master_receive [15:0][511:0]
);
    wire [15:0] HBUSREQ_ALL;
    wire [15:0] HREADY_ALL;
    wire [1:0] HTRANS_ALL [15:0];
    wire [2:0] HSIZE_ALL [15:0];
    wire [2:0] HBURST_ALL [15:0];
    wire [3:0] HPROT_ALL [15:0];
    wire [15:0] HWRITE_ALL;
    wire [15:0] HGRANT_ALL;
    wire [15:0] HREADY_ALL;
    wire [15:0] HLOCK_ALL;
    wire HRESP_ALL [15:0];
    wire [`AHB_BUS_WIDTH-1:0] HADDR_ALL [15:0];
    wire [`AHB_BUS_WIDTH-1:0] HRDATA_ALL [15:0];
    wire [`AHB_BUS_WIDTH-1:0] HWDATA_ALL [15:0];
    wire [15:0] HSPLIT_ALL [15:0];
    wire [15:0] HSEL_ALL;

    wire HBUSREQ;
    wire [1:0] HTRANS;
    wire [2:0] HSIZE;
    wire [2:0] HBURST;
    wire [3:0] HPROT;
    wire HWRITE;
    wire [3:0] HMASTER;
    wire HGRANT;
    wire HREADY;
    wire HRESP;
    wire [`AHB_BUS_WIDTH-1:0] HADDR;
    wire [`AHB_BUS_WIDTH-1:0] HRDATA;
    wire [`AHB_BUS_WIDTH-1:0] HWDATA;
    wire HLOCKMASTER;

    ahb_master master0(
        .HCLK(clk),
        .HRST_N(rst_n),
        .start(master_start[0]),
        .HGRANT_i(HGRANT_ALL[0]),
        .din(master_din[0]),
        .receive(master_receive[0]),
        .tgt_addr(32'h0),
        .okay(master_okay[0]),
        .HADDR_o(HADDR_ALL[0]),
        .HWDATA_o(HWDATA_ALL[0]),
        .HBURST_o(HBURST_ALL[0]),
        .HTRANS_o(HTRANS_ALL[0]),
        .HSIZE_o(HSIZE_ALL[0]),
        .HBUSREQ_o(HBUSREQ_ALL[0]),
        .HPROT_o(HPROT_ALL[0]),
        .HWRITE_o(HWRITE_ALL[0]),
        .HLOCK_o(HLOCK_ALL[0]),
        .HRDATA_i(HRDATA),
        .HRESP_i(HRESP),
        .HREADY_i(HREADY)
    );
    ahb_master master1 (
        .HCLK(clk),
        .HRST_N(rst_n),
        .start(master_start[1]), 
        .HGRANT_i(HGRANT_ALL[1]), 
        .din(master_din[1]), 
        .receive(master_receive[1]),
        .tgt_addr(32'h10000000), 
        .okay(master_okay[1]),
        .HADDR_o(HADDR_ALL[1]), 
        .HWDATA_o(HWDATA_ALL[1]), 
        .HBURST_o(HBURST_ALL[1]), 
        .HTRANS_o(HTRANS_ALL[1]), 
        .HSIZE_o(HSIZE_ALL[1]), 
        .HBUSREQ_o(HBUSREQ_ALL[1]), 
        .HPROT_o(HPROT_ALL[1]), 
        .HWRITE_o(HWRITE_ALL[1]), 
        .HLOCK_o(HLOCK_ALL[1]), 
        .HRDATA_i(HRDATA), 
        .HRESP_i(HRESP), 
        .HREADY_i(HREADY)
    );


    ahb_slave slave0(
        .HCLK(clk),
        .HRST_N(rst_n),
        .HSEL(HSEL_ALL[0]),
        .HADDR_i(HADDR),
        .HWDATA_i(HWDATA),
        .HTRANS_i(HTRANS),
        .HSIZE_i(HSIZE),
        .HBURST_i(HBURST),
        .HPROT_i(HPROT),
        .HWRITE_i(HWRITE),
        .HREADY_i(HREADY),
        .HRDATA_o(HRDATA_ALL[0]),
        .HREADY_o(HREADY_ALL[0]),
        .HRESP_o(HRESP_ALL[0]),
        .HSPLIT_o(HSPLIT_ALL[0])
    );
    ahb_slave slave1(
        .HCLK(clk),               // 时钟信号
        .HRST_N(rst_n),           // 复位信号
        .HSEL(HSEL_ALL[1]),       // 片选信号
        .HADDR_i(HADDR),           // 地址输入
        .HWDATA_i(HWDATA),         // 数据输入
        .HTRANS_i(HTRANS),         // 传输类型输入
        .HSIZE_i(HSIZE),           // 数据宽度输入
        .HBURST_i(HBURST),         // 传输突发类型输入
        .HPROT_i(HPROT),           // 保护类型输入
        .HWRITE_i(HWRITE),         // 写使能输入
        .HREADY_i(HREADY),       // 准备好信号输入
        .HRDATA_o(HRDATA_ALL[1]),  // 读取数据输出
        .HREADY_o(HREADY_ALL[1]), // 准备好信号输出
        .HRESP_o(HRESP_ALL[1]),     // 响应信号输出
        .HSPLIT_o(HSPLIT_ALL[1])
    );
    ahb_arbiter ahb_arbiter (
        .HRST_N(rst_n),
        .HCLK(clk),
        .HADDR_i(HADDR),
        .HBUSREQ_i(HBUSREQ_ALL),
        .HLOCK_i(HLOCK_ALL),
        .HSPLIT_i(HSPLIT_ALL),
        .HREADY_i(HREADY),
        .HRESP_i(HRESP),
        .HBURST_i(HBURST),
        .HTRANS_i(HTRANS),
        .HGRANT_o(HGRANT_ALL),
        .HLOCKMASTER_o(HLOCKMASTER),
        .HMASTER_o(HMASTER)
    );

    ahb_write_mux ahb_write_mux (
        .HCLK(clk),
        .HRST_N(rst_n),
        .HADDR_i(HADDR_ALL),
        .HWDATA_i(HWDATA_ALL),
        .HTRANS_i(HTRANS_ALL),
        .HSIZE_i(HSIZE_ALL),
        .HBURST_i(HBURST_ALL),
        .HPROT_i(HPROT_ALL),
        .HWRITE_i(HWRITE_ALL),
        .HMASTER_i(HMASTER),
        .HGRANT_i(HGRANT_ALL),
        .HREADY_i(HREADY),
        .HADDR_o(HADDR),
        .HWDATA_o(HWDATA),
        .HTRANS_o(HTRANS),
        .HSIZE_o(HSIZE),
        .HBURST_o(HBURST),
        .HPROT_o(HPROT),
        .HWRITE_o(HWRITE)
    );
    ahb_read_mux ahb_read_mux (
        .HCLK(clk),
        .HRST_N(rst_n),
        .HREADY_i(HREADY_ALL),  
        .HRDATA_i(HRDATA_ALL),  
        .HRESP_i(HRESP_ALL),  
        .HADDR_i(HADDR),
        .HRDATA_o(HRDATA),  
        .HREADY_o(HREADY),  
        .HRESP_o(HRESP)     
    );

    ahb_decoder ahb_decoder (
        .HCLK(clk),
        .HRST_N(rst_n),
        .HREADY_i(HREADY),
        .HADDR_i(HADDR),
        .HSEL_o(HSEL_ALL)
    );


endmodule
