// from SY22-2909-2_1052_Adapter_and_2150_Console_FETOP_Jan69.pdf
// also see 7201-FEMDM-S6-SX.pdf pages 6-28 thru 6-33 [pdf 30-35]
`default_nettype   none
module x2150(i_clk, i_reset,
	i_bus_out, o_bus_in,
	i_address_out, i_command_out, i_service_out, i_data_out,
	o_address_in, o_status_in, o_service_in, o_data_in, o_disc_in,
	i_operational_out, i_select_out, i_hold_out, i_suppress_out,
	o_operational_in, o_select_in, o_request_in,
	o_tt, o_fd, o_misc,
	i_keyboard,
	i_keyboard_strobe,
	i_end_of_forms_contact,i_rh_margin,i_1052_busy,i_1052_not_busy,
	i_request_pb,i_ready_pb,i_not_ready_pb,
	i_cemode_sw,
	i_contin_sw,
	o_ce_state,
	o_ce_data_reg);

input wire i_clk;
input wire i_reset;

	input wire [8:0] i_bus_out;
	output wire [8:0] o_bus_in;
	input wire i_address_out;
	input wire i_command_out;
	input wire i_service_out;
	input wire i_data_out;
	output wire o_address_in;
	output wire o_status_in;
	output wire o_service_in;
	output wire o_data_in;
	output wire o_disc_in;
	input wire i_operational_out;
	input wire i_select_out;
	input wire i_hold_out;
	input wire i_suppress_out;
	output wire o_operational_in;
	output wire o_select_in;
	output wire o_request_in;

wire request_in;	// XXX sort this out and make it disappear

output wire [6:0] o_tt;
output wire [4:0] o_fd;
output wire [1:0] o_misc;
input [6:0] i_keyboard;
input wire i_keyboard_strobe;
input wire i_end_of_forms_contact;
input wire i_rh_margin;
input wire i_1052_busy;
input wire i_1052_not_busy;
input wire i_request_pb;
input wire i_ready_pb;
input wire i_not_ready_pb;

input wire i_cemode_sw;	// 0=online
input wire i_contin_sw;	// 1=continuous write
output wire [9:0] o_ce_state;
output wire [7:0] o_ce_data_reg;

// pg021
parameter MYADDRESS = 8'h09;

parameter CE_EMIT_1 = 8'hF0;	// ebcdic '0'
parameter CE_EMIT_2 = 8'hC1;	// ebcdic 'A'

parameter DELAY = 1;
parameter TIMEOUT_700NS = 7;
parameter TIMEOUT_200NS = 2;
parameter TIMEOUT_500NS = 5;
parameter TIMEOUT_28MS = 280;
parameter TIMEOUT_20MS = 200;

reg [7:0] bus_in;
wire bus_in_p;
wire [7:0] bus_out;
wire bus_out_p;
wire [8:0] my_address = {~^{MYADDRESS}, MYADDRESS};

assign bus_out = i_bus_out[7:0];
assign bus_out_p = i_bus_out[8];

wire select_out = i_select_out & i_hold_out & ~ce_mode;
// pg021
wire address_match = i_bus_out == my_address;
wire x_address_match_and_address_out = address_match & i_address_out;
wire gen_sel_io_disc_reset;
wire not_busy;
wire status_conditions;
wire reset_device_end_and_busy;
wire gen_sel_initial_reset;
wire turn_on_device_end;
wire turn_on_stop_busy_and_channel_end;
wire eob;
wire cancel;
wire not_end_of_line;		// XXX used but never set
wire not_end_of_line_latch;	// XXX used but never set
wire end_of_line_contact;	// XXX used but never set
wire end_of_line_latch;		// XXX used but never set
wire status_in_tag_delay;
wire gen_or_selective_reset;
wire status_in_and_service_out;
wire lower_case_character;
wire upper_case_character;

wire o_t1;
wire o_t2;
wire o_r1;
wire o_r2;
wire o_r2a;
wire o_r5;
wire o_cycle_clutch;
wire o_space;
wire o_crlf;
wire o_up_shift;
wire o_down_shift;
wire o_lock_keyboard;
wire o_alarm;
wire o_check;

assign o_tt = {o_check, o_t1, o_t2, o_r1, o_r2, o_r2a, o_r5};
assign o_fd = {o_cycle_clutch, o_space, o_crlf, o_up_shift, o_down_shift};
assign o_misc = {o_lock_keyboard, o_alarm};

wire i_keyboard_c;
assign i_keyboard_c = i_keyboard[6];

//////// not shown, reconstruction (ie guess-work)

wire select_in;
latch1 u_select_in(i_clk,
	~(operational_in_tgr | ~select_out) &
		(~(x_address_match_and_address_out | request_in)),
	~i_hold_out | i_reset,
	select_in);
assign o_select_in = ce_mode ? i_select_out : select_in;

assign gen_sel_init_reset = ~i_operational_out & ~i_suppress_out;
assign gen_sel_initial_reset = gen_sel_init_reset;
assign gen_or_selective_reset = gen_sel_init_reset;
assign not_busy = not_1052_busy;
assign service_in = service_in_tgr;
assign turns_on_service_in = turn_on_service_in;
assign not_busy_or_stop = ~(busy_latch | stop);
assign not_end_of_line_latch = ~end_of_line_latch;
assign sample_comp_check = sample_compare_check;
assign o_cycle_clutch = cycle_time & ~x_function & ~stop;	// or is this "aux"?
assign o_up_shift = pick_funct_magnets[0];
assign o_down_shift = pick_funct_magnets[1];
assign o_crlf = pick_funct_magnets[3];
assign o_space = pick_funct_magnets[4] | (sp & x_function & cycle_time);
assign o_alarm = pick_bell_relay;
assign end_of_line_latch = eol;
assign not_end_of_line = not_end_of_line_latch;
assign end_of_line_contact = i_rh_margin;
assign reset_device_end_and_busy = reset_device_end_stored & busy_condition;
assign status_in_tag_delay = status_in_tag_delayed;
assign status_in_and_service_out = status_in_tag_delayed & i_service_out;
assign eob = (i_keyboard == 7'o136) & i_keyboard_strobe;
assign cancel = (i_keyboard == 7'o140) & i_keyboard_strobe;
// assign keyboard_strobe = i_keyboard_strobe & ~eob & ~cancel;
assign keyboard_strobe = i_keyboard_strobe;
assign rd_wr = (read | write) & ~command_reset;

// experimental short-cuts for now:
assign tn_cycle_time = 0;
assign read_gate = 0;
assign alternate_coding = 0;
// pg631
assign o_lock_keyboard = ~read | printer_busy | ~not_busy_or_stop | initial_sel_tgr;
wire proceed;
latch1 u_proceed(i_clk,
	(read & initial_sel_tgr) | (read & service_in_and_service_out),
	~not_busy_or_stop | gen_or_selective_reset,
	proceed);
//assign o_lock_keyboard = ~proceed;

// later evolutions of bus & tag:
assign o_data_in = 0;
assign o_disc_in = 0;

//////// page 64
//////// figure md-2 (i/o op) initial selection-read, write, sense
// objectives:
// 1 match address-out byte with internally plugged address.
// 2 raise operational-in
// 3 raise address-in and gate address byte to bus-in lines
//	when address-out falls
// 4 set command latches and drop address-in when command-out delay rises
// 5 raise status-in and gate status-byte to bus-in lines when
//	command-out falls
// 6 drop operational-in and status-in when service-out rises

// pg101
wire address_in_tgr;
latch1 u_address_in_tgr(i_clk,
	(~operational_in_tgr &			// guess-fix
		(x_address_match_and_address_out & select_out)
			| (select_out & ~i_address_out & request_in)),
		(command_out_delay | i_reset),
	address_in_tgr);

// pg101
wire initial_sel_tgr;
latch1 u_initial_sel_tgr(i_clk,
(x_address_match_and_address_out),
((gate_status_in & i_command_out) |
	service_out_delay |
	gen_sel_io_disc_reset),
initial_sel_tgr);

// pg012
wire service_out_delay;
delay1 #(DELAY) u_service_out(i_clk, i_reset,
	i_service_out & operational_in_tgr, service_out_delay);

// pg101
wire operational_in_tgr;
latch1 u_operational_in_tgr(i_clk,
	(address_in_tgr & ~o_select_in & i_select_out),
	((~i_select_out & ~address_in_tgr & ~status_in_tgr
	& ~o_service_in & ~oper_in_intlk) | gen_sel_io_disc_reset),
	operational_in_tgr);
assign o_operational_in = operational_in_tgr;

wire gate_address_in;
assign gate_address_in = ~i_address_out & address_in_tgr & operational_in_tgr;

wire [8:0] address_in_byte;
assign address_in_byte = my_address & {9{gate_address_in & operational_in_tgr}};

assign o_address_in = gate_address_in & operational_in_tgr;

wire command_out;
assign command_out = i_command_out & operational_in_tgr;

// pg012
wire command_out_delay;
delay1 #(DELAY) u_command_out(i_clk, i_reset,
	command_out, command_out_delay);

// pg101
wire oper_in_intlk;
latch1 u_oper_in_intlk(i_clk,
	(command_out & address_in_tgr),
	(gen_or_selective_reset | status_in_tgr |
			(~sense_command & service_in_and_service_out)),
	oper_in_intlk);

wire command_gate;
assign command_gate = command_out & address_in_tgr & initial_sel_tgr & not_bus_out_parity_error;

wire sense_gate;
assign sense_gate = command_gate & not_busy & valid_command;
wire write_gate;
assign write_gate = sense_gate & ready;

wire x_write_gate_command;
assign x_write_gate_command = write_gate & write_command_bits;

// pg111
wire service_request;
latch1 u_service_request(i_clk,
	(((sense_command_bits & valid_command) | x_write_gate_command)
		| turn_on_service_in),
	((command_or_service_out & service_in_tgr) |
		gen_sel_io_disc_reset),
	service_request);

// pg641
wire turn_on_service_in;
assign turn_on_service_in =
	| (ss_7 & ~shift_change & keyboard_strobe & ~stop)
	| (ss_6 &
		~shift_change &	// XXX not in ild; may be necessary
		not_end_of_line & write & not_busy_or_stop & not_serv_in_and_serv_out)
	| sample_compare_check;

// pg151
wire write_command;
latch1 u_write_command(i_clk,
	x_write_gate_command,
	command_reset,
	write_command);

// pg141
wire not_0123;
assign not_0123 = ~|bus_out[7:4];
wire valid_command;
assign valid_command = not_0123 & ((~bus_out[3]
& bus_out[2]	// guess: don't match this: it makes testio illegal
		& ~bus_out[1] & ~bus_out[0]) |
	(bus_out[3] & ~bus_out[2] & bus_out[1]) |
	(~bus_out[2] & bus_out[0]));
wire write_command_bits;
wire read_command_bits;
wire sense_command_bits;
wire testio_command_bits;

// pg141
assign write_command_bits = ~bus_out[1] & bus_out[0];
assign read_command_bits = bus_out[1] & ~bus_out[0];
assign sense_command_bits = ~bus_out[1] & ~bus_out[0];
// pg141
assign testio_command_bits = ~bus_out[3] & ~bus_out[2] &
	sense_command_bits & command_gate & not_0123;

// pg151
wire read_command;
latch1 u_read_command(i_clk,
	read_command_bits & sense_gate,
	command_reset,
	read_command);

// pg151
wire sense_command;
latch1 u_sense_command(i_clk,
	sense_command_bits & sense_gate,
	command_reset,
	sense_command);

wire testio;
latch1 u_testio(i_clk,
	testio_command_bits,
	~initial_sel_tgr,
	testio);

wire x_oper_ncs_nai;
assign x_oper_ncs_nai = operational_in_tgr & ~command_or_service_out & ~address_in_tgr;

wire gate_status_in;
// pg111
wire status_in_tgr;
latch1 u_status_in_tgr(i_clk,
	(initial_sel_tgr & x_oper_ncs_nai) |
		(x_oper_ncs_nai & ~service_in_tgr & status_conditions),
	~operational_in_tgr | cmd_or_serv_out_delay,
	status_in_tgr);
assign gate_status_in = status_in_tgr;

assign o_status_in = operational_in_tgr & gate_status_in;

wire [7:0] status_byte;
// XXX gate_sense_in not shown or'd in here, but I don't see how
// else the sense data could work.
assign status_byte = status_bit_lines & {8{gate_status_in | gate_sense_in}};

//////// page 65:
//////// figure md-3 (i/o op) data transfer--write
// objectives:
// 1 raise request-in:
//   a immediately after initial selection (service requet latch, figure md-2)
//   b when the printer has finished printing the previous character, or
//	when the printer has finished performing the function defined by
//	the previous character (service request latch, figure md-2)
// 2 raise service-in when command-out indicates "proceed"
// 3 start read/write clock and gate bus out lines to data registers when
//	service-out rises
// 4 repeat, starting with 1b, and continue until the command-out line
//	indicates "stop"

// XXX how does this compare with "o_request_in" on page 66?
//assign request_in = ~((~operational_in_tgr & address_in_tgr &
//			~o_request_in & i_select_out) |
//		(i_select_out & ce_mode)) &
//	~i_address_out & ~operational_in_tgr &
//	(~i_suppress_out & (status_stacked |
//		channel_end | attention_interrupt));
assign request_in = ~((~operational_in_tgr & address_in_tgr &
			~o_request_in & i_select_out) |
		(i_select_out & ce_mode)) &
	~i_address_out & ~operational_in_tgr &
	(status_conditions | service_request);

// pg121
wire busy_condition;
latch1 u_busy_condition(i_clk,
	(((write_command | read_command | sense_command) &
			~initial_sel_tgr) |
		attention_status | turn_on_device_end |
		turn_on_stop_busy_and_channel_end),
	reset_device_end_and_busy | gen_sel_initial_reset,
	busy_condition);

// pg641
wire turn_off_service_in;
assign turn_off_service_in = ss_2 & ~printer_busy & write & ~stop;

// pg111
wire service_in_tgr;
latch1 u_service_in_tgr(i_clk,
	(operational_in_tgr & ~address_in_tgr & ~command_or_service_out)
		& busy_condition & service_request,
	(command_out & service_in) |
		(service_in & ~write_command & i_service_out) |
		gen_sel_io_disc_reset | turn_off_service_in,
	service_in_tgr);

wire service_in_and_service_out;
wire not_serv_in_and_serv_out;
wire service_response;
wire command_or_service_out;
assign service_in_and_service_out = o_service_in & i_service_out;
assign not_serv_in_and_serv_out = ~service_in_and_service_out;
// assign service_response = service_in_and_service_out;	// more complex on page 15
assign command_or_service_out = i_service_out | i_command_out;

assign o_service_in = service_in_tgr & operational_in_tgr;

wire cmd_or_serv_out_delay;
delay1 #(DELAY) u_cmd_or_serv(i_clk, i_reset,
	command_or_service_out, cmd_or_serv_out_delay);

//////// page 66:
//////// figure md-4 (i/o op) ending sequence
// objectives:
// 1 set stop and channel end latches when command-out indicates "stop"
// 2 start the read/write clock if the carrier is to be returned
// 3 set store device and latch when carrier is through moving (returning)
// 4 set device end latch:
//   a at the same time as the channel end latch if the carrier is not
//	to be returned
//   b after channel end status has been accepted by the channel,
//	and the carrier finishes returning
// 5 raise request-in for any pending status interrupt conditions
// 6 set channel end and device end latches during initial selection for
//	either control command
// 7 set channel end and device end latches during sense byte transfer
//	for sense command

wire write_read_turn_on_channel_end;
wire reset_device_end_stored;
wire device_end_interrupt;
wire control_alarm;
wire pick_bell_relay;
wire control;

// pg621
ss2 #(1) u_ready_ss(i_clk, i_reset, ready, ready_ss);
// pg621
ss2 #(TIMEOUT_20MS) u_bell(i_clk, i_reset, control_alarm, pick_bell_relay);

assign turn_on_stop_busy_and_channel_end = ~i_select_out & i_address_out & operational_in_tgr;
assign write_read_turn_on_channel_end = (i_command_out & service_in) |
	eob | cancel;
// fails to assert comand_reset if status_in is not delayed here.
// assign reset_device_end_stored = device_end_latch & status_in_tgr;
assign reset_device_end_stored = device_end_latch & status_in_tag_delayed;

// pg161
wire haltio;
latch1 u_haltio(i_clk,
	turn_on_stop_busy_and_channel_end,
	~i_address_out,
	haltio);

// pg131
wire channel_end;
latch1 u_channel_end(i_clk,
	(sense_command & service_in_and_service_out) |
		control |
		turn_on_stop_busy_and_channel_end |
		turn_on_stop_busy_and_channel_end |
		write_read_turn_on_channel_end,
	gen_or_selective_reset | status_in_and_service_out,
	channel_end);

// pg121
wire stop;
latch1 u_stop(i_clk,
	write_read_turn_on_channel_end | turn_on_stop_busy_and_channel_end,
	gen_sel_init_reset | reset_device_end_stored,
	stop);

assign status_conditions = (channel_end & ~status_stacked) |
	(~i_suppress_out & status_stacked) |
	device_end_interrupt | attention_interrupt;

// XXX how does this compare with "request_in" on page 65?
//assign o_request_in = (status_conditions | service_request) &
//	~i_address_out & ~i_suppress_out & ~o_select_in
//	& ~operational_in_tgr;
assign o_request_in = request_in;

// pg641
assign turn_on_device_end = stop & not_1052_busy &
	inhibit_carrier_return & ~printer_busy;

// (busy-condition also shown on page 65)

wire busy_bit;
assign busy_bit = busy_condition & initial_sel_tgr &
	~(testio &
		(attention_status | device_end | channel_end | status_stacked));

// pg621
wire store_dev_end;
latch1 u_store_dev_end(i_clk,
	turn_on_device_end | ready_ss,
	gen_sel_init_reset | reset_device_end_stored,
	store_dev_end);

assign device_end_interrupt = store_dev_end & ~status_in_tgr & ~status_stacked;
assign control = sense_gate & bus_out[1] & bus_out[0];

// pg131
wire device_end_latch;
latch1 u_device_end_latch(i_clk,
	device_end_interrupt | (sense_command & service_in_and_service_out) | control,
	gen_sel_init_reset | reset_device_end_stored,
	device_end_latch);
wire device_end;
assign device_end = device_end_latch;

assign control_alarm = control & bus_out[3];

wire u1052_busy;
wire not_1052_busy;

// pg641
wire busy_latch;
latch1 u_busy_latch(i_clk,
	i_1052_busy,
	i_1052_not_busy | i_reset,	// hack
	busy_latch);
assign u1052_busy = busy_latch;
assign not_1052_busy = ~busy_latch;

// pg641
wire eol;
latch1 u_eol(i_clk,
	busy_latch & i_rh_margin,
	gen_sel_init_reset | (i_1052_busy & carrier_return_latch),
	eol);

// pg631
wire carrier_return_latch;
latch1 u_carrier_return_latch(i_clk,
	(stop & ~inhibit_carrier_return_latch & not_1052_busy) |
		(eol & not_1052_busy),
	gen_sel_init_reset | (~i_rh_margin & ss_6),
	carrier_return_latch);
wire carrier_return;
assign carrier_return = carrier_return_latch;

// pg641
wire printer_busy;
latch1 u_printer_busy(i_clk,
	cycle_time & ~ss_2,
	(ss_4 & read & ~end_of_line_contact) |
		(ss_6 & ~shift_change) |
		gen_sel_init_reset,
	printer_busy);

//// XXX needs more
wire lower_upper_case;
latch1 u_lower_upper_case(i_clk,
	(carrier_return & stop) | (1'b0),
	gen_or_selective_reset | ss_4,	// XXX a guess
	lower_upper_case);

// pg161
wire command_reset;
assign command_reset = gen_sel_init_reset | (device_end &
	gate_status_in & status_in_tag_delayed);

// pg641
wire inhibit_carrier_return_latch;
latch1 u_inhibit_carrier_return_latch(i_clk,
	(carrier_return_latch & stop & printer_busy) |
		(~bus_out[3] & write_gate),
	command_reset,
	inhibit_carrier_return_latch);
wire inhibit_carrier_return;
assign inhibit_carrier_return = inhibit_carrier_return_latch;

// pg121
wire status_stacked;
latch1 u_status_stacked(i_clk,
	i_command_out & status_in_tgr,
	gen_or_selective_reset | status_in_and_service_out,
	status_stacked);

wire selective_reset;
wire general_reset;
wire gen_sel_reset;
wire gen_sel_reset_1;
assign selective_reset = operational_in_tgr & i_suppress_out & ~i_operational_out;
assign general_reset = (operational_in_tgr & ~i_suppress_out & ~i_operational_out) | i_reset;
assign gen_sel_reset_1 = selective_reset | general_reset | ce_reset;
assign gen_sel_io_disc_reset = haltio | gen_sel_reset_1;
assign gen_sel_reset = gen_sel_reset_1 & not_ce_mode;
//////// page 67:
//////// figure md-5 (i/o op) data transfer--read
// objectives:
// 1 start read/write clock at ss 5 when a key is operated
// 2 gate keyboard translator output to data register
// 3 raise request-in
// 4 raise operational-in and address-in, gate address byte to
//	bus-in lines
// 5 raise service-in and gate data register output to bus-in lines
//	when comand-out falls
// 6 start read/write clock at cycle time (to operate printer) when channel
//	accepts data byte replying service-out to service-in

//////// page 68
//////// figure md-6 (i/o op) sense and status bytes
// objectives:
// 1 set equipment check latch if:
//   a printer tilt/rotate parity disagrees with keyboard parity
//	bit during a read command;
//   b keyboard output parity is not odd parity;
//   c printer fails to take a mechanical cycle when directed to
//	print, up- or down-shift, tab, space, or backspace
// 2 set unit check latch when status-in trigger is on for any of
//	following conditions:
//   a equipment check latch is on
//   b ready latch is not on
//   c command reject latch is on
//   d bus-out check latch is on (even parity byte on bus-out lines)

wire x_tilt_rotate_parity;
wire x_keyboard_parity;
wire sample_compare_check;
wire aux_magnet;
wire reset_sense_bytes;
// this is never true at sample compare time:
// assign x_tilt_rotate_parity = ^{o_r1, o_r2, o_r2a, o_r5, o_t1, o_t2};
assign x_tilt_rotate_parity = ^tt_out;

assign x_keyboard_parity = ^{~i_keyboard[6], i_keyboard[5:0]};
assign sample_compare_check = ss_7 & ~stop & ~shift_change & keyboard_strobe;
assign aux_magnet = ~x_tilt_rotate_parity;

// pg021
wire equipment_check;
latch1 u_equipment_check(i_clk,
	(sample_compare_check & x_keyboard_parity) |
	(sample_compare_check & ~x_function &
		((x_tilt_rotate_parity | i_keyboard_c) &
		(~i_keyboard_c & ~x_tilt_rotate_parity))),
	reset_sense_bytes,
	equipment_check);
assign reset_sense_bytes = ~busy_condition & sense_gate &
		(read_command | write_command | control_alarm) |
	(general_reset | ce_reset);

reg scc_delayed;
wire [7:0] case_character;
assign case_character = lower_case ? "L" : "U";
wire [5:0] tilt_rotate_data;
wire [5:0] tt2;
assign tt2 = tt_out;
assign tilt_rotate_data = {o_t1,o_t2,
	o_r1,o_r2,o_r2a,o_r5};
always @(posedge i_clk) begin
	scc_delayed <= sample_compare_check;
	if (sample_compare_check & ~scc_delayed) begin
if (x_keyboard_parity) begin
$display("T=%d bad keyboard-parity", $time);
end
if (~x_function & ((x_tilt_rotate_parity | i_keyboard_c) &
                (~i_keyboard_c & ~x_tilt_rotate_parity))) begin
$display("T=%d bad output compare failed", $time);
end
$display("T=%d\tp=%sC.%o.%b==%b tt=%x.%b function=%b", $time,
case_character, i_keyboard[5:0], ~i_keyboard_c, x_keyboard_parity,
tt2, x_tilt_rotate_parity, x_function);
	end
end

// pg621
wire ready;
latch1 u_ready(i_clk,
	i_ready_pb | gen_sel_init_reset,
	i_not_ready_pb | i_end_of_forms_contact,
	ready);
wire intervention_required;
assign intervention_required = ~ready;

wire rd_wr;

// pg131
wire unit_check;
wire x_unit_check_out;
latch2 u_unit_check(i_clk, i_reset,
	(equipment_check |
(intervention_required & rd_wr) |
		command_reject | bus_out_check)
		& (channel_end | device_end) &
		~sense_command & ~status_in_tag_delay & ~status_in_tgr,
	reset_sense_bytes,
	x_unit_check_out);
// XXX the ild only shows sense-command affecting the setting
//	of the latch, but in order to report the source of
//	of an equipment check it must have been (also? instead?)
//	involved with the masking of the latch during a sense operation.
// assign unit_check x_unit_check_out;
assign unit_check = x_unit_check_out & ~sense_command;

// pg141
wire invalid_command;
assign invalid_command = ~valid_command & ~testio_command_bits;	// guess

// pg141
wire command_reject;
latch1 u_command_reject(i_clk,
	invalid_command & command_gate,
	reset_sense_bytes,
	command_reject);

// pg021
wire x_bus_out_parity_error = ~not_bus_out_parity_error;
wire not_bus_out_parity_error = ^{i_bus_out};
wire bus_out_check;

// XXX ild does not show any of these conditions, sets bus_out_check
//	unconditionally (even when not selected or bus-out not driven.)
wire x_bus_out_check_sample = (command_out & address_in_tgr & initial_sel_tgr)
	| set_data_reg_to_bus_out;

latch1 u_bus_out_check(i_clk,
	x_bus_out_parity_error & x_bus_out_check_sample,
	reset_sense_bytes,
	bus_out_check);

wire x_reset_store_request;
wire reset_attn_stored;
assign reset_attn_stored = attn_status_latch & ~i_service_out & gate_status_in;
assign x_reset_store_request = reset_attn_stored | gen_sel_reset;

wire request_pb_interlock;
latch1 u_request_pb_interlock(i_clk,
	x_reset_store_request & i_request_pb,
	~i_request_pb,
	request_pb_interlock);

// pg621
wire store_request;
latch1 u_store_request(i_clk,
	~(request_pb_interlock | x_reset_store_request) & i_request_pb,
	x_reset_store_request,
	store_request);

wire turn_on_attention;
assign turn_on_attention = store_request;

// pg131
wire attention_status;
latch1 u_attention_status(i_clk,
	turn_on_attention & ~i_suppress_out & ~busy_condition &
			~initial_sel_tgr,
	gen_or_selective_reset | status_in_and_service_out,
	attention_status);
wire attn_status_latch = attention_status;

assign attention_interrupt = attention_status & ~status_stacked;

wire gate_sense_in;
assign gate_sense_in = sense_command & service_in_tgr;

// pg131
wire unit_exception;
latch1 u_unit_exception(i_clk,
	cancel,
	gen_sel_init_reset | status_in_and_service_out,
	unit_exception);

wire x_busy_status;
assign x_busy_status = (~((device_end | channel_end | status_stacked |
	attention_status) & testio) & initial_sel_tgr & busy_condition);

wire [7:0] status_bit_lines;
// XXX command reject input to "and" does not show other input
//	which must logically be gate-sense-in.
assign status_bit_lines = {
	(attention_interrupt & status_in_tgr)
		| (command_reject & gate_sense_in),
	intervention_required & gate_sense_in,
	bus_out_check & gate_sense_in,
	(equipment_check & gate_sense_in) | x_busy_status,
	status_in_tgr & channel_end,
	status_in_tgr & device_end_latch,
	status_in_tgr & unit_check,
	status_in_tgr & unit_exception
};
////////
wire [7:0] translate_bcd_to_8_bit;
wire [7:0] ce_bus_out;
wire [6:0] pick_funct_magnets;
wire [5:0] pick_tr_magnets;

wire not_ce_mode;
wire gen_sel_init_reset;

wire x_function;
wire service_in;
wire turns_on_service_in;
wire not_busy_or_stop;
wire shift_chane;
wire ce_mode;
wire ce_write;
wire ce_read;
wire not_inhibit;
wire sample_comp_check;
wire alternate_coding;
wire read_gate;
wire tn_cycle_time;
wire keyboard_strobe;
wire attention_interrupt;

wire status_in_tag_delayed;

delay1 #(DELAY) u_status_in(i_clk, i_reset, o_status_in, status_in_tag_delayed);

wire ss_1;
wire ss_2;
wire ss_4;
wire ss_5;
wire ss_6;
wire ss_7;
wire [4:0] fd_out;
wire [5:0] tt_out;
wire ready_ss;
wire tt_check;

// pg601
// XXX page 66 md-3: "& write" shown here.
ss2 #(TIMEOUT_700NS) u_ss1(i_clk, i_reset, turn_on_ss_1 & write, ss_1);

ss2 #(TIMEOUT_200NS) u_ss2(i_clk, i_reset, ~ss_1, ss_2);
ss2 #(TIMEOUT_200NS) u_ss4(i_clk, i_reset, ~u1052_busy & not_end_of_line, ss_4);
ss2 #(TIMEOUT_28MS) u_ss5(i_clk, i_reset, turn_on_ss_5, ss_5);
ss2 #(TIMEOUT_500NS) u_ss6(i_clk, i_reset, turn_on_ss_6&~ss_5
	& not_end_of_line, ss_6);
ss2 #(TIMEOUT_200NS) u_ss7(i_clk, i_reset, ~ss_6, ss_7);

// pg421
cfdecode function_decode(i_clk, i_reset,
	data_reg, carrier_return_latch, shift_change, ready, cycle_time,
	l_u_case_latch,
	x_function, fd_out);
// pg411
tt3 translator_8bit_to_tt(i_clk, i_reset, data_reg,
	tt_out, lower_case_character, upper_case_character);
assign tt_check = aux_magnet;

// pg521-pg551
ptt2e u_ptt2e(i_clk, i_reset, i_keyboard[5:0], l_u_case_latch,
	translate_bcd_to_8_bit);

//////// page 13
//////// figure 4 data register, input and output controls

wire set_data_reg_to_bus_out;
wire set_data_reg_to_keyboard;
wire set_data_reg_to_ce_bus;

// pg201, pg211
//wire [7:0] data_reg;
//latch2 #(.W(8)) u_data_reg(i_clk, i_reset,
//	(bus_out & {8{set_data_reg_to_bus_out}} ) |
//	(translate_bcd_to_8_bit & {8{set_data_reg_to_keyboard}}) |
//	(ce_bus_out & {8{set_data_reg_to_ce_bus }}),
//	{8{data_register_reset}},
//	data_reg);

reg [7:0] data_reg;
always @(posedge i_clk) begin
	if (data_register_reset)
		data_reg <= 0;
	else
	data_reg <= data_reg |
		(bus_out & {8{set_data_reg_to_bus_out}} ) |
		(translate_bcd_to_8_bit & {8{set_data_reg_to_keyboard}}) |
		(ce_bus_out & {8{set_data_reg_to_ce_bus }});
end

assign set_data_reg_to_bus_out = not_busy_or_stop & not_ce_mode & ss_1;
assign set_data_reg_to_keyboard = read & ss_6;
assign set_data_reg_to_ce_bus = not_busy_or_stop & ce_write & ss_1;

wire data_register_reset;
assign data_register_reset = (read & ss_5) |
		(~shift_change & write & ss_4) |
	gen_sel_init_reset;

wire gate_data_reg;
assign pick_funct_magnets = fd_out & {5{cycle_time & x_function}};
// glitch: x_function delayed behind cycle_time on automatic crlf
assign pick_tr_magnets = tt_out & {6{cycle_time & ~x_function & ~stop}};
assign o_check = tt_check & (cycle_time & ~x_function & ~stop);
assign gate_data_reg = read_command & service_in;
wire [7:0] bus_in_noparity = data_reg & {8{gate_data_reg}} | status_byte;
assign o_bus_in = address_in_byte | {bus_in_p, bus_in_noparity };
assign bus_in_p = (gate_data_reg | gate_status_in | gate_sense_in) &
	~^{bus_in_noparity};

assign { o_t1, o_t2, o_r1, o_r2, o_r2a, o_r5} = pick_tr_magnets;

//////// page 15
//////// figure 5 read/write clock

wire turn_on_ss_1;
wire write;
// pg701
assign service_response = service_in_and_service_out |
	(ce_mode & turns_on_service_in) |
	ce_write;
// pg641
assign turn_on_ss_1 = (service_response &
			not_busy_or_stop & not_end_of_line_latch)
	| (ss_6 & shift_change);
assign write = write_command | ce_write;

wire read;
assign read = read_command | ce_read;

// pg631
wire turn_on_cycle_time;
assign turn_on_cycle_time = (ss_2 & write) |
	(service_response & read) |
	(shift_change & read & ss_7) |
	(stop & ~inhibit_carrier_return & not_1052_busy) |
	(not_1052_busy & end_of_line_latch) |
	(sample_comp_check & alternate_coding) |
	read_gate | tn_cycle_time;

wire cycle_time;
latch1 u_cycle_time(i_clk,
	turn_on_cycle_time & ~u1052_busy,
	u1052_busy | gen_sel_reset,
	cycle_time);

// pg631
wire turn_on_ss_5;
assign turn_on_ss_5 = ~u1052_busy & read & keyboard_strobe;

// pg631
wire turn_on_ss_6;
latch1 u_turn_on_ss_6(i_clk,
	((read_command | ce_read) & ss_5) |
		(ss_4 & (write_command | ce_write)),
i_reset |
	ss_6,
	turn_on_ss_6);
//////// page 19
//////// figure 6 shift controls

// pg611
wire bus_out_6_not_bus_out_7;
assign bus_out_6_not_bus_out_7 = bus_out[1] & ~bus_out[0];
wire down_shift, up_shift;
wire upper_case, lower_case;
assign down_shift = ss_6 & i_keyboard[5:0] == 6'o76;
wire x_shift_down, x_shift_up;
wire set_lc_and_shift_change_latches;
wire set_uc_and_shift_change_latches;
// XXX there should probably be an | or so in this next:
//assign x_shift_down = (bus_out[1] & bus_out_6_not_bus_out_7 &
//	upper_case & write_gate) & ((lower_case_character &
//	(ss_2 & ~x_function) & upper_case) & down_shift);
// maybe:
//assign x_shift_down = (bus_out_6_not_bus_out_7 &
//	upper_case & write_gate) | ((lower_case_character &
//	(ss_2 & ~x_function) & upper_case) | down_shift);
assign x_shift_down = (lower_case_character &
	(ss_2 & ~x_function) & upper_case) | down_shift;
assign set_lc_and_shift_change_latches = upper_case & x_shift_down; 

assign up_shift = ss_6 & i_keyboard[5:0] == 6'o16;
assign x_shift_up = (upper_case_character & (ss_2 & ~x_function) & lower_case) | up_shift;
assign set_uc_and_shift_change_latches = lower_case & x_shift_up; 

// pg611
wire l_u_case_latch;
latch1 u_l_u_case_latch(i_clk,
	i_reset |
	(write_read_turn_on_channel_end & ~inhibit_carrier_return_latch) |
	set_lc_and_shift_change_latches,
	set_uc_and_shift_change_latches,
	l_u_case_latch);
assign lower_case = l_u_case_latch;
assign upper_case = ~l_u_case_latch;

wire x_turn_on_shift_change;
assign x_turn_on_shift_change = set_lc_and_shift_change_latches |
	set_uc_and_shift_change_latches;

wire shift_change_latch;
latch1 u_shift_change_latch(i_clk,
	x_turn_on_shift_change,
	((read & ss_4) | (write & ss_7)) |
i_reset |	// hack
			(~read & gen_sel_initial_reset),
	shift_change_latch);
wire shift_change;
assign shift_change = shift_change_latch;

// pg611
wire sp;
latch1 u_sp(i_clk,
	(x_shift_down & lower_case) | (x_shift_up & upper_case),
	shift_change_latch | ss_4 | ~read | gen_sel_initial_reset,
	sp);
//////// page 26
//////// figure 14 ce write

wire ce_reset;
assign ce_reset = 0;
assign ce_read = 0;
assign ce_write = 0;
wire ce_mode_delayed;
wire not_init_sel_or_busy_cond;
wire off_line;
wire flip_binary_latch;
wire cycle_a;
wire cycle_b;

assign off_line = 1;	// bogus, but good enough here

assign o_ce_state = {
	read, write, inhibit_carrier_return,
		upper_case, printer_busy, cycle_time,
	command_reject, intervention_required, bus_out_check, equipment_check,
	~o_lock_keyboard, attention_interrupt };
assign o_ce_data_reg = data_reg;
wire not_clk_out;

assign not_init_sel_or_busy_cond = ~(initial_sel_tgr | busy_condition);
assign not_clk_out = ~cycle_time;

// pg701
latch1 u_ce_mode(i_clk,
	not_init_sel_or_busy_cond & not_clk_out & i_cemode_sw,
	i_reset | ~(i_cemode_sw & not_clk_out),
	ce_mode);
assign not_ce_mode = ~ce_mode;

assign ce_read = ~i_contin_sw & ce_mode & off_line;
assign ce_write = i_contin_sw & ce_mode & off_line;
delay1 #(DELAY) u_ce_mode_delayed(i_clk, i_reset, ce_mode, ce_mode_delayed);
assign ce_reset = ce_mode ^ ce_mode_delayed;

assign flip_binary_latch = (ce_write | write) & ss_4 & ~shift_change;
// pg701
latch1 u_binary_trigger(i_clk,
	flip_binary_latch & cycle_b,
	i_reset | (flip_binary_latch & cycle_a),
	cycle_a);

assign cycle_b = ~cycle_a;

assign ce_bus_out = cycle_a ? CE_EMIT_1 : CE_EMIT_2;

endmodule
