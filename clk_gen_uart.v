//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
//Date        : Thu Sep  4 00:27:36 2025
//Host        : DESKTOP-0ODM8BR running 64-bit major release  (build 9200)
//Command     : generate_target clk_gen_uart.bd
//Design      : clk_gen_uart
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "clk_gen_uart,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=clk_gen_uart,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=1,numReposBlks=1,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=Global}" *) (* HW_HANDOFF = "clk_gen_uart.hwdef" *) 
module clk_gen_uart
   (BUSY_AES,
    CLK,
    DIN_AES,
    DOUT_AES,
    DVLD_AES,
    EN_AES,
    KDRDY_AES,
    KIN_AES,
    KVLD_AES,
    NRST,
    RSTn_AES,
    RX_UART,
    TX_UART);
  (* X_INTERFACE_INFO = "xilinx.com:signal:data:1.0 DATA.BUSY_AES DATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DATA.BUSY_AES, LAYERED_METADATA undef" *) input BUSY_AES;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLK, ASSOCIATED_RESET NRST, CLK_DOMAIN clk_gen_uart_CLK_0, FREQ_HZ 100000000, INSERT_VIP 0, PHASE 0.0" *) input CLK;
  output [127:0]DIN_AES;
  input [127:0]DOUT_AES;
  (* X_INTERFACE_INFO = "xilinx.com:signal:data:1.0 DATA.DVLD_AES DATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DATA.DVLD_AES, LAYERED_METADATA undef" *) input DVLD_AES;
  output EN_AES;
  output KDRDY_AES;
  output [127:0]KIN_AES;
  (* X_INTERFACE_INFO = "xilinx.com:signal:data:1.0 DATA.KVLD_AES DATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DATA.KVLD_AES, LAYERED_METADATA undef" *) input KVLD_AES;
  input NRST;
  output RSTn_AES;
  input RX_UART;
  (* X_INTERFACE_INFO = "xilinx.com:signal:data:1.0 DATA.TX_UART DATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DATA.TX_UART, LAYERED_METADATA undef" *) output TX_UART;

  wire BUSY_AES_1;
  wire CLK_0_1;
  wire [127:0]DOUT_AES_1;
  wire DVLD_AES_1;
  wire KVLD_AES_1;
  wire NRST_1;
  wire RX_UART_1;
  wire [127:0]UART_Interface_Contr_0_DIN_AES;
  wire UART_Interface_Contr_0_EN_AES;
  wire UART_Interface_Contr_0_KDRDY_AES;
  wire [127:0]UART_Interface_Contr_0_KIN_AES;
  wire UART_Interface_Contr_0_RSTn_AES;
  wire UART_Interface_Contr_0_TX_UART;

  assign BUSY_AES_1 = BUSY_AES;
  assign CLK_0_1 = CLK;
  assign DIN_AES[127:0] = UART_Interface_Contr_0_DIN_AES;
  assign DOUT_AES_1 = DOUT_AES[127:0];
  assign DVLD_AES_1 = DVLD_AES;
  assign EN_AES = UART_Interface_Contr_0_EN_AES;
  assign KDRDY_AES = UART_Interface_Contr_0_KDRDY_AES;
  assign KIN_AES[127:0] = UART_Interface_Contr_0_KIN_AES;
  assign KVLD_AES_1 = KVLD_AES;
  assign NRST_1 = NRST;
  assign RSTn_AES = UART_Interface_Contr_0_RSTn_AES;
  assign RX_UART_1 = RX_UART;
  assign TX_UART = UART_Interface_Contr_0_TX_UART;
  clk_gen_uart_UART_Interface_Contr_0_1 UART_Interface_Contr_0
       (.BUSY_AES(BUSY_AES_1),
        .CLK(CLK_0_1),
        .DIN_AES(UART_Interface_Contr_0_DIN_AES),
        .DOUT_AES(DOUT_AES_1),
        .DVLD_AES(DVLD_AES_1),
        .EN_AES(UART_Interface_Contr_0_EN_AES),
        .KDRDY_AES(UART_Interface_Contr_0_KDRDY_AES),
        .KIN_AES(UART_Interface_Contr_0_KIN_AES),
        .KVLD_AES(KVLD_AES_1),
        .NRST(NRST_1),
        .RSTn_AES(UART_Interface_Contr_0_RSTn_AES),
        .RX_UART(RX_UART_1),
        .TX_UART(UART_Interface_Contr_0_TX_UART));
endmodule
