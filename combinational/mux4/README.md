# mux4: 4-to-1 Multiplexer

A parameterised 4-to-1 multiplexer. `sel` picks one of `d0`–`d3` using a `case` statement inside `always_comb`, with a `default` branch to avoid inferring a latch. A one-line ternary version is left commented out for comparison.

| Port | Dir | Width | Description |
| --- | --- | --- | --- |
| `d0`–`d3` | in | `WIDTH` (default 4) | Data inputs |
| `sel` | in | 2 | Select |
| `y` | out | `WIDTH` | Selected input |

**Test:** `tb_mux4.sv`. Status: does not compile yet (known issue below).

```bash
iverilog -g2012 -o sim.vvp mux4.sv tb_mux4.sv && vvp sim.vvp
```

**Known issues**

- `always_comb begin` is missing its closing `end` before `endmodule`.
- The testbench drives 1-bit `d0`–`d3` and `y`, while the module defaults to `WIDTH = 4`. Set `WIDTH` to 1 in the testbench instance, or widen the testbench signals.
