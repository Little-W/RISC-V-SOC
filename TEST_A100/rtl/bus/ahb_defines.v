`define AHB_BUS_WIDTH 32
`define DEFAULT_MASTER 16'b0000000000000001
`define DUMMY_MASTER 16'b1000000000000000
`define GRANT_MASTER0 16'b0000000000000001
`define GRANT_MASTER1 16'b0000000000000010
`define GRANT_MASTER2 16'b0000000000000100
`define GRANT_MASTER3 16'b0000000000001000
`define GRANT_MASTER4 16'b0000000000010000
`define GRANT_MASTER5 16'b0000000000100000
`define GRANT_MASTER6 16'b0000000001000000
`define GRANT_MASTER7 16'b0000000010000000
`define GRANT_MASTER8 16'b0000000100000000
`define GRANT_MASTER9 16'b0000001000000000
`define DEFAULT_MASTER_ID 0
`define DUMMY_MASTER_ID 15
`define TRANS_IDLE 2'b00 
`define TRANS_BUSY 2'b01
`define TRANS_NONESEQ 2'b10
`define TRANS_SEQ 2'b11
`define BUSRT_SINGLE 3'b000 
`define BURST_INCR 3'b001 
`define BURST_WRAP4 3'b010 
`define BURST_INCR4 3'b011 
`define BURST_WRAP8 3'b100
`define BURST_INCR8 3'b011
`define BURST_WRAP16 3'b110 
`define BURST_INCR16 3'b111
`define SIZE_B 3'b000 
`define SIZE_HW 3'b001
`define SIZE_W 3'b010
`define SIZE_DW 3'b011
`define SIZE_4W 3'b100
`define SIZE_8W 3'b101 
`define SIZE_16W 3'b110
`define SIZE_32W 3'b111

// AMBA 2.0 defs with SPLIT capability
// `define RESP_OKAY 2'b00
// `define RESP_ERROR 2'b01
// `define RESP_RETRY 2'b10
// `define RESP_SPLIT 2'b11

//AMBA 5 AHB HRESP defs
`define RESP_OKAY 1'b0
`define RESP_ERROR 1'b1

`define SEL_SLAVE0 16'b0000000000000001
`define SEL_SLAVE1 16'b0000000000000010
`define SEL_SLAVE2 16'b0000000000000100
`define SEL_SLAVE3 16'b0000000000001000
`define SEL_SLAVE4 16'b0000000000010000
`define SEL_SLAVE5 16'b0000000000100000
`define SEL_SLAVE6 16'b0000000001000000
`define SEL_SLAVE7 16'b0000000010000000
`define SEL_SLAVE8 16'b0000000100000000
`define SEL_SLAVE9 16'b0000001000000000
`define SEL_DUMMY_SLAVE 16'b1000000000000000

`define DEVICE_OK 4'b0001

`define INCR_LIMIT 50