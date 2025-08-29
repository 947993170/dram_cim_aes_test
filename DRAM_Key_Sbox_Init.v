`include "wbl_data_rom.vh"

// Module to program DRAM with precomputed key/SBOX data.
// WBL_DATA1..WBL_DATA16 stream 64-bit words derived from
// sbox_final_continuous_even_col*.txt and
// sbox_final_continuous_odd_col*.txt files. Each wr_done
// pulse advances to the next word. After 64 words
// (ADDR=6'b111111) DONE is asserted and IO_EN is deasserted.

module DRAM_Key_Sbox_Init (
    input  wire        CLK,
    input  wire        RSTn,
    input  wire        wr_done,
    input  wire        START,
    output reg         DONE,
    // signals driving the external DRAM controller
    output wire        IO_EN,
    output wire [5:0]  ADDR,
    output wire [63:0] WBL_DATA1,
    output wire [63:0] WBL_DATA2,
    output wire [63:0] WBL_DATA3,
    output wire [63:0] WBL_DATA4,
    output wire [63:0] WBL_DATA5,
    output wire [63:0] WBL_DATA6,
    output wire [63:0] WBL_DATA7,
    output wire [63:0] WBL_DATA8,
    output wire [63:0] WBL_DATA9,
    output wire [63:0] WBL_DATA10,
    output wire [63:0] WBL_DATA11,
    output wire [63:0] WBL_DATA12,
    output wire [63:0] WBL_DATA13,
    output wire [63:0] WBL_DATA14,
    output wire [63:0] WBL_DATA15,
    output wire [63:0] WBL_DATA16
);

    // ------------------------------------------------------------------
    // ROM data generated from sbox_final_continuous_even_col* and
    // sbox_final_continuous_odd_col* files
    // ------------------------------------------------------------------
    // The ROM contents are defined in the included wbl_data_rom.vh file

    localparam LAST_ADDR = 6'd63;

    reg        active;
    reg [5:0]  addr_reg;
    reg [63:0] data1_reg, data2_reg, data3_reg, data4_reg;
    reg [63:0] data5_reg, data6_reg, data7_reg, data8_reg;
    reg [63:0] data9_reg, data10_reg, data11_reg, data12_reg;
    reg [63:0] data13_reg, data14_reg, data15_reg, data16_reg;

    assign IO_EN     = active;
    assign ADDR      = addr_reg;
    assign WBL_DATA1  = data1_reg;
    assign WBL_DATA2  = data2_reg;
    assign WBL_DATA3  = data3_reg;
    assign WBL_DATA4  = data4_reg;
    assign WBL_DATA5  = data5_reg;
    assign WBL_DATA6  = data6_reg;
    assign WBL_DATA7  = data7_reg;
    assign WBL_DATA8  = data8_reg;
    assign WBL_DATA9  = data9_reg;
    assign WBL_DATA10 = data10_reg;
    assign WBL_DATA11 = data11_reg;
    assign WBL_DATA12 = data12_reg;
    assign WBL_DATA13 = data13_reg;
    assign WBL_DATA14 = data14_reg;
    assign WBL_DATA15 = data15_reg;
    assign WBL_DATA16 = data16_reg;

    // ------------------------------------------------------------------
    // Control logic
    // ------------------------------------------------------------------
    always @(posedge CLK or negedge RSTn) begin
        if (!RSTn) begin
            active    <= 1'b0;
            addr_reg  <= 6'd0;
            DONE      <= 1'b0;
            data1_reg <= 64'h0;
            data2_reg <= 64'h0;
            data3_reg <= 64'h0;
            data4_reg <= 64'h0;
            data5_reg  <= 64'h0;
            data6_reg  <= 64'h0;
            data7_reg  <= 64'h0;
            data8_reg  <= 64'h0;
            data9_reg  <= 64'h0;
            data10_reg <= 64'h0;
            data11_reg <= 64'h0;
            data12_reg <= 64'h0;
            data13_reg <= 64'h0;
            data14_reg <= 64'h0;
            data15_reg <= 64'h0;
            data16_reg <= 64'h0;
        end else begin
            if (START && !active) begin
                // start streaming from address 0
                active    <= 1'b1;
                addr_reg  <= 6'd0;
                DONE      <= 1'b0;
                data1_reg  <= WBL_ROM1[0];
                data2_reg  <= WBL_ROM2[0];
                data3_reg  <= WBL_ROM3[0];
                data4_reg  <= WBL_ROM4[0];
                data5_reg  <= WBL_ROM5[0];
                data6_reg  <= WBL_ROM6[0];
                data7_reg  <= WBL_ROM7[0];
                data8_reg  <= WBL_ROM8[0];
                data9_reg  <= WBL_ROM9[0];
                data10_reg <= WBL_ROM10[0];
                data11_reg <= WBL_ROM11[0];
                data12_reg <= WBL_ROM12[0];
                data13_reg <= WBL_ROM13[0];
                data14_reg <= WBL_ROM14[0];
                data15_reg <= WBL_ROM15[0];
                data16_reg <= WBL_ROM16[0];
            end else if (active && wr_done) begin
                if (addr_reg == LAST_ADDR) begin
                    // finished streaming all addresses
                    active <= 1'b0;
                    DONE   <= 1'b1;
                end else begin
                    addr_reg  <= addr_reg + 1'b1;
                    data1_reg  <= WBL_ROM1[addr_reg + 1'b1];
                    data2_reg  <= WBL_ROM2[addr_reg + 1'b1];
                    data3_reg  <= WBL_ROM3[addr_reg + 1'b1];
                    data4_reg  <= WBL_ROM4[addr_reg + 1'b1];
                    data5_reg  <= WBL_ROM5[addr_reg + 1'b1];
                    data6_reg  <= WBL_ROM6[addr_reg + 1'b1];
                    data7_reg  <= WBL_ROM7[addr_reg + 1'b1];
                    data8_reg  <= WBL_ROM8[addr_reg + 1'b1];
                    data9_reg  <= WBL_ROM9[addr_reg + 1'b1];
                    data10_reg <= WBL_ROM10[addr_reg + 1'b1];
                    data11_reg <= WBL_ROM11[addr_reg + 1'b1];
                    data12_reg <= WBL_ROM12[addr_reg + 1'b1];
                    data13_reg <= WBL_ROM13[addr_reg + 1'b1];
                    data14_reg <= WBL_ROM14[addr_reg + 1'b1];
                    data15_reg <= WBL_ROM15[addr_reg + 1'b1];
                    data16_reg <= WBL_ROM16[addr_reg + 1'b1];
                end
            end
        end
    end

endmodule
