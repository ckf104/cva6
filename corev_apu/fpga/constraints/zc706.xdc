# Disable all pins because this may not be used as top warp. And the following pin set is not success.

# following xdc: https://support.xilinx.com/s/article/56354?language=zh_CN
set_property BITSTREAM.General.UnconstrainedPins {Allow} [current_design]


# ## This copy from gensis-2.xdc and use vivado to select zc706 pins.
# 
# ## Buttons
# set_property -dict {PACKAGE_PIN AB16 IOSTANDARD LVCMOS18} [get_ports cpu_reset]
# 
# ## To use FTDI FT2232 JTAG
# set_property -dict { PACKAGE_PIN AB27 IOSTANDARD LVCMOS18 } [get_ports trst];
# set_property -dict { PACKAGE_PIN AB15 IOSTANDARD LVCMOS18 } [get_ports tck ];
# set_property -dict { PACKAGE_PIN AB24 IOSTANDARD LVCMOS18 } [get_ports tdi ];
# set_property -dict { PACKAGE_PIN AB25 IOSTANDARD LVCMOS18 } [get_ports tdo ];
# set_property -dict { PACKAGE_PIN AB26 IOSTANDARD LVCMOS18 } [get_ports tms ];
# 
# ## UART
# set_property -dict {PACKAGE_PIN AB29 IOSTANDARD LVCMOS18} [get_ports tx]
# set_property -dict {PACKAGE_PIN AB17 IOSTANDARD LVCMOS18} [get_ports rx]
# 
# 
# ## LEDs
# set_property -dict {PACKAGE_PIN AA17 IOSTANDARD LVCMOS18} [get_ports {led[0]}]
# set_property -dict {PACKAGE_PIN AA15 IOSTANDARD LVCMOS18} [get_ports {led[1]}]
# set_property -dict {PACKAGE_PIN AA14 IOSTANDARD LVCMOS18} [get_ports {led[2]}]
# set_property -dict {PACKAGE_PIN AA13 IOSTANDARD LVCMOS18} [get_ports {led[3]}]
# set_property -dict {PACKAGE_PIN AA8 IOSTANDARD LVCMOS18} [get_ports {led[4]}]
# set_property -dict {PACKAGE_PIN AA7 IOSTANDARD LVCMOS18} [get_ports {led[5]}]
# set_property -dict {PACKAGE_PIN AA4 IOSTANDARD LVCMOS18} [get_ports {led[6]}]
# set_property -dict {PACKAGE_PIN AA3 IOSTANDARD LVCMOS18} [get_ports {led[7]}]
# 
# ## Switches
# set_property -dict {PACKAGE_PIN AA27 IOSTANDARD LVCMOS18} [get_ports {sw[0]}]
# set_property -dict {PACKAGE_PIN AA25 IOSTANDARD LVCMOS18} [get_ports {sw[1]}]
# set_property -dict {PACKAGE_PIN AA24 IOSTANDARD LVCMOS18} [get_ports {sw[2]}]
# set_property -dict {PACKAGE_PIN AA23 IOSTANDARD LVCMOS18} [get_ports {sw[3]}]
# set_property -dict {PACKAGE_PIN AA22 IOSTANDARD LVCMOS18} [get_ports {sw[4]}]
# set_property -dict {PACKAGE_PIN AA20 IOSTANDARD LVCMOS18} [get_ports {sw[5]}]
# set_property -dict {PACKAGE_PIN AA19 IOSTANDARD LVCMOS18} [get_ports {sw[6]}]
# set_property -dict {PACKAGE_PIN AA18 IOSTANDARD LVCMOS18} [get_ports {sw[7]}]
# 
# ## Fan Control
# set_property -dict {PACKAGE_PIN AB14 IOSTANDARD LVCMOS18} [get_ports fan_pwm]
# 
# ## Ethernet
# set_property -dict {PACKAGE_PIN AB1 IOSTANDARD LVCMOS18} [get_ports eth_rst_n];          #IO_L14N_T2_SRCC_12 Sch=eth_phyrst_n
# set_property -dict {PACKAGE_PIN AB6 IOSTANDARD LVCMOS18} [get_ports eth_txck];           #IO_L14P_T2_SRCC_33 Sch=eth_tx_clk
# set_property -dict {PACKAGE_PIN AB12 IOSTANDARD LVCMOS18} [get_ports eth_txctl];         #IO_L20P_T3_33 Sch=eth_tx_en
# set_property -dict {PACKAGE_PIN AC16 IOSTANDARD LVCMOS18} [get_ports { eth_txd[0] }];    #IO_L22N_T3_33 Sch=eth_tx_d[0]
# set_property -dict {PACKAGE_PIN AC14 IOSTANDARD LVCMOS18} [get_ports { eth_txd[1] }];    #IO_L17P_T2_33 Sch=eth_tx_d[1]
# set_property -dict {PACKAGE_PIN AC13 IOSTANDARD LVCMOS18} [get_ports { eth_txd[2] }];    #IO_L18N_T2_33 Sch=eth_tx_d[2]
# set_property -dict {PACKAGE_PIN AC12 IOSTANDARD LVCMOS18} [get_ports { eth_txd[3] }];    #IO_L17N_T2_33 Sch=eth_tx_d[3]
# set_property -dict {PACKAGE_PIN AC8 IOSTANDARD LVCMOS18} [get_ports { eth_rxd[0] }];     #IO_L21N_T3_DQS_33 Sch=eth_rx_d[0]
# set_property -dict {PACKAGE_PIN AB2 IOSTANDARD LVCMOS18} [get_ports eth_rxck];           #IO_L13P_T2_MRCC_33 Sch=eth_rx_clk
# set_property -dict {PACKAGE_PIN AB5 IOSTANDARD LVCMOS18} [get_ports eth_rxctl];          #IO_L18P_T2_33 Sch=eth_rx_ctl
# set_property -dict {PACKAGE_PIN AC7 IOSTANDARD LVCMOS18} [get_ports { eth_rxd[1] }];     #IO_L21P_T3_DQS_33 Sch=eth_rx_d[1]
# set_property -dict {PACKAGE_PIN AC4 IOSTANDARD LVCMOS18} [get_ports { eth_rxd[2] }];     #IO_L20N_T3_33 Sch=eth_rx_d[2]
# set_property -dict {PACKAGE_PIN AC3 IOSTANDARD LVCMOS18} [get_ports { eth_rxd[3] }];     #IO_L22P_T3_33 Sch=eth_rx_d[3]
# set_property -dict {PACKAGE_PIN AA29 IOSTANDARD LVCMOS18} [get_ports eth_mdc ];          #IO_L23P_T3_33 Sch=eth_mdc
# set_property -dict {PACKAGE_PIN AA30 IOSTANDARD LVCMOS18} [get_ports eth_mdio];          #IO_L23N_T3_33 Sch=eth_mdio
# 
# #############################################
# # Ethernet Constraints for 1Gb/s
# #############################################
# # Modified for 125MHz receive clock
# create_clock -period 8.000 -name eth_rxck [get_ports eth_rxck]
# 
# set_clock_groups -asynchronous -group [get_clocks eth_rxck -include_generated_clocks]
# set_clock_groups -asynchronous -group [get_clocks clk_out2_xlnx_clk_gen]
# 
# #############################################
# ## SD Card
# #############################################
# set_property -dict {PACKAGE_PIN AB19 IOSTANDARD LVCMOS18} [get_ports spi_clk_o]
# set_property -dict {PACKAGE_PIN AB22 IOSTANDARD LVCMOS18} [get_ports spi_ss]
# set_property -dict {PACKAGE_PIN AB20 IOSTANDARD LVCMOS18} [get_ports spi_miso]
# set_property -dict {PACKAGE_PIN AB21 IOSTANDARD LVCMOS18} [get_ports spi_mosi]
# 
# ## JTAG
# # minimize routing delay
# 
# set_max_delay -to   [get_ports tdo ] 20
# set_max_delay -from [get_ports tms ] 20
# set_max_delay -from [get_ports tdi ] 20
# set_max_delay -from [get_ports trst] 20
# 
# #############################################
# ## Fix from Bugs
# #############################################
# 
# ### 1. clock
# ### ERROR: [Place 30-574] Poor placement for routing between an IO pin and BUFG. If this sub optimal condition is acceptable for this design, you may use the CLOCK_DEDICATED_ROUTE constraint in the .xdc file to demote this message to a WARNING. 
# ### However, the use of this override is highly discouraged. These examples can be used directly in the .xdc file to override this clock rule.
# ###         < set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets tck_IBUF] >
# ### 
# ###         Clock Rule: rule_gclkio_bufg
# ###         Status: FAILED
# ###         Rule Description: An IOB driving a BUFG must use a CCIO in the same half side (top/bottom) of chip as the BUFG
# ### 
# ###         tck_IBUF_inst (IBUF.O) is locked to IOB_X0Y56
# ###         tck_IBUF_BUFG_inst (BUFG.I) is provisionally placed by clockplacer on BUFGCTRL_X0Y0
# 
# set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets tck_IBUF]