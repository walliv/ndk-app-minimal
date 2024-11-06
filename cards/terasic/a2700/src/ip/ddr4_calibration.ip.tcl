package require -exact qsys 21.3

array set PARAMS $IP_PARAMS_L
source $PARAMS(IP_COMMON_TCL)

# adjust parameters in "ddr4_calibration_ip" system
proc do_adjust_ddr4_calibration_ip {device family ipname filename} {

    load_system $filename
    set_project_property DEVICE $device
    set_project_property DEVICE_FAMILY $family
    set_project_property HIDE_FROM_IP_CATALOG {true}

    set_instance_parameter_value emif_cal_0 {AXM_ID_NUM} {0}
    set_instance_parameter_value emif_cal_0 {DIAG_ENABLE_JTAG_UART} {0}
    set_instance_parameter_value emif_cal_0 {DIAG_EXPORT_SEQ_AVALON_SLAVE} {CAL_DEBUG_EXPORT_MODE_DISABLED}
    set_instance_parameter_value emif_cal_0 {DIAG_EXPORT_VJI} {0}
    set_instance_parameter_value emif_cal_0 {DIAG_EXTRA_CONFIGS} {}
    set_instance_parameter_value emif_cal_0 {DIAG_SIM_CAL_MODE_ENUM} {SIM_CAL_MODE_SKIP}
    set_instance_parameter_value emif_cal_0 {DIAG_SIM_VERBOSE} {0}
    set_instance_parameter_value emif_cal_0 {DIAG_SYNTH_FOR_SIM} {0}
    set_instance_parameter_value emif_cal_0 {ENABLE_DDRT} {0}
    set_instance_parameter_value emif_cal_0 {NUM_CALBUS_INTERFACE} {2}
    set_instance_parameter_value emif_cal_0 {PHY_DDRT_EXPORT_CLK_STP_IF} {0}
    set_instance_parameter_value emif_cal_0 {SHORT_QSYS_INTERFACE_NAMES} {1}
    set_instance_property emif_cal_0 AUTO_EXPORT true

    # add the exports
    set_interface_property emif_calbus_0 EXPORT_OF emif_cal_0.emif_calbus_0
    set_interface_property emif_calbus_1 EXPORT_OF emif_cal_0.emif_calbus_1
    set_interface_property emif_calbus_clk EXPORT_OF emif_cal_0.emif_calbus_clk

    save_system $ipname
}

do_adjust_ddr4_calibration_ip $PARAMS(IP_DEVICE) $PARAMS(IP_DEVICE_FAMILY) $PARAMS(IP_COMP_NAME) $PARAMS(IP_BUILD_DIR)/[get_ip_filename $PARAMS(IP_COMP_NAME)]
