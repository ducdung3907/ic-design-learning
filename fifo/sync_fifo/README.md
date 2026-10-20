# sync_fifo: Synchronous FIFO

A single-clock FIFO built as a circular buffer. Read and write pointers wrap at `DEPTH`, and an occupancy `count` drives the `full` and `empty` flags. Writes when full and reads when empty are ignored. A simultaneous read and write keeps `count` unchanged. `DEPTH` does not need to be a power of two (default 5).

| Port | Dir | Width | Description |
| --- | --- | --- | --- |
| `clk`, `rst_n` | in | 1 | Clock, async reset (active low) |
| `wr_en`, `din` | in | 1, `WIDTH` | Write request and data |
| `rd_en` | in | 1 | Read request |
| `dout` | out | `WIDTH` | Read data, valid one cycle after `rd_en` |
| `full`, `empty` | out | 1 | Status flags |
| `count` | out | `$clog2(DEPTH+1)` | Number of stored words |

**Test:** `tb_sync_fifo.sv` is self-checking: it compares `dout`, `full` and `empty` against a reference model every cycle, including simultaneous read/write. Status: PASS.

```bash
iverilog -g2012 -o sim.vvp sync_fifo.sv tb_sync_fifo.sv && vvp sim.vvp
```
