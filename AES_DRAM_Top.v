// Top level wrapper connecting the AES core with the 16-core DRAM
// controller.  External interface follows the naming and timing
// convention described in the specification table and waveform.
module AES_DRAM_Top(
    input  wire         CLK,
    input  wire         RSTn,
    input  wire         CLK_spw_1v8,
    input  wire         CLRb_spw_1v8,
    input  wire         EN,
    input  wire         INIT,
    input  wire [127:0] Kin,
    input  wire [127:0] Din,
    input  wire         Kdrdy,
    // DRAM outputs to FPGA
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
    // DRAM control/data from FPGA
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
    // parallel/serial control signals
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
    output wire         LIMIN_1v8_16,
    output wire [127:0] Dout,
    output wire         Kvld,
    output wire         Dvld,
    output wire         BSY,
    output wire         InitDone,
    output wire         Trigger
);

    // Internal aliases for renamed ports
    wire CLK  = CLK_spw_1v8;
    wire RSTn = CLRb_spw_1v8;

    // DRAM read data bus collected from individual pins
    wire [16:1] DRAM16_data = {ROUT_1v8_16, ROUT_1v8_15, ROUT_1v8_14, ROUT_1v8_13,
                               ROUT_1v8_12, ROUT_1v8_11, ROUT_1v8_10, ROUT_1v8_9,
                               ROUT_1v8_8,  ROUT_1v8_7,  ROUT_1v8_6,  ROUT_1v8_5,
                               ROUT_1v8_4,  ROUT_1v8_3,  ROUT_1v8_2,  ROUT_1v8_1};

    // Wires between AES core and DRAM controller
    wire [7:0]  dram_byte;
    wire        rd_done;
    wire [15:0] lim_in;
    wire [2:0]  demux_add [0:15];
    wire [5:0]  rwl_add   [0:15];

    // Wires from DRAM controller to top-level pins (AES operation)
    wire [16:1] aes_dram_din;
    wire [16:1] aes_dram_rad;
    wire [16:1] aes_dram_lim;
    wire [1:0]  aes_lim_sel;
    wire        aes_add_in_w;
    wire        aes_add_vld_w;
    wire        aes_data_vld_w;
    wire        aes_clk_out_w;
    wire        aes_wri_en_w;
    wire        aes_rd_en_w;
    wire        aes_vsaen_w;
    wire        aes_ref_wwl_w;
    wire        aes_dmx2_w;
    wire [2:0]  aes_pc_data_w;
    wire [1:0]  aes_pc_d_in_w;
    wire [1:0]  aes_pc_r_ad_w;

    // Wires from key/SBOX initialization module
    wire [16:1] init_dram_din;
    wire [16:1] init_dram_rad;
    wire [16:1] init_dram_lim;
    wire [1:0]  init_lim_sel;
    wire        init_add_in_w;
    wire        init_add_vld_w;
    wire        init_data_vld_w;
    wire        init_clk_out_w;
    wire        init_wri_en_w;
    wire        init_rd_en_w;
    wire        init_vsaen_w;
    wire        init_ref_wwl_w;
    wire        init_dmx2_w;
    wire        init_cinh_ps_1v8;
    wire        init_sr_ps_1v8;
    wire        init_clk_ps_1v8;
    wire        init_clrb_spw_1v8;
    wire        init_clk_spw_1v8;
    wire        init_clrb_spr_1v8;
    wire        init_clk_spr_1v8;
    wire        init_done;

    // ------------------------------------------------------------------
    // AES core. The DRAM output byte is broadcast to all 16 RIO inputs.
    // Address and LIM signals produced by the AES core are forwarded to
    // the DRAM controller.
    // ------------------------------------------------------------------
    StdAES_Optimized u_aes (
        .CLK   (CLK),
        .RSTn  (RSTn),
        .EN    (EN && init_done),
        .Din   (Din),
        .Kin   (Kin),
        .KDrdy (Kdrdy),
        .RIO_00(dram_byte), .RIO_01(dram_byte), .RIO_02(dram_byte), .RIO_03(dram_byte),
        .RIO_04(dram_byte), .RIO_05(dram_byte), .RIO_06(dram_byte), .RIO_07(dram_byte),
        .RIO_08(dram_byte), .RIO_09(dram_byte), .RIO_10(dram_byte), .RIO_11(dram_byte),
        .RIO_12(dram_byte), .RIO_13(dram_byte), .RIO_14(dram_byte), .RIO_15(dram_byte),
        .Dout  (Dout),
        .Kvld (Kvld),
        .Dvld (Dvld),
        .BSY  (BSY),
        .DEMUX_ADD_00(demux_add[0]),  .DEMUX_ADD_01(demux_add[1]),
        .DEMUX_ADD_02(demux_add[2]),  .DEMUX_ADD_03(demux_add[3]),
        .DEMUX_ADD_04(demux_add[4]),  .DEMUX_ADD_05(demux_add[5]),
        .DEMUX_ADD_06(demux_add[6]),  .DEMUX_ADD_07(demux_add[7]),
        .DEMUX_ADD_08(demux_add[8]),  .DEMUX_ADD_09(demux_add[9]),
        .DEMUX_ADD_10(demux_add[10]), .DEMUX_ADD_11(demux_add[11]),
        .DEMUX_ADD_12(demux_add[12]), .DEMUX_ADD_13(demux_add[13]),
        .DEMUX_ADD_14(demux_add[14]), .DEMUX_ADD_15(demux_add[15]),
        .RWL_DEC_ADD_00(rwl_add[0]),  .RWL_DEC_ADD_01(rwl_add[1]),
        .RWL_DEC_ADD_02(rwl_add[2]),  .RWL_DEC_ADD_03(rwl_add[3]),
        .RWL_DEC_ADD_04(rwl_add[4]),  .RWL_DEC_ADD_05(rwl_add[5]),
        .RWL_DEC_ADD_06(rwl_add[6]),  .RWL_DEC_ADD_07(rwl_add[7]),
        .RWL_DEC_ADD_08(rwl_add[8]),  .RWL_DEC_ADD_09(rwl_add[9]),
        .RWL_DEC_ADD_10(rwl_add[10]), .RWL_DEC_ADD_11(rwl_add[11]),
        .RWL_DEC_ADD_12(rwl_add[12]), .RWL_DEC_ADD_13(rwl_add[13]),
        .RWL_DEC_ADD_14(rwl_add[14]), .RWL_DEC_ADD_15(rwl_add[15]),
        .IN    (lim_in)
    );

    // ------------------------------------------------------------------
    // DRAM controller. It receives address and LIM signals from the AES
    // core and returns serialized DRAM data which is then used by AES.
    // Unused write channels are tied off.
    // ------------------------------------------------------------------
    DRAM_write_read_16core u_dram (
        .clk          (CLK),
        .rst_n        (RSTn),
        .IO_EN        (EN && init_done),
        .IO_MODEL     (2'b10), // read mode
        .CIM_model    (2'b00),
        .DATA_IN      (lim_in),
        .WBL_DATA_IN1 (64'b0),  .WBL_DATA_IN2 (64'b0),
        .WBL_DATA_IN3 (64'b0),  .WBL_DATA_IN4 (64'b0),
        .WBL_DATA_IN5 (64'b0),  .WBL_DATA_IN6 (64'b0),
        .WBL_DATA_IN7 (64'b0),  .WBL_DATA_IN8 (64'b0),
        .WBL_DATA_IN9 (64'b0),  .WBL_DATA_IN10(64'b0),
        .WBL_DATA_IN11(64'b0),  .WBL_DATA_IN12(64'b0),
        .WBL_DATA_IN13(64'b0),  .WBL_DATA_IN14(64'b0),
        .WBL_DATA_IN15(64'b0),  .WBL_DATA_IN16(64'b0),
        .WWL_ADD      (6'b0),
        .RWL_DEC_ADD1 (rwl_add[0]),  .RWL_DEC_ADD2 (rwl_add[1]),
        .RWL_DEC_ADD3 (rwl_add[2]),  .RWL_DEC_ADD4 (rwl_add[3]),
        .RWL_DEC_ADD5 (rwl_add[4]),  .RWL_DEC_ADD6 (rwl_add[5]),
        .RWL_DEC_ADD7 (rwl_add[6]),  .RWL_DEC_ADD8 (rwl_add[7]),
        .RWL_DEC_ADD9 (rwl_add[8]),  .RWL_DEC_ADD10(rwl_add[9]),
        .RWL_DEC_ADD11(rwl_add[10]), .RWL_DEC_ADD12(rwl_add[11]),
        .RWL_DEC_ADD13(rwl_add[12]), .RWL_DEC_ADD14(rwl_add[13]),
        .RWL_DEC_ADD15(rwl_add[14]), .RWL_DEC_ADD16(rwl_add[15]),
        .DEMUX_ADD1   (demux_add[0][1:0]),  .DEMUX_ADD2   (demux_add[1][1:0]),
        .DEMUX_ADD3   (demux_add[2][1:0]),  .DEMUX_ADD4   (demux_add[3][1:0]),
        .DEMUX_ADD5   (demux_add[4][1:0]),  .DEMUX_ADD6   (demux_add[5][1:0]),
        .DEMUX_ADD7   (demux_add[6][1:0]),  .DEMUX_ADD8   (demux_add[7][1:0]),
        .DEMUX_ADD9   (demux_add[8][1:0]),  .DEMUX_ADD10  (demux_add[9][1:0]),
        .DEMUX_ADD11  (demux_add[10][1:0]), .DEMUX_ADD12  (demux_add[11][1:0]),
        .DEMUX_ADD13  (demux_add[12][1:0]), .DEMUX_ADD14  (demux_add[13][1:0]),
        .DEMUX_ADD15  (demux_add[14][1:0]), .DEMUX_ADD16  (demux_add[15][1:0]),
        .DEMUX_ADD_3  (demux_add[0][2]),
        .DRAM_DATA_OUT(dram_byte),
        .RD_DONE      (rd_done),
        .DRAM16_data  (DRAM16_data),
        .PC_data      (aes_pc_data_w),
        .ADD_IN       (aes_add_in_w),
        .ADD_VALID_IN (aes_add_vld_w),
        .PC_D_IN      (aes_pc_d_in_w),
        .D_IN         (aes_dram_din),
        .DATA_VALID_IN(aes_data_vld_w),
        .clk_out      (aes_clk_out_w),
        .WRI_EN       (aes_wri_en_w),
        .R_AD         (aes_dram_rad),
        .PC_R_AD      (aes_pc_r_ad_w),
        .LIM_IN       (aes_dram_lim),
        .LIM_SEL      (aes_lim_sel),
        .DE_ADD3      (aes_dmx2_w),
        .RD_EN        (aes_rd_en_w),
        .VSAEN        (aes_vsaen_w),
        .REF_WWL      (aes_ref_wwl_w)
    );

    // Initialization module to program DRAM with round keys and SBOX
    DRAM_Key_Sbox_Init u_init (
        .CLK        (CLK),
        .RSTn       (RSTn),
        .START      (INIT),
        .DONE       (init_done),
        .RAD_1v8_1  (init_dram_rad[1]),  .RAD_1v8_2  (init_dram_rad[2]),
        .RAD_1v8_3  (init_dram_rad[3]),  .RAD_1v8_4  (init_dram_rad[4]),
        .RAD_1v8_5  (init_dram_rad[5]),  .RAD_1v8_6  (init_dram_rad[6]),
        .RAD_1v8_7  (init_dram_rad[7]),  .RAD_1v8_8  (init_dram_rad[8]),
        .RAD_1v8_9  (init_dram_rad[9]),  .RAD_1v8_10 (init_dram_rad[10]),
        .RAD_1v8_11 (init_dram_rad[11]), .RAD_1v8_12 (init_dram_rad[12]),
        .RAD_1v8_13 (init_dram_rad[13]), .RAD_1v8_14 (init_dram_rad[14]),
        .RAD_1v8_15 (init_dram_rad[15]), .RAD_1v8_16 (init_dram_rad[16]),
        .DIN_1v8_1  (init_dram_din[1]),  .DIN_1v8_2  (init_dram_din[2]),
        .DIN_1v8_3  (init_dram_din[3]),  .DIN_1v8_4  (init_dram_din[4]),
        .DIN_1v8_5  (init_dram_din[5]),  .DIN_1v8_6  (init_dram_din[6]),
        .DIN_1v8_7  (init_dram_din[7]),  .DIN_1v8_8  (init_dram_din[8]),
        .DIN_1v8_9  (init_dram_din[9]),  .DIN_1v8_10 (init_dram_din[10]),
        .DIN_1v8_11 (init_dram_din[11]), .DIN_1v8_12 (init_dram_din[12]),
        .DIN_1v8_13 (init_dram_din[13]), .DIN_1v8_14 (init_dram_din[14]),
        .DIN_1v8_15 (init_dram_din[15]), .DIN_1v8_16 (init_dram_din[16]),
        .ADDIN_1v8  (init_add_in_w),
        .ADVLD_1v8  (init_add_vld_w),
        .DVLD_1v8   (init_data_vld_w),
        .DMX2_1v8   (init_dmx2_w),
        .RDEN_1v8   (init_rd_en_w),
        .WRIEN_1v8  (init_wri_en_w),
        .VSAEN_1v8  (init_vsaen_w),
        .REFWWL_1v8 (init_ref_wwl_w),
        .CLK_chip_1v8(init_clk_out_w),
        .CINH_ps_1v8(init_cinh_ps_1v8),
        .SR_ps_1v8  (init_sr_ps_1v8),
        .CLK_ps_1v8 (init_clk_ps_1v8),
        .CLRb_spw_1v8(init_clrb_spw_1v8),
        .CLK_spw_1v8(init_clk_spw_1v8),
        .CLRb_spr_1v8(init_clrb_spr_1v8),
        .CLK_spr_1v8(init_clk_spr_1v8),
        .LIMSEL0_1v8(init_lim_sel[0]),
        .LIMSEL1_1v8(init_lim_sel[1]),
        .LIMIN_1v8_1 (init_dram_lim[1]),  .LIMIN_1v8_2 (init_dram_lim[2]),
        .LIMIN_1v8_3 (init_dram_lim[3]),  .LIMIN_1v8_4 (init_dram_lim[4]),
        .LIMIN_1v8_5 (init_dram_lim[5]),  .LIMIN_1v8_6 (init_dram_lim[6]),
        .LIMIN_1v8_7 (init_dram_lim[7]),  .LIMIN_1v8_8 (init_dram_lim[8]),
        .LIMIN_1v8_9 (init_dram_lim[9]),  .LIMIN_1v8_10(init_dram_lim[10]),
        .LIMIN_1v8_11(init_dram_lim[11]), .LIMIN_1v8_12(init_dram_lim[12]),
        .LIMIN_1v8_13(init_dram_lim[13]), .LIMIN_1v8_14(init_dram_lim[14]),
        .LIMIN_1v8_15(init_dram_lim[15]), .LIMIN_1v8_16(init_dram_lim[16])
    );

    // Select between initialization and normal AES operation
    wire init_active = ~init_done;
    assign ADDIN_1v8   = init_active ? init_add_in_w   : aes_add_in_w;
    assign ADVLD_1v8   = init_active ? init_add_vld_w  : aes_add_vld_w;
    assign DVLD_1v8    = init_active ? init_data_vld_w : aes_data_vld_w;
    assign CLK_chip_1v8 = init_active ? init_clk_out_w : aes_clk_out_w;
    assign WRIEN_1v8   = init_active ? init_wri_en_w   : aes_wri_en_w;
    assign RDEN_1v8    = init_active ? init_rd_en_w    : aes_rd_en_w;
    assign VSAEN_1v8   = init_active ? init_vsaen_w   : aes_vsaen_w;
    assign REFWWL_1v8  = init_active ? init_ref_wwl_w : aes_ref_wwl_w;
    assign DMX2_1v8    = init_active ? init_dmx2_w    : aes_dmx2_w;
    assign LIMSEL0_1v8 = init_active ? init_lim_sel[0]: aes_lim_sel[0];
    assign LIMSEL1_1v8 = init_active ? init_lim_sel[1]: aes_lim_sel[1];

    assign {CINH_ps_1v8, SR_ps_1v8, CLK_ps_1v8} =
           init_active ? {init_cinh_ps_1v8, init_sr_ps_1v8, init_clk_ps_1v8}
                        : aes_pc_data_w;
    assign {CLRb_spw_1v8, CLK_spw_1v8} =
           init_active ? {init_clrb_spw_1v8, init_clk_spw_1v8}
                        : aes_pc_d_in_w;
    assign {CLRb_spr_1v8, CLK_spr_1v8} =
           init_active ? {init_clrb_spr_1v8, init_clk_spr_1v8}
                        : aes_pc_r_ad_w;

    assign {RAD_1v8_16, RAD_1v8_15, RAD_1v8_14, RAD_1v8_13,
            RAD_1v8_12, RAD_1v8_11, RAD_1v8_10, RAD_1v8_9,
            RAD_1v8_8,  RAD_1v8_7,  RAD_1v8_6,  RAD_1v8_5,
            RAD_1v8_4,  RAD_1v8_3,  RAD_1v8_2,  RAD_1v8_1} =
           init_active ? init_dram_rad : aes_dram_rad;
    assign {DIN_1v8_16, DIN_1v8_15, DIN_1v8_14, DIN_1v8_13,
            DIN_1v8_12, DIN_1v8_11, DIN_1v8_10, DIN_1v8_9,
            DIN_1v8_8,  DIN_1v8_7,  DIN_1v8_6,  DIN_1v8_5,
            DIN_1v8_4,  DIN_1v8_3,  DIN_1v8_2,  DIN_1v8_1} =
           init_active ? init_dram_din : aes_dram_din;
    assign {LIMIN_1v8_16, LIMIN_1v8_15, LIMIN_1v8_14, LIMIN_1v8_13,
            LIMIN_1v8_12, LIMIN_1v8_11, LIMIN_1v8_10, LIMIN_1v8_9,
            LIMIN_1v8_8,  LIMIN_1v8_7,  LIMIN_1v8_6,  LIMIN_1v8_5,
            LIMIN_1v8_4,  LIMIN_1v8_3,  LIMIN_1v8_2,  LIMIN_1v8_1} =
           init_active ? init_dram_lim : aes_dram_lim;

    // output signals following the required interface naming

    assign InitDone = init_done;
    assign Trigger  = EN && init_done;

endmodule

