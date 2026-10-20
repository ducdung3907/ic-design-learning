# alu: Parameterised ALU

A combinational ALU (`alu4`) with a 3-bit opcode and status flags. `WIDTH` is a parameter and must be at least 2.

| `op` | Operation | Flags |
| --- | --- | --- |
| `000` | ADD | carry, signed overflow |
| `001` | SUB | borrow in `carry`, signed overflow |
| `010` | AND | |
| `011` | OR | |
| `100` | XOR | |
| `101` | SLT (signed set-less-than) | |
| `110` | Shift left by 1 | `carry` = bit shifted out |
| `111` | Shift right by 1 (logical) | `carry` = bit shifted out |

`zero` is high whenever the result `y` is 0.

**Test:** `tb_alu.sv` runs all 2048 op/operand combinations in two orders, then 4000 random cases (8096 checks). Status: PASS.

```bash
iverilog -g2012 -o sim.vvp alu.sv tb_alu.sv && vvp sim.vvp
```

Icarus prints "constant selects in always_* processes are not currently supported" warnings for this file. They are a simulator limitation and do not affect the result.
