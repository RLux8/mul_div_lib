# vhdl files
MULDIV_FILES = ../hdl/*.vhd

WORKDIR = work

#GHDL CONFIG
GHDL_CMD = ghdl
GHDL_FLAGS = --std=08 --ieee=synopsys --warn-no-vital-generic --workdir=$(WORKDIR)
GHDL_COMPILE_FLAGS = --std=08

# Simulation break condition
GHDL_SIM_OPT = --assert-level=error --ieee-asserts=disable

DURATION_LIMIT=5ms

WAVEFORM_VIEWER = surfer

.PHONY: clean

all: clean make run view

compile:
	@mkdir -p $(WORKDIR)
	@$(GHDL_CMD) -i --work=mul_div_lib  $(GHDL_FLAGS) $(GHDL_COMPILE_FLAGS)  $(MULDIV_FILES) 
	@$(GHDL_CMD) -i --work=md_test_lib $(GHDL_FLAGS)  $(GHDL_COMPILE_FLAGS)  tb/*.vhd
	@$(GHDL_CMD) -m $(GHDL_FLAGS) $(GHDL_COMPILE_FLAGS)  -Pwork  md_test_lib.muldiv_tb
	@$(GHDL_CMD) -e $(GHDL_FLAGS) $(GHDL_COMPILE_FLAGS) --work=vio_test_lib -Pwork md_test_lib.muldiv_tb

run:
	@$(GHDL_CMD) -r $(GHDL_FLAGS) $(GHDL_COMPILE_FLAGS) -Pwork --work=md_test_lib md_test_lib.muldiv_tb $(GHDL_SIM_OPT) --stop-time=${DURATION_LIMIT}

runwave:
	@$(GHDL_CMD) -r $(GHDL_FLAGS) $(GHDL_COMPILE_FLAGS) -Pwork --work=md_test_lib md_test_lib.muldiv_tb --wave=$(WORKDIR)/tb.ghw $(GHDL_SIM_OPT) --stop-time=${DURATION_LIMIT}

view:
	@$(WAVEFORM_VIEWER) -s tb.surf.ron $(WORKDIR)/tb.ghw

clean:
	@rm -rf $(WORKDIR)
