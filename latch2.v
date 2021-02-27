`default_nettype   none
module latch2(i_clk, i_rst,
	i_set, i_clear, o_out);

parameter W=1;

input wire i_clk;
input wire i_rst;
input wire [W-1:0] i_set;
input wire [W-1:0] i_clear;
output reg [W-1:0] o_out;

reg [W-1:0] i_set_delayed;
reg [W-1:0] i_clear_delayed;

wire [W-1:0] bits_to_set;
wire [W-1:0] no_bits_to_clear;
wire [W-1:0] no_initial_clear;

assign bits_to_set = (i_set & ~i_set_delayed);
assign no_bits_to_clear = ~i_clear | i_clear_delayed;
assign no_initial_clear = ~{(W){i_rst}};

always @(posedge i_clk) begin
	i_set_delayed <= i_set;
	i_clear_delayed <= i_clear;
	o_out <= (o_out | bits_to_set) & no_bits_to_clear & no_initial_clear;
end

endmodule
