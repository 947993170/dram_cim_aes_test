// Module to program DRAM with AES round keys and SBOX contents using the
// existing 16-core DRAM controller in write mode.  A simple state machine
// walks through ROM tables of pre-computed round keys and the AES SBOX and
// streams them into the DRAM interface.

module DRAM_Key_Sbox_Init (
    input  wire        CLK,
    input  wire        RSTn,
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

    reg [1:0]  state, state_next;
    reg [7:0]  index, index_next;
    reg [5:0]  addr, addr_next;
    reg        io_en, io_en_next;
    reg        done_next;

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

    // ------------------------------------------------------------------
    // Moore state machine written in three-segment style
    // ------------------------------------------------------------------

    // state register
    always @(posedge CLK or negedge RSTn) begin
        if (!RSTn)
            state <= IDLE;
        else
            state <= state_next;
    end

    // next state logic
    always @(*) begin
        case (state)
            IDLE:       state_next = START ? WRITE_KEYS : IDLE;
            WRITE_KEYS: state_next = (index == 8'd21) ? WRITE_SBOX : WRITE_KEYS;
            WRITE_SBOX: state_next = (index == 8'd31) ? FINISHED   : WRITE_SBOX;
            FINISHED:   state_next = FINISHED;
            default:    state_next = IDLE;
        endcase
    end

    // index register
    always @(posedge CLK or negedge RSTn) begin
        if (!RSTn)
            index <= 8'd0;
        else
            index <= index_next;
    end

    // next index logic
    always @(*) begin
        case (state)
            IDLE:       index_next = 8'd0;
            WRITE_KEYS: index_next = (index == 8'd21) ? 8'd0      : index + 1'b1;
            WRITE_SBOX: index_next = (index == 8'd31) ? index     : index + 1'b1;
            default:    index_next = index;
        endcase
    end

    // address register
    always @(posedge CLK or negedge RSTn) begin
        if (!RSTn)
            addr <= 6'd0;
        else
            addr <= addr_next;
    end

    // next address logic
    always @(*) begin
        case (state)
            IDLE:       addr_next = 6'd0;
            WRITE_KEYS: addr_next = addr + 1'b1;
            WRITE_SBOX: addr_next = (index == 8'd31) ? addr : addr + 1'b1;
            default:    addr_next = addr;
        endcase
    end

    // IO_EN register
    always @(posedge CLK or negedge RSTn) begin
        if (!RSTn)
            io_en <= 1'b0;
        else
            io_en <= io_en_next;
    end

    // IO_EN next logic
    always @(*) begin
        case (state)
            WRITE_KEYS,
            WRITE_SBOX: io_en_next = 1'b1;
            default:    io_en_next = 1'b0;
        endcase
    end

    // DONE register
    always @(posedge CLK or negedge RSTn) begin
        if (!RSTn)
            DONE <= 1'b0;
        else
            DONE <= done_next;
    end

    // DONE next logic
    always @(*) begin
        case (state)
            FINISHED: done_next = 1'b1;
            default:  done_next = 1'b0;
        endcase
    end

    // ------------------------------------------------------------------
    // Drive outputs toward the external DRAM controller
    // ------------------------------------------------------------------
    assign IO_EN = io_en;
    assign ADDR  = addr;

    assign WBL_DATA1  = wbl_data[0];
    assign WBL_DATA2  = wbl_data[1];
    assign WBL_DATA3  = wbl_data[2];
    assign WBL_DATA4  = wbl_data[3];
    assign WBL_DATA5  = wbl_data[4];
    assign WBL_DATA6  = wbl_data[5];
    assign WBL_DATA7  = wbl_data[6];
    assign WBL_DATA8  = wbl_data[7];
    assign WBL_DATA9  = wbl_data[8];
    assign WBL_DATA10 = wbl_data[9];
    assign WBL_DATA11 = wbl_data[10];
    assign WBL_DATA12 = wbl_data[11];
    assign WBL_DATA13 = wbl_data[12];
    assign WBL_DATA14 = wbl_data[13];
    assign WBL_DATA15 = wbl_data[14];
    assign WBL_DATA16 = wbl_data[15];

endmodule

