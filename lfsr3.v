`default_nettype none
//
// linear feedback shift register - 16:
// galois configuration, xnor
// x^16 + x^15 + x^13 + x^11 + 1
//
//	W	K	W	K	W	K
//	1	1	9	110	17	12000
//	2	3	10	240	18	20400
//	3	6	11	500	19	72000
//	4	c	12	e08	20	90000
//	5	14	13	1c80	21	140000
//	6	30	14	3802	22	300000
//	7	60	15	6000	23	420000
//	8	b8	16	b400	24	e10000
//

module lfsr3(i_clk, i_reset, i_step, o_state);
parameter W=16;
parameter K='hb400;

input wire i_clk;
input wire i_reset;
input wire i_step;	// step lfsr

output reg [W-1:0] o_state;

wire [W-1:0] next_state;

genvar i;
assign next_state[W-1] = ~o_state[0];
generate for (i = 0; i < W-1; i = i + 1)
if (|(K & (1<<i)))
assign next_state[i] = o_state[i+1] ^ ~o_state[0];
else
assign next_state[i] = o_state[i+1];
endgenerate

always @(posedge i_clk)
	if (i_reset)
		o_state <= 0;
	else if (i_step) begin
		o_state <= next_state;
	end
endmodule
