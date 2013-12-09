VHDLS = \
  midi_read.vhd \
  midi_read_tb.vhd \


STD=standard
#STD=synopsys

show_ghw:   midi_read_tb test.ghw
	gtkwave test.ghw test.sav
midi_read_tb: ${VHDLS}
	ghdl -a --std=93c --ieee=${STD} ${VHDLS} 
	ghdl -e --std=93c -fexplicit --ieee=${STD} midi_read_tb
test.ghw: midi_read_tb
#	./midi_read_tb --wave=test.ghw --stop-time=10000ms
	./midi_read_tb --wave=test.ghw 
clean:
	rm *.o *.vcd *.ghw *.dat *.cf *.raw *.wav midi_read_tb

