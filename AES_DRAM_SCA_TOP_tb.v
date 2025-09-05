`timescale 1ns/1ps

// Basic testbench for AES_DRAM_SCA_TOP
// Generates differential clock and reset, drives UART inputs
// with a simple frame containing a known AES key and plaintext.
// DRAM return lines are tied low as no DRAM model is provided.

module AES_DRAM_SCA_TOP_tb;
    // differential clock
    reg CLK_p;
    reg CLK_n;

    // UART and control
    reg NRST;
    reg RX_UART;
    wire TX_UART;
    wire BSY;
    wire clk_mo;
    wire rst_mo;

    // switch inputs
    reg SW1, SW2, SW3, SW4, SW5, SW6, SW7, SW8, SW9, SW10, SW11, SW12;

    // DRAM data returning to FPGA
    reg ROUT_1v8_1, ROUT_1v8_2, ROUT_1v8_3, ROUT_1v8_4;
    reg ROUT_1v8_5, ROUT_1v8_6, ROUT_1v8_7, ROUT_1v8_8;
    reg ROUT_1v8_9, ROUT_1v8_10, ROUT_1v8_11, ROUT_1v8_12;
    reg ROUT_1v8_13, ROUT_1v8_14, ROUT_1v8_15, ROUT_1v8_16;

    // outputs from DUT
    wire RAD_1v8_1, RAD_1v8_2, RAD_1v8_3, RAD_1v8_4;
    wire RAD_1v8_5, RAD_1v8_6, RAD_1v8_7, RAD_1v8_8;
    wire RAD_1v8_9, RAD_1v8_10, RAD_1v8_11, RAD_1v8_12;
    wire RAD_1v8_13, RAD_1v8_14, RAD_1v8_15, RAD_1v8_16;

    wire DIN_1v8_1, DIN_1v8_2, DIN_1v8_3, DIN_1v8_4;
    wire DIN_1v8_5, DIN_1v8_6, DIN_1v8_7, DIN_1v8_8;
    wire DIN_1v8_9, DIN_1v8_10, DIN_1v8_11, DIN_1v8_12;
    wire DIN_1v8_13, DIN_1v8_14, DIN_1v8_15, DIN_1v8_16;

    wire ADDIN_1v8, ADVLD_1v8, DVLD_1v8, DMX2_1v8;
    wire RDEN_1v8, WRIEN_1v8, VSAEN_1v8, REFWWL_1v8;
    wire CLK_chip_1v8, CINH_ps_1v8, SR_ps_1v8, CLK_ps_1v8;
    wire CLRb_spw_1v8, CLK_spw_1v8, CLRb_spr_1v8, CLK_spr_1v8;
    wire LIMSEL0_1v8, LIMSEL1_1v8;
    wire LIMIN_1v8_1, LIMIN_1v8_2, LIMIN_1v8_3, LIMIN_1v8_4;
    wire LIMIN_1v8_5, LIMIN_1v8_6, LIMIN_1v8_7, LIMIN_1v8_8;
    wire LIMIN_1v8_9, LIMIN_1v8_10, LIMIN_1v8_11, LIMIN_1v8_12;
    wire LIMIN_1v8_13, LIMIN_1v8_14, LIMIN_1v8_15, LIMIN_1v8_16;

    // instantiate design under test
    AES_DRAM_SCA_TOP dut (
        .CLK_p(CLK_p), .CLK_n(CLK_n),
        .NRST(NRST), .RX_UART(RX_UART),
        .TX_UART(TX_UART), .BSY(BSY),
        .clk_mo(clk_mo), .rst_mo(rst_mo),
        .SW1(SW1), .SW2(SW2), .SW3(SW3), .SW4(SW4),
        .SW5(SW5), .SW6(SW6), .SW7(SW7), .SW8(SW8),
        .SW9(SW9), .SW10(SW10), .SW11(SW11), .SW12(SW12),
        .ROUT_1v8_1(ROUT_1v8_1), .ROUT_1v8_2(ROUT_1v8_2),
        .ROUT_1v8_3(ROUT_1v8_3), .ROUT_1v8_4(ROUT_1v8_4),
        .ROUT_1v8_5(ROUT_1v8_5), .ROUT_1v8_6(ROUT_1v8_6),
        .ROUT_1v8_7(ROUT_1v8_7), .ROUT_1v8_8(ROUT_1v8_8),
        .ROUT_1v8_9(ROUT_1v8_9), .ROUT_1v8_10(ROUT_1v8_10),
        .ROUT_1v8_11(ROUT_1v8_11), .ROUT_1v8_12(ROUT_1v8_12),
        .ROUT_1v8_13(ROUT_1v8_13), .ROUT_1v8_14(ROUT_1v8_14),
        .ROUT_1v8_15(ROUT_1v8_15), .ROUT_1v8_16(ROUT_1v8_16),
        .RAD_1v8_1(RAD_1v8_1), .RAD_1v8_2(RAD_1v8_2),
        .RAD_1v8_3(RAD_1v8_3), .RAD_1v8_4(RAD_1v8_4),
        .RAD_1v8_5(RAD_1v8_5), .RAD_1v8_6(RAD_1v8_6),
        .RAD_1v8_7(RAD_1v8_7), .RAD_1v8_8(RAD_1v8_8),
        .RAD_1v8_9(RAD_1v8_9), .RAD_1v8_10(RAD_1v8_10),
        .RAD_1v8_11(RAD_1v8_11), .RAD_1v8_12(RAD_1v8_12),
        .RAD_1v8_13(RAD_1v8_13), .RAD_1v8_14(RAD_1v8_14),
        .RAD_1v8_15(RAD_1v8_15), .RAD_1v8_16(RAD_1v8_16),
        .DIN_1v8_1(DIN_1v8_1), .DIN_1v8_2(DIN_1v8_2),
        .DIN_1v8_3(DIN_1v8_3), .DIN_1v8_4(DIN_1v8_4),
        .DIN_1v8_5(DIN_1v8_5), .DIN_1v8_6(DIN_1v8_6),
        .DIN_1v8_7(DIN_1v8_7), .DIN_1v8_8(DIN_1v8_8),
        .DIN_1v8_9(DIN_1v8_9), .DIN_1v8_10(DIN_1v8_10),
        .DIN_1v8_11(DIN_1v8_11), .DIN_1v8_12(DIN_1v8_12),
        .DIN_1v8_13(DIN_1v8_13), .DIN_1v8_14(DIN_1v8_14),
        .DIN_1v8_15(DIN_1v8_15), .DIN_1v8_16(DIN_1v8_16),
        .ADDIN_1v8(ADDIN_1v8), .ADVLD_1v8(ADVLD_1v8),
        .DVLD_1v8(DVLD_1v8), .DMX2_1v8(DMX2_1v8),
        .RDEN_1v8(RDEN_1v8), .WRIEN_1v8(WRIEN_1v8),
        .VSAEN_1v8(VSAEN_1v8), .REFWWL_1v8(REFWWL_1v8),
        .CLK_chip_1v8(CLK_chip_1v8), .CINH_ps_1v8(CINH_ps_1v8),
        .SR_ps_1v8(SR_ps_1v8), .CLK_ps_1v8(CLK_ps_1v8),
        .CLRb_spw_1v8(CLRb_spw_1v8), .CLK_spw_1v8(CLK_spw_1v8),
        .CLRb_spr_1v8(CLRb_spr_1v8), .CLK_spr_1v8(CLK_spr_1v8),
        .LIMSEL0_1v8(LIMSEL0_1v8), .LIMSEL1_1v8(LIMSEL1_1v8),
        .LIMIN_1v8_1(LIMIN_1v8_1), .LIMIN_1v8_2(LIMIN_1v8_2),
        .LIMIN_1v8_3(LIMIN_1v8_3), .LIMIN_1v8_4(LIMIN_1v8_4),
        .LIMIN_1v8_5(LIMIN_1v8_5), .LIMIN_1v8_6(LIMIN_1v8_6),
        .LIMIN_1v8_7(LIMIN_1v8_7), .LIMIN_1v8_8(LIMIN_1v8_8),
        .LIMIN_1v8_9(LIMIN_1v8_9), .LIMIN_1v8_10(LIMIN_1v8_10),
        .LIMIN_1v8_11(LIMIN_1v8_11), .LIMIN_1v8_12(LIMIN_1v8_12),
        .LIMIN_1v8_13(LIMIN_1v8_13), .LIMIN_1v8_14(LIMIN_1v8_14),
        .LIMIN_1v8_15(LIMIN_1v8_15), .LIMIN_1v8_16(LIMIN_1v8_16)
    );

    // clock generation
    initial begin
        CLK_p = 0;
        forever #5 CLK_p = ~CLK_p; // 100 MHz clock
    end
    always @* CLK_n = ~CLK_p;

    // simple UART transmitter task (LSB first)
    localparam integer BIT_PERIOD = 10416; // cycles of 100 MHz clock
    task send_byte(input [7:0] data);
        integer i;
        begin
            RX_UART = 0;
            repeat(BIT_PERIOD) @(posedge CLK_p);
            for (i = 0; i < 8; i = i + 1) begin
                RX_UART = data[i];
                repeat(BIT_PERIOD) @(posedge CLK_p);
            end
            RX_UART = 1;
            repeat(BIT_PERIOD) @(posedge CLK_p);
        end
    endtask

    // stimulus
    initial begin
        NRST = 0;
        RX_UART = 1;
        {SW1,SW2,SW3,SW4,SW5,SW6,SW7,SW8,SW9,SW10,SW11,SW12} = 12'b0;
        {ROUT_1v8_1,ROUT_1v8_2,ROUT_1v8_3,ROUT_1v8_4,
         ROUT_1v8_5,ROUT_1v8_6,ROUT_1v8_7,ROUT_1v8_8,
         ROUT_1v8_9,ROUT_1v8_10,ROUT_1v8_11,ROUT_1v8_12,
         ROUT_1v8_13,ROUT_1v8_14,ROUT_1v8_15,ROUT_1v8_16} = 16'b0;

        // release reset after some cycles
        repeat(20) @(posedge CLK_p);
        NRST = 1;

        // send header, key and plaintext over UART
        send_byte(8'h01); // header
        send_byte(8'h00); send_byte(8'h11); send_byte(8'h22); send_byte(8'h33);
        send_byte(8'h44); send_byte(8'h55); send_byte(8'h66); send_byte(8'h77);
        send_byte(8'h88); send_byte(8'h99); send_byte(8'haA); send_byte(8'hbB);
        send_byte(8'hcC); send_byte(8'hdD); send_byte(8'heE); send_byte(8'hfF);
        send_byte(8'h00); send_byte(8'h01); send_byte(8'h02); send_byte(8'h03);
        send_byte(8'h04); send_byte(8'h05); send_byte(8'h06); send_byte(8'h07);
        send_byte(8'h08); send_byte(8'h09); send_byte(8'h0A); send_byte(8'h0B);
        send_byte(8'h0C); send_byte(8'h0D); send_byte(8'h0E); send_byte(8'h0F);

        // wait for some time to allow processing
        repeat(500000) @(posedge CLK_p);
        $finish;
    end
endmodule

// ---------------------------------------------------------------------------
// Simple stubs for vendor specific primitives used in AES_DRAM_SCA_TOP.
// ---------------------------------------------------------------------------
module clk_wiz_400m(
    output clk_400m,
    output clk_100m,
    output clk_200m,
    output clk_vsa,
    input  clk_in1
);
    assign clk_400m = clk_in1;
    assign clk_100m = clk_in1;
    assign clk_200m = clk_in1;
    assign clk_vsa  = clk_in1;
endmodule

module IBUFDS #(
    parameter DIFF_TERM   = "FALSE",
    parameter IBUF_LOW_PWR = "TRUE",
    parameter IOSTANDARD  = "DEFAULT"
)(
    output O,
    input  I,
    input  IB
);
    assign O = I; // ignore differential behaviour for simulation
endmodule
