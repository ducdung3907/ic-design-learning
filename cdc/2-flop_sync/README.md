# 2-flop_sync: Two-Flop Synchronizer

Passes a signal from another clock domain into `clk` through two flip-flops in series. If the first flop goes metastable, it has a full clock cycle to settle before the second flop samples it, which greatly reduces the chance of a metastable value reaching the logic.

| Port | Dir | Width | Description |
| --- | --- | --- | --- |
| `clk`, `rst_n` | in | 1 | Destination clock, async reset (active low) |
| `async_in` | in | `WIDTH` | Signal from the other clock domain |
| `sync_out` | out | `WIDTH` | Synchronized signal, 2 cycles later |

Multi-bit use is only safe when at most one bit changes at a time (for example a Gray-code pointer), which is how `fifo/async_fifo` uses it.

**Test:** `tb_synchronizer.sv` changes the input, including off the clock edge, and prints the output at each stage. It has no automatic pass/fail check, so read the printed log or the waveform.

```bash
iverilog -g2012 -o sim.vvp synchronizer.sv tb_synchronizer.sv && vvp sim.vvp
```
