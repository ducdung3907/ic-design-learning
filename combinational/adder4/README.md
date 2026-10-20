# adder4: Ripple-Carry Adder

A ripple-carry adder built from 1-bit full adders.

`adder4.sv` contains three modules:

- `full_adder`: 1-bit full adder (`sum = a ^ b ^ cin`, majority-function carry)
- `adder4_slow`: 4-bit version wired by hand from four full adders
- `adder4`: parameterised `WIDTH`-bit version built with a `generate` loop

| Port | Dir | Width | Description |
| --- | --- | --- | --- |
| `a`, `b` | in | `WIDTH` | Operands |
| `cin` | in | 1 | Carry in |
| `sum` | out | `WIDTH` | Sum |
| `cout` | out | 1 | Carry out |

**Test:** `tb_adder4.sv` checks all 8 full-adder inputs and all 512 adder inputs (520 checks). Status: PASS.

```bash
iverilog -g2012 -o sim.vvp adder4.sv tb_adder4.sv && vvp sim.vvp
```
