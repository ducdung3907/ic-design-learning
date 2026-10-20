# clk_div: Clock Divider

`clk_divider` counts input clock cycles up to `N`. Every `N` cycles it toggles `clk_out` (so `clk_out` has a period of 2N input cycles) and pulses `tick` high for one cycle.

| Port | Dir | Width | Description |
| --- | --- | --- | --- |
| `clk`, `rst_n` | in | 1 | Clock, async reset (active low) |
| `tick` | out | 1 | One-cycle pulse every `N` cycles |
| `clk_out` | out | 1 | Divided clock |

Parameter `N` (default 4) sets the division.

**Test:** `tb_clk_divider.sv` runs the divider with `N = 4` and dumps `clk_div.vcd`. It has no automatic pass/fail check, so check the waveform:

```bash
iverilog -g2012 -o sim.vvp clk_divider.sv tb_clk_divider.sv && vvp sim.vvp
gtkwave clk_div.vcd
```
