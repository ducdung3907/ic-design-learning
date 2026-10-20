# graycode_converter: Binary ↔ Gray Code

Two parameterised converters built with `generate` loops:

- `bin2gray`: `gray[i] = bin[i+1] ^ bin[i]`, MSB copied
- `gray2bin`: `bin[i] = bin[i+1] ^ gray[i]`, MSB copied

Gray code changes only one bit between consecutive values, which is why the async FIFO uses it for pointers crossing clock domains.

**Test:** `tb_gray_converters.sv` round-trips every value (bin → gray → bin) and checks that consecutive Gray codes differ by exactly one bit. Status: fails to run in Icarus 12 (known issue below).

```bash
iverilog -g2012 -o sim.vvp gray_converters.sv tb_gray_converters.sv && vvp sim.vvp
```

**Known issue:** Icarus needs a numeric first argument in `$fatal`. Change `$fatal("Error: ...")` to `$fatal(1, "Error: ...")` on lines 38 and 45 of the testbench.
