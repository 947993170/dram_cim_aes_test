//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
//Date        : Thu Sep  4 00:27:36 2025
//Host        : DESKTOP-0ODM8BR running 64-bit major release  (build 9200)
//Command     : generate_target clk_gen_uart_wrapper.bd
//Design      : clk_gen_uart_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module clk_gen_uart_wrapper
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
  input BUSY_AES;
  input CLK;
  output [127:0]DIN_AES;
  input [127:0]DOUT_AES;
  input DVLD_AES;
  output EN_AES;
  output KDRDY_AES;
  output [127:0]KIN_AES;
  input KVLD_AES;
  input NRST;
  output RSTn_AES;
  input RX_UART;
  output TX_UART;

  wire BUSY_AES;
  wire CLK;
  wire [127:0]DIN_AES;
  wire [127:0]DOUT_AES;
  wire DVLD_AES;
  wire EN_AES;
  wire KDRDY_AES;
  wire [127:0]KIN_AES;
  wire KVLD_AES;
  wire NRST;
  wire RSTn_AES;
  wire RX_UART;
  wire TX_UART;

  clk_gen_uart clk_gen_uart_i
       (.BUSY_AES(BUSY_AES),
        .CLK(CLK),
        .DIN_AES(DIN_AES),
        .DOUT_AES(DOUT_AES),
        .DVLD_AES(DVLD_AES),
        .EN_AES(EN_AES),
        .KDRDY_AES(KDRDY_AES),
        .KIN_AES(KIN_AES),
        .KVLD_AES(KVLD_AES),
        .NRST(NRST),
        .RSTn_AES(RSTn_AES),
        .RX_UART(RX_UART),
        .TX_UART(TX_UART));
endmodule
