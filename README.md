# Hardware SHA-256 Accelerator

A synthesizable, iterative SHA-256 compression engine implemented in SystemVerilog, with a class-based verification environment and FPGA implementation on a Xilinx Artix-7 device.

## Overview

This project implements the SHA-256 compression function as a 64-round iterative datapath. A single compression-round unit is reused across all 64 rounds, providing an area-efficient hardware architecture.

The project also includes a Python reference implementation for generating verification vectors and a class-based SystemVerilog verification environment for self-checking functional verification.

The design was synthesized, placed, and routed using Xilinx Vivado and evaluated for resource utilization, timing, throughput, and power.

## Architecture

The SHA-256 compression engine consists of:

- 64-round iterative compression datapath
- Reusable single-round compression unit
- 32-bit working registers `a` through `h`
- 64-word message schedule
- SHA-256 round constants
- SHA-256 initial hash values
- FSM-based control
- FPGA wrapper with a serialized message-schedule interface

### Compression Flow

```text
                 +----------------------+
                 |  Message Schedule    |
                 |     W[0] ... W[63]   |
                 +----------+-----------+
                            |
                            v
                 +----------------------+
                 |   Compression Round  |
                 |                      |
                 |  Σ0, Σ1, Ch, Maj      |
                 |  T1, T2              |
                 +----------+-----------+
                            |
                            v
                 +----------------------+
                 |   a,b,c,d,e,f,g,h    |
                 |      Registers       |
                 +----------+-----------+
                            |
                            +----> Next Round
```
## Final Results

| Metric | Result |
|---|---:|
| Architecture | **64-round iterative SHA-256** |
| Verification | **1,000 / 1,000 passed** |
| Pass Rate | **100%** |
| LUTs | **1,346** |
| Flip-Flops | **2,582** |
| BRAM | **0** |
| DSP | **0** |
| Post-route Fmax | **85.7 MHz** |
| Core Throughput | **664 Mbps** |
| Estimated On-Chip Power | **98 mW** |
