// Module to program DRAM with AES round keys and SBOX contents using the
// existing 16-core DRAM controller in write mode.  A simple state machine
// walks through ROM tables of pre-computed round keys and the AES SBOX and
// streams them into the DRAM interface.

module DRAM_Key_Sbox_Init (
    input  wire CLK,
    input  wire RSTn,
    input  wire START,
    output reg  DONE,
    // DRAM control/data outputs (no readback required for programming)
    output wire RAD_1v8_1,
    output wire RAD_1v8_2,
    output wire RAD_1v8_3,
    output wire RAD_1v8_4,
    output wire RAD_1v8_5,
    output wire RAD_1v8_6,
    output wire RAD_1v8_7,
    output wire RAD_1v8_8,
    output wire RAD_1v8_9,
    output wire RAD_1v8_10,
    output wire RAD_1v8_11,
    output wire RAD_1v8_12,
    output wire RAD_1v8_13,
    output wire RAD_1v8_14,
    output wire RAD_1v8_15,
    output wire RAD_1v8_16,
    output wire DIN_1v8_1,
    output wire DIN_1v8_2,
    output wire DIN_1v8_3,
    output wire DIN_1v8_4,
    output wire DIN_1v8_5,
    output wire DIN_1v8_6,
    output wire DIN_1v8_7,
    output wire DIN_1v8_8,
    output wire DIN_1v8_9,
    output wire DIN_1v8_10,
    output wire DIN_1v8_11,
    output wire DIN_1v8_12,
    output wire DIN_1v8_13,
    output wire DIN_1v8_14,
    output wire DIN_1v8_15,
    output wire DIN_1v8_16,
    output wire ADDIN_1v8,
    output wire ADVLD_1v8,
    output wire DVLD_1v8,
    output wire DMX2_1v8,
    output wire RDEN_1v8,
    output wire WRIEN_1v8,
    output wire VSAEN_1v8,
    output wire REFWWL_1v8,
    output wire CLK_chip_1v8,
    // parallel/serial control signals
    output wire CINH_ps_1v8,
    output wire SR_ps_1v8,
    output wire CLK_ps_1v8,
    output wire CLRb_spw_1v8,
    output wire CLK_spw_1v8,
    output wire CLRb_spr_1v8,
    output wire CLK_spr_1v8,
    output wire LIMSEL0_1v8,
    output wire LIMSEL1_1v8,
    output wire LIMIN_1v8_1,
    output wire LIMIN_1v8_2,
    output wire LIMIN_1v8_3,
    output wire LIMIN_1v8_4,
    output wire LIMIN_1v8_5,
    output wire LIMIN_1v8_6,
    output wire LIMIN_1v8_7,
    output wire LIMIN_1v8_8,
    output wire LIMIN_1v8_9,
    output wire LIMIN_1v8_10,
    output wire LIMIN_1v8_11,
    output wire LIMIN_1v8_12,
    output wire LIMIN_1v8_13,
    output wire LIMIN_1v8_14,
    output wire LIMIN_1v8_15,
    output wire LIMIN_1v8_16
);

    // ------------------------------------------------------------------
    // ROM tables: AES-128 round keys for key 0x000102030405060708090a0b0c0d0e0f
    // and the AES substitution box.
    // ------------------------------------------------------------------
    localparam [127:0] ROUND_KEYS [0:10] = '{
        128'h000102030405060708090a0b0c0d0e0f,
        128'hd6aa74fdd2af72fadaa678f1d6ab76fe,
        128'hb692cf0b643dbdf1be9bc5006830b3fe,
        128'hb6ff744ed2c2c9bf6c590cbf0469bf41,
        128'h47f7f7bc95353e03f96c32bcfd058dfd,
        128'h3caaa3e8a99f9deb50f3af57adf622aa,
        128'h5e390f7df7a69296a7553dc10aa31f6b,
        128'h14f9701ae35fe28c440adf4d4ea9c026,
        128'h47438735a41c65b9e016baf4aebf7ad2,
        128'h549932d1f08557681093ed9cbe2c974e,
        128'h13111d7fe3944a17f307a78b4d2b30c5
    };

    localparam [7:0] SBOX [0:255] = '{
        8'h63,8'h7c,8'h77,8'h7b,8'hf2,8'h6b,8'h6f,8'hc5,8'h30,8'h01,8'h67,8'h2b,8'hfe,8'hd7,8'hab,8'h76,
        8'hca,8'h82,8'hc9,8'h7d,8'hfa,8'h59,8'h47,8'hf0,8'had,8'hd4,8'ha2,8'haf,8'h9c,8'ha4,8'h72,8'hc0,
        8'hb7,8'hfd,8'h93,8'h26,8'h36,8'h3f,8'hf7,8'hcc,8'h34,8'ha5,8'he5,8'hf1,8'h71,8'hd8,8'h31,8'h15,
        8'h04,8'hc7,8'h23,8'hc3,8'h18,8'h96,8'h05,8'h9a,8'h07,8'h12,8'h80,8'he2,8'heb,8'h27,8'hb2,8'h75,
        8'h09,8'h83,8'h2c,8'h1a,8'h1b,8'h6e,8'h5a,8'ha0,8'h52,8'h3b,8'hd6,8'hb3,8'h29,8'he3,8'h2f,8'h84,
        8'h53,8'hd1,8'h00,8'hed,8'h20,8'hfc,8'hb1,8'h5b,8'h6a,8'hcb,8'hbe,8'h39,8'h4a,8'h4c,8'h58,8'hcf,
        8'hd0,8'hef,8'haa,8'hfb,8'h43,8'h4d,8'h33,8'h85,8'h45,8'hf9,8'h02,8'h7f,8'h50,8'h3c,8'h9f,8'ha8,
        8'h51,8'ha3,8'h40,8'h8f,8'h92,8'h9d,8'h38,8'hf5,8'hbc,8'hb6,8'hda,8'h21,8'h10,8'hff,8'hf3,8'hd2,
        8'hcd,8'h0c,8'h13,8'hec,8'h5f,8'h97,8'h44,8'h17,8'hc4,8'ha7,8'h7e,8'h3d,8'h64,8'h5d,8'h19,8'h73,
        8'h60,8'h81,8'h4f,8'hdc,8'h22,8'h2a,8'h90,8'h88,8'h46,8'hee,8'hb8,8'h14,8'hde,8'h5e,8'h0b,8'hdb,
        8'he0,8'h32,8'h3a,8'h0a,8'h49,8'h06,8'h24,8'h5c,8'hc2,8'hd3,8'hac,8'h62,8'h91,8'h95,8'he4,8'h79,
        8'he7,8'hc8,8'h37,8'h6d,8'h8d,8'hd5,8'h4e,8'ha9,8'h6c,8'h56,8'hf4,8'hea,8'h65,8'h7a,8'hae,8'h08,
        8'hba,8'h78,8'h25,8'h2e,8'h1c,8'ha6,8'hb4,8'hc6,8'he8,8'hdd,8'h74,8'h1f,8'h4b,8'hbd,8'h8b,8'h8a,
        8'h70,8'h3e,8'hb5,8'h66,8'h48,8'h03,8'hf6,8'h0e,8'h61,8'h35,8'h57,8'hb9,8'h86,8'hc1,8'h1d,8'h9e,
        8'he1,8'hf8,8'h98,8'h11,8'h69,8'hd9,8'h8e,8'h94,8'h9b,8'h1e,8'h87,8'he9,8'hce,8'h55,8'h28,8'hdf,
        8'h8c,8'ha1,8'h89,8'h0d,8'hbf,8'he6,8'h42,8'h68,8'h41,8'h99,8'h2d,8'h0f,8'hb0,8'h54,8'hbb,8'h16
    };

    // ------------------------------------------------------------------
    // State machine to stream data into DRAM controller.
    // ------------------------------------------------------------------
    localparam IDLE       = 2'd0,
               WRITE_KEYS = 2'd1,
               WRITE_SBOX = 2'd2,
               FINISHED   = 2'd3;

    reg [1:0]  state;
    reg [7:0]  index;
    reg [5:0]  addr;
    reg        io_en;

    // current 64-bit word to be written
    reg [63:0] current_word;

    always @(*) begin
        if (state == WRITE_KEYS) begin
            current_word = index[0] ? ROUND_KEYS[index[7:1]][63:0]
                                     : ROUND_KEYS[index[7:1]][127:64];
        end else if (state == WRITE_SBOX) begin
            current_word = {
                SBOX[index*8+0], SBOX[index*8+1], SBOX[index*8+2], SBOX[index*8+3],
                SBOX[index*8+4], SBOX[index*8+5], SBOX[index*8+6], SBOX[index*8+7]
            };
        end else begin
            current_word = 64'h0;
        end
    end

    // replicate 64-bit word to all 16 DRAM chips
    wire [63:0] wbl_data [0:15];
    genvar gi;
    generate
        for (gi=0; gi<16; gi=gi+1) begin : GEN_WBL
            assign wbl_data[gi] = current_word;
        end
    endgenerate

    // FSM sequencing
    always @(posedge CLK or negedge RSTn) begin
        if (!RSTn) begin
            state <= IDLE;
            index <= 8'd0;
            addr  <= 6'd0;
            io_en <= 1'b0;
            DONE  <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    io_en <= 1'b0;
                    DONE  <= 1'b0;
                    if (START) begin
                        state <= WRITE_KEYS;
                        index <= 0;
                        addr  <= 0;
                    end
                end
                WRITE_KEYS: begin
                    io_en <= 1'b1;
                    if (index == 8'd21) begin // 11 keys * 2 words - 1
                        state <= WRITE_SBOX;
                        index <= 0;
                        addr  <= addr + 1'b1;
                    end else begin
                        index <= index + 1'b1;
                        addr  <= addr + 1'b1;
                    end
                end
                WRITE_SBOX: begin
                    io_en <= 1'b1;
                    if (index == 8'd31) begin // 256 bytes /8 -1
                        state <= FINISHED;
                    end else begin
                        index <= index + 1'b1;
                        addr  <= addr + 1'b1;
                    end
                end
                FINISHED: begin
                    io_en <= 1'b0;
                    DONE  <= 1'b1;
                end
            endcase
        end
    end

    // ------------------------------------------------------------------
    // DRAM controller instance in write mode
    // ------------------------------------------------------------------
    wire [16:1] dram_din;
    wire [16:1] dram_rad;
    wire [16:1] dram_lim;
    wire [1:0]  lim_sel;
    wire        add_in_w, add_vld_w, data_vld_w, clk_out_w;
    wire        wri_en_w, rd_en_w, vsaen_w, ref_wwl_w, dmx2_w;
    wire [2:0]  pc_data_w;
    wire [1:0]  pc_d_in_w;
    wire [1:0]  pc_r_ad_w;

    DRAM_write_read_16core u_dram (
        .clk          (CLK),
        .rst_n        (RSTn),
        .IO_EN        (io_en),
        .IO_MODEL     (2'b01), // write mode
        .CIM_model    (2'b00),
        .DATA_IN      (16'b0),
        .WBL_DATA_IN1 (wbl_data[0]),   .WBL_DATA_IN2 (wbl_data[1]),
        .WBL_DATA_IN3 (wbl_data[2]),   .WBL_DATA_IN4 (wbl_data[3]),
        .WBL_DATA_IN5 (wbl_data[4]),   .WBL_DATA_IN6 (wbl_data[5]),
        .WBL_DATA_IN7 (wbl_data[6]),   .WBL_DATA_IN8 (wbl_data[7]),
        .WBL_DATA_IN9 (wbl_data[8]),   .WBL_DATA_IN10(wbl_data[9]),
        .WBL_DATA_IN11(wbl_data[10]),  .WBL_DATA_IN12(wbl_data[11]),
        .WBL_DATA_IN13(wbl_data[12]),  .WBL_DATA_IN14(wbl_data[13]),
        .WBL_DATA_IN15(wbl_data[14]),  .WBL_DATA_IN16(wbl_data[15]),
        .WWL_ADD      (addr),
        .RWL_DEC_ADD1 (6'd0), .RWL_DEC_ADD2 (6'd0),
        .RWL_DEC_ADD3 (6'd0), .RWL_DEC_ADD4 (6'd0),
        .RWL_DEC_ADD5 (6'd0), .RWL_DEC_ADD6 (6'd0),
        .RWL_DEC_ADD7 (6'd0), .RWL_DEC_ADD8 (6'd0),
        .RWL_DEC_ADD9 (6'd0), .RWL_DEC_ADD10(6'd0),
        .RWL_DEC_ADD11(6'd0), .RWL_DEC_ADD12(6'd0),
        .RWL_DEC_ADD13(6'd0), .RWL_DEC_ADD14(6'd0),
        .RWL_DEC_ADD15(6'd0), .RWL_DEC_ADD16(6'd0),
        .DEMUX_ADD1   (2'd0), .DEMUX_ADD2   (2'd0),
        .DEMUX_ADD3   (2'd0), .DEMUX_ADD4   (2'd0),
        .DEMUX_ADD5   (2'd0), .DEMUX_ADD6   (2'd0),
        .DEMUX_ADD7   (2'd0), .DEMUX_ADD8   (2'd0),
        .DEMUX_ADD9   (2'd0), .DEMUX_ADD10  (2'd0),
        .DEMUX_ADD11  (2'd0), .DEMUX_ADD12  (2'd0),
        .DEMUX_ADD13  (2'd0), .DEMUX_ADD14  (2'd0),
        .DEMUX_ADD15  (2'd0), .DEMUX_ADD16  (2'd0),
        .DEMUX_ADD_3  (1'b0),
        .DRAM_DATA_OUT(),
        .RD_DONE      (),
        .DRAM16_data  (16'b0),
        .PC_data      (pc_data_w),
        .ADD_IN       (add_in_w),
        .ADD_VALID_IN (add_vld_w),
        .PC_D_IN      (pc_d_in_w),
        .D_IN         (dram_din),
        .DATA_VALID_IN(data_vld_w),
        .clk_out      (clk_out_w),
        .WRI_EN       (wri_en_w),
        .R_AD         (dram_rad),
        .PC_R_AD      (pc_r_ad_w),
        .LIM_IN       (dram_lim),
        .LIM_SEL      (lim_sel),
        .DE_ADD3      (dmx2_w),
        .RD_EN        (rd_en_w),
        .VSAEN        (vsaen_w),
        .REF_WWL      (ref_wwl_w)
    );

    // ------------------------------------------------------------------
    // Map controller outputs to top-level pins
    // ------------------------------------------------------------------
    assign ADDIN_1v8   = add_in_w;
    assign ADVLD_1v8   = add_vld_w;
    assign DVLD_1v8    = data_vld_w;
    assign CLK_chip_1v8 = clk_out_w;
    assign WRIEN_1v8   = wri_en_w;
    assign RDEN_1v8    = rd_en_w;
    assign VSAEN_1v8   = vsaen_w;
    assign REFWWL_1v8  = ref_wwl_w;
    assign DMX2_1v8    = dmx2_w;
    assign LIMSEL0_1v8 = lim_sel[0];
    assign LIMSEL1_1v8 = lim_sel[1];
    assign {CINH_ps_1v8, SR_ps_1v8, CLK_ps_1v8} = pc_data_w;
    assign {CLRb_spw_1v8, CLK_spw_1v8}          = pc_d_in_w;
    assign {CLRb_spr_1v8, CLK_spr_1v8}          = pc_r_ad_w;

    assign {RAD_1v8_16, RAD_1v8_15, RAD_1v8_14, RAD_1v8_13,
            RAD_1v8_12, RAD_1v8_11, RAD_1v8_10, RAD_1v8_9,
            RAD_1v8_8,  RAD_1v8_7,  RAD_1v8_6,  RAD_1v8_5,
            RAD_1v8_4,  RAD_1v8_3,  RAD_1v8_2,  RAD_1v8_1} = dram_rad;

    assign {DIN_1v8_16, DIN_1v8_15, DIN_1v8_14, DIN_1v8_13,
            DIN_1v8_12, DIN_1v8_11, DIN_1v8_10, DIN_1v8_9,
            DIN_1v8_8,  DIN_1v8_7,  DIN_1v8_6,  DIN_1v8_5,
            DIN_1v8_4,  DIN_1v8_3,  DIN_1v8_2,  DIN_1v8_1} = dram_din;

    assign {LIMIN_1v8_16, LIMIN_1v8_15, LIMIN_1v8_14, LIMIN_1v8_13,
            LIMIN_1v8_12, LIMIN_1v8_11, LIMIN_1v8_10, LIMIN_1v8_9,
            LIMIN_1v8_8,  LIMIN_1v8_7,  LIMIN_1v8_6,  LIMIN_1v8_5,
            LIMIN_1v8_4,  LIMIN_1v8_3,  LIMIN_1v8_2,  LIMIN_1v8_1} = dram_lim;

endmodule

