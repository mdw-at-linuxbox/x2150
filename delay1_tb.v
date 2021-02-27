`default_nettype none
module tb;
	reg clk;
	reg rst;

	parameter D = 3;
	parameter W = 4;

	reg [W-1:0] data;
	wire txd;
	wire busy;
	wire idle;
	wire [W-1:0] out;

initial begin
$dumpfile("delay1.vcd");
$dumpvars(0, u0);
end

	delay1 #(D,W) u0( .i_clk(clk), .i_reset(rst), .i_in(data), .o_out(out));

	always #1 clk = ~clk;

	initial begin
		{clk, rst} <= 1;

	$monitor("T=%0t data=%0x out=%0x", $time, data, out);
	#3 rst <= 0;

	#6 data <= 1;
	#6 data <= 5;
	#8 data <= 2;
	#6 data <= 3;
	#6 data <= 0;
	#30;
		$finish;

	end
endmodule
