`default_nettype   none
module latch1(i_clk, i_set,
	i_clear, o_out);

parameter W=1;

input wire i_clk;
input wire [W-1:0] i_set;
input wire i_clear;
output reg [W-1:0] o_out;

genvar i;
generate for (i = 0; i < W; i = i + 1)
always @(posedge i_clk) begin
if (i_set[i])
	o_out[i] <= 1;
if (i_clear)
	o_out[i] <= 0;
end
endgenerate

endmodule
