`timescale 1ns/1ps

// Testbench for wbl_key_gen
// Compares dynamically generated WBL words against
// pre-computed values from wbl_data_rom.vh for a
// fixed AES-128 key. The ROM was originally used in
// the design and serves as a golden reference.

module wbl_key_gen_tb;
    // Inputs to the DUT
    reg         CLK;
    reg         RSTn;
    reg         START;
    reg  [127:0] Kin;
    reg  [5:0]   addr;

    // Outputs from the DUT
    wire        DONE;
    wire [63:0] WBL1;
    wire [63:0] WBL2;
    wire [63:0] WBL3;
    wire [63:0] WBL4;
    wire [63:0] WBL5;
    wire [63:0] WBL6;
    wire [63:0] WBL7;
    wire [63:0] WBL8;
    wire [63:0] WBL9;
    wire [63:0] WBL10;
    wire [63:0] WBL11;
    wire [63:0] WBL12;
    wire [63:0] WBL13;
    wire [63:0] WBL14;
    wire [63:0] WBL15;
    wire [63:0] WBL16;

    // Instantiate the unit under test
    wbl_key_gen dut (
        .CLK  (CLK),
        .RSTn (RSTn),
        .START(START),
        .Kin  (Kin),
        .addr (addr),
        .DONE (DONE),
        .WBL1 (WBL1),
        .WBL2 (WBL2),
        .WBL3 (WBL3),
        .WBL4 (WBL4),
        .WBL5 (WBL5),
        .WBL6 (WBL6),
        .WBL7 (WBL7),
        .WBL8 (WBL8),
        .WBL9 (WBL9),
        .WBL10(WBL10),
        .WBL11(WBL11),
        .WBL12(WBL12),
        .WBL13(WBL13),
        .WBL14(WBL14),
        .WBL15(WBL15),
        .WBL16(WBL16)
    );

    // Include the original ROM contents as golden reference
    `include "wbl_data_rom.vh"

    integer errors;
    integer i;

    // clock generation
    initial begin
        CLK = 1'b0;
        forever #5 CLK = ~CLK;
    end

    initial begin
        // Reset and start sequence
        RSTn  = 1'b0;
        START = 1'b0;
        addr  = 6'd0;
        Kin   = 128'h00000000000000000000000000000000; // ROM key
        errors = 0;
        #20 RSTn = 1'b1;
        @(posedge CLK);
        START = 1'b1;
        @(posedge CLK);
        START = 1'b0;
        wait (DONE);

        for (i = 0; i < 64; i = i + 1) begin
            addr = i[5:0];
            #1; // allow combinational logic to settle
            if (WBL1  !== WBL_ROM1[i])  begin $display("Mismatch WBL1  addr %0d", i); errors = errors + 1; end
            if (WBL2  !== WBL_ROM2[i])  begin $display("Mismatch WBL2  addr %0d", i); errors = errors + 1; end
            if (WBL3  !== WBL_ROM3[i])  begin $display("Mismatch WBL3  addr %0d", i); errors = errors + 1; end
            if (WBL4  !== WBL_ROM4[i])  begin $display("Mismatch WBL4  addr %0d", i); errors = errors + 1; end
            if (WBL5  !== WBL_ROM5[i])  begin $display("Mismatch WBL5  addr %0d", i); errors = errors + 1; end
            if (WBL6  !== WBL_ROM6[i])  begin $display("Mismatch WBL6  addr %0d", i); errors = errors + 1; end
            if (WBL7  !== WBL_ROM7[i])  begin $display("Mismatch WBL7  addr %0d", i); errors = errors + 1; end
            if (WBL8  !== WBL_ROM8[i])  begin $display("Mismatch WBL8  addr %0d", i); errors = errors + 1; end
            if (WBL9  !== WBL_ROM9[i])  begin $display("Mismatch WBL9  addr %0d", i); errors = errors + 1; end
            if (WBL10 !== WBL_ROM10[i]) begin $display("Mismatch WBL10 addr %0d", i); errors = errors + 1; end
            if (WBL11 !== WBL_ROM11[i]) begin $display("Mismatch WBL11 addr %0d", i); errors = errors + 1; end
            if (WBL12 !== WBL_ROM12[i]) begin $display("Mismatch WBL12 addr %0d", i); errors = errors + 1; end
            if (WBL13 !== WBL_ROM13[i]) begin $display("Mismatch WBL13 addr %0d", i); errors = errors + 1; end
            if (WBL14 !== WBL_ROM14[i]) begin $display("Mismatch WBL14 addr %0d", i); errors = errors + 1; end
            if (WBL15 !== WBL_ROM15[i]) begin $display("Mismatch WBL15 addr %0d", i); errors = errors + 1; end
            if (WBL16 !== WBL_ROM16[i]) begin $display("Mismatch WBL16 addr %0d", i); errors = errors + 1; end
        end

        if (errors == 0) begin
            $display("wbl_key_gen test PASSED");
        end else begin
            $display("wbl_key_gen test FAILED with %0d errors", errors);
        end
        $finish;
    end

endmodule
