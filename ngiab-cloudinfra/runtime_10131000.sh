#!/bin/bash

# Fixed gage ID
GAGE_ID="gage-10131000"

echo "Running 6 simulations for $GAGE_ID"
echo ""

# 1. 10-day period
echo "=== Running 10-day period (Oct 1-10) ==="
./runtime.sh "$GAGE_ID" "2020-10-01" "2020-10-10" "serial"
./runtime.sh "$GAGE_ID" "2020-10-01" "2020-10-10" "parallel"

# 2. 30-day period
echo "=== Running 30-day period (Oct 1-30) ==="
./runtime.sh "$GAGE_ID" "2020-10-01" "2020-10-30" "serial"
./runtime.sh "$GAGE_ID" "2020-10-01" "2020-10-30" "parallel"

# 3. 3-month period
echo "=== Running 3-month period (Oct 1 - Jan 31) ==="
./runtime.sh "$GAGE_ID" "2020-10-01" "2021-01-31" "serial"
./runtime.sh "$GAGE_ID" "2020-10-01" "2021-01-31" "parallel" 