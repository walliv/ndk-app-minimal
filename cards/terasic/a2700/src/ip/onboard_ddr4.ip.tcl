package require -exact qsys 21.3

array set PARAMS $IP_PARAMS_L
source $PARAMS(IP_COMMON_TCL)

proc do_adjust_onboard_ddr4_ip_0 {} {
    set_instance_parameter_value emif_fm_0 {PHY_DDR4_MIMIC_HPS_EMIF} {0}
}

proc do_adjust_onboard_ddr4_ip_1 {} {
    set_instance_parameter_value emif_fm_0 {PHY_DDR4_MIMIC_HPS_EMIF} {1}
}


proc do_adjust_onboard_ddr4_ip  {device family ipname filename adjust_proc} {
    load_system $filename
    set_project_property DEVICE $device
    set_project_property DEVICE_FAMILY $family
    set_project_property HIDE_FROM_IP_CATALOG {true}

    set_instance_parameter_value emif_fm_0 {CTRL_DDR4_ECC_AUTO_CORRECTION_EN} {1}
    set_instance_parameter_value emif_fm_0 {CTRL_DDR4_ECC_EN} {1}
    set_instance_parameter_value emif_fm_0 {MEM_DDR4_FORMAT_ENUM} {MEM_FORMAT_SODIMM}
    set_instance_parameter_value emif_fm_0 {MEM_DDR4_ROW_ADDR_WIDTH} {16}
    set_instance_parameter_value emif_fm_0 {MEM_DDR4_SPEEDBIN_ENUM} {DDR4_SPEEDBIN_3200}
    set_instance_parameter_value emif_fm_0 {MEM_DDR4_TCCD_L_CYC} {7}
    set_instance_parameter_value emif_fm_0 {MEM_DDR4_TCL} {22}
    set_instance_parameter_value emif_fm_0 {MEM_DDR4_TDIVW_TOTAL_UI} {0.23}
    set_instance_parameter_value emif_fm_0 {MEM_DDR4_TDQSCK_PS} {160}
    set_instance_parameter_value emif_fm_0 {MEM_DDR4_TDQSQ_UI} {0.2}
    set_instance_parameter_value emif_fm_0 {MEM_DDR4_TIH_DC_MV} {65}
    set_instance_parameter_value emif_fm_0 {MEM_DDR4_TIH_PS} {65}
    set_instance_parameter_value emif_fm_0 {MEM_DDR4_TIS_AC_MV} {90}
    set_instance_parameter_value emif_fm_0 {MEM_DDR4_TIS_PS} {40}
    set_instance_parameter_value emif_fm_0 {MEM_DDR4_TQH_UI} {0.7}
    set_instance_parameter_value emif_fm_0 {MEM_DDR4_TQSH_CYC} {0.4}
    set_instance_parameter_value emif_fm_0 {MEM_DDR4_TRCD_NS} {13.75}
    set_instance_parameter_value emif_fm_0 {MEM_DDR4_TRFC_NS} {350.0}
    set_instance_parameter_value emif_fm_0 {MEM_DDR4_TRP_NS} {13.75}
    set_instance_parameter_value emif_fm_0 {MEM_DDR4_TRRD_L_CYC} {7}
    set_instance_parameter_value emif_fm_0 {MEM_DDR4_TWTR_L_CYC} {10}
    set_instance_parameter_value emif_fm_0 {MEM_DDR4_TWTR_S_CYC} {4}
    set_instance_parameter_value emif_fm_0 {MEM_DDR4_VDIVW_TOTAL} {110}
    set_instance_parameter_value emif_fm_0 {MEM_DDR4_WTCL} {18}
    set_instance_parameter_value emif_fm_0 {PHY_DDR4_ALLOW_72_DQ_WIDTH} {0}
    set_instance_parameter_value emif_fm_0 {PHY_DDR4_MEM_CLK_FREQ_MHZ} {1333.333}

    $adjust_proc

    set_instance_parameter_value emif_fm_0 {PHY_DDR4_USER_REF_CLK_FREQ_MHZ} {33.333}
    set_instance_property emif_fm_0 AUTO_EXPORT true

    # add the exports
    set_interface_property local_reset_req EXPORT_OF emif_fm_0.local_reset_req
    set_interface_property local_reset_status EXPORT_OF emif_fm_0.local_reset_status
    set_interface_property pll_ref_clk EXPORT_OF emif_fm_0.pll_ref_clk
    set_interface_property oct EXPORT_OF emif_fm_0.oct
    set_interface_property mem EXPORT_OF emif_fm_0.mem
    set_interface_property status EXPORT_OF emif_fm_0.status
    set_interface_property emif_usr_reset_n EXPORT_OF emif_fm_0.emif_usr_reset_n
    set_interface_property emif_usr_clk EXPORT_OF emif_fm_0.emif_usr_clk
    set_interface_property ctrl_amm_0 EXPORT_OF emif_fm_0.ctrl_amm_0
    set_interface_property emif_calbus EXPORT_OF emif_fm_0.emif_calbus
    set_interface_property emif_calbus_clk EXPORT_OF emif_fm_0.emif_calbus_clk

    save_system $ipname

}

proc do_nothing {} {}

set cb do_nothing
if {$PARAMS(IP_COMP_TYPE) == 0} {
    set cb do_adjust_onboard_ddr4_ip_0
} elseif {$PARAMS(IP_COMP_TYPE) == 1} {
    set cb do_adjust_onboard_ddr4_ip_1
}

do_adjust_onboard_ddr4_ip $PARAMS(IP_DEVICE) $PARAMS(IP_DEVICE_FAMILY) $PARAMS(IP_COMP_NAME) $PARAMS(IP_BUILD_DIR)/[get_ip_filename $PARAMS(IP_COMP_NAME)] $cb
