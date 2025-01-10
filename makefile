TOP_MOD = test_cordic
VERILATOR = $(VERILATOR_ROOT)/bin/verilator
SRC = src/cordic.sv src/ROM.sv
TOP_MOD_SICO = test_cordic_sico
SRC_SICO = src/cordic_sico.sv src/ROM.sv

V_FLAGS = --binary --Wno-fatal --trace --timing --sv --top-module $(TOP_MOD)
V_FLAGS_SICO = --binary --Wno-fatal --trace --timing --sv --top-module $(TOP_MOD_SICO)

all:
	$(VERILATOR) $(V_FLAGS) $(SRC)
	./obj_dir/V$(TOP_MOD)
	
sico:
	$(VERILATOR) $(V_FLAGS_SICO) $(SRC_SICO)
	./obj_dir/V$(TOP_MOD_SICO)

trace:
	make all
	gtkwave test_cordic.wcd