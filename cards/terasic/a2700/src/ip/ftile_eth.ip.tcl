package require -exact qsys 21.3

array set PARAMS $IP_PARAMS_L
source $PARAMS(IP_COMMON_TCL)

# adjust parameters in "ftile_eth_ip" system
proc do_adjust_ftile_eth_ip {device family ipname filename} {

    load_system $filename
    set_project_property DEVICE $device
    set_project_property DEVICE_FAMILY $family
    set_project_property HIDE_FROM_IP_CATALOG {true}

    # common IP core parameters
    set_instance_parameter_value eth_f_0 {DV_OVERRIDE} {1}
    set_instance_parameter_value eth_f_0 {ENABLE_ETK_GUI} {1}
    set_instance_parameter_value eth_f_0 {SYSPLL_RATE_GUI} {1}
    set_instance_parameter_value eth_f_0 {enforce_max_frame_size_gui} {1}
    set_instance_parameter_value eth_f_0 {link_fault_mode_gui} {Bidirectional}
    set_instance_parameter_value eth_f_0 {rx_max_frame_size_gui} {16383}
    set_instance_parameter_value eth_f_0 {rx_vlan_detection_gui} {0}
    set_instance_parameter_value eth_f_0 {tx_max_frame_size_gui} {16383}
    set_instance_parameter_value eth_f_0 {tx_vlan_detection_gui} {0}

    # configuration-specific parameters
    set_instance_parameter_value eth_f_0 {ENABLE_ADME_GUI} {1}
    set_instance_parameter_value eth_f_0 {ETH_MODE_GUI} {400G-8}
    set_instance_parameter_value eth_f_0 {PACKING_EN_GUI} {1}
    set_instance_parameter_value eth_f_0 {RSFEC_TYPE_GUI} {3}

    set_interface_property reconfig_xcvr_slave_1 EXPORT_OF eth_f_0.reconfig_xcvr_slave_1
    set_interface_property reconfig_xcvr_slave_2 EXPORT_OF eth_f_0.reconfig_xcvr_slave_2
    set_interface_property reconfig_xcvr_slave_3 EXPORT_OF eth_f_0.reconfig_xcvr_slave_3
    set_interface_property reconfig_xcvr_slave_4 EXPORT_OF eth_f_0.reconfig_xcvr_slave_4
    set_interface_property reconfig_xcvr_slave_5 EXPORT_OF eth_f_0.reconfig_xcvr_slave_5
    set_interface_property reconfig_xcvr_slave_6 EXPORT_OF eth_f_0.reconfig_xcvr_slave_6
    set_interface_property reconfig_xcvr_slave_7 EXPORT_OF eth_f_0.reconfig_xcvr_slave_7

    save_system $ipname
}

do_adjust_ftile_eth_ip $PARAMS(IP_DEVICE) $PARAMS(IP_DEVICE_FAMILY) $PARAMS(IP_COMP_NAME) $PARAMS(IP_BUILD_DIR)/[get_ip_filename $PARAMS(IP_COMP_NAME)]
