# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
[Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) format is required for commit messages.

## [Unreleased]

### Added
- cocotb: Introduced generator of random integers.
- cocotb: Introduced MVB rate limiter.
- build: Introduced EXPERIMENTAL env.sh file with mandatory environment variables.
- build: Introduced PLATFORM_TAGS variable for platform, replacement for SYNTH_FLAGS(TOOL).
- build: Introduced templates for DTS generation.
- cards: Introduced support for Terasic A2700 Accelerator card.
- comp: Introduced MFB_MVB_APPENDER component.
- comp: Introduced MVB_ITEM_COLLISION_RESOLVER component.
- comp: Introduced MEM_CLEAR component.
- comp: Added packages for statistics processing in Data Logger component.
- core: Added MISC signals between Top-Level and APP/PCIE/NET core.
- dma: Added performance counters to measure blocking behavior in RX DMA Calypte.
- uvm: Added support of the CMAC variant in Network Module verification.
- ver: Added meters to AVST(PCIE) and AXI(PCIE) for the old verification.
- pkg: Added two functions for slv array concatenation to TYPE_PACK.
- ci: Introduced checking of commit messages in MR using commitlint.

### Changed
- cocotb: Refactored implementation of MVB transactions and their usage in drivers and monitors.
- cocotb: Used prepare.sh + pyproject.toml instead of dep. list in cocotb top-level simulation.
- comp: Improved statistics processing for Data Logger component.
- comp: Refactored implementation of Histogramer component.
- comp: Refactored implementation of TCAM2 component.
- comp: Refactored implementation of MVB_TCAM component.
- core: Enabled Device Tree on all PCIe endpoints. This is required for proper identification of PCIe endpoints when bifurcation is enabled.
- docs: Improved NDK-FPGA documentation.
- uvm: Improved print of MVB transaction for APP-UVM verifications.

### Deprecated

### Removed

### Fixed
- cocotb: Fixed SOF/EOF error checking in cocotb MFB monitor.
- comp: Fixed histogram box update in Histogramer component.
- core: Fixed width of demo/testing ports in Network Module.
- uvm: Fixed LOGIC_VECTOR_ARRAY sequencer, the DB registration macro is now parameterized.
- uvm: Fixed count speed in MFB bus.

### Security

## [0.7.2] - 2024-10-17

### Fixed

- Fixed missing prefix DMA Medusa jenkins verification script.
- NFB-200G2QL: Fixed missing lock DNA_PORT2E to X0Y1 due to different Chip ID in each SLRs (private submodule).
- NFB-200G2QL: Fixed all PCIE paths for pblock (private submodule).

## [0.7.1] - 2024-10-16

### Fixed

- Fixed PCIE0 path for pblock to SLR1 on Netcope NFB-200G2QL card (private submodule).
- Fixed single-bit input problem on Agilex DSP counters in new Quartus.
- Fixed coding style in lots of files.
- Fixed Modules.tcl paths due to compatibility with new NDK-FPGA in external APPs.
- Fixed verification jenkins files.
- Fixed build jenkins files of APP-Minimal.

## [0.7.0] - 2024-10-09

- Initial release of NDK-FPGA. The changelog for the previous versions of this
  repository (formerly known as ndk-app-minimal) was not maintained,
  so the changelog starts here.
