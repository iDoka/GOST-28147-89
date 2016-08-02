#######################################################################################
##  Project    : GOST 28147-89 Verilog HDL code
##  Designer   : Dmitry Murzinov (kakstattakim@gmail.com)
##  Module     : Vivado tcl-script
##  Description: this script doing quick&dirty sanity check for your RTL
##  Revision   : $Rev
##  Version    : $GlobalRev$
##  Date       : $LastChangedDate$
##  License    : MIT
#######################################################################################

### path setup
set DIRRTL ./rtl
set DIRBIN ./syn/bin
set DIRSRC ./syn/src
set DIRLOG ./syn/log
set DIROUT ./syn/out


### Please set the name of Top Module and Name of Clock Signal:
set TOP     gost_28147_89
set CLOCK   clk

### Sources specify
set RTL_SRC ${DIRRTL}/${TOP}.v
set RTL_INC "$DIRRTL"

### Project defines
### !! ToDo pass from Makefile
set DEFINE GOST_SBOX_TESTPARAM

set PART xc7vx330tffg1157-3

### timing report settings
set NWORST  10
set MAXPATHS 5

### Read RTL-sources [please edit apropriate]:
#read_verilog -sv [glob ./rtl/*.sv]
read_verilog $RTL_SRC

### synthesys
synth_design -part $PART -top $TOP -directive runtimeoptimized \
   -include_dirs $RTL_INC -verilog_define $DEFINE -mode out_of_context

set_hierarchy_separator /

#### setting  CLOCK ####
#read_xdc ${DIRBIN}/clock.xdc
create_clock -period 2.9 -name CLK [get_ports $CLOCK]

#### setting CONFIG ####
read_xdc ${DIRBIN}/config.xdc

#### IO-locate and standard constraints:
#read_xdc ${DIRBIN}/pinout.xdc

#### ILA instantiation ####
#source ${DIRBIN}/ila-debug-core.tcl

### some reports
report_utilization                           -file ${DIRLOG}/post_synth_utilization.rpt
report_clock_utilization -clock_roots_only   -file ${DIRLOG}/post_synth_clk_util.rpt
report_timing_summary                        -file ${DIRLOG}/post_synth_timing_summary.rpt
report_timing -nworst $NWORST -unique_pins   -file ${DIRLOG}/post_synth_timing_worst.rpt
report_timing -setup -max_paths $MAXPATHS    -file ${DIRLOG}/post_synth_timing_setup.rpt
report_timing -hold  -max_paths $MAXPATHS    -file ${DIRLOG}/post_synth_timing_hold.rpt
report_drc                                   -file ${DIRLOG}/post_synth_drc.rpt
# The following checks are sorted by importance (most important to least important)
# when reviewing and fixing the issues flagged by:
check_timing -verbose                        -file ${DIRLOG}/post_synth_timing_check.rpt

#write_edif    -force ${DIROUT}/$TOP.edif

###### opt #######
opt_design -verbose

###### place #######
place_design

###### phys_opt #######
phys_opt_design

###### route #######
route_design

### some reports
report_route_status                          -file ${DIRLOG}/post_route_status.rpt
report_utilization  -no_primitives           -file ${DIRLOG}/post_route_util.rpt
report_clock_utilization -clock_roots_only   -file ${DIRLOG}/post_route_clk_util.rpt
report_timing_summary -delay_type max -warn_on_violation \
    -datasheet -report_unconstrained         -file ${DIRLOG}/post_route_timing_summary.rpt
report_timing -nworst $NWORST -unique_pins   -file ${DIRLOG}/post_route_timing_worst.rpt
report_timing -setup -max_paths $MAXPATHS    -file ${DIRLOG}/post_route_timing_setup.rpt
report_timing -hold  -max_paths $MAXPATHS    -file ${DIRLOG}/post_route_timing_hold.rpt
report_ram_utilization                       -file ${DIRLOG}/post_route_ram_utilization.rpt

report_power                                 -file ${DIRLOG}/post_route_power.rpt
report_drc -ruledeck methodology_checks      -file ${DIRLOG}/post_imp_drc_ruledeck.rpt

#write_verilog  -force -mode timesim -sdf_anno true -sdf_file ${TOP}.sdf ${DIROUT}/${TOP}_sdf.v
#write_sdf -force ${DIROUT}/${TOP}.sdf

#write_bitstream -force ${DIROUT}/$TOP.bit
#write_debug_probes -force ${DIROUT}/$TOP.ltx
