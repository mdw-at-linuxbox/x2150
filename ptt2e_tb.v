`default_nettype none
module tb;

localparam eNL = 'h15;
localparam eSP = 'h40;
localparam e_a = 'h81;
localparam e_A = 'hc1;
localparam e_0 = 'hf0;
	reg clk;
	reg rst;

	reg [5:0] ptt;
	wire [7:0] lc_data, uc_data;

function [7:0] ptt2e;
input lc;
input [5:0] p;
if (lc)
case(p)
1: ptt2e = "1";
2: ptt2e = "2";
3: ptt2e = "3";
4: ptt2e = "4";
5: ptt2e = "5";
6: ptt2e = "6";
7: ptt2e = "7";
'o10: ptt2e = "8";
'o11: ptt2e = "9";
'o12: ptt2e = "0";
'o13: ptt2e = "";
'o20: ptt2e = "@";
'o21: ptt2e = "/";
'o22: ptt2e = "s";
'o23: ptt2e = "t";
'o24: ptt2e = "u";
'o25: ptt2e = "v";
'o26: ptt2e = "w";
'o30: ptt2e = "y";
'o31: ptt2e = "z";
'o33: ptt2e = ",";
'o40: ptt2e = "-";	// or _?
'o41: ptt2e = "j";
'o42: ptt2e = "k";
'o43: ptt2e = "l";
'o44: ptt2e = "m";
'o45: ptt2e = "n";
'o46: ptt2e = "o";
'o47: ptt2e = "p";
'o50: ptt2e = "q";
'o51: ptt2e = "r";
'o53: ptt2e = "$";
'o55: ptt2e = "\\";	// newline
'o60: ptt2e = "&";
'o61: ptt2e = "a";
'o62: ptt2e = "b";
'o63: ptt2e = "c";
'o64: ptt2e = "d";
'o65: ptt2e = "e";
'o66: ptt2e = "f";
'o67: ptt2e = "g";
'o70: ptt2e = "@";
'o71: ptt2e = "/";
'o73: ptt2e = "~";
default:
ptt2e = 0;
endcase
else
case(p)
1: ptt2e = "=";
2: ptt2e = "<";
3: ptt2e = ";";
4: ptt2e = ";";
5: ptt2e = "%";
6: ptt2e = "'";
7: ptt2e = ">";
'o10: ptt2e = "*";
'o11: ptt2e = "(";
'o12: ptt2e = ")";
'o13: ptt2e = "\"";
'o20: ptt2e = "^";	// cent
'o21: ptt2e = "?";
'o22: ptt2e = "S";
'o23: ptt2e = "T";
'o24: ptt2e = "U";
'o25: ptt2e = "V";
'o26: ptt2e = "W";
'o30: ptt2e = "Y";
'o31: ptt2e = "Z";
'o33: ptt2e = "|";
'o40: ptt2e = "-";	// or _?
'o41: ptt2e = "J";
'o42: ptt2e = "K";
'o43: ptt2e = "L";
'o44: ptt2e = "M";
'o45: ptt2e = "N";
'o46: ptt2e = "O";
'o47: ptt2e = "P";
'o50: ptt2e = "Q";
'o51: ptt2e = "R";
'o53: ptt2e = "!";
'o55: ptt2e = "\\";	// newline
'o60: ptt2e = "+";
'o61: ptt2e = "A";
'o62: ptt2e = "B";
'o63: ptt2e = "C";
'o64: ptt2e = "D";
'o65: ptt2e = "E";
'o66: ptt2e = "F";
'o67: ptt2e = "G";
'o70: ptt2e = "H";
'o71: ptt2e = "I";
'o73: ptt2e = "~";	// not
default:
ptt2e = 0;
endcase
endfunction

initial begin
$dumpfile("ptt2e.vcd");
$dumpvars(0, tb);
end

	ptt2e #(3) u0( .i_clk(clk), .i_reset(rst),
		.i_keyboard(ptt),
		.i_lower_upper_case(1'b1),
		.o_out(lc_data));

	ptt2e #(3) u1( .i_clk(clk), .i_reset(rst),
		.i_keyboard(ptt),
		.i_lower_upper_case(1'b0),
		.o_out(uc_data));

	always #1 clk = ~clk;

	integer count;

	wire [7:0] lc_ptt_2_c = ptt2e(1, ptt);
	wire [7:0] uc_ptt_2_c = ptt2e(0, ptt);

	initial begin
		{clk, rst} <= 1;

	$monitor("T=%0t ptt=%o lc=%0x (%c) uc=%0x (%c)", $time,
		ptt, lc_data, lc_ptt_2_c, uc_data, uc_ptt_2_c);

	repeat(2) @(posedge clk);
		rst <= 0;

	for (count = 0; count < 64; count = count + 1) begin
		ptt <= count;
		#2;
	end

	#30;
		$finish;

	end
endmodule
