# proxymonitor.py: ProxyMonitor
# Copyright (C) 2024 CESNET z. s. p. o.
# Author(s): Ondřej Schwarz <Ondrej.Schwarz@cesnet.cz>
#
# SPDX-License-Identifier: BSD-3-Clause

from cocotb_bus.monitors import BusMonitor
from abc import ABC, abstractmethod


class ProxyMonitor(BusMonitor, ABC):
    """
    Generic Proxy Monitor used for redirecting traffic from cocotb BusMonitor
    and running it through a filter. It automatically connects to the _recv
    function of the passed BusMonitor.

    Attributes:
        _item_cnt(int): number of items which successfully passed through the filter.
    """

    def __init__(self, monitor: BusMonitor):
        """
        Args:
            monitor: BusMonitor which this class is to be the proxy for.
        """
        super().__init__(monitor.entity, monitor.name, monitor.clock)
        monitor.add_callback(self.monitor_callback)
        self._item_cnt = 0

    @property
    def item_cnt(self):
        return self._item_cnt

    def monitor_callback(self, *args, **kwargs) -> None:
        """
        Callback connected to the passed BusMonitor's _recv function.
        The received transaction is run through a filter and then
        passed on through the _recv function.
        """
        filtered_transaction = self._filter_transaction(*args, **kwargs)

        if filtered_transaction is None:
            return

        self._recv(filtered_transaction)
        self._item_cnt += 1

    @abstractmethod
    def _filter_transaction(self, transaction, *args, **kwargs) -> any:
        """
        Filter function used in function monitor_callback. It is ment to be redefined
        for specific usecases.
        The placeholder filter implemented here lets all the transactions through.
        """
        return transaction

    async def _monitor_recv(self):
        """
        This function must be implemented in every BusMonitor child, however, here it has
        no use. However, it may be redifined for specific usecases.
        """
        pass
