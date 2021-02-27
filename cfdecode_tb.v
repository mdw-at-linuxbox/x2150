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
	reg cr_latch;
	reg shift_change;
	reg ready;
	reg cycle_time;
	reg case_latch;
	wire x_function;
	wire [4:0] fd_out;

initial begin
$dumpfile("cfdecode.vcd");
$dumpvars(0, u0);
end

	cfdecode #(3) u0( .i_clk(clk), .i_reset(rst),
		.i_data_reg(data),
		.i_carrier_return_latch(cr_latch),
		.i_shift_change(shift_change),
		.i_ready(ready),
		.i_cycle_time(cycle_time),
		.i_case_latch(case_latch),
		.o_function(x_function),
		.o_fd_out(fd_out));

	always #1 clk = ~clk;

	reg [1:0] cdel;
	always @(posedge clk) begin
		if (cdel > 1)
			cdel <= cdel - 1;
		else if (cdel == 1) begin
			cycle_time <= 0;
			cdel <= 0;
		end
		else if (cycle_time) cdel <= 2;
	end

	initial begin
		{clk, rst} <= 1;

	cycle_time <= 0;
	shift_change <= 0;
	case_latch <= 0;
	ready <= 1;
	{cr_latch,shift_change,cycle_time} <= 0;

	$monitor("T=%0t data=%x function=%b fd_out=%0x", $time, data, x_function, fd_out);

	repeat(2) @(posedge clk);
		rst <= 0;

	#2 data <= e_0;
	$display("T=%t - 0", $time);
	cycle_time <= 1;
	#8 data <= eNL;
	$display("T=%t - nl", $time);
	cycle_time <= 1;
	#8 data <= eSP;
	$display("T=%t - sp", $time);
	cycle_time <= 1;
	#8 shift_change <= 1;
	$display("T=%t - shift_change 1", $time);
	data <= e_A;
	cycle_time <= 1;
	#8 shift_change <= 0;
	$display("T=%t - shift_change 0", $time);
	data <= e_a;
	cycle_time <= 1;
	#8 cr_latch <= 1;
	$display("T=%t - cr_latch", $time);
	cycle_time <= 1;
	#8 cr_latch <= 0;
	cycle_time <= 1;

	#30;
		$finish;

	end
endmodule
