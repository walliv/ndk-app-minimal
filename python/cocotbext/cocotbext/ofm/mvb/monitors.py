# monitors.py: MVBMonitor
# Copyright (C) 2024 CESNET z. s. p. o.
# Author(s): Ondřej Schwarz <Ondrej.Schwarz@cesnet.cz>
#
# SPDX-License-Identifier: BSD-3-Clause

from cocotb_bus.monitors import BusMonitor
from cocotb.triggers import RisingEdge


class MVBProtocolError(Exception):
    pass


class MVBMonitor(BusMonitor):
    """
    Master monitor intended for monitoring the MVB bus.
    """
    _signals = ["data", "vld", "src_rdy", "dst_rdy"]

    def __init__(self, entity, name, clock, array_idx=None) -> None:
        super().__init__(entity, name, clock, array_idx=array_idx)
        self.__item_cnt = 0
        self.__items = len(self.bus.vld)
        self.__word_width = len(self.bus.data) // 8  # width in bytes
        self.__item_width = self.__word_width // self.__items

    @property
    def item_cnt(self) -> int:
        """The number of MVB transactions proccessed."""
        return self.__item_cnt

    @property
    def items(self) -> int:
        """The number of MVB items."""
        return self.__items

    @property
    def word_width(self) -> int:
        """The width of MVB word in bytes."""
        return self.__word_width

    @property
    def item_width(self) -> int:
        """The width of MVB item in bytes."""
        return self.__item_width

    def _is_valid_word(self, signal_src_rdy, signal_dst_rdy) -> bool:
        """Checks if the received word is valid transaction."""
        if signal_dst_rdy is None:
            return (signal_src_rdy.value == 1)
        else:
            return (signal_src_rdy.value == 1) and (signal_dst_rdy.value == 1)

    def receive_data(self, data, offset):
        self._recv(data[offset*self.__item_width:(offset+1)*self.__item_width])

    async def _monitor_recv(self) -> None:
        """Receive function used with cocotb testbench."""
        # Avoid spurious object creation by recycling
        clk_re = RisingEdge(self.clock)

        while True:
            await clk_re

            if self.in_reset:
                continue

            if self._is_valid_word(self.bus.src_rdy, self.bus.dst_rdy):
                data_val = self.bus.data.value
                data_val.big_endian = False
                data_bytes = data_val.buff

                vld = self.bus.vld.value

                for offset in range(self.__items):
                    if (vld[self.__items-offset-1]):
                        self.log.debug(f"ITEM {self._item_cnt}")
                        self.log.debug(f"received item: {data_bytes[offset*self.__item_width:(offset+1)*self.__item_width]}")
                        self.log.debug(f"word: {data_bytes}")
                        self.log.debug(f"item vld: {vld[self.__items-offset-1]}")
                        self.log.debug(f"word vld: {vld}")
                        self.receive_data(data_bytes, offset)

                        self._item_cnt += 1
