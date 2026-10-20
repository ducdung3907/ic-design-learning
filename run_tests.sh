#!/usr/bin/env bash
# Compile and run every testbench in this repo with Icarus Verilog.
#
# Usage:
#   ./run_tests.sh                  # run all modules
#   ./run_tests.sh fifo/async_fifo  # run one module folder
#
# Each module folder holds its design files plus one tb_*.sv testbench.
# Build outputs and waveforms go to build/ (ignored by git).

set -u
ROOT="$(cd "$(dirname "$0")" && pwd)"
BUILD="$ROOT/build"
mkdir -p "$BUILD"

if ! command -v iverilog >/dev/null 2>&1; then
    echo "iverilog not found. Install Icarus Verilog first (e.g. 'brew install icarus-verilog' or 'sudo apt install iverilog')."
    exit 1
fi

if [ $# -gt 0 ]; then
    DIRS=("$@")
else
    mapfile -t DIRS < <(cd "$ROOT" && find . -name 'tb_*.sv' -not -path './build/*' -exec dirname {} \; | sed 's|^\./||' | sort -u)
fi

pass=0; fail=0; ran=0
printf "%-34s %s\n" "MODULE" "RESULT"
printf "%-34s %s\n" "------" "------"

for dir in "${DIRS[@]}"; do
    dir="${dir%/}"
    name="$(echo "$dir" | tr '/' '_')"
    log="$BUILD/$name.log"

    designs=$(cd "$ROOT/$dir" && ls *.sv | grep -v '^tb_')
    tbs=$(cd "$ROOT/$dir" && ls tb_*.sv)

    if ! (cd "$ROOT/$dir" && iverilog -g2012 -o "$BUILD/$name.vvp" $designs $tbs) >"$log" 2>&1; then
        printf "%-34s %s\n" "$dir" "FAIL (does not compile, see build/$name.log)"
        fail=$((fail + 1)); continue
    fi

    # Run from build/ so any .vcd waveform the testbench dumps lands there.
    (cd "$BUILD" && timeout 120 vvp -n "$name.vvp") >>"$log" 2>&1
    status=$?

    if [ $status -ne 0 ] || grep -qiE '\bFAIL|ERROR|FATAL|mismatch' "$log"; then
        printf "%-34s %s\n" "$dir" "FAIL (see build/$name.log)"
        fail=$((fail + 1))
    elif grep -qiE 'PASS|SUCCESS' "$log"; then
        printf "%-34s %s\n" "$dir" "PASS"
        pass=$((pass + 1))
    else
        printf "%-34s %s\n" "$dir" "RAN (no self-check, inspect waveform/log)"
        ran=$((ran + 1))
    fi
done

echo
echo "Summary: $pass passed, $fail failed, $ran ran without a self-check"
[ $fail -eq 0 ]
