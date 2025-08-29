// Module to program DRAM with key/SBOX data.
// The original implementation relied on a pre-computed
// ROM (wbl_data_rom.vh).  In order to allow different keys
// at run-time, the ROM is replaced with the behavioural
// generator contained in wbl_key_gen.v.  Given the input
// 128-bit key the generator performs the AES-128 key
// expansion and recreates the bit manipulations used by the
// software scripts.  Each wr_done pulse advances to the next
// address.  After 64 words (ADDR=6'b111111) DONE is asserted
// and IO_EN is deasserted.

module DRAM_Key_Sbox_Init (
    input  wire        CLK,
    input  wire        RSTn,
    input  wire        wr_done,
    input  wire        START,
    input  wire [127:0] Kin,
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
    // Dynamic data generator
    // ------------------------------------------------------------------
    // wbl_key_gen calculates the 16 64-bit words for a given
    // address and input key.  The words are latched locally
    // whenever the address advances.

    localparam LAST_ADDR = 6'd63;

    wire [63:0] gen1, gen2, gen3, gen4;
    wire [63:0] gen5, gen6, gen7, gen8;
    wire [63:0] gen9, gen10, gen11, gen12;
    wire [63:0] gen13, gen14, gen15, gen16;

    wire [5:0] gen_addr = (active && wr_done && addr_reg != LAST_ADDR) ?
                          addr_reg + 6'd1 : addr_reg;

    wbl_key_gen GEN (
        .Kin  (Kin),
        .addr (gen_addr),
        .WBL1 (gen1),
        .WBL2 (gen2),
        .WBL3 (gen3),
        .WBL4 (gen4),
        .WBL5 (gen5),
        .WBL6 (gen6),
        .WBL7 (gen7),
        .WBL8 (gen8),
        .WBL9 (gen9),
        .WBL10(gen10),
        .WBL11(gen11),
        .WBL12(gen12),
        .WBL13(gen13),
        .WBL14(gen14),
        .WBL15(gen15),
        .WBL16(gen16)
    );

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
                data1_reg  <= gen1;
                data2_reg  <= gen2;
                data3_reg  <= gen3;
                data4_reg  <= gen4;
                data5_reg  <= gen5;
                data6_reg  <= gen6;
                data7_reg  <= gen7;
                data8_reg  <= gen8;
                data9_reg  <= gen9;
                data10_reg <= gen10;
                data11_reg <= gen11;
                data12_reg <= gen12;
                data13_reg <= gen13;
                data14_reg <= gen14;
                data15_reg <= gen15;
                data16_reg <= gen16;
            end else if (active && wr_done) begin
                if (addr_reg == LAST_ADDR) begin
                    // finished streaming all addresses
                    active <= 1'b0;
                    DONE   <= 1'b1;
                end else begin
                    addr_reg  <= addr_reg + 1'b1;
                    data1_reg  <= gen1;
                    data2_reg  <= gen2;
                    data3_reg  <= gen3;
                    data4_reg  <= gen4;
                    data5_reg  <= gen5;
                    data6_reg  <= gen6;
                    data7_reg  <= gen7;
                    data8_reg  <= gen8;
                    data9_reg  <= gen9;
                    data10_reg <= gen10;
                    data11_reg <= gen11;
                    data12_reg <= gen12;
                    data13_reg <= gen13;
                    data14_reg <= gen14;
                    data15_reg <= gen15;
                    data16_reg <= gen16;
                end
            end
        end
    end

endmodule
