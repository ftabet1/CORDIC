TOP_MOD = test_cordic
TOP_MOD_SICO = test_cordic_sico
TOP_MOD_HB = test_cordic_hb
VERILATOR = $(VERILATOR_ROOT)/bin/verilator
SRC = src/cordic.sv src/ROM.sv
SRC_SICO = src/cordic_sico.sv src/ROM.sv
SRC_HB = src/cordic_hb.sv src/ROM.sv

V_FLAGS = --binary --Wno-fatal --trace --timing --sv --top-module $(TOP_MOD)
V_FLAGS_SICO = --binary --Wno-fatal --trace --timing --sv --top-module $(TOP_MOD_SICO)
V_FLAGS_HB = --binary --Wno-fatal --trace --timing --sv --top-module $(TOP_MOD_HB)

all:
	$(VERILATOR) $(V_FLAGS) $(SRC)
	./obj_dir/V$(TOP_MOD)
	
sico:
	$(VERILATOR) $(V_FLAGS_SICO) $(SRC_SICO)
	./obj_dir/V$(TOP_MOD_SICO)

hb:
	$(VERILATOR) $(V_FLAGS_HB) $(SRC_HB)
	./obj_dir/V$(TOP_MOD_HB)

trace:
	make all
	gtkwave test_cordic.wcd