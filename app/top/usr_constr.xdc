# usr_constr.xdc

#set_false_path -through [get_ports cm_i/app_i/proc_rst]
#set_false_path -through [get_pins -filter {REF_PIN_NAME=~RESET} -of [get_cells * -hierarchical -filter {NAME=~ cm_i/app_i/subcore_i}] ]
#set_false_path -from [get_pins {cm_i/reset_tree_gen_i/rst_sync_g[3].rst_sync_i/three_reg_sync.rff3_reg/C}] -through [get_pins -filter {REF_PIN_NAME=~RESET} -of [get_cells * -hierarchical -filter {NAME=~ cm_i/app_i/subcore_i}] ]
#set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets -of [get_pins -filter {REF_PIN_NAME=~O} -of [get_cells * -hierarchical -filter {NAME=~ cm_i/app_i/barrel_proc_debug_core_i/mi_rst_buf_i}] ] ]
set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets -of [get_pins -filter {REF_PIN_NAME=~O} -of [get_cells * -hierarchical -filter {NAME=~ cm_i/app_i/mi_rst_buf_i}] ] ]
set_property CLOCK_DEDICATED_ROUTE TRUE [get_nets -of [get_pins -filter {REF_PIN_NAME=~O} -of [get_cells * -filter {NAME=~ sysclk_ibuf_i}]]]
