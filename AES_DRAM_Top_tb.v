`timescale 1ns/1ps

// Simple testbench for AES_DRAM_Top
// Provides clock/reset stimulus and drives the external DRAM
// interface with zeros. This allows basic bring-up of the
// top-level integration without requiring a full DRAM model.
//
// The DRAM array on the board is expected to perform the
// AddRoundKey and Sbox operations while the FPGA logic handles
// MixColumns and ShiftRows.  A behavioural model of the DRAM is
// beyond the scope of this example, but the scaffold below gives
// a starting point for further development.

module AES_DRAM_Top_tb;
    // clock and reset
    reg CLK;
    reg RSTn;

    // top-level inputs
    reg EN;
    reg [127:0] Kin;
    reg [127:0] Din;
    reg KDrdy;

    // DRAM array outputs towards FPGA (currently tied to zero)
    reg ROUT_1v8_1;
    reg ROUT_1v8_2;
    reg ROUT_1v8_3;
    reg ROUT_1v8_4;
    reg ROUT_1v8_5;
    reg ROUT_1v8_6;
    reg ROUT_1v8_7;
    reg ROUT_1v8_8;
    reg ROUT_1v8_9;
    reg ROUT_1v8_10;
    reg ROUT_1v8_11;
    reg ROUT_1v8_12;
    reg ROUT_1v8_13;
    reg ROUT_1v8_14;
    reg ROUT_1v8_15;
    reg ROUT_1v8_16;

    // outputs from DUT
    wire [127:0] Dout;
    wire Kvld;
    wire Dvld;
    wire BSY;
    wire Trigger;

    // instantiate design under test
    AES_DRAM_Top dut (
        .CLK        (CLK),
        .RSTn       (RSTn),
        .EN         (EN),
//        .Kin        (Kin),
//        .Din        (Din),
        .KDrdy      (KDrdy),
//        .Dout       (Dout),
//        .Kvld       (Kvld),
//        .Dvld       (Dvld),
//        .BSY        (BSY),
//        .Trigger    (Trigger),
        .SW4 (1'b0),
        .SW5 (1'b0),
        .SW6 (1'b0),
        .SW7 (1'b0),
        .SW8 (1'b0),
        .SW9 (1'b0),
        .SW10 (1'b0),
        .SW11 (1'b0),
        .SW12 (1'b0),
        .ROUT_1v8_1 (ROUT_1v8_1),
        .ROUT_1v8_2 (ROUT_1v8_2),
        .ROUT_1v8_3 (ROUT_1v8_3),
        .ROUT_1v8_4 (ROUT_1v8_4),
        .ROUT_1v8_5 (ROUT_1v8_5),
        .ROUT_1v8_6 (ROUT_1v8_6),
        .ROUT_1v8_7 (ROUT_1v8_7),
        .ROUT_1v8_8 (ROUT_1v8_8),
        .ROUT_1v8_9 (ROUT_1v8_9),
        .ROUT_1v8_10(ROUT_1v8_10),
        .ROUT_1v8_11(ROUT_1v8_11),
        .ROUT_1v8_12(ROUT_1v8_12),
        .ROUT_1v8_13(ROUT_1v8_13),
        .ROUT_1v8_14(ROUT_1v8_14),
        .ROUT_1v8_15(ROUT_1v8_15),
        .ROUT_1v8_16(ROUT_1v8_16),
        // remaining outputs are left unconnected in this basic test
        .RAD_1v8_1(), .RAD_1v8_2(), .RAD_1v8_3(), .RAD_1v8_4(),
        .RAD_1v8_5(), .RAD_1v8_6(), .RAD_1v8_7(), .RAD_1v8_8(),
        .RAD_1v8_9(), .RAD_1v8_10(), .RAD_1v8_11(), .RAD_1v8_12(),
        .RAD_1v8_13(), .RAD_1v8_14(), .RAD_1v8_15(), .RAD_1v8_16(),
        .DIN_1v8_1(), .DIN_1v8_2(), .DIN_1v8_3(), .DIN_1v8_4(),
        .DIN_1v8_5(), .DIN_1v8_6(), .DIN_1v8_7(), .DIN_1v8_8(),
        .DIN_1v8_9(), .DIN_1v8_10(), .DIN_1v8_11(), .DIN_1v8_12(),
        .DIN_1v8_13(), .DIN_1v8_14(), .DIN_1v8_15(), .DIN_1v8_16(),
        .ADDIN_1v8(), .ADVLD_1v8(), .DVLD_1v8(), .DMX2_1v8(),
        .RDEN_1v8(), .WRIEN_1v8(), .VSAEN_1v8(), .REFWWL_1v8(),
        .CLK_chip_1v8(), .CINH_ps_1v8(), .SR_ps_1v8(), .CLK_ps_1v8(),
        .CLRb_spw_1v8(), .CLK_spw_1v8(), .CLRb_spr_1v8(), .CLK_spr_1v8(),
        .LIMSEL0_1v8(), .LIMSEL1_1v8(),
        .LIMIN_1v8_1(), .LIMIN_1v8_2(), .LIMIN_1v8_3(), .LIMIN_1v8_4(),
        .LIMIN_1v8_5(), .LIMIN_1v8_6(), .LIMIN_1v8_7(), .LIMIN_1v8_8(),
        .LIMIN_1v8_9(), .LIMIN_1v8_10(), .LIMIN_1v8_11(), .LIMIN_1v8_12(),
        .LIMIN_1v8_13(), .LIMIN_1v8_14(), .LIMIN_1v8_15(), .LIMIN_1v8_16()
    );

    // clock generation
    initial CLK = 0;
    always #5 CLK = ~CLK; // 100 MHz clock

    // stimulus
    initial begin
        // initialise inputs
        RSTn   = 0;
        EN     = 0;
        KDrdy  = 0;
        Kin    = 128'h0;
        Din    = 128'h0;
        {ROUT_1v8_1, ROUT_1v8_2, ROUT_1v8_3, ROUT_1v8_4,
         ROUT_1v8_5, ROUT_1v8_6, ROUT_1v8_7, ROUT_1v8_8,
         ROUT_1v8_9, ROUT_1v8_10, ROUT_1v8_11, ROUT_1v8_12,
         ROUT_1v8_13, ROUT_1v8_14, ROUT_1v8_15, ROUT_1v8_16} = 16'b0;

        // apply reset
        #20;
        RSTn = 1;

        // start initialization and encryption sequence
        EN    = 1;
        KDrdy = 1; // indicate key/data ready
        Kin   = 128'h00112233445566778899aabbccddeeff;
        Din   = 128'h000102030405060708090a0b0c0d0e0f;

        // run for a while then finish
        #1000;
        $finish;
    end
endmodule
