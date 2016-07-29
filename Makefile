# $Id:  $

# ====================================================================== #
#                                                                        #
#  Makefile for  GOST 28147-89 CryptoCore project                        #
#                                                                        #
#  Copyright (c) 2014 Dmitry Murzinov (kakstattakim@gmail.com)           #
#                                                                        #
# ====================================================================== #


# project name
PROJECT=gost_28147_89
SOURCES=$(PROJECT).v

DEFINE=GOST_SBOX_TESTPARAM


SIM_DIR=./sim/bin
SYN_DIR=./syn/bin
CUR_DIR=$(shell pwd)

#ICARUS_SETUP:=. /soft/icarus.setup
#MENTOR_SETUP:=. /soft/mentor.setup
MENTOR_SETUP:=date
#SYNPLIFY_SETUP:=. /soft/synplify.setup
SYNPLIFY_SETUP:=date

IVERILOG_SETUP:=. /opt/iverilog.setup
VERILATOR_SETUP:=. /opt/verilator.setup

SYN_LOG=../log/$(PROJECT).log
SIM_LOG=../log/$(PROJECT).log

#######################################################################
all: syn
default_target: help

##### HELP target #####
help:
	@echo ""
	@echo " Current project:   $(PROJECT)"
	@echo " Current directory: $(CUR_DIR)"
	@echo ""
	@echo " Available targets :"
	@echo " =================="
	@echo " make              : print this text"
	@echo " make synplify     : synthesize design using Synplify to get netlist"
	@echo " make sim          : compile and run simulation RTL-design using iverilog/ModelSim"
	@echo " make sim-gui      : compile and run simulation RTL-design using ModelSim with GUI"
	@echo " make clean        : remove all temporary files"
	@echo ""

sbox-gen:
	@gcc -D$(DEFINE) -o s-box-generator syn/src/s-box-generator.c
	@./s-box-generator > rtl/sbox.vh
	@rm s-box-generator


############### SIM target ###############
sim:  sbox-gen   iverilog
sim-gui: modelsim-gui

##### Mentor Modelsim #####

modelsim:
		@cd $(SIM_DIR);\
		$(MENTOR_SETUP);\
		vsim -64 -c -quiet -do gost28147-89.tcl;\
		cd $(CUR_DIR);

modelsim-gui:
		@cd $(SIM_DIR);\
		$(MENTOR_SETUP);\
		vsim -64 -do gost28147-89_gui.tcl;\
		cd $(CUR_DIR);


##### Icarus Verilog #####
iverilog: icarus icarus-wave

icarus:
	@cd $(SIM_DIR);\
	rm -rf $(PROJECT).vvp;\
	$(IVERILOG_SETUP);\
	iverilog  -g2005-sv -I../../rtl -D$(DEFINE) -s tb -o $(PROJECT).vvp ../src/$(PROJECT)_tb.v  ../../rtl/$(PROJECT).v;\
	vvp -n $(PROJECT).vvp -lxt2;\
	cd $(CUR_DIR);

icarus-wave:
	@gtkwave $(SIM_DIR)/$(PROJECT).vcd $(SIM_DIR)/$(PROJECT).gtkw &


############### SYN target ###############
syn: sbox-gen yosys

##### Yosys #####
yosys:
	@cd $(SYN_DIR);\
	yosys -Q -T -v 2 -s yosys.ys -L $(SYN_LOG);\
	cd $(CUR_DIR);

##### Synplify #####
synplify:
		@cd $(SYN_DIR);\
		$(SYNPLIFY_SETUP);\
		synplify_pro -enable64bit -batch synplify.tcl;\
		cd $(CUR_DIR);


##### Vivado #####
vivado: sbox-gen
	@vivado -nojournal -nolog -mode batch -source $(SYN_DIR)/vivado.tcl
	-@grep VIOLATED syn/log/post_route_timing_worst.rpt


##### PHONY target #####
.PHONY : clean syn sim yosys synplify vivado ise modelsim iverilog icarus

