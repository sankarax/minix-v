# MINI-XV

MINI-XV is a 32-bit multi-cycle RISC-V-based SoC implemented in SystemVerilog. The project includes a custom CPU core, memory system, memory-mapped peripheral bus, FIFO, and UART transmitter.

The processor can execute machine code generated from C using the RISC-V GCC toolchain.

## Features

- 32-bit multi-cycle RISC-V CPU
- Controller FSM and datapath
- 32-register register file and ALU
- Arithmetic, logical, load/store, branch, and jump instructions
- Instruction and data memory
- Memory-mapped OBI peripheral interface
- FIFO-buffered UART transmitter
- Self-checking SystemVerilog testbenches

## C Program Execution

A Fibonacci program written in C is compiled using RISC-V GCC and executed directly on MINI-XV.

The complete data path was verified:

```text
C Program
   |
RISC-V GCC
   |
Machine Code
   |
MINI-XV
   |
OBI Bus
   |
FIFO
   |
UART TX
```

The processor successfully computes:

```text
F(40) = 102334155
```

All 40 Fibonacci values are also transmitted and verified through the UART interface.

## Project Structure

```text
rtl/        SystemVerilog RTL
tb/         Verification testbenches
software/   C program and RISC-V machine code
```

## Tools

- SystemVerilog
- AMD Vivado
- RISC-V GCC Toolchain

## Status

All CPU instruction, compiled C, and end-to-end UART verification tests pass.
