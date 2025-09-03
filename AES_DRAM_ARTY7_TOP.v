`timescale 1ns / 1ps

// Final top-level integrating UART interface with DRAM CIM-based AES core.
module AES_DRAM_ARTY7_TOP(
    // UART interface
    input  wire         NRST,
    input  wire         RX_UART,
    output wire         TX_UART,
    output wire         BSY,
    output wire         clk_mo,
    output wire         rst_mo,
    // DRAM interface
    input  wire         CLK_p,
    input  wire         CLK_n,
    input  wire         SW1,
    input  wire         SW2,
    input  wire         SW3,
    input  wire         SW4,
    input  wire         SW5,
    input  wire         SW6,
    input  wire         SW7,
    input  wire         SW8,
    input  wire         SW9,
    input  wire         SW10,
    input  wire         SW11,
    input  wire         SW12,
    input  wire         ROUT_1v8_1,
    input  wire         ROUT_1v8_2,
    input  wire         ROUT_1v8_3,
    input  wire         ROUT_1v8_4,
    input  wire         ROUT_1v8_5,
    input  wire         ROUT_1v8_6,
    input  wire         ROUT_1v8_7,
    input  wire         ROUT_1v8_8,
    input  wire         ROUT_1v8_9,
    input  wire         ROUT_1v8_10,
    input  wire         ROUT_1v8_11,
    input  wire         ROUT_1v8_12,
    input  wire         ROUT_1v8_13,
    input  wire         ROUT_1v8_14,
    input  wire         ROUT_1v8_15,
    input  wire         ROUT_1v8_16,
    output wire         RAD_1v8_1,
    output wire         RAD_1v8_2,
    output wire         RAD_1v8_3,
    output wire         RAD_1v8_4,
    output wire         RAD_1v8_5,
    output wire         RAD_1v8_6,
    output wire         RAD_1v8_7,
    output wire         RAD_1v8_8,
    output wire         RAD_1v8_9,
    output wire         RAD_1v8_10,
    output wire         RAD_1v8_11,
    output wire         RAD_1v8_12,
    output wire         RAD_1v8_13,
    output wire         RAD_1v8_14,
    output wire         RAD_1v8_15,
    output wire         RAD_1v8_16,
    output wire         DIN_1v8_1,
    output wire         DIN_1v8_2,
    output wire         DIN_1v8_3,
    output wire         DIN_1v8_4,
    output wire         DIN_1v8_5,
    output wire         DIN_1v8_6,
    output wire         DIN_1v8_7,
    output wire         DIN_1v8_8,
    output wire         DIN_1v8_9,
    output wire         DIN_1v8_10,
    output wire         DIN_1v8_11,
    output wire         DIN_1v8_12,
    output wire         DIN_1v8_13,
    output wire         DIN_1v8_14,
    output wire         DIN_1v8_15,
    output wire         DIN_1v8_16,
    output wire         ADDIN_1v8,
    output wire         ADVLD_1v8,
    output wire         DVLD_1v8,
    output wire         DMX2_1v8,
    output wire         RDEN_1v8,
    output wire         WRIEN_1v8,
    output wire         VSAEN_1v8,
    output wire         REFWWL_1v8,
    output wire         CLK_chip_1v8,
    output wire         CINH_ps_1v8,
    output wire         SR_ps_1v8,
    output wire         CLK_ps_1v8,
    output wire         CLRb_spw_1v8,
    output wire         CLK_spw_1v8,
    output wire         CLRb_spr_1v8,
    output wire         CLK_spr_1v8,
    output wire         LIMSEL0_1v8,
    output wire         LIMSEL1_1v8,
    output wire         LIMIN_1v8_1,
    output wire         LIMIN_1v8_2,
    output wire         LIMIN_1v8_3,
    output wire         LIMIN_1v8_4,
    output wire         LIMIN_1v8_5,
    output wire         LIMIN_1v8_6,
    output wire         LIMIN_1v8_7,
    output wire         LIMIN_1v8_8,
    output wire         LIMIN_1v8_9,
    output wire         LIMIN_1v8_10,
    output wire         LIMIN_1v8_11,
    output wire         LIMIN_1v8_12,
    output wire         LIMIN_1v8_13,
    output wire         LIMIN_1v8_14,
    output wire         LIMIN_1v8_15,
    output wire         LIMIN_1v8_16
);

    // Wires between UART controller and DRAM AES core
    wire        CLK;        // buffered clock from differential input
    wire        aes_bsy;
    wire [127:0] aes_dout;
    wire        aes_dvld;
    wire        aes_kvld;
    wire [127:0] din_aes;
    wire [127:0] kin_aes;
    wire        en_aes;
    wire        kdrdy_aes;
    wire        rstn_aes;
    wire        CLK_int;
    wire        trigger;

    IBUFDS #(
        .DIFF_TERM ("FALSE"),
        .IBUF_LOW_PWR("TRUE"),
        .IOSTANDARD("DEFAULT")
    ) IBUFDS_inst (
        .O (CLK),
        .I (CLK_p),
        .IB(CLK_n)
    );

    // UART to AES controller
    clk_gen_uart_wrapper clk_gen_intf_0(
        .BUSY_AES(aes_bsy),
        .DIN_AES(din_aes),
        .DOUT_AES(aes_dout),
        .DVLD_AES(aes_dvld),
        .EN_AES(en_aes),
        .KDRDY_AES(kdrdy_aes),
        .KIN_AES(kin_aes),
        .KVLD_AES(aes_kvld),
        .NRST(NRST),
        .RSTn_AES(rstn_aes),
        .RX_UART(RX_UART),
        .TX_UART(TX_UART),
        .sys_clock(CLK),
        .CLK_int(CLK_int)
    );

    // DRAM CIM-based AES core
    AES_DRAM_Top aes_dram_0(
        .CLK(CLK),
        .RSTn(rstn_aes),
        .EN(en_aes),
        .Din(din_aes),
        .Kin(kin_aes),
        .KDrdy(kdrdy_aes),
        .Dout(aes_dout),
        .Dvld(aes_dvld),
        .Kvld(aes_kvld),
        .BSY(aes_bsy),
        .Trigger(trigger),
        .SW1(SW1), .SW2(SW2), .SW3(SW3), .SW4(SW4),
        .SW5(SW5), .SW6(SW6), .SW7(SW7), .SW8(SW8),
        .SW9(SW9), .SW10(SW10), .SW11(SW11), .SW12(SW12),
        .ROUT_1v8_1(ROUT_1v8_1),   .ROUT_1v8_2(ROUT_1v8_2),
        .ROUT_1v8_3(ROUT_1v8_3),   .ROUT_1v8_4(ROUT_1v8_4),
        .ROUT_1v8_5(ROUT_1v8_5),   .ROUT_1v8_6(ROUT_1v8_6),
        .ROUT_1v8_7(ROUT_1v8_7),   .ROUT_1v8_8(ROUT_1v8_8),
        .ROUT_1v8_9(ROUT_1v8_9),   .ROUT_1v8_10(ROUT_1v8_10),
        .ROUT_1v8_11(ROUT_1v8_11), .ROUT_1v8_12(ROUT_1v8_12),
        .ROUT_1v8_13(ROUT_1v8_13), .ROUT_1v8_14(ROUT_1v8_14),
        .ROUT_1v8_15(ROUT_1v8_15), .ROUT_1v8_16(ROUT_1v8_16),
        .RAD_1v8_1(RAD_1v8_1),   .RAD_1v8_2(RAD_1v8_2),
        .RAD_1v8_3(RAD_1v8_3),   .RAD_1v8_4(RAD_1v8_4),
        .RAD_1v8_5(RAD_1v8_5),   .RAD_1v8_6(RAD_1v8_6),
        .RAD_1v8_7(RAD_1v8_7),   .RAD_1v8_8(RAD_1v8_8),
        .RAD_1v8_9(RAD_1v8_9),   .RAD_1v8_10(RAD_1v8_10),
        .RAD_1v8_11(RAD_1v8_11), .RAD_1v8_12(RAD_1v8_12),
        .RAD_1v8_13(RAD_1v8_13), .RAD_1v8_14(RAD_1v8_14),
        .RAD_1v8_15(RAD_1v8_15), .RAD_1v8_16(RAD_1v8_16),
        .DIN_1v8_1(DIN_1v8_1),   .DIN_1v8_2(DIN_1v8_2),
        .DIN_1v8_3(DIN_1v8_3),   .DIN_1v8_4(DIN_1v8_4),
        .DIN_1v8_5(DIN_1v8_5),   .DIN_1v8_6(DIN_1v8_6),
        .DIN_1v8_7(DIN_1v8_7),   .DIN_1v8_8(DIN_1v8_8),
        .DIN_1v8_9(DIN_1v8_9),   .DIN_1v8_10(DIN_1v8_10),
        .DIN_1v8_11(DIN_1v8_11), .DIN_1v8_12(DIN_1v8_12),
        .DIN_1v8_13(DIN_1v8_13), .DIN_1v8_14(DIN_1v8_14),
        .DIN_1v8_15(DIN_1v8_15), .DIN_1v8_16(DIN_1v8_16),
        .ADDIN_1v8(ADDIN_1v8),
        .ADVLD_1v8(ADVLD_1v8),
        .DVLD_1v8(DVLD_1v8),
        .DMX2_1v8(DMX2_1v8),
        .RDEN_1v8(RDEN_1v8),
        .WRIEN_1v8(WRIEN_1v8),
        .VSAEN_1v8(VSAEN_1v8),
        .REFWWL_1v8(REFWWL_1v8),
        .CLK_chip_1v8(CLK_chip_1v8),
        .CINH_ps_1v8(CINH_ps_1v8),
        .SR_ps_1v8(SR_ps_1v8),
        .CLK_ps_1v8(CLK_ps_1v8),
        .CLRb_spw_1v8(CLRb_spw_1v8),
        .CLK_spw_1v8(CLK_spw_1v8),
        .CLRb_spr_1v8(CLRb_spr_1v8),
        .CLK_spr_1v8(CLK_spr_1v8),
        .LIMSEL0_1v8(LIMSEL0_1v8),
        .LIMSEL1_1v8(LIMSEL1_1v8),
        .LIMIN_1v8_1(LIMIN_1v8_1),   .LIMIN_1v8_2(LIMIN_1v8_2),
        .LIMIN_1v8_3(LIMIN_1v8_3),   .LIMIN_1v8_4(LIMIN_1v8_4),
        .LIMIN_1v8_5(LIMIN_1v8_5),   .LIMIN_1v8_6(LIMIN_1v8_6),
        .LIMIN_1v8_7(LIMIN_1v8_7),   .LIMIN_1v8_8(LIMIN_1v8_8),
        .LIMIN_1v8_9(LIMIN_1v8_9),   .LIMIN_1v8_10(LIMIN_1v8_10),
        .LIMIN_1v8_11(LIMIN_1v8_11), .LIMIN_1v8_12(LIMIN_1v8_12),
        .LIMIN_1v8_13(LIMIN_1v8_13), .LIMIN_1v8_14(LIMIN_1v8_14),
        .LIMIN_1v8_15(LIMIN_1v8_15), .LIMIN_1v8_16(LIMIN_1v8_16)
    );

    assign BSY = trigger;

    // Mirror output clock and reset
    not logic_0(rst_mo, NRST);
    and logic_1(clk_mo, NRST, CLK);

endmodule

