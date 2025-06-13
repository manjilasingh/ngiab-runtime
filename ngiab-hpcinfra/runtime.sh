#!/bin/bash

set -e

# Get command line arguments
GAGE_ID=${1:-"gage-01583500"} 
START_DATE=${2:-"2020-10-01"}  
END_DATE=${3:-"2020-10-10"}  
RUN_MODE=${4:-"serial"}     

USER="msingh9"
PREPROCESS_OUTPUT="/home/$USER/ngiab_preprocess_output/$GAGE_ID"
HOST_DATA_PATH="$PREPROCESS_OUTPUT"

echo "=== Configuration ==="
echo "Gage ID: $GAGE_ID"
echo "Start Date: $START_DATE"
echo "End Date: $END_DATE"
echo "Run Mode: $RUN_MODE"
echo "===================="

echo "=== Deleting existing files in /home/$USER/ngiab_preprocess_output ==="
rm -rf "/home/$USER/ngiab_preprocess_output"/*

# preprocess data and time it
echo "=== Running data preprocessing with timing ==="
start_preprocess=$(date +%s)
uvx --from ngiab_data_preprocess cli -i "$GAGE_ID" -sfr --start "$START_DATE" --end "$END_DATE"
end_preprocess=$(date +%s)
preprocess_time=$((end_preprocess - start_preprocess))

# Clean outputs and restarts
for folder in outputs restarts; do
    DIR="$HOST_DATA_PATH/$folder"
    if [ -d "$DIR" ]; then
        echo "Deleting all files in $DIR..."
        find "$DIR" -type f -delete
    fi
    echo "$folder folder is clean."
done

# Detect architecture and set appropriate image
if uname -a | grep -q 'arm64\|aarch64'; then
    ARCH=arm64
    IMAGE_URL=library://trupeshkumarpatel/awiciroh/ciroh-ngen-singularity:latest_arm
    IMAGE_NAME=ciroh-ngen-singularity_latest.sif
else
    ARCH=amd64
    IMAGE_URL=library://ciroh-it-support/ngiab/ciroh-ngen-singularity:latest_x86
    IMAGE_NAME=ciroh-ngen-singularity_latest.sif
fi

# Pull latest Singularity image
echo "Pulling latest Singularity image..."
singularity pull -F --arch $ARCH $IMAGE_NAME $IMAGE_URL

echo "Running NextGen model in $RUN_MODE mode..."
echo "=== Running NGIAB (NextGen) with Singularity ==="
start_ngen=$(date +%s)
if [ "$RUN_MODE" = "parallel" ]; then
    singularity run --bind "$HOST_DATA_PATH:/ngen/ngen/data" $IMAGE_NAME /ngen/ngen/data auto 4
else
    singularity run --bind "$HOST_DATA_PATH:/ngen/ngen/data" $IMAGE_NAME /ngen/ngen/data auto 1
fi
end_ngen=$(date +%s)
ngen_time=$((end_ngen - start_ngen))

echo ""
echo "==================== SUMMARY ===================="
echo "Configuration:"
echo "  Gage ID:    $GAGE_ID"
echo "  Start Date: $START_DATE"
echo "  End Date:   $END_DATE"
echo "  Run Mode:   $RUN_MODE"
echo ""
echo "Timing Results:"
echo "Data Preprocess Time: $preprocess_time seconds"
echo "NGIAB Run Time:      $ngen_time seconds"
echo "================================================="

exit 0 