# monitors.py: Specialzed MVBMonitor for MVB_HASH_TABLE_SIMPLE
# Copyright (C) 2024 CESNET z. s. p. o.
# Author(s): Ondřej Schwarz <Ondrej.Schwarz@cesnet.cz>
#
# SPDX-License-Identifier: BSD-3-Clause

from cocotbext.ofm.mvb.monitors import MVBMonitor
from cocotbext.ofm.mvb.transaction import MvbTrClassic


class MVB_HASH_TABLE_SIMPLE_Monitor(MVBMonitor):
    _signals = ["data", "match", "vld", "src_rdy", "dst_rdy"]

    def recv_bytes(self, vld):
        data_val = self.bus.data.value
        data_val.big_endian = False
        data_bytes = data_val.buff

        match_val = self.bus.match.value
        match_val.big_endian = False

        self.log.debug(f"MATCH: {match_val}")

        item_bytes = self._item_widths["data"] // 8
        for i in range(self._items):
            # Mask and shift the Valid signal per each Item
            if vld & 1:
                if match_val & 1:
                    # Getting the data slice (Item) from the "bytes" transaction
                    data_b = data_bytes[i*item_bytes : (i+1)*item_bytes]
                    # Converting the data slice (Item) to the MvbTrClassic object
                    mvb_tr = MvbTrClassic.from_bytes(data_b)
                    self._recv((mvb_tr, 1))
                else:
                    mvb_tr = MvbTrClassic()
                    mvb_tr.data = 0
                    self._recv((mvb_tr, 0))
            match_val >>= 1
            vld >>= 1
