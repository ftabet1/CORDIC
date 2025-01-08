TOP_MOD = test_cordic
VERILATOR = $(VERILATOR_ROOT)/bin/verilator
SRC = src/cordic.sv src/ROM.sv
V_FLAGS = --binary --Wno-fatal --trace --timing --top-module $(TOP_MOD)

all:
	$(VERILATOR) $(V_FLAGS) $(SRC)
	./obj_dir/V$(TOP_MOD)
	
trace:
	make all
	gtkwave test_cordic.wcd