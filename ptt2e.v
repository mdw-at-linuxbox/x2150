// from SY22-2909-2_1052_Adapter_and_2150_Console_FETOP_Jan69.pdf
// pdf page 11; figure 3: 1052 keyboard code translation and printer output
// pdf page 18: figure 7: keyboard translator
// the logic in the actual hardware most likely only
// translates the codes the keyboard can actually generate,
// unfortunately only the logic for the first 3 bits is presented.
//
// a complete list of ptt/8 ("bcd") codes is here,
// GA24-3231-7_360-30_funcChar.pdf page 62
// this logic translates all of them.
//
`default_nettype   none
module ptt2e(i_clk, i_reset,
	i_keyboard,
	i_lower_upper_case,
	o_out);

// verilator lint_off UNUSED
input wire i_clk;
input wire i_reset;
// verilator lint_on UNUSED

input wire [5:0] i_keyboard;
input wire i_lower_upper_case;
output wire [7:0] o_out;

wire not_xlate_0;
wire xlate_1;
wire xlate_2;
wire xlate_3;
wire xlate_4;
wire not_xlate_5;
wire not_xlate_6;
wire not_xlate_7;

wire b1;
wire b2;
wire b4;
wire b8;
wire ba;
wire bb;
wire lc;
wire uc;

assign lc = i_lower_upper_case;
assign uc = ~i_lower_upper_case;
assign {bb,ba,b8,b4,b2,b1} = i_keyboard;

assign o_out = {~not_xlate_0, xlate_1, xlate_2, xlate_3,
	xlate_4, ~not_xlate_5, ~not_xlate_6, ~not_xlate_7};

assign not_xlate_0 = ((~b8 & ~b4 & ~b2 & ~b1) |	// [_+@-& sp
	(uc & ~bb & ~ba) |		// =<;:%'>*()" sp uc
	(b8 & b4) |			// uc lf nl ht lc
	(~bb & ba & ~b8 & ~b4 & ~b2) |	// [?@/
	(b8 & b2 & b1) |		// "!]^#,$.
	(ba & b8 & b2) |		// !^,. lc
	(bb & b8 & b2));		// ]^$. lc
assign xlate_1 = (b8 & ~b4 & b2 & b1) |	// "!]^#,$.
	(~bb & ~ba & (~b8 | ~b4)) |	// =<;:%'>*()"1234567890# sp
	(uc & ~b8) |			// =<;:%'>[?STUVWX_JKLMNOP+ABCDEFG
	(~b8 & ~b4 & ~b2 & ~b1) |	// [_+@-& sp
	(uc & ~b4 & ~b2) |		// =*([?YZ_JQR+AHI sp
	(~bb & ~b8 & ~b4 & ~b2);	// =[?1@/ sp
assign xlate_2 = (lc & ~bb & ba & ~b8) |	// @/uvyz lf
	(lc & ~bb & ~b8 & b2) |		// 2367stwx
	(lc & ~bb & ~ba & b8) |		// 890# uc
	(bb & ~ba & ~b8 & ~b4 & ~b2 & ~b1) |	// _-
	(~bb & ~ba & b8 & b2 & b1) |	// "#
	(~bb & ba & b8 & ~b2) |		// YZyz lf
	(~bb & ba & ~b8 & b2) |		// STWXstwx
	(~bb & b4) |			// :%'>UVWX4567uvwx uc lf
	(~bb & ~b8 & ~b2 & b1) |	// =%?V15/v
	(lc & ~bb & b1);		// 13579#/tvxz, lf
assign xlate_3 = ((lc | bb) & ~ba & b1) |	// JLNPR]jlnpr$ nl
					// 13579#jlnpr$ nl
	(lc & ~ba & ~b8 & b2) |		// 2367klop
	(~bb & ~ba & b8 & ~b1) |	// *)80 uc
	(~ba & ~b4 & b2 & b1) |		// ;"L]3#l$
	(bb & ~ba & b8 & ~b2) |		// QRqr nl
	(lc & ba & ~b8 & ~b4 & ~b2 & ~b1) |	// @&
	(uc & bb & b8 & ~b4 & b2 & b1) |	// ]^
	(~ba & b4 & ~b1) |		// :'MO46mo uc
	(~ba & ~b8 & ~b4 & b1) |	// =;JL13jl
	(bb & ~ba & ~b8 & b2) |		// KLOPklop
	(~ba & b8 & b4);		// uc nl
assign xlate_4 = (uc & ~bb & ~b4 & ~b2 & b1) |	// =(?Z
	(uc & ~bb & ~ba & ~b4 & b2) |	// <;)"
	(uc & ~bb & ~ba & ~b8 & b4) |	// :%'>
	(b8 & ~b4 & (b1 | ~b2)) |	// ("Z!R]I^9#z,r$i.
					// *(YZQRHI89yzqrhi
	(~bb & ba & ~b4 & ~b2 & ~b1) |	// [Y@y
	(uc & bb & ~b4 & ~b2 & ~b1);	// _Q+H
assign not_xlate_5 = ~((bb & b4) |		// MNOPDEFGmnopdefg nl ht lc
	(lc & ~bb & ba & ~b8 & ~b2 & ~b1) |	// @u
	(uc & bb & ~b8 & ~b2 & ~b1) |	// _M+D
	(uc & ba & b8 & b2 & b1) |	// !^
	(uc & ~bb & ~ba & (b8 | b2)) |	// *()" uc
					// <;'>)" uc
	(uc & ~bb & ~b8 & ~b2 & b1) | // =%?V
	((lc | ba) & b4));	// 4567uvwxmnopdefg uc lf nl ht lc
				// UVWXDEFGuvwxdefg lf ht lc
assign not_xlate_6 = ~((ba & b4 & b2) |			// WXFGwxfg lc
	(uc & ba & ~b8 & ~b4 & ~b1) |	// [S+B
	(uc & ~bb & ~ba & ~b8 & b4 & ~b2 & ~b1) |	// :
	(uc & ~bb & ~b8 & ~b4 & b1) |	// =;?T
	(b8 & b4 & b2) |		// uc lc
	(b2 & b1) |			// ;>"TX!LP]CG^37#tx,lp$cg.
	((lc | bb) & ~b8 & b2));		// 2367stwxklopbcfg
					// KLOPBCFGklopbcfg
assign not_xlate_7 = ~((b8 & b4 & b1) |			// lf nl ht
	(b8 & ~b2 & b1) |		// lf nl ht
	(uc & ~bb & ~ba & ~b8 & b4 & b2 & ~b1) |	// '
	(uc & bb & ~ba & ~b8 & ~b4 & ~b2) |	// _J
	(uc & ~bb & ~ba & b8 & ~b4 & b2) |	// )"
	((lc | ba) & b1) |		// 13579#/tvxz,jlnpr$acegi. lf nl ht
					// ?TVXZ!ACEGI^/tvxz,acegi. lf ht
	(bb & ~b8 & b1));		// JLNPACEGjlnpaceg

endmodule
