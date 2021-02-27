// from SY22-2909-2_1052_Adapter_and_2150_Console_FETOP_Jan69.pdf
// figure 9; function decoder
// pdf page 20; 1052 & 2150 feto/fedm (5-66) 20
`default_nettype   none
module cfdecode(i_clk, i_reset,
	i_data_reg,
	i_carrier_return_latch,
	i_shift_change,
	i_ready,
	i_cycle_time,
	i_case_latch,
	o_function,
	o_fd_out);

// verilator lint_off UNUSED
input wire i_clk;
input wire i_reset;
// verilator lint_on UNUSED

input wire [7:0] i_data_reg;
input wire i_carrier_return_latch;
input wire i_shift_change;
input wire i_ready;
input wire i_cycle_time;
input wire i_case_latch;
output wire o_function;
output wire [4:0] o_fd_out;

wire pick_space_magnet;
wire pick_crlf_magnet;
wire pick_ready;
wire pick_lc_magnet;
wire pick_uc_magnet;

wire space;
wire x_e8ctrl;
wire x_functcycle;
wire cr_and_lf;

assign o_fd_out = {pick_space_magnet, pick_crlf_magnet, pick_ready,
	pick_lc_magnet, pick_uc_magnet};

wire b0,b1,b2,b3,b4,b5,b6,b7;

assign {b0,b1,b2,b3,b4,b5,b6,b7} = i_data_reg;

assign space = i_data_reg == 8'h40;

// any ebcdic control character (that's also a ptt8 control char)
assign x_e8ctrl = ~b0 & ~b1 & ~b4 & b5;	// [0123][4567]
// 'h15 == nl newline
assign cr_and_lf = (x_e8ctrl & ~b2 & b3 & ~b6 & b7) | i_carrier_return_latch;

assign o_function = space | i_carrier_return_latch | i_shift_change | x_e8ctrl;
assign x_functcycle = o_function & i_cycle_time;

assign pick_space_magnet = space & ~cr_and_lf & x_functcycle;

assign pick_crlf_magnet = cr_and_lf & x_functcycle;

assign pick_ready = i_ready & x_functcycle;

assign pick_lc_magnet = pick_ready & i_case_latch & ~space;
assign pick_uc_magnet = pick_ready & ~i_case_latch & ~space;

endmodule
