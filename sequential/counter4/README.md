# counter4: 4-bit Up Counter

A 4-bit counter that increments on each rising clock edge while `en` is high and wraps from 15 to 0. `rst_n` is an asynchronous active-low reset.

| Port | Dir | Width | Description |
| --- | --- | --- | --- |
| `clk` | in | 1 | Clock |
| `rst_n` | in | 1 | Async reset, active low |
| `en` | in | 1 | Count enable |
| `count` | out | 4 | Current count |

**Test:** `tb_counter4.sv` checks counting, roll-over, hold when disabled, and reset mid-cycle (19 checks). Status: PASS.

```bash
iverilog -g2012 -o sim.vvp counter4.sv tb_counter4.sv && vvp sim.vvp
```
