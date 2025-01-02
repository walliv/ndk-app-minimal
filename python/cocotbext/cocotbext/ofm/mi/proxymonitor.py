# proxymonitor.py: ProxyMonitor
# Copyright (C) 2024 CESNET z. s. p. o.
# Author(s): Ondřej Schwarz <Ondrej.Schwarz@cesnet.cz>
#
# SPDX-License-Identifier: BSD-3-Clause

from cocotbext.ofm.base.proxymonitor import ProxyMonitor
from cocotbext.ofm.mi.monitors import MIMonitor
from cocotbext.ofm.mi.transaction import MiTransaction, MiTransactionType


class MIProxyMonitor(ProxyMonitor):
    """
    Proxy Monitor intended for the MI Monitor. It filters out transactions sent
    from the wrong side (= "request" / "response").

    Example:
    Two MI monitors are connected to a MI Pipe, one is connected to the request (master)
    side and the other to the response (slave) side. When a transaction appears on
    the pipe, it is detected by both monitors, and both generate an MI transaction
    and send it to the scoreboard. However, only one of the two transactions is
    the wanted one. If the transaction on the bus was a request transaction, the
    transaction from the request monitor should be accepted and vice versa.
    The purpose of this monitor is to filter out the unwanted transactions.
    """
    def __init__(self, monitor: MIMonitor, side: MiTransactionType):
        """
        Args:
            monitor: BusMonitor which this class is to be the proxy for.
            side: which side is the monitor to be proxied connected to.
                  MiTransactionType.Request.value and MiTransactionType.Response.value should be used.
        """
        super().__init__(monitor)
        self._side = side

    def _filter_transaction(self, transaction: MiTransaction) -> MiTransaction:
        """Filter that lets through only the transactions from the chosen side."""
        if transaction.trans_type == self._side:
            return transaction
        else:
            return None
