# transaction.py: MI transactions
# Copyright (C) 2024 CESNET z. s. p. o.
# Author(s): Ondřej Schwarz <Ondrej.Schwarz@cesnet.cz>
#
# SPDX-License-Identifier: BSD-3-Clause

from cocotbext.ofm.base.transaction import Transaction
from dataclasses import dataclass
from enum import Enum


class MiTransactionType(Enum):
    Request = 0
    Response = 1


class MiBaseTransaction(Transaction):
    """Base class for MI Transactions with configurable data items"""


@dataclass
class MiRequestTransaction(MiBaseTransaction):
    """Transaction for MI Request driver."""
    trans_type: MiTransactionType = None
    addr: int = 0
    data: bytes = b""
    data_len: int = 0


@dataclass
class MiResponseTransaction(MiBaseTransaction):
    """Transaction for MI Response driver."""
    trans_type: MiTransactionType = None
    data: bytes = b""


@dataclass
class MiTransaction(MiRequestTransaction):
    """Full MI transaction for monitor and test."""
    be: int = 0
