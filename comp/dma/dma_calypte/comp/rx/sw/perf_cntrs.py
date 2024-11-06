#!/usr/bin/env python3
# Copyright (C) 2024 CESNET z. s. p. o.
# Author(s): Vladislav Valek <valekv@cesnet.cz>

import nfb
import argparse
from data_logger.data_logger import DataLogger
from time import sleep

import curses


class RxDmaPerfCounters(DataLogger):

    DT_COMPATIBLE = "cesnet,dma_calypte_rx_perf_cntrs"

    def __init__(self, **kwargs):
        super().__init__(**kwargs)

        self.counter_names = {
            0 : "PCIE_MFB_STALL_CNTR",
            1 : "DMA_HDR_ADDR_STALL_CNTR",
            2 : "DATA_ADDR_STALL_CNTR",
            3 : "DMA_HDR_ADDR_REQ_CNTR",
            4 : "DATA_ADDR_REQ_CNTR",
            5 : "PCIE_MFB_BEATS_CNTR"
        }

        self.cntr_num = self.config['CNTER_CNT']

    def show_cntrs(self):
        print("Loading {} counters.".format(self.cntr_num))

        for i in range(self.cntr_num):
            cntr_val = self.load_cnter(i)

            print("{}: {}".format(self.counter_names[i], cntr_val))

    def load_cntrs_all(self):
        cntr_storage = [0]*self.cntr_num

        for i in range(self.cntr_num):
            cntr_storage[i] = self.load_cnter(i)

        return cntr_storage

    def measure_blocking(self, stdscr):
        stdscr.clear()

        try:
            while True:
                cntr_storage = self.load_cntrs_all()

                if (cntr_storage[5] != 0):
                    pcie_mfb_stall = (cntr_storage[0] / cntr_storage[5]) * 100
                else:
                    pcie_mfb_stall = 0.0

                stdscr.addstr(0, 0, "PCIE IP stalls:         {:.2}% (absolute {})".format(pcie_mfb_stall, cntr_storage[0]))

                if (cntr_storage[4] != 0):
                    data_addr_stall = (cntr_storage[2] / cntr_storage[4]) * 100
                else:
                    data_addr_stall = 0.0

                stdscr.addstr(1, 0, "Wait for data address:  {:.2}% (absolute {})".format(data_addr_stall, cntr_storage[2]))

                if (cntr_storage[3] != 0):
                    dma_hdr_addr_stall = (cntr_storage[1] / cntr_storage[3]) * 100
                else:
                    dma_hdr_addr_stall = 0.0

                stdscr.addstr(2, 0, "Wait for DMA address:   {:.2}% (absolute {})".format(dma_hdr_addr_stall, cntr_storage[1]))

                stdscr.addstr(3, 0, "Total data address req: {}".format(cntr_storage[4]))
                stdscr.addstr(4, 0, "Total DMA addr req:     {}".format(cntr_storage[3]))
                stdscr.addstr(5, 0, "Total DMA PCIE beats:   {}".format(cntr_storage[5]))

                stdscr.refresh()
                sleep(1)
                stdscr.clear()

        except KeyboardInterrupt:
            print("Interrupt caught, terminating...")


def parseParams():
    parser = argparse.ArgumentParser(
        description="Control script for performance counters.",
    )

    access = parser.add_argument_group('Card specifiers')
    access.add_argument(
        '-d', '--device', default=nfb.libnfb.Nfb.default_dev_path,
        metavar='device', help="Target device")
    access.add_argument(
        '-i', '--index', type=int, metavar='index', default=0, help="Index of a counter array inside DeviceTree")

    common = parser.add_argument_group("Counters control")
    common.add_argument('-p', '--print', action='store_true', help="Prints internal registers in JSON format")
    common.add_argument('-m', '--measure', action='store_true', help="Continuously measures the amount of blocking")
    common.add_argument('--rst', action='store_true', help="Reset the component.")

    args = parser.parse_args()
    return args


if __name__ == '__main__':
    args = parseParams()
    perf_cntrs = RxDmaPerfCounters(dev=args.device, index=args.index)

    if args.rst:
        perf_cntrs.rst()
    elif args.print:
        print(perf_cntrs.stats_to_str(hist=True))
    elif args.measure:
        perf_cntrs.rst()
        curses.wrapper(perf_cntrs.measure_blocking)
    else:
        perf_cntrs.show_cntrs()
