`default_nettype   none
module delay1(i_clk, i_reset,
	i_in, o_out);

parameter D = 1;
parameter W = 1;

localparam Dp = D+1;

input wire i_clk;
input wire i_reset;
input wire [W-1:0] i_in;
output wire [W-1:0] o_out;

generate case (D)
0:
assign o_out = i_in;
1: begin
reg [W-1:0] delay_1;
always @(posedge i_clk)
	delay_1 <= i_in;
assign o_out = delay_1;
end
default: begin
reg [Dp*W-1:0] delay_line;
always @(posedge i_clk) begin
	if (i_reset)
		delay_line <= 0;
	else begin
		delay_line = {i_in, delay_line[W*Dp-W-1:W]};
	end
end
assign o_out = delay_line[W-1:0];
end
endcase
endgenerate

endmodule
