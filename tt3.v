// from SY22-2909-2_1052_Adapter_and_2150_Console_FETOP_Jan69.pdf
// figure 6; printer translator translate 8-bit to tilt/rotate
// pdf page 17; "functional units 17
//
// altered to generate same tilt codes that appear on
// pdf page 22; "figure 10 1052 internal tilt/rotate code"
//
`default_nettype   none
module tt3(i_clk, i_reset,
	i_data_reg,
	o_tt_out,
	o_lower_case_character,
	o_upper_case_character);

// verilator lint_off UNUSED
input wire i_clk;
input wire i_reset;
// verilator lint_on UNUSED

input wire [7:0] i_data_reg;
output wire [5:0] o_tt_out;
output wire o_lower_case_character;
output wire o_upper_case_character;

wire not_t1;
wire t2;
wire not_r1;
wire not_r2;
wire not_r2a;
wire not_r5;

assign o_tt_out = {~not_t1, t2, ~not_r1, ~not_r2, ~not_r2a, ~not_r5};

wire b0,b1,b2,b3,b4,b5,b6,b7;

assign {b0,b1,b2,b3,b4,b5,b6,b7} = i_data_reg;

assign not_t1 = (~b0 & ~b4 & ~b5 & b7) |	// /
	(b0 & ~b3) |		// abcdefghistuvwxyzABCDEFGHISTUVWXYZ
	(~b0 & b2 & b3 & ~b6 & ~b7) |	// @
	(b2 & ~b3 & b6 & b7) |		// ,?txTX
	(~b2 & b3 & b4 & b5 & b6 & b7) |	// ^
	(~b2 & ~b3 & b6 & ~b7) |	// [+bfBF
	(~b2 & ~b3 & ~b5) |		// [.abchiABCHI
	(~b0 & ~b2 & ~b5 & ~b7);	// [&]
assign t2 = (~b0 & b3 & b6 & ~b7) |	// ];:=
	(~b0 & ~b3 & ~b4 & b7) |	// /
	(~b0 & ~b3 & b4 & ~b5 & ~b7) |	// [
	(~b0 & (~b2 | ~b7) & b5 & ~b6) |	// <(*)
					// <*%@ 
	(b2 & (b0 | b3 | b6 ));		// stuvwxyzSTUVWXYZ0123456789
					// :#@'="0123456789
					// ,>?:#="stwxSTWX2367
assign not_r1 = (b0 & ~b4 & ~b5 & ~b7) |	// bksBKS02
	(~b4 & b6) |			// bcfgklopstwxBCFGKLOPSTWX2367
	(~b2 & (b3 | b7) & b6) |	// ]$;^klopKLOP
					// .!$^cglpCGLP
	(b2 & ~b3 & b6 & ~b7) |		// >swSW
	(~b0 & b4 & ~b5 & b7) |		// .$,#
	(~b0 & b3 & b7) |		// $)^#'"
	(~b0 & ~b2 & ~b3 & ~b6 & ~b7);	// <
assign not_r2 = (b0 & (b4 | b5)) |		// hiqryzHIQRYZ89
					// defgmnopuvwxDEFGMNOPUVWX4567
	(~b0 & (~b2 |b3) & b7) |	// .(!$)^
					// $)^#'"
	(b3 & b4 & ~b5) |		// ]$:#qrQR89
	(b4 & ~b5 & b7) |		// .$,#irzIRZ9
	(~b2 & b3 & b4 & ~b6) |		// *)qrQR
	(b2 & ~b3 & b5 & ~b7) |		// %>uwUW
	(b0 & ~b6 & ~b7);		// dhmquyDHMQUY048
assign not_r2a = (b4 & ~b5 & b7) |		// .$,#irzIRZ9
	(b0 & ~b5 & ~b6 & ~b7) |	// hqyHQY08
	(~b0 & b3 & b6 & b7) |		// $^#"
	(~b2 & b3 & b4 & (~b5 | ~b6)) |	// ]$qrQR
					// *)qrQR
	(~b2 & b4 & b7);		// .(!$)^irIR
assign not_r5 = (~b0 & b2 & b3 & ~b6) |	// @'
	(b4 & ~b5 & b7) |		// .$,#irzIRZ9
	(~b0 & ~b2 & ~b3) |		// [.<(+!
	(~b4 & b5 & ~b7) |		// dfmouwDFMOUW46
	(~b0 & ~b5 & ~b6 & ~b7) |	// &-
	(~b0 & b3 & ~b5) |		// &]$:#
	(~b0 & b2 & b3 & b7) |		// #'"
	(~b0 & ~b2 & b6 & b7) |		// .!$^
	(~b0 & b2 & b5 & ~b6 & b7) |	// _'
	(~b4 & b6 & ~b7);		// bfkoswBFKOSW26
assign o_lower_case_character = (~b1) |		// a-z
	(b0 & b2 & b3) |			// 0-9
	(~b0 & ~b5 & b7) |			// .$/,#
	(b2 & b3 & ~b6 & ~b7) |			// @048
	(~b0 & ~b4);				// &-/
assign o_upper_case_character = ~o_lower_case_character;

endmodule
