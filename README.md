# NGIAB-CloudInfra and NGIAB-HPCInfra Runtime Analysis

This repository contains runtime analysis scripts for NGIAB-CloudInfra and NGIAB-HPCInfra.

## Repository Structure

The repository contains runtime analysis scripts for multiple gage IDs:

- `runtime.sh` - Main runtime analysis script
- `runtime_10131000.sh` - Runtime analysis for gage-10131000
- `runtime_02369800.sh` - Runtime analysis for gage-02369800
- `runtime_01013500.sh` - Runtime analysis for gage-01013500

## Required Updates

Before running the runtime scripts, you need to update the following variables in `runtime.sh`:

1. **User Configuration**:
```bash
USER="your_username"  # Replace with your username
PREPROCESS_OUTPUT="/home/$USER/ngiab_preprocess_output/$GAGE_ID"  # Update path if needed
HOST_DATA_PATH="$PREPROCESS_OUTPUT"  # Update if using different data path
```

## Runtime Analysis

Each runtime script performs 6 simulations for a specific gage ID:

1. 10-day period (Oct 1-10, 2020)
   - Serial execution
   - Parallel execution

2. 30-day period (Oct 1-30, 2020)
   - Serial execution
   - Parallel execution

3. 3-month period (Oct 1, 2020 - Jan 31, 2021)
   - Serial execution
   - Parallel execution

## Usage

To run the runtime analysis:

1. Make the scripts executable:
```bash
chmod +x runtime.sh runtime_*.sh
```

2. Run the analysis for a specific gage:
```bash
./runtime_10131000.sh  # For gage-10131000
./runtime_02369800.sh  # For gage-02369800
./runtime_01013500.sh  # For gage-01013500
```

Or run with custom parameters:
```bash
./runtime.sh "gage-10131000" "2020-10-01" "2020-10-10" "parallel"
```

