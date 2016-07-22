## $Id: gost28147-89.tcl 13 2012-03-22 11:02:55Z Doka $

####################################################################
#    This file is part of the GOST 28147-89 CryptoCore project     #
#                                                                  #
#    Copyright (c) 2014 Dmitry Murzinov (kakstattakim@gmail.com)   #
####################################################################

##  Run this file with command:   cd proj/gost28147/sim/bin; source gost28147-89.tcl

set name_tb "gost_28147_89_tb"
set timesim 2500ns

#####################################################
## path to verilog source code
set dir_src ../../rtl
## path to testbenches dir
set dir_sim ../../sim/src
## path to script dir
set dir_script ../bin
## path to work  dir
set dir_work ../run

## set include file dirs
set dir_inc  $dir_src+$dir_sim+../../rtl/tech

## set project defines
set DEFINE GOST_SBOX_TESTPARAM

#####################################################
quit -sim

vlib work

vlog +define+$DEFINE +incdir+$dir_inc $dir_src/gost_28147_89.v
#vlog +define+$DEFINE +incdir+$dir_inc -sv  $dir_sim/$name_tb.sv
vlog +define+$DEFINE +incdir+$dir_inc $dir_sim/$name_tb.v

vsim -novopt +notimingchecks -wlfdeleteonquit -t 1ns  work.tb

run $timesim
quit
