# prio_encoder: 4-bit Priority Encoder

`priority_encoder` outputs the index of the highest set bit of `req`, using `casez` with don't-care bits. `valid` is low when no request bit is set.

| Port | Dir | Width | Description |
| --- | --- | --- | --- |
| `req` | in | 4 | Request lines (bit 3 has highest priority) |
| `enc_out` | out | 2 | Index of the highest active request |
| `valid` | out | 1 | High if any request is active |

**Test:** `tb_prio_encoder.sv` checks all 16 inputs. Status: PASS.

```bash
iverilog -g2012 -o sim.vvp prio_encoder.sv tb_prio_encoder.sv && vvp sim.vvp
```
