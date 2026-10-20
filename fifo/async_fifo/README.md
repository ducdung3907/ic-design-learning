# async_fifo: Asynchronous (Dual-Clock) FIFO

A FIFO with independent write (`wclk`) and read (`rclk`) clocks, for passing data safely between clock domains.

How it works:

1. Each side keeps a binary pointer one bit wider than the address, so full and empty can be told apart.
2. Each pointer is converted to Gray code (`bin2gray`), so only one bit changes per increment.
3. The Gray pointer is passed into the other clock domain through a 2-flop `synchronizer`.
4. **Empty** (read side): the next read pointer equals the synchronized write pointer.
5. **Full** (write side): the next write pointer equals the synchronized read pointer with its top two bits inverted.
6. Flags are registered from the *next* pointer values, so they update in the same cycle as the pointer.

| Port | Dir | Width | Description |
| --- | --- | --- | --- |
| `wclk`, `rclk` | in | 1 | Write and read clocks |
| `rst_n` | in | 1 | Async reset (active low), shared by both domains |
| `wr_en`, `din` | in | 1, `WIDTH` | Write request and data |
| `full` | out | 1 | No space left (write domain) |
| `rd_en` | in | 1 | Read request |
| `dout` | out | `WIDTH` | Read data, one cycle of read latency |
| `empty` | out | 1 | No data available (read domain) |

`DEPTH` must be a power of two and at least 4; the module stops simulation with `$fatal` otherwise.

Files: `async_fifo.sv`, plus local copies of `gray_converters.sv` and `synchronizer.sv` (identical to the ones in `combinational/graycode_converter` and `cdc/2-flop_sync`) so this folder builds on its own.

**Test:** `tb_async_fifo.sv` runs the write clock at 10 ns and the read clock at 14 ns, checks every read against a reference queue, and checks that `full` asserts after exactly `DEPTH` writes. Status: PASS.

```bash
iverilog -g2012 -o sim.vvp async_fifo.sv gray_converters.sv synchronizer.sv tb_async_fifo.sv && vvp sim.vvp
```
