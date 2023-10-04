#!/usr/bin/env python3

from os import remove
from os.path import exists,dirname,join, abspath

script_dir = dirname(abspath(__file__))
filename = "floorplan_with_pci.xdc"

# Construct the full path to the file
file_path = join(script_dir, filename)

if exists(file_path):
   remove(file_path)


with open(file_path, mode='w', newline='\n', encoding='UTF-8') as f:
    path_root = "fpga_common_i/app_i/subcore_i/"
    k = 0

    for j in range (15):
        for i in range (3):
            pblock_name = "pblock_cluster_" + str(k)
            cr = "\n"
            f.write("#-------------------------- " + pblock_name + "-------------------------------#\n")
            f.write("create_pblock " + pblock_name + "\n")
            if k==17 or k==20 or k==23 or k==26:
                f.write("resize_pblock [get_pblock " + pblock_name + "] -add {CLOCKREGION_X" + str(2*i) +"Y" + str(j) + ":CLOCKREGION_X" + str(2*i) +"Y" + str(j) +"}\n")
            else:
                f.write("resize_pblock [get_pblock " + pblock_name + "] -add {CLOCKREGION_X" + str(2*i) +"Y" + str(j) + ":CLOCKREGION_X" + str(2*i+1) +"Y" + str(j) +"}\n")
            f.write("set_property IS_SOFT false [get_pblocks " + pblock_name +"]\n")
            f.write("add_cells_to_pblock " + pblock_name + " [get_cells " + path_root + "array_gen[" + str(k) +"]*"  + "]\n")
            f.write("set_property CONTAIN_ROUTING TRUE [get_pblocks "+ pblock_name + "]\n")
            f.write("#-----------------------------------------------------------------------------------------------------------------------------------#" + cr + "\n")
            k=k+1
