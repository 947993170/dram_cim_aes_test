//`timescale 1 ns/1 ps
module StdAES_Optimized
(
    // inputs
    input  wire         CLK,
    input  wire         RSTn,
(* mark_debug = "true" *)    input  wire         EN,
    input  wire [127:0] Din,
(* mark_debug = "true" *)    input  wire         KDrdy,

(* mark_debug = "true" *)    input  wire [7:0]   RIO_00,
(* mark_debug = "true" *)    input  wire [7:0]   RIO_01,
(* mark_debug = "true" *)    input  wire [7:0]   RIO_02,
(* mark_debug = "true" *)    input  wire [7:0]   RIO_03,
    input  wire [7:0]   RIO_04,
    input  wire [7:0]   RIO_05,
    input  wire [7:0]   RIO_06,
    input  wire [7:0]   RIO_07,
    input  wire [7:0]   RIO_08,
    input  wire [7:0]   RIO_09,
    input  wire [7:0]   RIO_10,
    input  wire [7:0]   RIO_11,
(* mark_debug = "true" *)    input  wire [7:0]   RIO_12,
(* mark_debug = "true" *)    input  wire [7:0]   RIO_13,
(* mark_debug = "true" *)    input  wire [7:0]   RIO_14,
(* mark_debug = "true" *)    input  wire [7:0]   RIO_15,

    // outputs
    output reg  [127:0] Dout,
    output reg          Kvld,
    output reg          Dvld,
    output reg          BSY,

	output reg IO_EN,
    input wire RD_DONE,
    output wire [2:0]   DEMUX_ADD_00,
    output wire [2:0]   DEMUX_ADD_01,
    output wire [2:0]   DEMUX_ADD_02,
    output wire [2:0]   DEMUX_ADD_03,
    output wire [2:0]   DEMUX_ADD_04,
    output wire [2:0]   DEMUX_ADD_05,
    output wire [2:0]   DEMUX_ADD_06,
    output wire [2:0]   DEMUX_ADD_07,
    output wire [2:0]   DEMUX_ADD_08,
    output wire [2:0]   DEMUX_ADD_09,
    output wire [2:0]   DEMUX_ADD_10,
    output wire [2:0]   DEMUX_ADD_11,
    output wire [2:0]   DEMUX_ADD_12,
    output wire [2:0]   DEMUX_ADD_13,
    output wire [2:0]   DEMUX_ADD_14,
    output wire [2:0]   DEMUX_ADD_15,

    output wire [5:0]   RWL_DEC_ADD_00,
    output wire [5:0]   RWL_DEC_ADD_01,
    output wire [5:0]   RWL_DEC_ADD_02,
    output wire [5:0]   RWL_DEC_ADD_03,
    output wire [5:0]   RWL_DEC_ADD_04,
    output wire [5:0]   RWL_DEC_ADD_05,
    output wire [5:0]   RWL_DEC_ADD_06,
    output wire [5:0]   RWL_DEC_ADD_07,
    output wire [5:0]   RWL_DEC_ADD_08,
    output wire [5:0]   RWL_DEC_ADD_09,
    output wire [5:0]   RWL_DEC_ADD_10,
    output wire [5:0]   RWL_DEC_ADD_11,
    output wire [5:0]   RWL_DEC_ADD_12,
    output wire [5:0]   RWL_DEC_ADD_13,
    output wire [5:0]   RWL_DEC_ADD_14,
    output wire [5:0]   RWL_DEC_ADD_15,

(* mark_debug = "true"*)    output wire [15:0]  IN,
    output wire         SEL_AD1,
(* mark_debug = "true"*)    output wire         SEL_AD0

);

    // -------------------------------------------------
    // internal regs/wires (\u4fdd\u7559\u539f\u6709)
    // -------------------------------------------------
    wire        rst = ~RSTn;

    reg [127:0] dat;
    reg [3:0]   dcnt;
    reg [1:0]   sel;


    // ?? RIO \u89c4\u8303\u6210\u987a\u5e8f\u4fe1\u53f7\uff08\u82e5\u4f60?? RIO_08/09\uff0c\u8bf7\u6620\u5c04\u66ff\u6362?? 8'h00??
    wire [7:0] rio_00 = RIO_00;
    wire [7:0] rio_01 = RIO_01;
    wire [7:0] rio_02 = RIO_02;
    wire [7:0] rio_03 = RIO_03;
    wire [7:0] rio_04 = RIO_04;
    wire [7:0] rio_05 = RIO_05;
    wire [7:0] rio_06 = RIO_06;
    wire [7:0] rio_07 = RIO_07;
    wire [7:0] rio_08 = RIO_08;   // TODO: \u82e5\u5b58?? RIO_08\uff0c\u8bf7\u6539\u4e3a RIO_08
    wire [7:0] rio_09 = RIO_09;   // TODO: \u82e5\u5b58?? RIO_09\uff0c\u8bf7\u6539\u4e3a RIO_09
    wire [7:0] rio_10 = RIO_10;
    wire [7:0] rio_11 = RIO_11;
    wire [7:0] rio_12 = RIO_12;
    wire [7:0] rio_13 = RIO_13;
    wire [7:0] rio_14 = RIO_14;
    wire [7:0] rio_15 = RIO_15;

    // FSM \u53c2\u6570
    localparam         IN_MSB_FIRST = 1'b1;

    // \u72b6???\u7f16??
    localparam [1:0] ST_IDLE   = 2'd0;
    localparam [1:0] ST_READ   = 2'd1;  // 8 cycles
    localparam [1:0] ST_LOOKUP = 2'd2;  // 1 cycle
	localparam [1:0] ST_MIX    = 2'd3;  // 1 cycle
    localparam [1:0] ST_OUT    = 2'd4;  // 1 cycle

    reg [1:0] current_state, next_state;
	reg [1:0] prev_state; // track previous FSM state for pulsed IO_EN

	
    reg [3:0] grp_idx;    // 0..10
    reg [3:0] read_cnt;   // 0..7
	reg [3:0] read_cnt_dff;   // 0..7


    // ark \u5bc4\u5b58\u5668\uff1a8 \u62cd\u91c7?? bit7..0
(* mark_debug = "true" *)   reg [7:0] ark_q_00;
(* mark_debug = "true" *)	reg	[7:0] ark_q_01;
(* mark_debug = "true" *)	reg [7:0] ark_q_02;
(* mark_debug = "true" *)	reg [7:0] ark_q_03;
    reg [7:0] ark_q_04, ark_q_05, ark_q_06, ark_q_07;
    reg [7:0] ark_q_08, ark_q_09, ark_q_10, ark_q_11;
(* mark_debug = "true" *)   reg [7:0] ark_q_12;
(* mark_debug = "true" *)	reg [7:0] ark_q_13;
(* mark_debug = "true" *)	reg [7:0] ark_q_14;
(* mark_debug = "true" *)	reg [7:0] ark_q_15;

    // \u67e5\u8868\u7ed3\u679c\u5bc4\u5b58
//    reg [7:0] sbox_q_00, sbox_q_01, sbox_q_02, sbox_q_03;
//    reg [7:0] sbox_q_04, sbox_q_05, sbox_q_06, sbox_q_07;
//    reg [7:0] sbox_q_08, sbox_q_09, sbox_q_10, sbox_q_11;
//    reg [7:0] sbox_q_12, sbox_q_13, sbox_q_14, sbox_q_15;

    // \u5730\u5740\u5bc4\u5b58\u8f93\u51fa
    reg [2:0] demux_q_00, demux_q_01, demux_q_02, demux_q_03;
    reg [2:0] demux_q_04, demux_q_05, demux_q_06, demux_q_07;
    reg [2:0] demux_q_08, demux_q_09, demux_q_10, demux_q_11;
    reg [2:0] demux_q_12, demux_q_13, demux_q_14, demux_q_15;

    reg [5:0] rwl_q_00, rwl_q_01, rwl_q_02, rwl_q_03;
    reg [5:0] rwl_q_04, rwl_q_05, rwl_q_06, rwl_q_07;
    reg [5:0] rwl_q_08, rwl_q_09, rwl_q_10, rwl_q_11;
    reg [5:0] rwl_q_12, rwl_q_13, rwl_q_14, rwl_q_15;

    // AES ??
    wire [127:0] dat_next;
    wire [127:0] src128 = use_datnext(grp_idx) ? dat_next : Din;
	
	

    // -------------------------------------------------
    // \u539f\u6709 Dvld/Kvld/BSY/counter/sel \u903b\u8f91\uff08\u672a\u6539\u52a8??
    // -------------------------------------------------
    always @(posedge CLK or posedge rst) begin
        if (rst)       Dvld <= 1'b0;
        else if (EN)   Dvld <= (sel == 2'b10) && (current_state == ST_LOOKUP);
		else begin
			Dvld <= 1'b0;
		end
    end

    always @(posedge CLK or posedge rst) begin
        if (rst)       Kvld <= 1'b0;
        else if (EN)   Kvld <= KDrdy ? 1'b1 : 1'b0;
    end

    always @(posedge CLK or posedge rst) begin
        if (rst) begin
            BSY <= 1'b0;
        end else if (EN) begin
            if (KDrdy)            BSY <= 1'b1;
            else if (current_state == ST_OUT) BSY <= 1'b0;
            else                   BSY <= BSY;
        end
    end

    StdAES_Optimized_AES_Core aes_core (
        .din (dat     ),
        .dout(dat_next),
        .sel (sel     )
    );

    // \u8f6e\u6b21\u8ba1\u6570?? sel \u63a7\u5236
    always @(posedge CLK) begin
        if (rst) begin
            dcnt <= 4'd0;
            sel  <= 2'd0;
        end else if (EN) begin
            if (KDrdy) begin
                dcnt <= 4'd11;
                sel  <= 2'd0;
            end else if (current_state == ST_MIX) begin
                if (grp_idx == 4'd0) begin
                    sel <= 2'd1;
                end else begin
                    if (dcnt > 0)	
                        dcnt <= dcnt - 4'd1;
                    sel <= (dcnt == 4'd2) ? 2'd2 : 2'd1;
                end
            end
        end
    end

    always @(posedge CLK) begin
        if (rst) begin
            dat <= 128'h5555_5555_5555_5555_5555_5555_5555_5555;
        end else if (EN) begin
            if (KDrdy) begin
                dat <= Din;
            end else if (current_state == ST_MIX) begin
                dat <= {
					rio_00, rio_01, rio_02, rio_03,
					rio_04, rio_05, rio_06, rio_07,
					rio_08, rio_09, rio_10, rio_11,
					rio_12, rio_13, rio_14, rio_15
                };
            end
        end else begin
			dat <= dat;
		end
    end

    always @ (posedge CLK) begin
		if (!RSTn) begin
			Dout <= 128'h0;
		end else if ((sel == 2'b10) && (current_state == ST_LOOKUP)) begin
			Dout <= {
				ark_q_00, ark_q_01, ark_q_02, ark_q_03,
				ark_q_04, ark_q_05, ark_q_06, ark_q_07,
				ark_q_08, ark_q_09, ark_q_10, ark_q_11,
				ark_q_12, ark_q_13, ark_q_14, ark_q_15
			};
		end else begin
			Dout <= Dout;
		end
	end

    // =================================================
    // \u4e0b\u9762\u662f\uff1a\u4e09\u6bb5\u5f0f\u72b6\u6001\u673a\uff08\u8bfb\u2192\u67e5\uff09\u6574??
    // =================================================



    // group \u914d\u7f6e\u51fd\u6570\uff08\u65e0 initial??
    function [2:0] get_demux_code;
        input [3:0] g;
    begin
        case (g)
            4'd0, 4'd4, 4'd8  : get_demux_code = 3'b111;
            4'd1, 4'd5, 4'd9  : get_demux_code = 3'b110;
            4'd2, 4'd6, 4'd10 : get_demux_code = 3'b101;
            4'd3, 4'd7        : get_demux_code = 3'b100;
            default           : get_demux_code = 3'b000;
        endcase
    end
    endfunction

    function [5:0] get_row_code;
        input [3:0] g;
    begin
        case (g)
            4'd0,4'd1,4'd2,4'd3   : get_row_code = 6'h00;
            4'd4,4'd5,4'd6,4'd7   : get_row_code = 6'h01;
            4'd8,4'd9,4'd10       : get_row_code = 6'h02;
            default               : get_row_code = 6'h00;
        endcase
    end
    endfunction

    function use_datnext;
        input [3:0] g;
    begin
        use_datnext = (g != 4'd0);
    end
    endfunction

    function [15:0] pick_2b;
        input [127:0] data128;
        input [3:0]   idx;      // 0..7
    begin
        if (IN_MSB_FIRST == 1'b1) pick_2b = data128[127 - (idx*16) -: 16];
        else                      pick_2b = data128[(idx*16) +: 16];
    end
    endfunction


    // \u72b6\u6001\u5bc4\u5b58\u53ca\u8ba1\u6570
    always @(posedge CLK or posedge rst) begin
        if (rst) begin
            current_state <= ST_IDLE;
            grp_idx  <= 4'd0;
            read_cnt <= 4'd0;
        end else if (EN) begin
            current_state <= next_state;
            case (current_state)
                ST_IDLE: begin
                    grp_idx  <= 4'd0;
                    read_cnt <= 4'd0;
                end
                ST_READ: begin
                    if (RD_DONE) begin
                        read_cnt <= (read_cnt == 4'd8) ? 4'd0 : read_cnt + 4'd1;
                    end
                end
                ST_LOOKUP: begin
                    if (RD_DONE && grp_idx < 4'd10) begin
                        grp_idx <= grp_idx + 4'd1;
                    end
                end
                default: ;
            endcase
        end
    end
	
	// ------------------------------------------------------------------
    // Generate single-cycle IO_EN pulses for each DRAM read request. A
    // pulse is issued when entering ST_READ, after every RD_DONE while more
    // reads remain in ST_READ, and once when entering ST_LOOKUP.
    // ------------------------------------------------------------------
    always @(posedge CLK or posedge rst) begin
        if (rst) begin
            IO_EN      <= 1'b0;
            prev_state <= ST_IDLE;
        end else if (EN) begin
            IO_EN      <= 1'b0; // default low
            if ((prev_state != ST_READ) && (current_state == ST_READ)) begin
                // first read of ST_READ
                IO_EN <= 1'b1;
            end else if ((current_state == ST_READ) && RD_DONE && (read_cnt_dff != 4'd7)) begin
                // subsequent reads within ST_READ
                IO_EN <= 1'b1;
            end else if ((prev_state != ST_LOOKUP) && (current_state == ST_LOOKUP)) begin
                // single read needed in ST_LOOKUP
                IO_EN <= 1'b1;
            end
            prev_state <= current_state;
        end else begin
            IO_EN      <= 1'b0;
            prev_state <= prev_state;
        end
    end

    // \u6b21\u6001\u903b\u8f91
    always @(*) begin
        next_state = ST_IDLE;
        case (current_state)
            ST_IDLE   : next_state = (EN && KDrdy) ? ST_READ   : ST_IDLE;
            ST_READ   : next_state = (read_cnt_dff == 4'd7) ? ST_LOOKUP : ST_READ;
            ST_LOOKUP : next_state = (grp_idx == 4'd10) ? ST_OUT : ST_MIX;
			ST_MIX    : next_state = ST_READ;
            ST_OUT    : next_state = ST_IDLE;
            default   : next_state = ST_IDLE;
        endcase
    end
	
	
    always @(posedge CLK or posedge rst) begin
        if (rst) begin
            read_cnt_dff <= 4'd0;
        end else if (current_state == ST_READ) begin
			read_cnt_dff <= read_cnt;
        end else begin
			read_cnt_dff <= 4'h0;
		end
    end
	
	always @(*) begin
		case (current_state)
			ST_READ: begin
				demux_q_00 = get_demux_code(grp_idx); rwl_q_00 = get_row_code(grp_idx);
				demux_q_01 = get_demux_code(grp_idx); rwl_q_01 = get_row_code(grp_idx);
				demux_q_02 = get_demux_code(grp_idx); rwl_q_02 = get_row_code(grp_idx);
				demux_q_03 = get_demux_code(grp_idx); rwl_q_03 = get_row_code(grp_idx);
				demux_q_04 = get_demux_code(grp_idx); rwl_q_04 = get_row_code(grp_idx);
				demux_q_05 = get_demux_code(grp_idx); rwl_q_05 = get_row_code(grp_idx);
				demux_q_06 = get_demux_code(grp_idx); rwl_q_06 = get_row_code(grp_idx);
				demux_q_07 = get_demux_code(grp_idx); rwl_q_07 = get_row_code(grp_idx);
				demux_q_08 = get_demux_code(grp_idx); rwl_q_08 = get_row_code(grp_idx);
				demux_q_09 = get_demux_code(grp_idx); rwl_q_09 = get_row_code(grp_idx);
				demux_q_10 = get_demux_code(grp_idx); rwl_q_10 = get_row_code(grp_idx);
				demux_q_11 = get_demux_code(grp_idx); rwl_q_11 = get_row_code(grp_idx);
				demux_q_12 = get_demux_code(grp_idx); rwl_q_12 = get_row_code(grp_idx);
				demux_q_13 = get_demux_code(grp_idx); rwl_q_13 = get_row_code(grp_idx);
				demux_q_14 = get_demux_code(grp_idx); rwl_q_14 = get_row_code(grp_idx);
				demux_q_15 = get_demux_code(grp_idx); rwl_q_15 = get_row_code(grp_idx);
			end
			ST_LOOKUP: begin
				// \u5730\u5740 = {1'b0, ark[7:6]} & ark[5:0]
				demux_q_00 = {1'b0, ark_q_00[7:6]}; rwl_q_00 = ark_q_00[5:0];
				demux_q_01 = {1'b0, ark_q_01[7:6]}; rwl_q_01 = ark_q_01[5:0];
				demux_q_02 = {1'b0, ark_q_02[7:6]}; rwl_q_02 = ark_q_02[5:0];
				demux_q_03 = {1'b0, ark_q_03[7:6]}; rwl_q_03 = ark_q_03[5:0];
				demux_q_04 = {1'b0, ark_q_04[7:6]}; rwl_q_04 = ark_q_04[5:0];
				demux_q_05 = {1'b0, ark_q_05[7:6]}; rwl_q_05 = ark_q_05[5:0];
				demux_q_06 = {1'b0, ark_q_06[7:6]}; rwl_q_06 = ark_q_06[5:0];
				demux_q_07 = {1'b0, ark_q_07[7:6]}; rwl_q_07 = ark_q_07[5:0];
				demux_q_08 = {1'b0, ark_q_08[7:6]}; rwl_q_08 = ark_q_08[5:0];
				demux_q_09 = {1'b0, ark_q_09[7:6]}; rwl_q_09 = ark_q_09[5:0];
				demux_q_10 = {1'b0, ark_q_10[7:6]}; rwl_q_10 = ark_q_10[5:0];
				demux_q_11 = {1'b0, ark_q_11[7:6]}; rwl_q_11 = ark_q_11[5:0];
				demux_q_12 = {1'b0, ark_q_12[7:6]}; rwl_q_12 = ark_q_12[5:0];
				demux_q_13 = {1'b0, ark_q_13[7:6]}; rwl_q_13 = ark_q_13[5:0];
				demux_q_14 = {1'b0, ark_q_14[7:6]}; rwl_q_14 = ark_q_14[5:0];
				demux_q_15 = {1'b0, ark_q_15[7:6]}; rwl_q_15 = ark_q_15[5:0];
			end
			default : begin
				demux_q_00 = 3'b000; rwl_q_00 = 6'h00;
				demux_q_01 = 3'b000; rwl_q_01 = 6'h00;
				demux_q_02 = 3'b000; rwl_q_02 = 6'h00;
				demux_q_03 = 3'b000; rwl_q_03 = 6'h00;
				demux_q_04 = 3'b000; rwl_q_04 = 6'h00;
				demux_q_05 = 3'b000; rwl_q_05 = 6'h00;
				demux_q_06 = 3'b000; rwl_q_06 = 6'h00;
				demux_q_07 = 3'b000; rwl_q_07 = 6'h00;
				demux_q_08 = 3'b000; rwl_q_08 = 6'h00;
				demux_q_09 = 3'b000; rwl_q_09 = 6'h00;
				demux_q_10 = 3'b000; rwl_q_10 = 6'h00;
				demux_q_11 = 3'b000; rwl_q_11 = 6'h00;
				demux_q_12 = 3'b000; rwl_q_12 = 6'h00;
				demux_q_13 = 3'b000; rwl_q_13 = 6'h00;
				demux_q_14 = 3'b000; rwl_q_14 = 6'h00;
				demux_q_15 = 3'b000; rwl_q_15 = 6'h00;
			end
		endcase
	end
			

    // \u65f6\u5e8f\u8f93\u51fa\u4e0e\u6570\u636e\u8def??
//    always @(posedge CLK or posedge rst) begin
//        if (rst) begin
//            sbox_q_00 <= 8'h00; sbox_q_01 <= 8'h00; sbox_q_02 <= 8'h00; sbox_q_03 <= 8'h00;
//            sbox_q_04 <= 8'h00; sbox_q_05 <= 8'h00; sbox_q_06 <= 8'h00; sbox_q_07 <= 8'h00;
//            sbox_q_08 <= 8'h00; sbox_q_09 <= 8'h00; sbox_q_10 <= 8'h00; sbox_q_11 <= 8'h00;
//            sbox_q_12 <= 8'h00; sbox_q_13 <= 8'h00; sbox_q_14 <= 8'h00; sbox_q_15 <= 8'h00;
//        end else if (EN) begin
//            case (current_state)
//                //ST_LOOKUP: begin
//				ST_MIX: begin
//
//                    // \u8bfb\u53d6 RIO \u7ed3\u679c
//                    sbox_q_00 <= rio_00; sbox_q_01 <= rio_01; sbox_q_02 <= rio_02; sbox_q_03 <= rio_03;
//                    sbox_q_04 <= rio_04; sbox_q_05 <= rio_05; sbox_q_06 <= rio_06; sbox_q_07 <= rio_07;
//                    sbox_q_08 <= rio_08; sbox_q_09 <= rio_09; sbox_q_10 <= rio_10; sbox_q_11 <= rio_11;
//                    sbox_q_12 <= rio_12; sbox_q_13 <= rio_13; sbox_q_14 <= rio_14; sbox_q_15 <= rio_15;
//                end
//
//                default: begin
//					sbox_q_00 <= sbox_q_00; sbox_q_01 <= sbox_q_01; sbox_q_02 <= sbox_q_02; sbox_q_03 <= sbox_q_03;
//					sbox_q_04 <= sbox_q_04; sbox_q_05 <= sbox_q_05; sbox_q_06 <= sbox_q_06; sbox_q_07 <= sbox_q_07;
//					sbox_q_08 <= sbox_q_08; sbox_q_09 <= sbox_q_09; sbox_q_10 <= sbox_q_10; sbox_q_11 <= sbox_q_11;
//					sbox_q_12 <= sbox_q_12; sbox_q_13 <= sbox_q_13; sbox_q_14 <= sbox_q_14; sbox_q_15 <= sbox_q_15;
//                end
//            endcase
//        end else begin
//            sbox_q_00 <= sbox_q_00; sbox_q_01 <= sbox_q_01; sbox_q_02 <= sbox_q_02; sbox_q_03 <= sbox_q_03;
//            sbox_q_04 <= sbox_q_04; sbox_q_05 <= sbox_q_05; sbox_q_06 <= sbox_q_06; sbox_q_07 <= sbox_q_07;
//            sbox_q_08 <= sbox_q_08; sbox_q_09 <= sbox_q_09; sbox_q_10 <= sbox_q_10; sbox_q_11 <= sbox_q_11;
//            sbox_q_12 <= sbox_q_12; sbox_q_13 <= sbox_q_13; sbox_q_14 <= sbox_q_14; sbox_q_15 <= sbox_q_15;
//        end
//    end
	
	
	    // \u65f6\u5e8f\u8f93\u51fa\u4e0e\u6570\u636e\u8def??
    always @(posedge CLK) begin
		if (!RSTn) begin
			ark_q_00 <= 8'h0; 
			ark_q_01 <= 8'h0; 
			ark_q_02 <= 8'h0; 
			ark_q_03 <= 8'h0;
			ark_q_04 <= 8'h0; 
			ark_q_05 <= 8'h0; 
			ark_q_06 <= 8'h0; 
			ark_q_07 <= 8'h0;
			ark_q_08 <= 8'h0; 
			ark_q_09 <= 8'h0; 
			ark_q_10 <= 8'h0; 
			ark_q_11 <= 8'h0;
			ark_q_12 <= 8'h0; 
			ark_q_13 <= 8'h0; 
			ark_q_14 <= 8'h0; 
			ark_q_15 <= 8'h0;
		end else begin
			case (current_state)
				ST_READ: begin
					// \u91c7\u6837\u5f53\u524d\u4f4d\u9762\uff08bit = 7-read_cnt\uff09
					case (read_cnt_dff)
						4'd0: begin
							ark_q_00 <= {rio_07[7],rio_06[7],rio_05[7],rio_04[7],rio_03[7],rio_02[7],rio_01[7],rio_00[7]};
							ark_q_01 <= {rio_15[7],rio_14[7],rio_13[7],rio_12[7],rio_11[7],rio_10[7],rio_09[7],rio_08[7]};
						end           
						4'd1: begin   
							ark_q_02 <= {rio_07[6],rio_06[6],rio_05[6],rio_04[6],rio_03[6],rio_02[6],rio_01[6],rio_00[6]};
							ark_q_03 <= {rio_15[6],rio_14[6],rio_13[6],rio_12[6],rio_11[6],rio_10[6],rio_09[6],rio_08[6]};
						end           
						4'd2: begin   
							ark_q_04 <= {rio_07[5],rio_06[5],rio_05[5],rio_04[5],rio_03[5],rio_02[5],rio_01[5],rio_00[5]};
							ark_q_05 <= {rio_15[5],rio_14[5],rio_13[5],rio_12[5],rio_11[5],rio_10[5],rio_09[5],rio_08[5]};
						end           
						4'd3: begin   
							ark_q_06 <= {rio_07[4],rio_06[4],rio_05[4],rio_04[4],rio_03[4],rio_02[4],rio_01[4],rio_00[4]};
							ark_q_07 <= {rio_15[4],rio_14[4],rio_13[4],rio_12[4],rio_11[4],rio_10[4],rio_09[4],rio_08[4]};
						end           
						4'd4: begin   
							ark_q_08 <= {rio_07[3],rio_06[3],rio_05[3],rio_04[3],rio_03[3],rio_02[3],rio_01[3],rio_00[3]};
							ark_q_09 <= {rio_15[3],rio_14[3],rio_13[3],rio_12[3],rio_11[3],rio_10[3],rio_09[3],rio_08[3]};
						end           
						4'd5: begin   
							ark_q_10 <= {rio_07[2],rio_06[2],rio_05[2],rio_04[2],rio_03[2],rio_02[2],rio_01[2],rio_00[2]};
							ark_q_11 <= {rio_15[2],rio_14[2],rio_13[2],rio_12[2],rio_11[2],rio_10[2],rio_09[2],rio_08[2]};
						end           
						4'd6: begin   
							ark_q_12 <= {rio_07[1],rio_06[1],rio_05[1],rio_04[1],rio_03[1],rio_02[1],rio_01[1],rio_00[1]};
							ark_q_13 <= {rio_15[1],rio_14[1],rio_13[1],rio_12[1],rio_11[1],rio_10[1],rio_09[1],rio_08[1]};
						end           
						4'd7: begin   
							ark_q_14 <= {rio_07[0],rio_06[0],rio_05[0],rio_04[0],rio_03[0],rio_02[0],rio_01[0],rio_00[0]};
							ark_q_15 <= {rio_15[0],rio_14[0],rio_13[0],rio_12[0],rio_11[0],rio_10[0],rio_09[0],rio_08[0]};
						end
						default: begin
						end
					endcase
				end

				default: begin
					ark_q_00 <= 8'h0; 
					ark_q_01 <= 8'h0; 
					ark_q_02 <= 8'h0; 
					ark_q_03 <= 8'h0;
					ark_q_04 <= 8'h0; 
					ark_q_05 <= 8'h0; 
					ark_q_06 <= 8'h0; 
					ark_q_07 <= 8'h0;
					ark_q_08 <= 8'h0; 
					ark_q_09 <= 8'h0; 
					ark_q_10 <= 8'h0; 
					ark_q_11 <= 8'h0;
					ark_q_12 <= 8'h0; 
					ark_q_13 <= 8'h0; 
					ark_q_14 <= 8'h0; 
					ark_q_15 <= 8'h0;
				end
			endcase
		end
    end
	

    // \u7aef\u53e3\u8f93\u51fa
    assign IN = ((read_cnt < 4'd8) && (current_state == ST_READ)) ? pick_2b(src128, read_cnt) : 16'h0;


    assign DEMUX_ADD_00 = demux_q_00; assign RWL_DEC_ADD_00 = rwl_q_00;
    assign DEMUX_ADD_01 = demux_q_01; assign RWL_DEC_ADD_01 = rwl_q_01;
    assign DEMUX_ADD_02 = demux_q_02; assign RWL_DEC_ADD_02 = rwl_q_02;
    assign DEMUX_ADD_03 = demux_q_03; assign RWL_DEC_ADD_03 = rwl_q_03;
    assign DEMUX_ADD_04 = demux_q_04; assign RWL_DEC_ADD_04 = rwl_q_04;
    assign DEMUX_ADD_05 = demux_q_05; assign RWL_DEC_ADD_05 = rwl_q_05;
    assign DEMUX_ADD_06 = demux_q_06; assign RWL_DEC_ADD_06 = rwl_q_06;
    assign DEMUX_ADD_07 = demux_q_07; assign RWL_DEC_ADD_07 = rwl_q_07;
    assign DEMUX_ADD_08 = demux_q_08; assign RWL_DEC_ADD_08 = rwl_q_08;
    assign DEMUX_ADD_09 = demux_q_09; assign RWL_DEC_ADD_09 = rwl_q_09;
    assign DEMUX_ADD_10 = demux_q_10; assign RWL_DEC_ADD_10 = rwl_q_10;
    assign DEMUX_ADD_11 = demux_q_11; assign RWL_DEC_ADD_11 = rwl_q_11;
    assign DEMUX_ADD_12 = demux_q_12; assign RWL_DEC_ADD_12 = rwl_q_12;
    assign DEMUX_ADD_13 = demux_q_13; assign RWL_DEC_ADD_13 = rwl_q_13;
    assign DEMUX_ADD_14 = demux_q_14; assign RWL_DEC_ADD_14 = rwl_q_14;
    assign DEMUX_ADD_15 = demux_q_15; assign RWL_DEC_ADD_15 = rwl_q_15;

    assign SEL_AD1 = 1'b0;
    assign SEL_AD0 = (current_state == ST_READ) ? 1'b1 :1'b0;
	
(* mark_debug = "true" *)	wire [8:0] RD_ADDR_00;
(* mark_debug = "true" *)	wire [8:0] RD_ADDR_01;
(* mark_debug = "true" *)	wire [8:0] RD_ADDR_02;
(* mark_debug = "true" *)	wire [8:0] RD_ADDR_03;

(* mark_debug = "true" *)	wire [8:0] RD_ADDR_12;
(* mark_debug = "true" *)	wire [8:0] RD_ADDR_13;
(* mark_debug = "true" *)	wire [8:0] RD_ADDR_14;
(* mark_debug = "true" *)	wire [8:0] RD_ADDR_15;
	
	assign RD_ADDR_00 = {DEMUX_ADD_00,RWL_DEC_ADD_00};
	assign RD_ADDR_01 = {DEMUX_ADD_01,RWL_DEC_ADD_01};
	assign RD_ADDR_02 = {DEMUX_ADD_02,RWL_DEC_ADD_02};
	assign RD_ADDR_03 = {DEMUX_ADD_03,RWL_DEC_ADD_03};
	
	assign RD_ADDR_12 = {DEMUX_ADD_12,RWL_DEC_ADD_12};
	assign RD_ADDR_13 = {DEMUX_ADD_13,RWL_DEC_ADD_13};
	assign RD_ADDR_14 = {DEMUX_ADD_14,RWL_DEC_ADD_14};
	assign RD_ADDR_15 = {DEMUX_ADD_15,RWL_DEC_ADD_15};


endmodule
