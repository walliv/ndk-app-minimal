# drivers.py: MVBDriver
# Copyright (C) 2024 CESNET z. s. p. o.
# Author(s): Ondřej Schwarz <Ondrej.Schwarz@cesnet.cz>
#            Daniel Kondys <kondys@cesnet.cz>
#
# SPDX-License-Identifier: BSD-3-Clause

from cocotb.handle import ModifiableObject

from cocotbext.ofm.base.drivers import BusDriver
from cocotbext.ofm.mvb.utils import random_delays_config
from cocotbext.ofm.utils.signals import await_signal_sync

from typing import Any

from ..base.generators import ItemRateLimiter
from ..base.transaction import IdleTransaction
from .transaction import MvbTrClassic


class MVBDriver(BusDriver):
    """Driver intender for the MVB bus used for sending transactions to the bus.

    Atributes:
       os(list): list of names of optional signals that are on the bus
                 (filtered version of the _optional_signals).
       _item_cnt(int): number of ready items in the current word.
       items(int): number of MVB items in word.
       item_widths(dict): dictionary where "keys" are the names of the (optional) signals on the bus
                          and "values" are their respective widths.
       bus_isarray(bool): indicates whether the bus is a vector or an array.
       _data(dict): dictionary where "keys" are the names of the (optional) signals on the bus
                    and "values" are their respective current values.
       _cDelays, _mode, _delays_fill: see random_delays_config in .utils.

    """

    _signals = ["vld", "src_rdy", "dst_rdy"]
    _optional_signals = ["data", "meta", "addr", "discard", "length"]

    def __init__(self, entity, name, clock, array_idx=None, mvb_params={}) -> None:
        super().__init__(entity, name, clock, array_idx=array_idx)

        self.os = [s for s in MVBDriver._optional_signals if hasattr(self.bus, s)]
        self._item_cnt = 0
        self.items = len(self.bus.vld)
        self.item_widths = self._get_item_widths()
        self.bus_isarray = not isinstance(getattr(self.bus, self.os[0]), ModifiableObject)
        self._data = self._init_data()
        self._cDelays, self._mode, self._delays_fill = random_delays_config(self.items, mvb_params)

        self._clear_control_signals()
        self.bus.vld.value = 0
        self.bus.src_rdy.value = 0

    def _get_item_widths(self) -> dict:
        """Make a dictionary of all optional signals on the bus and the width of each one's item."""

        return {s: len(getattr(self.bus, s)) // self.items for s in self.os}

    def _init_data(self) -> dict:
        """Make a dictionary of all optional signals on the bus and initialize their values."""

        if self.bus_isarray:
            return {s: [0] * self.items for s in self.os}
        else:
            return {s: 0 for s in self.os}

    def _clear_control_signals(self) -> None:
        """Sets control signals to default values without sending them to the MVB bus."""

        if self.bus_isarray:
            for sig in self._data:
                self._data[sig] = [0] * self.items
        else:
            for sig in self._data:
                self._data[sig] = 0
        self._vld = 0
        self._src_rdy = 0

    def _propagate_control_signals(self) -> None:
        """Sends value of control signals to the MVB bus."""

        for sig, val in self._data.items():
            getattr(self.bus, sig).value = val
        self.bus.vld.value = self._vld
        self.bus.src_rdy.value = self._src_rdy

    async def _stack_items(self, transaction):
        """Concatenates transactions (MVB Items) to form a word on the bus"""

        # TODO: account for Idle transactions
        if self.bus_isarray:
            for signal in self._data:
                item_ptr = self.items-1 - self._item_cnt
                self._data[signal][item_ptr] = getattr(transaction, signal)
        else:
            for signal, value in self._data.items():
                shift_size = self.item_widths[signal] * self._item_cnt
                tr_part = getattr(transaction, signal)
                # Prepend the Item to the word: shift and OR
                self._data[signal] = (tr_part << shift_size) | value

    async def _move_word(self) -> None:
        """Sends MVB word to the MVB bus if possible and clears the word."""

        self._src_rdy = 1 if self._vld > 0 else 0
        self._propagate_control_signals()

        await self._clk_re
        await await_signal_sync(clk_re=self._clk_re, signal=self.bus.dst_rdy, value=1)

        self._clear_control_signals()

    async def _driver_send(self, transaction: Any, sync: bool = True, **kwargs: Any) -> None:
        """Prepares and sends transaction to the MVB bus."""

        self.log.debug(f"Recieved item: {transaction}")

        if isinstance(data, bytes):
            mvb_tr = MvbTrClassic.from_bytes(data)
        else:
            mvb_tr = data
        await self._stack_items(mvb_tr)

        self._vld |= 1 << self._item_cnt
        self._item_cnt += 1

        # self.log.debug("Current word state:")
        # self.log.debug(f"\t{self._item_cnt}/{self.items} Items filled")
        # self.log.debug(f"\tData: {self._data}")

        if self._item_cnt == self.items:
            await self._move_word()
            self._item_cnt = 0

    async def _send_thread(self) -> None:
        """Function used with cocotb testbench."""

        while True:
            while not self._sendQ:
                self._pending.clear()
                await self._pending.wait()

            while self._sendQ:
                transaction, callback, event, kwargs = self._sendQ.popleft()
                await self._send(transaction, callback=None, event=event, sync=False, **kwargs)
                if event:
                    event.set()
                if callback:
                    callback(transaction)

            await self._move_word()
            await self._move_word()
