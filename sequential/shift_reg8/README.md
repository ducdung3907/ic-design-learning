# shift_reg8: 8-bit Shift Register

An 8-bit register that either loads `data_in` in parallel or shifts left by one, taking `serial_in` into bit 0. `load` has priority over `en`. `rst_n` is an asynchronous active-low reset.

| Port | Dir | Width | Description |
| --- | --- | --- | --- |
| `clk`, `rst_n` | in | 1 | Clock, async reset (active low) |
| `load` | in | 1 | Parallel load (highest priority) |
| `en` | in | 1 | Shift enable |
| `serial_in` | in | 1 | Bit shifted in |
| `data_in` | in | 8 | Parallel load value |
| `q` | out | 8 | Register contents |

**Test:** `tb_shift_reg8.sv` checks load, shifting, load-over-enable priority and reset (9 checks). Status: PASS.

```bash
iverilog -g2012 -o sim.vvp shift_reg8.sv tb_shift_reg8.sv && vvp sim.vvp
```
