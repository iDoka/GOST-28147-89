#### setting CONFIG bank ####
set_property CFGBVS         GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

##### http://www.xilinx.com/support/documentation/application_notes/xapp1232-bitstream-id-with-usr_access.pdf
##### https://forums.xilinx.com/t5/Implementation/set-property-BITSTREAM-CONFIG-USR-ACCESS-TIMESTAMP-current/m-p/708578#M15707
##### ddddd_MMMM_yyyyyy_hhhhh_mmmmmm_ssssss
##### (bit 31)......................(bit 0)
set_property BITSTREAM.CONFIG.USR_ACCESS TIMESTAMP [current_design]
#report_property [current_design] BITSTREAM.CONFIG.USR_ACCESS

##### this value might be used for naming bitstream:
#get_property REGISTER.USR_ACCESS [lindex [get_hw_devices] 0]
