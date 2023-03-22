BENDER    ?= bender
VSIM_LIB  ?= sim/work
VLOG_ARGS ?= -work $(VSIM_LIB)
# VLOG_ARGS ?= -suppress 2583 -suppress 13314

GUI ?= 0

##############
# Simulation #
##############

.PHONY: all clean run script script-clean deps

all: sim/tcl/compile.tcl
	bash sim/compile.sh

sim/tcl/compile.tcl: Bender.yml
	$(BENDER) script vsim -t sim --vlog-arg="$(VLOG_ARGS)" > $@

deps: Bender.yml
	$(BENDER) update
	$(BENDER) checkout

script: deps sim/tcl/compile.tcl

script-clean:
	rm -rf sim/tcl/compile.tcl

run:
ifeq ($(GUI), 0)
	bash sim/simulate.sh
else
	bash sim/simulate.sh --gui
endif

clean:
	rm -rf $(VSIM_LIB)

