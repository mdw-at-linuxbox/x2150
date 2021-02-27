`default_nettype none
module tb;
	reg clk;
	reg rst;

	parameter D = 3;

	reg data;
	wire txd;
	wire busy;
	wire idle;
	wire out;

initial begin
$dumpfile("ss2.vcd");
$dumpvars(0, u0);
end

	ss2 #(D) u0( .i_clk(clk), .i_reset(rst), .i_in(data), .o_out(out));

	always #1 clk = ~clk;

	initial begin
		{clk, rst} <= 1;

	$monitor("T=%0t data=%b out=%b", $time, data, out);
	#3 rst <= 0;

	#6 data <= 1;
	#6 data <= 0;
	#10 data <= 1;
	#2 data <= 0;
	#2 data <= 1;
	#6 data <= 0;
	#2 data <= 1;
	#4 data <= 0;
	#30;
		$finish;

	end
endmodule
