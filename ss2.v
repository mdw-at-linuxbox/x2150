`default_nettype   none
module ss2(i_clk, i_reset,
	i_in, o_out);

parameter N = 5;
parameter [0:0] NE = 0;

input wire i_clk;
input wire i_reset;
input wire i_in;
output reg o_out;

reg [$clog2(N):0] count;

always @(posedge i_clk) begin
	if (i_reset) begin
		o_out <= NE;
		count <= 1;
	end else case (count)
	default:
		count <= count - 1;
	1:
		begin
			o_out <= NE;
			if (~(i_in ^ NE))
				count <= 0;
		end
	0:
		if (i_in ^ NE) begin
			o_out <= ~NE;
			count <= N;
		end
	endcase
end
endmodule
