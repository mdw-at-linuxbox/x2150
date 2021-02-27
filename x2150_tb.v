`default_nettype   none
`timescale 10ns / 1ns
module tb;
	reg clk, rst;

	localparam CSW_BIT_ATTN =31;
	localparam CSW_BIT_MOD  =30;
	localparam CSW_BIT_CUEND =29;
	localparam CSW_BIT_BUSY =28;
	localparam CSW_BIT_CHEND =27;
	localparam CSW_BIT_DVEND =26;
	localparam CSW_BIT_UC   =25;
	localparam CSW_BIT_UE   =24;

	localparam BT_DEVICE_END = (1<<CSW_BIT_DVEND-24);
	localparam BT_CHANNEL_END = (1<<CSW_BIT_CHEND-24);

	// bus and tag
	wire [8:0] bus_out;
	wire [8:0] bus_in;
	reg address_out;
	reg command_out;
	reg service_out;
	reg data_out;
	wire address_in;
	wire status_in;
	wire service_in;
/* verilator lint_off UNUSED */
	wire data_in;
	wire disc_in;
/* verilator lint_on UNUSED */
	reg operational_out;
	reg select_out;
	reg hold_out;
	reg suppress_out;
	wire operational_in;
	wire select_in;
/* verilator lint_off UNUSED */
	wire request_in;
/* verilator lint_on UNUSED */

localparam CYCLE_TIME = 15;
localparam BUSY_TIME = 35;
localparam RECOVERY = 10;
localparam SHIFT_ENGAGE = 7;
localparam SHIFT_TIME = 15;
localparam CRLF_TIME = 150;

	// 1052
	wire [6:0] tt;
	wire [4:0] fd;
	wire [1:0] misc;
	reg [6:0] keyboard;
	reg keyboard_strobe;
	reg end_of_forms_contact;
	wire rh_margin;
	reg x_1052_busy;
	reg x_1052_not_busy;
	reg request_pb;
	reg ready_pb;
	reg not_ready_pb;
	reg cemode_sw;
	reg contin_sw;
	wire [9:0] ce_state;
	wire [7:0] ce_data_reg;

	wire t1;
	wire t2;
	wire r1;
	wire r2;
	wire r2a;
	wire r5;
	wire check;
	assign {check,t1,t2,r1,r2,r2a,r5} = tt;
	wire cycle_clutch;
assign cycle_clutch = |tt;
	wire space;
	wire crlf;
	wire up_shift;
	wire down_shift;
	assign {space, crlf, up_shift, down_shift} = fd;
	wire lock_keyboard;
	wire alarm;
	assign {lock_keyboard, alarm} = misc;
	reg [7:0] bs_out;
	wire bs_out_p;
	wire [7:0] bs_in;
	wire bs_in_p;
	wire bad_parity_in;

	assign bs_out_p = (~^{bs_out} | parity_control[1]) ^ parity_control[0];

	assign bus_out = {bs_out_p, bs_out};
	assign {bs_in_p, bs_in} = bus_in;
	assign bad_parity_in = ~^{bus_in};

	reg [1:0] parity_control;

	reg [7:0] cycle_counter;
	reg [7:0] carrier_pos;
	reg [2:0] cycle_kind;
localparam KIND_PRINT = 3'd1;
localparam KIND_SHIFT = 3'd2;
localparam KIND_SPACE = 3'd3;
localparam KIND_CRLF = 3'd4;
	reg [6:0] char_pos;
localparam MAX_CHAR_POS=125-1;

reg [7:0] data_to_send [0:31];
reg [4:0] data_index, data_size;
assign data_to_send[0] = 'hc2;	// B
assign data_to_send[1] = 'h81;	// a
assign data_to_send[2] = 'h82;	// b
assign data_to_send[3] = 'ha8;	// y
assign data_to_send[4] = 'h40;	// sp
assign data_to_send[5] = 'hc9;	// I
assign data_to_send[6] = 'h40;	// sp
assign data_to_send[7] = 'h88;	// h
assign data_to_send[8] = 'h85;	// e
assign data_to_send[9] = 'h99;	// r
assign data_to_send[10] = 'h85;	// e
assign data_to_send[11] = 'h5a;	// !
//assign data_to_send[12] = 'h15;

reg [5:0] keydata[0:512];
reg [8:0] kbd_index, kbd_size;
assign keydata[0] = 'o76;	// lc
assign keydata[1] = 'o61;	// a
assign keydata[2] = 'o12;	// 0
assign keydata[3] = 'o01;	// 1
assign keydata[4] = 'o02;	// 2
assign keydata[5] = 'o03;	// 3
assign keydata[6] = 'o11;	// 9
assign keydata[7] = 'o00;	// space
assign keydata[8] = 'o16;	// uc
assign keydata[9] = 'o27;	// X
assign keydata[10] = 'o33;	// !
assign keydata[11] = 'o36;	// eob
assign keydata[12] = 'o44;	// m
assign keydata[13] = 'o71;	// i
assign keydata[14] = 'o22;	// s
assign keydata[15] = 'o40;	// -
assign keydata[16] = 'o44;	// m
assign keydata[17] = 'o71;	// i
assign keydata[18] = 'o22;	// s
assign keydata[19] = 'o40;	// cancel	special
assign keydata[20] = 'o62;	// b
assign keydata[21] = 'o61;	// a
assign keydata[22] = 'o64;	// d
assign keydata[23] = 'o47;	// p		special
assign keydata[24] = 'o61;	// a
assign keydata[25] = 'o51;	// r
assign keydata[26] = 'o71;	// i
assign keydata[27] = 'o36;	// eob
assign keydata[28] = 'o76;	// lc
assign keydata[29] = 'o73;	// .
assign keydata[30] = 'o73;	// .
assign keydata[31] = 'o73;	// .
assign keydata[32] = 'o16;	// uc
assign keydata[33] = 'o67;	// G
assign keydata[34] = 'o76;	// lc
assign keydata[35] = 'o24;	// u
assign keydata[36] = 'o64;	// d
assign keydata[37] = 'o65;	// e
assign keydata[38] = 'o40;	// -
assign keydata[39] = 'o64;	// d
assign keydata[40] = 'o61;	// a
assign keydata[41] = 'o23;	// t
assign keydata[42] = 'o61;	// a
assign keydata[43] = 'o36;	// eob
reg [8:0] max_read_data;

wire [7:0] tt_char;

	reg maybe_status = 0;
	reg do_stack_status = 0;
	reg maybe_recv_data = 0;
	reg maybe_send_data = 0;
	reg maybe_kbd_data = 0;
wire [5:0] rotate_tilt;
wire signed [4:0] rotate;
wire [1:0] tilt;
assign tilt = 2'd3-{t2,t1};
assign rotate = (((4'sd5 - 4'sd5*r5) - 4'sd2*r2) - 4'sd2*r2a) - r1;
assign rotate_tilt = {t1,t2,r1,r2,r2a,r5};
// assign rotate_tilt = {t2,t1,r1,r2a,r2,r5,up_shift,1'b0};
wire [87:0] shift_mode;
assign shift_mode = up_shift ? (down_shift ? "?shift?" : "up shift") : down_shift ? "lower shift" : "";
assign rh_margin = char_pos >= MAX_CHAR_POS;

function [7:0] tt_to_upper_case;
input [5:0] tt;
case (tt)
'h1e: tt_to_upper_case = "[";
'h36: tt_to_upper_case = "<";
'h38: tt_to_upper_case = "(";
'h0e: tt_to_upper_case = "+";
'h20: tt_to_upper_case = "!";
'h10: tt_to_upper_case = "]";
'h39: tt_to_upper_case = "*";
'h31: tt_to_upper_case = ")";
'h37: tt_to_upper_case = ";";
'h00: tt_to_upper_case = "^";
'h3b: tt_to_upper_case = "%";
'h2e: tt_to_upper_case = "_";
'h33: tt_to_upper_case = ">";
'h1f: tt_to_upper_case = "?";
'h3a: tt_to_upper_case = ":";
'h32: tt_to_upper_case = "'";
'h3f: tt_to_upper_case = "=";
'h30: tt_to_upper_case = "\"";
'h0f: tt_to_upper_case = "A";
'h06: tt_to_upper_case = "B";
'h07: tt_to_upper_case = "C";
'h0a: tt_to_upper_case = "D";
'h0b: tt_to_upper_case = "E";
'h02: tt_to_upper_case = "F";
'h03: tt_to_upper_case = "G";
'h09: tt_to_upper_case = "H";
'h08: tt_to_upper_case = "I";
'h2f: tt_to_upper_case = "J";
'h26: tt_to_upper_case = "K";
'h27: tt_to_upper_case = "L";
'h2a: tt_to_upper_case = "M";
'h2b: tt_to_upper_case = "N";
'h22: tt_to_upper_case = "O";
'h23: tt_to_upper_case = "P";
'h29: tt_to_upper_case = "Q";
'h28: tt_to_upper_case = "R";
'h16: tt_to_upper_case = "S";
'h17: tt_to_upper_case = "T";
'h1a: tt_to_upper_case = "U";
'h1b: tt_to_upper_case = "V";
'h12: tt_to_upper_case = "W";
'h13: tt_to_upper_case = "X";
'h19: tt_to_upper_case = "Y";
'h18: tt_to_upper_case = "Z";
default: tt_to_upper_case = "~";
endcase
endfunction
function [7:0] tt_to_lower_case;
input [5:0] tt;
case (tt)
'h00: tt_to_lower_case = ".";
'h0e: tt_to_lower_case = "&";
'h20: tt_to_lower_case = "$";
'h2e: tt_to_lower_case = "-";
'h1f: tt_to_lower_case = "/";
'h10: tt_to_lower_case = ",";
'h30: tt_to_lower_case = "#";
'h1e: tt_to_lower_case = "@";
'h0f: tt_to_lower_case = "a";
'h06: tt_to_lower_case = "b";
'h07: tt_to_lower_case = "c";
'h0a: tt_to_lower_case = "d";
'h0b: tt_to_lower_case = "e";
'h02: tt_to_lower_case = "f";
'h03: tt_to_lower_case = "g";
'h09: tt_to_lower_case = "h";
'h08: tt_to_lower_case = "i";
'h2f: tt_to_lower_case = "j";
'h26: tt_to_lower_case = "k";
'h27: tt_to_lower_case = "l";
'h2a: tt_to_lower_case = "m";
'h2b: tt_to_lower_case = "n";
'h22: tt_to_lower_case = "o";
'h23: tt_to_lower_case = "p";
'h29: tt_to_lower_case = "q";
'h28: tt_to_lower_case = "r";
'h16: tt_to_lower_case = "s";
'h17: tt_to_lower_case = "t";
'h1a: tt_to_lower_case = "u";
'h1b: tt_to_lower_case = "v";
'h12: tt_to_lower_case = "w";
'h13: tt_to_lower_case = "x";
'h19: tt_to_lower_case = "y";
'h18: tt_to_lower_case = "z";
'h31: tt_to_lower_case = "0";
'h3f: tt_to_lower_case = "1";
'h36: tt_to_lower_case = "2";
'h37: tt_to_lower_case = "3";
'h3a: tt_to_lower_case = "4";
'h3b: tt_to_lower_case = "5";
'h32: tt_to_lower_case = "6";
'h33: tt_to_lower_case = "7";
'h39: tt_to_lower_case = "8";
'h38: tt_to_lower_case = "9";
default: tt_to_lower_case = "|";
endcase
endfunction

assign tt_char = shift_state ? tt_to_upper_case(rotate_tilt) : tt_to_lower_case(rotate_tilt);

reg shift_state;

wire [6:0] key_data_parity;
assign key_data_parity = {
	~^{keydata[kbd_index], (kbd_index == 19 || kbd_index == 23)},
	keydata[kbd_index]};

reg lock_keyboard_delayed;
	always @(posedge clk)
		lock_keyboard_delayed <= lock_keyboard;

	always @(posedge clk) begin
		if (lock_keyboard)
			keyboard_strobe <= 0;
		if (rst) begin
		end else if (~lock_keyboard & lock_keyboard_delayed) begin
			if (kbd_index < kbd_size) begin
$display("T=%d keyboard parity.data=%o index=%d", $time, key_data_parity, kbd_index);
				keyboard <= key_data_parity;
				keyboard_strobe <= 1;
				kbd_index <= kbd_index + 1;
			end else begin
$display("T=%d keyboard unlocked, but out of data: oops?", $time);
keyboard <= 'o100;
keyboard_strobe <= 1;
			end
		end
	end
	

	always @(posedge clk) begin
		if (rst) begin
			cycle_counter <= 0;
			char_pos <= 0;
		end else if (~|cycle_counter) case ({cycle_clutch,
				up_shift, down_shift, crlf, space})
			5'b00000:
				;
			5'b10000: begin
$display("T=%d clutch start: aux=%b bits=%x tilt=%d rotate=%d char=%s", $time, check, rotate_tilt, tilt, rotate, tt_char);
				cycle_kind = KIND_PRINT;
				cycle_counter <= CYCLE_TIME + BUSY_TIME + RECOVERY;
				if (char_pos < MAX_CHAR_POS)
					char_pos <= char_pos + 1;
				end
			5'b01000,
			5'b00100: begin
if (up_shift) shift_state <= 1; else if (down_shift) shift_state <= 0;
$display("T=%d clutch start: %s", $time, shift_mode);
				cycle_kind = KIND_SHIFT;
				cycle_counter <= SHIFT_ENGAGE + SHIFT_TIME + 1;
				end
			5'b01010,
			5'b00110,
			5'b00010: begin
if (up_shift) shift_state <= 1; else if (down_shift) shift_state <= 0;
$display("T=%d clutch start: carrier return + index %s", $time, shift_mode);
				cycle_kind = KIND_CRLF;
				cycle_counter <= CYCLE_TIME + CRLF_TIME + RECOVERY;
				char_pos <= 0;
				end
			5'b01001,
			5'b00101,
			5'b00001: begin
if (up_shift) shift_state <= 1; else if (down_shift) shift_state <= 0;
$display("T=%d clutch start: space %s", $time, shift_mode);
				cycle_kind = KIND_SPACE;
				cycle_counter <= CYCLE_TIME + BUSY_TIME + RECOVERY;
				if (char_pos < MAX_CHAR_POS)
					char_pos <= char_pos + 1;
			end
			endcase
		else begin
// $display("T=%d clutch count: cycle_counter=%x", $time, cycle_counter);
			cycle_counter <= cycle_counter - 1;
			case (cycle_kind)
			KIND_PRINT: begin
			x_1052_busy <= cycle_counter == BUSY_TIME + RECOVERY;
			x_1052_not_busy <= cycle_counter == RECOVERY;
			end
			KIND_SHIFT: begin
			x_1052_busy <= cycle_counter == SHIFT_TIME+1;
			x_1052_not_busy <= cycle_counter == 1;
			end
			KIND_CRLF: begin
			x_1052_busy <= cycle_counter == CRLF_TIME + RECOVERY;
			x_1052_not_busy <= cycle_counter == RECOVERY;
			end
			KIND_SPACE: begin
			x_1052_busy <= cycle_counter == BUSY_TIME + RECOVERY;
			x_1052_not_busy <= cycle_counter == RECOVERY;
			end
			endcase
		end
	end
reg found_bad_parity;
wire sample_parity;
assign sample_parity = status_in | address_in | service_in;
	always @(posedge clk)
		if (~sample_parity)
			found_bad_parity <= 0;
		else if (~found_bad_parity & bad_parity_in) begin
			found_bad_parity <= 1;
$display("T=%d: bad parity: bus=%0x", $time, bus_in);
		end


reg saw_devend;
	always @(posedge clk)
		if (status_in & bs_in[2])
			saw_devend <= 1;

	always @(posedge clk) begin
		if (status_in) begin
$display("T=%d have status: status=%0x", $time, bs_in);
			#4 service_out <= 1;
			while (status_in)
				#2;
			#2 service_out <= 0;
		end
	end

	always @(posedge clk)
	if (maybe_status & address_in) begin
$display("T=%d about to receive status? dev=%0x", $time, bs_in);
		#4 command_out <= 1;
		#8 command_out <= 0;
		while (operational_in & ~status_in)
			#2;
		#2;
		while (status_in | service_out)
			#2 ;
		#4 hold_out <= 0;
$display("T=%d #1 done getting status", $time);
	end

	always @(posedge clk)
	if (maybe_send_data & service_in) begin
		if (data_index < data_size) begin
$display("T=%d sending data? %d,data=%0x", $time, data_index,data_to_send[data_index]);
			bs_out <= data_to_send[data_index];
			data_index <= data_index + 1;
				#4 service_out <= 1;
			while (operational_in & service_in)
				#2;
			#2 service_out <= 0;
		end else begin
$display("T=%d sending data? %d,no more data", $time, data_index);
			command_out <= 1;
			while (operational_in & service_in)
				#2;
			#2 command_out <= 0;
		end
	end

	always @(posedge clk)
	if (maybe_recv_data & service_in) begin
if (max_read_data == 1) begin
$display("T=%d recv: discard data=%0x", $time, bs_in);
	#4 command_out <= 1;
end else begin
$display("T=%d receiving data? data=%0x", $time, bs_in);
		#4 service_out <= 1;
end
max_read_data <= max_read_data - 1;
		while (operational_in & service_in)
			#2;
		#2 service_out <= 0;
		command_out <= 0;
	end

reg start_poll;
	always @(posedge clk) if (start_poll) begin
		if (request_in) begin
			hold_out <= 1;
			#8;
			while (hold_out & ~operational_in)
				#2;
			hold_out <= 0;
		end
	end
	always @(posedge clk) if (start_poll) begin
		if (address_in) begin
$display("T=%d poll: got dev=%0x", $time, bs_in);
			#4 command_out <= 1;
			#8 command_out <= 0;
			while (operational_in & ~status_in)
				#2;
			#2;
			while (status_in | service_out)
				#2 ;
			#4 hold_out <= 0;
$display("T=%d #2 done getting status", $time);
		end
	end

	always @(posedge clk) begin
		if (request_pb)
			request_pb <= 0;
		if (ready_pb)
			ready_pb <= 0;
		if (not_ready_pb)
			not_ready_pb <= 0;
	end

initial begin
$dumpfile("x2150.vcd");
$dumpvars(0, tb);
end

	x2150 u0( .i_clk(clk), .i_reset(rst),
		.i_bus_out(bus_out), .o_bus_in(bus_in),
		.i_address_out(address_out), .i_command_out(command_out),
		.i_service_out(service_out), .i_data_out(data_out),
		.o_address_in(address_in), .o_status_in(status_in),
		.o_service_in(service_in), .o_data_in(data_in),
		.o_disc_in(disc_in),
		.i_operational_out(operational_out),
		.i_select_out(select_out), .i_hold_out(hold_out),
		.i_suppress_out(suppress_out),
		.o_operational_in(operational_in),
		.o_select_in(select_in), .o_request_in(request_in),
		.o_tt(tt), .o_fd(fd), .o_misc(misc),
		.i_keyboard(keyboard),
		.i_keyboard_strobe(keyboard_strobe),
		.i_end_of_forms_contact(end_of_forms_contact),
		.i_rh_margin(rh_margin),
		.i_1052_busy(x_1052_busy),
		.i_1052_not_busy(x_1052_not_busy),
		.i_request_pb(request_pb),
		.i_ready_pb(ready_pb),
		.i_not_ready_pb(not_ready_pb),
		.i_cemode_sw(cemode_sw),
		.i_contin_sw(contin_sw),
		.o_ce_state(ce_state),
		.o_ce_data_reg(ce_data_reg));

	always #1 clk = ~clk;

	always @(posedge clk)
		select_out <= hold_out;

	initial begin
// $monitor("T=%d cycle_clutch=%b cycle_counter", $time, cycle_clutch, cycle_counter);
		{clk,rst} <= 1;

	#3 rst <= 0;


	// initial reset
$display("T=%d  -- initial reset --", $time);
	parity_control <= 0;
	bs_out <= 0;
	{address_out, command_out, service_out, data_out} <= 0;
	{operational_out, select_out, hold_out, suppress_out} <= 0;
	{keyboard, keyboard_strobe} <= 0;
	end_of_forms_contact <= 0;
	x_1052_busy <= 0;
	x_1052_not_busy <= 0;
	carrier_pos <= 0;
	start_poll <= 0;
	{request_pb, ready_pb, not_ready_pb} <= 0;
	{cemode_sw, contin_sw} <= 0;
	max_read_data <= 0;

	#2
operational_out	<= 1;
	#4
	maybe_status <= 1;
	hold_out <= 1;
	#16
	while (operational_in || address_in || status_in || service_in)
		#2 ;
	hold_out <= 0;
	bs_out <= 0;
$display("T=%d  -- push not ready pb --", $time);
	#8 not_ready_pb <= 1;
	#12 ;
	maybe_status <= 1;
	hold_out <= 1;
	#16
	while (operational_in || address_in || status_in || service_in)
		#2 ;
	hold_out <= 0;
	bs_out <= 0;
$display("T=%d  -- push ready pb --", $time);
	#8 ready_pb <= 1;
	#12 ;
	hold_out <= 1;
	#16
	while (operational_in || address_in || status_in || service_in)
		#2 ;
	maybe_status <= 0;
	hold_out <= 0;
	bs_out <= 0;
	#8
	hold_out <= 0;
	bs_out <= 0;
$display("T=%d  -- select no such device (0) --", $time);
	#8
	address_out <= 1;
	#2
	hold_out <= 1;
	#16
	address_out <= 0;
	#2
	hold_out <= 0;
	#8
	while (operational_in || address_in || status_in || service_in)
		#2 ;

	bs_out <= 9;
$display("T=%d  -- testio device=9 --", $time);
	#2
	address_out <= 1;
	#2
	hold_out <= 1;
	#16
	address_out <= 0;
	bs_out <= 0;
	#6
	command_out <= 1;
	#6
	command_out <= 0;
	#4
	while (~status_in)
		#2 ;
	#2 ;
	service_out <= 1;
	#2 ;
	while (status_in)
		#2 ;
	#2
	service_out <= 0;
	#8
	hold_out <= 0;
	#8
	while (operational_in || address_in || status_in || service_in)
		#2 ;

saw_devend <= 0;
$display("T=%d  -- write device=9 --", $time);
	bs_out <= 9;
	#2
	address_out <= 1;
	#2
	hold_out <= 1;
	#16
	address_out <= 0;
//	bs_out <= 'h1;		// write-icr
	bs_out <= 'h9;		// write-acr
	#6
	command_out <= 1;
	#6
	command_out <= 0;
	bs_out <= 0;
	#4
	while (~status_in)
		#2 ;
	#2 ;
	service_out <= 1;
	#2 ;
	while (status_in)
		#2 ;
	#2
	service_out <= 0;
	maybe_send_data <= 1;
	data_index <= 0;
	data_size <= 12;
	#2 ;
	while (~status_in)
		#2 ;
	#8
	hold_out <= 0;
	#8
	while (~saw_devend) begin
		if (request_in) begin
			maybe_status <= 1;
			hold_out <= 1;
			#8;
			if (hold_out & ~operational_in)
				hold_out <= 0;
		end else #2 ;
	end
	maybe_send_data <= 0;
	while (operational_in || address_in || status_in || service_in)
		#2 ;

saw_devend <= 0;
$display("T=%d  -- no-op device=9 --", $time);
	bs_out <= 9;
	#2
	address_out <= 1;
	#2
	hold_out <= 1;
	#16
	address_out <= 0;
	bs_out <= 'h3;		// no-op
	#6
	command_out <= 1;
	#6
	command_out <= 0;
	bs_out <= 0;
	#4
	while (~status_in)
		#2 ;
	#2 ;
	service_out <= 1;
	#2 ;
	while (status_in)
		#2 ;
	#2
	service_out <= 0;
	#8
	hold_out <= 0;
	#8
	if (~saw_devend)
$display("*** T=%d  no-op waiting for devend", $time);
	#2
	while (~saw_devend)
		if (request_in) begin
			maybe_status <= 1;
			hold_out <= 1;
			#8;
			if (hold_out & ~operational_in)
				hold_out <= 0;
		end else #2 ;
	while (operational_in || address_in || status_in || service_in)
		#2 ;

saw_devend <= 0;
$display("T=%d  -- alarm device=9 --", $time);
	bs_out <= 9;
	#2
	address_out <= 1;
	#2
	hold_out <= 1;
	#16
	address_out <= 0;
	bs_out <= 'hb;		// alarm
	#6
	command_out <= 1;
	#6
	command_out <= 0;
	bs_out <= 0;
	#4
	while (~status_in)
		#2 ;
	#2 ;
	service_out <= 1;
	#2 ;
	while (status_in)
		#2 ;
	#2
	service_out <= 0;
	maybe_send_data <= 1;
	#8
	while (~saw_devend)
		#2 ;
	hold_out <= 0;
	maybe_send_data <= 0;
//	while (operational_in || address_in || status_in || service_in)
//		#2 ;
	while (alarm)
		#2 ;

$display("T=%d  -- illegal command(73) device=9 --", $time);
	bs_out <= 9;
	#2
	address_out <= 1;
	#2
	hold_out <= 1;
	#16
	address_out <= 0;
	bs_out <= 'h73;	// illegal control command
	#6
	command_out <= 1;
	#6
	command_out <= 0;
	#4
	while (~status_in)
		#2 ;
	#2 ;
	service_out <= 1;
	#2 ;
	while (status_in)
		#2 ;
	#2
	service_out <= 0;
	#8
	hold_out <= 0;
	#8
	while (operational_in || address_in || status_in || service_in)
		#2 ;

$display("T=%d  -- sense device=9 --", $time);
	saw_devend <= 0;
	bs_out <= 9;
	#2
	address_out <= 1;
	#2
	hold_out <= 1;
	#16
	address_out <= 0;
	bs_out <= 'h4;		// sense
	#6
	command_out <= 1;
	hold_out <= 0;
	#6
	command_out <= 0;
	bs_out <= 0;
	#4
	while (~status_in)
		#2 ;
	#2 ;
	service_out <= 1;
	#2 ;
	while (status_in)
		#2 ;
	#2
	service_out <= 0;
	maybe_recv_data <= 1;
	#8
	#2
	while (~saw_devend)
		if (request_in) begin
			maybe_status <= 1;
			hold_out <= 1;
			#8;
			if (hold_out & ~operational_in)
				hold_out <= 0;
		end else #2 ;
	while (operational_in || address_in || status_in || service_in)
		#2 ;
	#8
$display("T=%d  -- unsolicited poll --", $time);
	hold_out <= 1;
	maybe_status <= 1;
	#30;
	if (hold_out & ~operational_in)
		hold_out <= 0;
	#10 ;
	maybe_status <= 0;
	#10 ;

saw_devend <= 0;
$display("T=%d  -- read device=9 / eob --", $time);
	max_read_data <= 20;
	kbd_index <= 0;
	kbd_size <= 12;
	bs_out <= 9;
	#2
	address_out <= 1;
	#2
	hold_out <= 1;
	#16
	address_out <= 0;
	bs_out <= 'ha;		// read
	#6
	command_out <= 1;
	#6
	command_out <= 0;
	bs_out <= 0;
	#4
	while (~status_in)
		#2 ;
	#2 ;
	service_out <= 1;
	#2 ;
	while (status_in)
		#2 ;
	#2
	service_out <= 0;
	maybe_kbd_data <= 1;
	maybe_recv_data <= 1;
	data_index <= 0;
	data_size <= 12;
	#2 ;
start_poll <= 1;
	hold_out <= 0;
	#2;
	#8
	while (~saw_devend) begin
		#2 ;
	end
	maybe_recv_data <= 0;
	maybe_kbd_data <= 0;
	while (operational_in || address_in || status_in || service_in)
		#2 ;

	start_poll <= 0;
	#30 ;

saw_devend <= 0;
$display("T=%d  -- read device=9 / count termination", $time);
	max_read_data <= 5;
kbd_index <= 12;
kbd_size = 19;
	bs_out <= 9;
	#2
	address_out <= 1;
	#2
	hold_out <= 1;
	#16
	address_out <= 0;
	bs_out <= 'ha;		// read
	#6
	command_out <= 1;
	#6
	command_out <= 0;
	bs_out <= 0;
	#4
	while (~status_in)
		#2 ;
	#2 ;
	service_out <= 1;
	#2 ;
	while (status_in)
		#2 ;
	#2
	service_out <= 0;
	maybe_kbd_data <= 1;
	maybe_recv_data <= 1;
	data_index <= 0;
	data_size <= 12;
	#2 ;
start_poll <= 1;
	hold_out <= 0;
	#2;
	#8
	while (~saw_devend) begin
		#2 ;
	end
	maybe_recv_data <= 0;
	maybe_kbd_data <= 0;
	while (operational_in || address_in || status_in || service_in)
		#2 ;

	start_poll <= 0;
	#30 ;

$display("T=%d  -- sense device=9 --", $time);
	saw_devend <= 0;
	bs_out <= 9;
	#2
	address_out <= 1;
	#2
	hold_out <= 1;
	#16
	address_out <= 0;
	bs_out <= 'h4;		// sense
	#6
	command_out <= 1;
	hold_out <= 0;
	#6
	command_out <= 0;
	bs_out <= 0;
	#4
	while (~status_in)
		#2 ;
	#2 ;
	service_out <= 1;
	#2 ;
	while (status_in)
		#2 ;
	#2
	service_out <= 0;
	maybe_recv_data <= 1;
	#8
	#2
	while (~saw_devend)
		if (request_in) begin
			maybe_status <= 1;
			hold_out <= 1;
			#8;
			if (hold_out & ~operational_in)
				hold_out <= 0;
		end else #2 ;
	while (operational_in || address_in || status_in || service_in)
		#2 ;
	#8


saw_devend <= 0;
$display("T=%d  -- read device=9 / cancel --", $time);
	max_read_data <= 5;
kbd_index <= 16;
kbd_size = 20;
	bs_out <= 9;
	#2
	address_out <= 1;
	#2
	hold_out <= 1;
	#16
	address_out <= 0;
	bs_out <= 'ha;		// read
	#6
	command_out <= 1;
	#6
	command_out <= 0;
	bs_out <= 0;
	#4
	while (~status_in)
		#2 ;
	#2 ;
	service_out <= 1;
	#2 ;
	while (status_in)
		#2 ;
	#2
	service_out <= 0;
	maybe_kbd_data <= 1;
	maybe_recv_data <= 1;
	data_index <= 0;
	data_size <= 12;
	#2 ;
start_poll <= 1;
	hold_out <= 0;
	#2;
	#8
	while (~saw_devend) begin
		#2 ;
	end
	maybe_recv_data <= 0;
	maybe_kbd_data <= 0;
	while (operational_in || address_in || status_in || service_in)
		#2 ;

	start_poll <= 0;
	#30 ;

$display("T=%d  -- sense device=9 --", $time);
	saw_devend <= 0;
	bs_out <= 9;
	#2
	address_out <= 1;
	#2
	hold_out <= 1;
	#16
	address_out <= 0;
	bs_out <= 'h4;		// sense
	#6
	command_out <= 1;
	hold_out <= 0;
	#6
	command_out <= 0;
	bs_out <= 0;
	#4
	while (~status_in)
		#2 ;
	#2 ;
	service_out <= 1;
	#2 ;
	while (status_in)
		#2 ;
	#2
	service_out <= 0;
	maybe_recv_data <= 1;
	#8
	#2
	while (~saw_devend)
		if (request_in) begin
			maybe_status <= 1;
			hold_out <= 1;
			#8;
			if (hold_out & ~operational_in)
				hold_out <= 0;
		end else #2 ;
	while (operational_in || address_in || status_in || service_in)
		#2 ;
	#8


saw_devend <= 0;
$display("T=%d  -- read device=9 / bad parity", $time);
	max_read_data <= 9;
kbd_index <= 20;
kbd_size = 28;
	bs_out <= 9;
	#2
	address_out <= 1;
	#2
	hold_out <= 1;
	#16
	address_out <= 0;
	bs_out <= 'ha;		// read
	#6
	command_out <= 1;
	#6
	command_out <= 0;
	bs_out <= 0;
	#4
	while (~status_in)
		#2 ;
	#2 ;
	service_out <= 1;
	#2 ;
	while (status_in)
		#2 ;
	#2
	service_out <= 0;
	maybe_kbd_data <= 1;
	maybe_recv_data <= 1;
	data_index <= 0;
	data_size <= 12;
	#2 ;
start_poll <= 1;
	hold_out <= 0;
	#2;
	#8
	while (~saw_devend) begin
		#2 ;
	end
	maybe_recv_data <= 0;
	maybe_kbd_data <= 0;
	while (operational_in || address_in || status_in || service_in)
		#2 ;

	start_poll <= 0;
	#30 ;

$display("T=%d  -- sense device=9 --", $time);
	saw_devend <= 0;
	bs_out <= 9;
	#2
	address_out <= 1;
	#2
	hold_out <= 1;
	#16
	address_out <= 0;
	bs_out <= 'h4;		// sense
	#6
	command_out <= 1;
	hold_out <= 0;
	#6
	command_out <= 0;
	bs_out <= 0;
	#4
	while (~status_in)
		#2 ;
	#2 ;
	service_out <= 1;
	#2 ;
	while (status_in)
		#2 ;
	#2
	service_out <= 0;
	maybe_recv_data <= 1;
	#8
	#2
	while (~saw_devend)
		if (request_in) begin
			maybe_status <= 1;
			hold_out <= 1;
			#8;
			if (hold_out & ~operational_in)
				hold_out <= 0;
		end else #2 ;
	while (operational_in || address_in || status_in || service_in)
		#2 ;
	#8

saw_devend <= 0;
$display("T=%d  -- read device=9 / good parity --", $time);
	max_read_data <= 15;
kbd_index <= 28;
kbd_size = 44;
	bs_out <= 9;
	#2
	address_out <= 1;
	#2
	hold_out <= 1;
	#16
	address_out <= 0;
	bs_out <= 'ha;		// read
	#6
	command_out <= 1;
	#6
	command_out <= 0;
	bs_out <= 0;
	#4
	while (~status_in)
		#2 ;
	#2 ;
	service_out <= 1;
	#2 ;
	while (status_in)
		#2 ;
	#2
	service_out <= 0;
	maybe_kbd_data <= 1;
	maybe_recv_data <= 1;
	data_index <= 0;
	data_size <= 12;
	#2 ;
start_poll <= 1;
	hold_out <= 0;
	#2;
	#8
	while (~saw_devend) begin
		#2 ;
	end
	maybe_recv_data <= 0;
	maybe_kbd_data <= 0;
	while (operational_in || address_in || status_in || service_in)
		#2 ;

	start_poll <= 0;
	#30 ;

$display("T=%d  -- sense device=9 --", $time);
	saw_devend <= 0;
	bs_out <= 9;
	#2
	address_out <= 1;
	#2
	hold_out <= 1;
	#16
	address_out <= 0;
	bs_out <= 'h4;		// sense
	#6
	command_out <= 1;
	hold_out <= 0;
	#6
	command_out <= 0;
	bs_out <= 0;
	#4
	while (~status_in)
		#2 ;
	#2 ;
	service_out <= 1;
	#2 ;
	while (status_in)
		#2 ;
	#2 ;
	service_out <= 0;
	#8 ;
	maybe_recv_data <= 1;
	#2 ;
	while (~saw_devend)
		if (request_in) begin
			maybe_status <= 1;
			hold_out <= 1;
			#8;
			if (hold_out & ~operational_in)
				hold_out <= 0;
		end else #2 ;
	while (operational_in || address_in || status_in || service_in)
		#2 ;
	#8
$display("T=%d  -- final poll --", $time);
	hold_out <= 1;
	maybe_status <= 1;
	#30;
	if (hold_out & ~operational_in)
		hold_out <= 0;

	#30 $finish;
	end
endmodule
