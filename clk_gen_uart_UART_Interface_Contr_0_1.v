// (c) Copyright 1995-2025 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:user:UART_Interface_Controller:1.0
// IP Revision: 8

`timescale 1ns/1ps

(* IP_DEFINITION_SOURCE = "package_project" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module clk_gen_uart_UART_Interface_Contr_0_1 (
  CLK,
  NRST,
  RX_UART,
  DOUT_AES,
  KVLD_AES,
  DVLD_AES,
  BUSY_AES,
  TX_UART,
  EN_AES,
  RSTn_AES,
  KIN_AES,
  DIN_AES,
  KDRDY_AES
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK, ASSOCIATED_RESET NRST, FREQ_HZ 100000000, PHASE 0.0, INSERT_VIP 0, CLK_DOMAIN /clk_wiz_0_clk_out1" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK CLK" *)
input wire CLK;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME NRST, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 NRST RST" *)
input wire NRST;
input wire RX_UART;
input wire [127 : 0] DOUT_AES;
input wire KVLD_AES;
input wire DVLD_AES;
input wire BUSY_AES;
output wire TX_UART;
output wire EN_AES;
output wire RSTn_AES;
output wire [127 : 0] KIN_AES;
output wire [127 : 0] DIN_AES;
output wire KDRDY_AES;

  UART_Interface_Controller #(
    .Counter_Parameter(10416),
    .S00('B0000),
    .S01('B0001),
    .S02('B0010),
    .S03('B0011),
    .S04('B0100),
    .S05('B0101),
    .S06('B0110),
    .S07('B0111),
    .S08('B1000),
    .S09('B1001),
    .S10('B1010)
  ) inst (
    .CLK(CLK),
    .NRST(NRST),
    .RX_UART(RX_UART),
    .DOUT_AES(DOUT_AES),
    .KVLD_AES(KVLD_AES),
    .DVLD_AES(DVLD_AES),
    .BUSY_AES(BUSY_AES),
    .TX_UART(TX_UART),
    .EN_AES(EN_AES),
    .RSTn_AES(RSTn_AES),
    .KIN_AES(KIN_AES),
    .DIN_AES(DIN_AES),
    .KDRDY_AES(KDRDY_AES)
  );
endmodule
