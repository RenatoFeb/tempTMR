## clock
set_property PACKAGE_PIN E3 [get_ports {clk}];
create_clock -name sysclk -period 10 -waveform {0 5} [get_ports {clk}];
set_property IOSTANDARD LVCMOS33 [get_ports {clk}];

## motor pins -Right on JD
## IN3
set_property -dict {PACKAGE_PIN H4 IOSTANDARD LVCMOS33} [get_ports {MOTOR_RF[0]}];
## IN4
set_property -dict {PACKAGE_PIN H1 IOSTANDARD LVCMOS33} [get_ports {MOTOR_RF[1]}];
## ENB
set_property -dict {PACKAGE_PIN G1 IOSTANDARD LVCMOS33} [get_ports {MOTOR_RF[2]}];
## IN1
set_property -dict {PACKAGE_PIN G3 IOSTANDARD LVCMOS33} [get_ports {MOTOR_RB[0]}];
## IN2
set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVCMOS33} [get_ports {MOTOR_RB[1]}];
## ENA
set_property -dict {PACKAGE_PIN G4 IOSTANDARD LVCMOS33} [get_ports {MOTOR_RB[2]}];


set_property -dict { PACKAGE_PIN U12   IOSTANDARD LVCMOS33 } [get_ports {flip_a }]; #IO_L20P_T3_A08_D24_14 Sch=sw[13]
set_property -dict { PACKAGE_PIN U11   IOSTANDARD LVCMOS33 } [get_ports {flip_b}]; #IO_L19N_T3_A09_D25_VREF_14 Sch=sw[14]
set_property -dict { PACKAGE_PIN V10   IOSTANDARD LVCMOS33 } [get_ports {flip_c}]; #IO_L21P_T3_DQS_14 Sch=sw[15]


set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports {fail_flag }]; #IO_L7P_T1_D09_14 Sch=led[4]

## motor pins -Left on JC
## IN3
set_property -dict {PACKAGE_PIN K1 IOSTANDARD LVCMOS33} [get_ports {MOTOR_LF[0]}];
## IN4
set_property -dict {PACKAGE_PIN F6 IOSTANDARD LVCMOS33} [get_ports {MOTOR_LF[1]}];
## ENB
set_property -dict {PACKAGE_PIN J2 IOSTANDARD LVCMOS33} [get_ports {MOTOR_LF[2]}];
## IN3
set_property -dict {PACKAGE_PIN G6 IOSTANDARD LVCMOS33} [get_ports {MOTOR_LB[0]}];
## IN4
set_property -dict {PACKAGE_PIN E7 IOSTANDARD LVCMOS33} [get_ports {MOTOR_LB[1]}];
## ENB
set_property -dict {PACKAGE_PIN J3 IOSTANDARD LVCMOS33} [get_ports {MOTOR_LB[2]}];


## switches for controlling the motor
##set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports {SWITCH[0]}];
##set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVCMOS33} [get_ports {SWITCH[1]}];
##set_property -dict {PACKAGE_PIN M13 IOSTANDARD LVCMOS33} [get_ports {SWITCH[2]}];


## Reed switch input
set_property PACKAGE_PIN C17 [get_ports reed_in]
set_property IOSTANDARD LVCMOS33 [get_ports reed_in]
set_property PULLUP true [get_ports reed_in]

## PmodENC on JB (front view, as loaded on PCB)
## JB1=D14, JB2=F16, JB3=G16, JB4=H14  (signals)
## JB7=E16, JB8=F13, JB9=G13, JB10=H16 (spares)
set_property -dict { PACKAGE_PIN A13   IOSTANDARD LVCMOS33  PULLUP TRUE } [get_ports { enc_a }];
set_property -dict { PACKAGE_PIN A15   IOSTANDARD LVCMOS33  PULLUP TRUE } [get_ports { enc_b }];
set_property -dict { PACKAGE_PIN B16   IOSTANDARD LVCMOS33  PULLUP TRUE } [get_ports { enc_btn_n }];

set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33  PULLUP TRUE } [get_ports { dir_switch_r }];
set_property -dict { PACKAGE_PIN L16   IOSTANDARD LVCMOS33  PULLUP TRUE } [get_ports { dir_switch_l }];

set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports { led0 }];

set_property -dict { PACKAGE_PIN C4    IOSTANDARD LVCMOS33 } [get_ports { uart_rx }]; #IO_L7P_T1_AD6P_35 Sch=uart_txd_in
set_property -dict { PACKAGE_PIN D4    IOSTANDARD LVCMOS33 } [get_ports { uart_tx  }]; #IO_L11N_T1_SRCC_35 Sch=uart_rxd_out


##7 segment display
set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33 } [get_ports { SEG[6] }]; #IO_L24N_T3_A00_D16_14 Sch=ca
set_property -dict { PACKAGE_PIN R10   IOSTANDARD LVCMOS33 } [get_ports { SEG[5] }]; #IO_25_14 Sch=cb
set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS33 } [get_ports { SEG[4] }]; #IO_25_15 Sch=cc
set_property -dict { PACKAGE_PIN K13   IOSTANDARD LVCMOS33 } [get_ports { SEG[3] }]; #IO_L17P_T2_A26_15 Sch=cd
set_property -dict { PACKAGE_PIN P15   IOSTANDARD LVCMOS33 } [get_ports { SEG[2] }]; #IO_L13P_T2_MRCC_14 Sch=ce
set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33 } [get_ports { SEG[1] }]; #IO_L19P_T3_A10_D26_14 Sch=cf
set_property -dict { PACKAGE_PIN L18   IOSTANDARD LVCMOS33 } [get_ports { SEG[0] }]; #IO_L4P_T0_D04_14 Sch=cg
set_property -dict { PACKAGE_PIN H15   IOSTANDARD LVCMOS33 } [get_ports { DP }]; #IO_L19N_T3_A21_VREF_15 Sch=dp
set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS33 } [get_ports { AN[0] }]; #IO_L23P_T3_FOE_B_15 Sch=an[0]
set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [get_ports { AN[1] }]; #IO_L23N_T3_FWE_B_15 Sch=an[1]
set_property -dict { PACKAGE_PIN T9    IOSTANDARD LVCMOS33 } [get_ports { AN[2] }]; #IO_L24P_T3_A01_D17_14 Sch=an[2]
set_property -dict { PACKAGE_PIN J14   IOSTANDARD LVCMOS33 } [get_ports { AN[3] }]; #IO_L19P_T3_A22_15 Sch=an[3]
#set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 } [get_ports { AnOut[4] }]; #IO_L8N_T1_D12_14 Sch=an[4]
#set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33 } [get_ports { AnOut[5] }]; #IO_L14P_T2_SRCC_14 Sch=an[5]
#set_property -dict { PACKAGE_PIN K2    IOSTANDARD LVCMOS33 } [get_ports { AnOut[6] }]; #IO_L23P_T3_35 Sch=an[6]
#set_property -dict { PACKAGE_PIN U13   IOSTANDARD LVCMOS33 } [get_ports { AnOut[7] }]; #IO_L23N_T3_A02_D18_14 Sch=an[7]

set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports { reset }]; #IO_L9P_T1_DQS_14 Sch=btnc

##Accelerometer
#set_property -dict { PACKAGE_PIN G13   IOSTANDARD LVCMOS33 } [get_ports { ACL_MISO }]; #IO_L11P_T1_SRCC_15 Sch=acl_miso
#set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS33 } [get_ports { ACL_MOSI }]; #IO_L5N_T0_AD9N_15 Sch=acl_mosi
#set_property -dict { PACKAGE_PIN F13   IOSTANDARD LVCMOS33 } [get_ports { ACL_SCLK }]; #IO_L14P_T2_SRCC_15 Sch=acl_sclk
#set_property -dict { PACKAGE_PIN E16   IOSTANDARD LVCMOS33 } [get_ports { ACL_CSN }]; #IO_L12P_T1_MRCC_15 Sch=acl_csn

set_property -dict { PACKAGE_PIN C14   IOSTANDARD LVCMOS33 } [get_ports { TMP_SCL }]; #IO_L1N_T0_AD0N_15 Sch=tmp_scl
set_property -dict { PACKAGE_PIN C15   IOSTANDARD LVCMOS33 } [get_ports { TMP_SDA }]; #IO_L12N_T1_MRCC_15 Sch=tmp_sda