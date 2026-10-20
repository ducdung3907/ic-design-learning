# IC Design Learning

Self-directed digital design exercises in **SystemVerilog**, written while studying Electrical and Electronic Engineering at NTU. The modules build up from combinational logic to sequential circuits, FSMs, clock-domain crossing and an asynchronous FIFO. Each module has its own testbench and is simulated with **Icarus Verilog**.

## Modules

| Area | Module | What it does | Key ideas |
| --- | --- | --- | --- |
| Combinational | [adder4](combinational/adder4) | Ripple-carry adder built from full adders | Structural design, `generate` loop, parameterised width |
| Combinational | [alu](combinational/alu) | ALU with 8 ops: ADD, SUB, AND, OR, XOR, SLT, SHL, SHR | Carry, signed overflow and zero flags |
| Combinational | [mux4](combinational/mux4) | 4-to-1 multiplexer | `case` in `always_comb`, latch avoidance |
| Combinational | [prio_encoder](combinational/prio_encoder) | 4-bit priority encoder with valid flag | `casez` with don't-cares |
| Combinational | [graycode_converter](combinational/graycode_converter) | Binary to Gray and Gray to binary | Parameterised `generate` |
| Combinational | [7seg](combinational/7seg) | Hex digit to 7-segment decoder | Lookup in `case` |
| Sequential | [counter4](sequential/counter4) | 4-bit up counter with enable | Async active-low reset, roll-over |
| Sequential | [shift_reg8](sequential/shift_reg8) | 8-bit shift register with parallel load | Load/enable priority |
| Sequential | [clk_div](sequential/clk_div) | Divide-by-N clock divider with tick output | Counter-based clock generation |
| FSM | [seq_detector_1011](fsm/seq_detector_1011) | Detects the overlapping bit pattern 1011 | Moore FSM, `enum` states |
| FSM | [traffic_light](fsm/traffic_light) | Two-road traffic light controller | Timed FSM, parameterised green/yellow times |
| CDC | [2-flop_sync](cdc/2-flop_sync) | Two-flop synchronizer | Metastability, clock-domain crossing |
| FIFO | [sync_fifo](fifo/sync_fifo) | Single-clock FIFO with full/empty/count | Circular buffer pointers |
| FIFO | [async_fifo](fifo/async_fifo) | Dual-clock FIFO | Gray-code pointers synchronized across clock domains |

## Running the tests

Install [Icarus Verilog](https://steveicarus.github.io/iverilog/), then from the repo root:

```bash
./run_tests.sh                  # run every testbench
./run_tests.sh fifo/async_fifo  # run one module
```

The script compiles each folder's design files with its `tb_*.sv` testbench, runs it, and prints PASS / FAIL for self-checking testbenches. Build files, logs and `.vcd` waveforms go to `build/`. Open a waveform with [GTKWave](https://gtkwave.sourceforge.net/), e.g. `gtkwave build/clk_div.vcd`.

To run one module by hand:

```bash
cd fifo/async_fifo
iverilog -g2012 -o sim.vvp async_fifo.sv gray_converters.sv synchronizer.sv tb_async_fifo.sv
vvp sim.vvp
```

## Repository layout

```
combinational/   adder4, alu, mux4, prio_encoder, graycode_converter, 7seg
sequential/      counter4, shift_reg8, clk_div
fsm/             seq_detector_1011, traffic_light
cdc/             2-flop_sync
fifo/            sync_fifo, async_fifo
run_tests.sh     compiles and runs every testbench
```

Each module folder holds the design file(s), a `tb_*.sv` testbench and a short README. `fifo/async_fifo` keeps its own copies of the synchronizer and Gray-code converters so it builds on its own.

## Tools

- SystemVerilog (IEEE 1800-2012)
- Icarus Verilog 12 for simulation

## AI use

- **Design (RTL):** all design modules (every `.sv` file not starting with `tb_`) were written by me.
- **Testbenches:** the `tb_*.sv` testbenches were generated with AI assistance (Claude Code), then run against my designs in Icarus Verilog.
- **Repo maintenance:** Claude Code reorganized the folder structure, wrote the READMEs and `run_tests.sh`, and made those commits under version control. That is why Claude appears as a contributor.
