#CFLAGS=-g -I. -O2
CFLAGS=-g -I. -O0
CXXFLAGS=-g -I. -Iobj -I/usr/share/verilator/include -I/usr/share/verilator/include/vltstd -std=c++17
O=verilated.o verilated_vcd_c.o
P=-lpthread
A=$B $Q
B=x2150_tb
Q=
all: $A
#
cfdecode.pdf: cfdecode.dot
	dot -Tps2 cfdecode.dot | ps2pdf - cfdecode.pdf
cfdecode.dot: cfdecode.v
	yosys -s cfdecode.ys
cfdecode_tb: cfdecode.v cfdecode_tb.v
	iverilog -y . -g2005-sv -o cfdecode_tb cfdecode_tb.v
ptt2e.pdf: ptt2e.dot
	dot -Tps2 ptt2e.dot | ps2pdf - ptt2e.pdf
ptt2e.dot: ptt2e.v
	yosys -s ptt2e.ys
ptt2e_tb: ptt2e.v ptt2e_tb.v
	iverilog -y . -g2005-sv -o ptt2e_tb ptt2e_tb.v
e2tt.pdf: e2tt.dot
	dot -Tps2 e2tt.dot | ps2pdf - e2tt.pdf
e2tt.dot: e2tt.v
	yosys -s e2tt.ys
e2tt_tb: e2tt.v e2tt_tb.v
	iverilog -y . -g2005-sv -o e2tt_tb e2tt_tb.v
tt3.pdf: tt3.dot
	dot -Tps2 tt3.dot | ps2pdf - tt3.pdf
tt3.dot: tt3.v
	yosys -s tt3.ys
tt3_tb: tt3.v tt3_tb.v
	iverilog -y . -g2005-sv -o tt3_tb tt3_tb.v
ss2.pdf: ss2.dot
	dot -Tps2 ss2.dot | ps2pdf - ss2.pdf
ss2.dot: ss2.v
	yosys -s ss2.ys
ss2_tb: ss2.v ss2_tb.v
	iverilog -y . -g2005-sv -o ss2_tb ss2_tb.v
delay1.pdf: delay1.dot
	dot -Tps2 delay1.dot | ps2pdf - delay1.pdf
delay1.dot: delay1.v
	yosys -s delay1.ys
delay1_tb: delay1.v delay1_tb.v
	iverilog -y . -g2005-sv -o delay1_tb delay1_tb.v
x2150.pdf: x2150.dot
	dot -Tps2 x2150.dot | ps2pdf - x2150.pdf
x2150.dot: x2150.v cfdecode.v tt3.v ptt2e.v ss2.v delay1.v latch1.v latch2.v
	yosys -s x2150.ys
x2150_tb: x2150.v x2150_tb.v cfdecode.v tt3.v ptt2e.v ss2.v delay1.v latch1.v latch2.v
	iverilog -y . -g2005-sv -o x2150_tb x2150_tb.v
ptt12: ptt12.o
ptt12.o: ptt8.h etoa.h tt2.h
ptt16: ptt16.o
ptt16.o: ptt8.h etoa.h tt2.h
latch1.pdf: latch1.dot
	dot -Tps2 latch1.dot | ps2pdf - latch1.pdf
latch1.dot: latch1.v latch1.ys
	yosys -s latch1.ys
latch1_tb: latch1.v latch1_tb.v
	iverilog -y . -g2005-sv -o latch1_tb latch1_tb.v
#
clean:
	rm -f $B $Q
	rm -f *.vcd
	rm -f ptt12 ptt16
	rm -f cfdecode_tb delay1_tb e2tt_tb latch1_tb ptt2e_tb ss2_tb x2150_tb
	rm -f tt3_tb
	rm -f cfdecode.dot ptt2e.dot e2tt.dot tt3.dot ss2.dot delay1.dot x2150.dot latch1.dot
	rm -f cfdecode.pdf ptt2e.pdf e2tt.pdf tt3.pdf ss2.pdf delay1.pdf x2150.pdf latch1.pdf
