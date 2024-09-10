#!/usr/bin/env python3
# Copyright (C) 2024 CESNET z. s. p. o.
# Author(s): Lukas Nevrkla <xnevrk03@stud.fit.vutbr.cz>

from setuptools import setup, find_packages

setup(
    name='logger_tools',
    version='1.0.0',
    author='Lukas Nevrkla',
    author_email='xnevrk03@stud.fit.vutbr.cz',
    description='SW tools for data_logger FPGA component',
    packages=find_packages(),
    install_requires=[
        'numpy',
        'pandas',
        'matplotlib',
        'seaborn',
        'Pillow'
    ],
    #extras_require={
    #    'nfb': ['nfb']
    #},
)
