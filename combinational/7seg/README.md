# 7seg: Hex to 7-Segment Decoder

`seven_seg` converts a 4-bit hex digit (0–F) into the segment pattern for a common-cathode 7-segment display (segment on = 1).

| Port | Dir | Width | Description |
| --- | --- | --- | --- |
| `hex_in` | in | 4 | Hex digit |
| `segments` | out | 7 | `{a, b, c, d, e, f, g}` |

**Test:** `tb_7seg.sv` checks all 16 digits. Status: PASS.

```bash
iverilog -g2012 -o sim.vvp 7seg.sv tb_7seg.sv && vvp sim.vvp
```
