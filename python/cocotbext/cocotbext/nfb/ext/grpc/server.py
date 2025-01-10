import time
import logging
import socket

import grpc
import cocotb

from concurrent import futures
from threading import Thread

from .nfb import NfbServicer
from .dma import DmaServicer

import nfb.ext.protobuf.v1.nfb_pb2_grpc as nfb_pb_grpc
import nfb.ext.protobuf.v1.dma_pb2_grpc as dma_pb_grpc


class NfbDmaThreadedGrpcServer:
    def __init__(self, ram, dev, addr="127.0.0.1", port=50051):
        super().__init__()
        self._log = logging.getLogger(__name__)

        self._port = port

        self._mi_reciver = NfbServicer(dev)
        self._dma_reciver = DmaServicer(ram)

        self._server = grpc.server(futures.ThreadPoolExecutor())
        self._server.add_insecure_port(f"{addr}:{port}")
        nfb_pb_grpc.add_NfbServicer_to_server(self._mi_reciver, self._server)
        dma_pb_grpc.add_DmaServicer_to_server(self._dma_reciver, self._server)

        self._thread = Thread(target=self._run)
        self._thread_terminate = False

    def _run(self):
        self._server.start()

        while not cocotb.regression_manager._tearing_down and not self._thread_terminate:
            time.sleep(0.1)

        self._dma_reciver._logout()
        self._mi_reciver.resp_force()
        self._server.stop(2.0)
        self._server.wait_for_termination()

    def start(self):
        self._thread.start()
        self._log.info(f"gRPC server started, listening on {self._port}. Device string: libnfb-ext-grpc.so:grpc+dma_vas:{socket.gethostname()}:{self._port}")

    def close(self):
        self._thread_terminate = True

    def __enter__(self):
        self.start()

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()
