# usr_constr.xdc

#set_false_path -through [get_ports cm_i/app_i/proc_rst]
#set_false_path -through [get_pins -filter {REF_PIN_NAME=~RESET} -of [get_cells * -hierarchical -filter {NAME=~ cm_i/app_i/subcore_i}] ]
set_false_path -from [get_pins {cm_i/reset_tree_gen_i/rst_sync_g[3].rst_sync_i/three_reg_sync.rff3_reg/C}] -through [get_pins -filter {REF_PIN_NAME=~RESET} -of [get_cells * -hierarchical -filter {NAME=~ cm_i/app_i/subcore_i}] ]
