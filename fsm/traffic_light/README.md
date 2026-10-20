# traffic_light: Traffic Light Controller

A timed FSM for a two-road junction (north-south and east-west). It cycles through `NS_GREEN → NS_YELLOW → EW_GREEN → EW_YELLOW`, staying `GREEN_TIME` cycles in each green state and `YELLOW_TIME` cycles in each yellow state. One road is always red while the other is green or yellow.

| Port | Dir | Width | Description |
| --- | --- | --- | --- |
| `clk`, `rst_n` | in | 1 | Clock, async reset (active low) |
| `ns`, `ew` | out | 3 | One-hot light: `100` red, `010` yellow, `001` green |

Parameters: `GREEN_TIME` (default 5), `YELLOW_TIME` (default 2).

**Test:** `tb_traffic_light.sv` checks the full light sequence and timing for 3 different parameter settings. Status: PASS.

```bash
iverilog -g2012 -o sim.vvp traffic_light.sv tb_traffic_light.sv && vvp sim.vvp
```

**Review note:** `state` is assigned with blocking `=` inside `always_ff`. It simulates correctly here, but non-blocking `<=` is the usual rule for registers in `always_ff`.
