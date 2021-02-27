`default_nettype none
module tb;

localparam eNL = 'h15;
localparam eSP = 'h40;
localparam e_a = 'h81;
localparam e_A = 'hc1;
localparam e_0 = 'hf0;
	reg clk;
	reg rst;

	reg [7:0] data;
	wire [5:0] tt_out;
	wire uc, lc;

initial begin
$dumpfile("e2tt.vcd");
$dumpvars(0, u0);
end

	e2tt #(3) u0( .i_clk(clk), .i_reset(rst),
		.i_data_reg(data),
		.o_tt_out(tt_out),
		.o_lower_case_character(lc),
		.o_upper_case_character(uc));

	always #1 clk = ~clk;

	initial begin
		{clk, rst} <= 1;

	$monitor("T=%0t data=%x tt_out=%0x lower=%b upper=%b",
		$time, data, tt_out, lc, uc);

	repeat(2) @(posedge clk);
		rst <= 0;

	#2 data <= e_0;
	#8 data <= eNL;
	#8 data <= eSP;
	#8 data <= e_A;
	#8 data <= e_a;
	#30;
		$finish;

	end
endmodule
