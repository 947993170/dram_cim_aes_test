// Top level wrapper connecting the AES core with the 16-core DRAM
// controller.  External interface follows the naming and timing
// convention described in the specification table and waveform.
module AES_DRAM_Top(
//    input  wire         CLK,
    input wire CLK_p,
    input wire CLK_n,
    input  wire         RSTn,
    input  wire         EN,
//    input  wire [127:0] Kin,
//    input  wire [127:0] Din,
    input  wire         KDrdy,
//    output wire [127:0] Dout,
//    output wire         Dvld,
//    output wire         Kvld,
//    output wire         BSY,
//    output reg          Trigger,
    // DRAM outputs to FPGA
    input  wire         SW1,
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
    wire [127:0] Dout;
    wire         Dvld;
    wire         Kvld;
    wire         BSY;
    reg          Trigger;

    wire clk_400m;
    wire clk_100m;
    
    // DRAM read data bus collected from individual pins
    wire [16:1] DRAM16_data = {ROUT_1v8_16, ROUT_1v8_15, ROUT_1v8_14, ROUT_1v8_13,
                               ROUT_1v8_12, ROUT_1v8_11, ROUT_1v8_10, ROUT_1v8_9,
                               ROUT_1v8_8,  ROUT_1v8_7,  ROUT_1v8_6,  ROUT_1v8_5,
                               ROUT_1v8_4,  ROUT_1v8_3,  ROUT_1v8_2,  ROUT_1v8_1};

    // Wires between AES core and DRAM controller
    // Each DRAM_DATA_OUT bus is 8-bits wide and feeds the AES core via RIO_xx
    wire [7:0]  dram_byte1,  dram_byte2,  dram_byte3,  dram_byte4;
    wire [7:0]  dram_byte5,  dram_byte6,  dram_byte7,  dram_byte8;
    wire [7:0]  dram_byte9,  dram_byte10, dram_byte11, dram_byte12;
    wire [7:0]  dram_byte13, dram_byte14, dram_byte15, dram_byte16;

    wire        rd_done;
    wire        wr_done;
    wire [15:0] lim_in;
    wire [2:0]  demux_add [0:15];
    wire [5:0]  rwl_add   [0:15];
    // Wires driving the DRAM controller outputs
    wire [16:1] dram_din_w;
    wire [16:1] dram_rad_w;
    wire [16:1] dram_lim_w;
    wire [1:0]  lim_sel_w;
    wire        add_in_w;
    wire        add_vld_w;
    wire        data_vld_w;
    wire        clk_out_w;
    wire        wri_en_w;
    wire        rd_en_w;
    wire        vsaen_w;
    wire        ref_wwl_w;
    wire        dmx2_w;
    wire [2:0]  pc_data_w;
    wire [1:0]  pc_d_in_w;
    wire [1:0]  pc_r_ad_w;

    // Wires for key/SBOX initialization generator
    wire        init_io_en;
    wire [5:0]  init_addr;
    wire [63:0] init_wbl_data [0:15];
    wire        init_done;

    IBUFDS #(
        .DIFF_TERM ("FALSE"),
        .IBUF_LOW_PWR("TRUE"),
        .IOSTANDARD("DEFAULT")
    ) IBUFDS_inst (
        .O (CLK),
        .I (CLK_p),
        .IB(CLK_n)
    );

    clk_wiz_400m u_clk_wiz_400m(
         .clk_400m(clk_400m),
         .clk_100m(clk_100m),
         .clk(CLK)
    );

    // ------------------------------------------------------------------
    // AES core. The DRAM output byte is broadcast to all 16 RIO inputs.
    // Address and LIM signals produced by the AES core are forwarded to
    // the DRAM controller.
    // ------------------------------------------------------------------
    StdAES_Optimized u_aes (
        .CLK   (clk_100m),
        .RSTn  (RSTn),
        .EN    (EN && init_done),
//        .Din   (Din),
        .Din   (128'h000102030405060708090a0b0c0d0e0f),
        .KDrdy (KDrdy),
        .RIO_00(dram_byte1), .RIO_01(dram_byte2), .RIO_02(dram_byte3), .RIO_03(dram_byte4),
        .RIO_04(dram_byte5), .RIO_05(dram_byte6), .RIO_06(dram_byte7), .RIO_07(dram_byte8),
        .RIO_08(dram_byte9), .RIO_09(dram_byte10), .RIO_10(dram_byte11), .RIO_11(dram_byte12),
        .RIO_12(dram_byte13), .RIO_13(dram_byte14), .RIO_14(dram_byte15), .RIO_15(dram_byte16),
        .Dout  (Dout),
        .Kvld (Kvld),
        .Dvld (Dvld),
        .BSY  (BSY),
        .RD_DONE (rd_done),
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
        .IN    (lim_in),
        .SEL_AD1 (cim_mode[1]),
        .SEL_AD0 (cim_mode[0])
    );
    // Initialization data generator for round keys and SBOX
    DRAM_Key_Sbox_Init u_init (
        .CLK       (clk_100m),
        .RSTn      (RSTn),
        .wr_done   (wr_done),
        .START     (EN),
//        .Kin       (Kin),
        .Kin       (128'h00112233445566778899aabbccddeeff),
        .DONE      (init_done),
        .IO_EN     (init_io_en),
        .ADDR      (init_addr),
        .WBL_DATA1 (init_wbl_data[0]),  .WBL_DATA2 (init_wbl_data[1]),
        .WBL_DATA3 (init_wbl_data[2]),  .WBL_DATA4 (init_wbl_data[3]),
        .WBL_DATA5 (init_wbl_data[4]),  .WBL_DATA6 (init_wbl_data[5]),
        .WBL_DATA7 (init_wbl_data[6]),  .WBL_DATA8 (init_wbl_data[7]),
        .WBL_DATA9 (init_wbl_data[8]),  .WBL_DATA10(init_wbl_data[9]),
        .WBL_DATA11(init_wbl_data[10]), .WBL_DATA12(init_wbl_data[11]),
        .WBL_DATA13(init_wbl_data[12]), .WBL_DATA14(init_wbl_data[13]),
        .WBL_DATA15(init_wbl_data[14]), .WBL_DATA16(init_wbl_data[15])
    );

    // Select between initialization and normal AES operation
    wire init_active = ~init_done;

    // Mux DRAM controller inputs based on current mode
    wire        io_en_sel       = init_active ? init_io_en        : (EN && init_done);
    wire [1:0]  io_model_sel    = init_active ? 2'b01             : 2'b10;
    wire [16:1] data_in_sel     = init_active ? 16'b0             : lim_in;
    wire [63:0] wbl_data_in1    = init_active ? init_wbl_data[0]  : 64'b0;
    wire [63:0] wbl_data_in2    = init_active ? init_wbl_data[1]  : 64'b0;
    wire [63:0] wbl_data_in3    = init_active ? init_wbl_data[2]  : 64'b0;
    wire [63:0] wbl_data_in4    = init_active ? init_wbl_data[3]  : 64'b0;
    wire [63:0] wbl_data_in5    = init_active ? init_wbl_data[4]  : 64'b0;
    wire [63:0] wbl_data_in6    = init_active ? init_wbl_data[5]  : 64'b0;
    wire [63:0] wbl_data_in7    = init_active ? init_wbl_data[6]  : 64'b0;
    wire [63:0] wbl_data_in8    = init_active ? init_wbl_data[7]  : 64'b0;
    wire [63:0] wbl_data_in9    = init_active ? init_wbl_data[8]  : 64'b0;
    wire [63:0] wbl_data_in10   = init_active ? init_wbl_data[9]  : 64'b0;
    wire [63:0] wbl_data_in11   = init_active ? init_wbl_data[10] : 64'b0;
    wire [63:0] wbl_data_in12   = init_active ? init_wbl_data[11] : 64'b0;
    wire [63:0] wbl_data_in13   = init_active ? init_wbl_data[12] : 64'b0;
    wire [63:0] wbl_data_in14   = init_active ? init_wbl_data[13] : 64'b0;
    wire [63:0] wbl_data_in15   = init_active ? init_wbl_data[14] : 64'b0;
    wire [63:0] wbl_data_in16   = init_active ? init_wbl_data[15] : 64'b0;
    wire [5:0]  wwl_add_sel     = init_active ? init_addr         : 6'b0;
    wire [5:0]  rwl_dec_add1    = init_active ? 6'd0              : rwl_add[0];
    wire [5:0]  rwl_dec_add2    = init_active ? 6'd0              : rwl_add[1];
    wire [5:0]  rwl_dec_add3    = init_active ? 6'd0              : rwl_add[2];
    wire [5:0]  rwl_dec_add4    = init_active ? 6'd0              : rwl_add[3];
    wire [5:0]  rwl_dec_add5    = init_active ? 6'd0              : rwl_add[4];
    wire [5:0]  rwl_dec_add6    = init_active ? 6'd0              : rwl_add[5];
    wire [5:0]  rwl_dec_add7    = init_active ? 6'd0              : rwl_add[6];
    wire [5:0]  rwl_dec_add8    = init_active ? 6'd0              : rwl_add[7];
    wire [5:0]  rwl_dec_add9    = init_active ? 6'd0              : rwl_add[8];
    wire [5:0]  rwl_dec_add10   = init_active ? 6'd0              : rwl_add[9];
    wire [5:0]  rwl_dec_add11   = init_active ? 6'd0              : rwl_add[10];
    wire [5:0]  rwl_dec_add12   = init_active ? 6'd0              : rwl_add[11];
    wire [5:0]  rwl_dec_add13   = init_active ? 6'd0              : rwl_add[12];
    wire [5:0]  rwl_dec_add14   = init_active ? 6'd0              : rwl_add[13];
    wire [5:0]  rwl_dec_add15   = init_active ? 6'd0              : rwl_add[14];
    wire [5:0]  rwl_dec_add16   = init_active ? 6'd0              : rwl_add[15];
    wire [1:0]  demux_add1      = init_active ? 2'd0              : demux_add[0][1:0];
    wire [1:0]  demux_add2      = init_active ? 2'd0              : demux_add[1][1:0];
    wire [1:0]  demux_add3      = init_active ? 2'd0              : demux_add[2][1:0];
    wire [1:0]  demux_add4      = init_active ? 2'd0              : demux_add[3][1:0];
    wire [1:0]  demux_add5      = init_active ? 2'd0              : demux_add[4][1:0];
    wire [1:0]  demux_add6      = init_active ? 2'd0              : demux_add[5][1:0];
    wire [1:0]  demux_add7      = init_active ? 2'd0              : demux_add[6][1:0];
    wire [1:0]  demux_add8      = init_active ? 2'd0              : demux_add[7][1:0];
    wire [1:0]  demux_add9      = init_active ? 2'd0              : demux_add[8][1:0];
    wire [1:0]  demux_add10     = init_active ? 2'd0              : demux_add[9][1:0];
    wire [1:0]  demux_add11     = init_active ? 2'd0              : demux_add[10][1:0];
    wire [1:0]  demux_add12     = init_active ? 2'd0              : demux_add[11][1:0];
    wire [1:0]  demux_add13     = init_active ? 2'd0              : demux_add[12][1:0];
    wire [1:0]  demux_add14     = init_active ? 2'd0              : demux_add[13][1:0];
    wire [1:0]  demux_add15     = init_active ? 2'd0              : demux_add[14][1:0];
    wire [1:0]  demux_add16     = init_active ? 2'd0              : demux_add[15][1:0];
    wire        demux_add_3     = init_active ? 1'b0              : demux_add[0][2];

    wire [1:0] cim_mode;
    // Single DRAM controller used for both initialization and AES operation
    DRAM_write_read_16core u_dram (
        .clk_100m     (clk_100m),
        .clk_400m     (clk_400m),
        .rst_n        (RSTn),
        .IO_EN        (io_en_sel),
        .IO_MODEL     (io_model_sel),
        .CIM_model    (cim_mode),
        .DATA_IN      (data_in_sel),
        .WBL_DATA_IN1 (wbl_data_in1),   .WBL_DATA_IN2 (wbl_data_in2),
        .WBL_DATA_IN3 (wbl_data_in3),   .WBL_DATA_IN4 (wbl_data_in4),
        .WBL_DATA_IN5 (wbl_data_in5),   .WBL_DATA_IN6 (wbl_data_in6),
        .WBL_DATA_IN7 (wbl_data_in7),   .WBL_DATA_IN8 (wbl_data_in8),
        .WBL_DATA_IN9 (wbl_data_in9),   .WBL_DATA_IN10(wbl_data_in10),
        .WBL_DATA_IN11(wbl_data_in11),  .WBL_DATA_IN12(wbl_data_in12),
        .WBL_DATA_IN13(wbl_data_in13),  .WBL_DATA_IN14(wbl_data_in14),
        .WBL_DATA_IN15(wbl_data_in15),  .WBL_DATA_IN16(wbl_data_in16),
        .WWL_ADD      (wwl_add_sel),
        .WT_DONE      (wr_done),
        .RWL_DEC_ADD1 (rwl_dec_add1),   .RWL_DEC_ADD2 (rwl_dec_add2),
        .RWL_DEC_ADD3 (rwl_dec_add3),   .RWL_DEC_ADD4 (rwl_dec_add4),
        .RWL_DEC_ADD5 (rwl_dec_add5),   .RWL_DEC_ADD6 (rwl_dec_add6),
        .RWL_DEC_ADD7 (rwl_dec_add7),   .RWL_DEC_ADD8 (rwl_dec_add8),
        .RWL_DEC_ADD9 (rwl_dec_add9),   .RWL_DEC_ADD10(rwl_dec_add10),
        .RWL_DEC_ADD11(rwl_dec_add11),  .RWL_DEC_ADD12(rwl_dec_add12),
        .RWL_DEC_ADD13(rwl_dec_add13),  .RWL_DEC_ADD14(rwl_dec_add14),
        .RWL_DEC_ADD15(rwl_dec_add15),  .RWL_DEC_ADD16(rwl_dec_add16),
        .DEMUX_ADD1   (demux_add1),     .DEMUX_ADD2   (demux_add2),
        .DEMUX_ADD3   (demux_add3),     .DEMUX_ADD4   (demux_add4),
        .DEMUX_ADD5   (demux_add5),     .DEMUX_ADD6   (demux_add6),
        .DEMUX_ADD7   (demux_add7),     .DEMUX_ADD8   (demux_add8),
        .DEMUX_ADD9   (demux_add9),     .DEMUX_ADD10  (demux_add10),
        .DEMUX_ADD11  (demux_add11),    .DEMUX_ADD12  (demux_add12),
        .DEMUX_ADD13  (demux_add13),    .DEMUX_ADD14  (demux_add14),
        .DEMUX_ADD15  (demux_add15),    .DEMUX_ADD16  (demux_add16),
        .DEMUX_ADD_3  (demux_add_3),
        .DRAM_DATA_OUT1(dram_byte1),  .DRAM_DATA_OUT2(dram_byte2),
        .DRAM_DATA_OUT3(dram_byte3),  .DRAM_DATA_OUT4(dram_byte4),
        .DRAM_DATA_OUT5(dram_byte5),  .DRAM_DATA_OUT6(dram_byte6),
        .DRAM_DATA_OUT7(dram_byte7),  .DRAM_DATA_OUT8(dram_byte8),
        .DRAM_DATA_OUT9(dram_byte9),  .DRAM_DATA_OUT10(dram_byte10),
        .DRAM_DATA_OUT11(dram_byte11), .DRAM_DATA_OUT12(dram_byte12),
        .DRAM_DATA_OUT13(dram_byte13), .DRAM_DATA_OUT14(dram_byte14),
        .DRAM_DATA_OUT15(dram_byte15), .DRAM_DATA_OUT16(dram_byte16),
        .RD_DONE      (rd_done),
        .DRAM16_data  (DRAM16_data),
        .PC_data      (pc_data_w),
        .ADD_IN       (add_in_w),
        .ADD_VALID_IN (add_vld_w),
        .PC_D_IN      (pc_d_in_w),
        .D_IN         (dram_din_w),
        .DATA_VALID_IN(data_vld_w),
        .clk_out      (clk_out_w),
        .WRI_EN       (wri_en_w),
        .R_AD         (dram_rad_w),
        .PC_R_AD      (pc_r_ad_w),
        .LIM_IN       (dram_lim_w),
        .LIM_SEL      (lim_sel_w),
        .DE_ADD3      (dmx2_w),
        .RD_EN        (rd_en_w),
        .VSAEN        (vsaen_w),
        .REF_WWL      (ref_wwl_w)
    );

    // Drive top-level outputs directly from DRAM controller
    assign ADDIN_1v8   = add_in_w;
    assign ADVLD_1v8   = add_vld_w;
    assign DVLD_1v8    = data_vld_w;
    assign CLK_chip_1v8 = clk_out_w;
    assign WRIEN_1v8   = wri_en_w;
    assign RDEN_1v8    = rd_en_w;
    assign VSAEN_1v8   = vsaen_w;
    assign REFWWL_1v8  = ref_wwl_w;
    assign DMX2_1v8    = dmx2_w;
    assign LIMSEL0_1v8 = lim_sel_w[0];
    assign LIMSEL1_1v8 = lim_sel_w[1];

    assign {CINH_ps_1v8, SR_ps_1v8, CLK_ps_1v8} = pc_data_w;
    assign {CLRb_spw_1v8, CLK_spw_1v8} = pc_d_in_w;
    assign {CLRb_spr_1v8, CLK_spr_1v8} = pc_r_ad_w;

    assign {RAD_1v8_16, RAD_1v8_15, RAD_1v8_14, RAD_1v8_13,
            RAD_1v8_12, RAD_1v8_11, RAD_1v8_10, RAD_1v8_9,
            RAD_1v8_8,  RAD_1v8_7,  RAD_1v8_6,  RAD_1v8_5,
            RAD_1v8_4,  RAD_1v8_3,  RAD_1v8_2,  RAD_1v8_1} = dram_rad_w;
    assign {DIN_1v8_16, DIN_1v8_15, DIN_1v8_14, DIN_1v8_13,
            DIN_1v8_12, DIN_1v8_11, DIN_1v8_10, DIN_1v8_9,
            DIN_1v8_8,  DIN_1v8_7,  DIN_1v8_6,  DIN_1v8_5,
            DIN_1v8_4,  DIN_1v8_3,  DIN_1v8_2,  DIN_1v8_1} = dram_din_w;
    assign {LIMIN_1v8_16, LIMIN_1v8_15, LIMIN_1v8_14, LIMIN_1v8_13,
            LIMIN_1v8_12, LIMIN_1v8_11, LIMIN_1v8_10, LIMIN_1v8_9,
            LIMIN_1v8_8,  LIMIN_1v8_7,  LIMIN_1v8_6,  LIMIN_1v8_5,
            LIMIN_1v8_4,  LIMIN_1v8_3,  LIMIN_1v8_2,  LIMIN_1v8_1} = dram_lim_w;

    always @ (posedge clk_100m) begin
        if (!RSTn) begin
            Trigger <= 1'b0;
        end else if (Dvld) begin
            Trigger <= 1'b1;
        end else begin
            Trigger <= 1'b0;
        end
    end

endmodule
