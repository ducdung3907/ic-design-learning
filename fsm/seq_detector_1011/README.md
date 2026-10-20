# seq_detector_1011: Sequence Detector FSM

A Moore FSM that raises `detected` for one cycle after the serial input `din` has received `1011`. Overlapping sequences are detected, so `1011011` gives two detections.

States: `S_RESET → S_1 → S_10 → S_101 → S_1011`. The state register is in `always_ff`, and next-state/output logic is in `always_comb` with defaults to avoid latches.

| Port | Dir | Width | Description |
| --- | --- | --- | --- |
| `clk`, `rst_n` | in | 1 | Clock, async reset (active low) |
| `din` | in | 1 | Serial input bit |
| `detected` | out | 1 | High in state `S_1011` |

**Test:** `tb_seq_detector_1011.sv` feeds bit streams with false starts and overlaps (12 checks). Status: PASS.

```bash
iverilog -g2012 -o sim.vvp seq_detector_1011.sv tb_seq_detector_1011.sv && vvp sim.vvp
```
