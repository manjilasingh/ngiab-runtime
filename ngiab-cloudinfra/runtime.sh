#!/bin/bash

set -e

# Get command line arguments
GAGE_ID=${1:-"gage-01583500"} 
START_DATE=${2:-"2020-10-01"} 
END_DATE=${3:-"2020-10-10"}   
RUN_MODE=${4:-"serial"}   

USER="manjila"
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

# from guide.sh
for folder in outputs restarts; do
    DIR="$HOST_DATA_PATH/$folder"
    if [ -d "$DIR" ]; then
        echo "Deleting all files in $DIR..."
        find "$DIR" -type f -delete
    fi
    echo "$folder folder is clean."
done


# Update to latest docker image and run
IMAGE_NAME="awiciroh/ciroh-ngen-image:latest"
echo "Pulling latest Docker image: $IMAGE_NAME"
docker pull $IMAGE_NAME


# Get the number of available CPU cores
NUM_CORES=$(nproc)
echo "Number of available CPU cores: $NUM_CORES"

echo "Running NextGen model in $RUN_MODE mode..."
echo "=== Running NGIAB (NextGen) with Docker ==="
start_ngen=$(date +%s)
if [ "$RUN_MODE" = "parallel" ]; then
    echo "Running in parallel mode with $NUM_CORES processes"
    docker run --rm -v "$HOST_DATA_PATH:/ngen/ngen/data" "$IMAGE_NAME" /ngen/ngen/data auto $NUM_CORES
else
    echo "Running in serial mode"
    docker run --rm -v "$HOST_DATA_PATH:/ngen/ngen/data" "$IMAGE_NAME" /ngen/ngen/data auto 1
fi
end_ngen=$(date +%s)
ngen_time=$((end_ngen - start_ngen))

# TEEHR setup and run
DATA_FOLDER_PATH="/home/$USER/ngiab_preprocess_output/$GAGE_ID"
IMAGE_NAME="awiciroh/ngiab-teehr"
TEEHR_CONTAINER_PREFIX="teehr-evaluation"

# Detect platform architecture for default tag
if uname -a | grep -q 'arm64\|aarch64'; then
    teehr_image_tag="latest" # ARM64 architecture
else
    teehr_image_tag="x86"    # x86 architecture
fi

CONTAINER_NAME="${TEEHR_CONTAINER_PREFIX}-$(date +%s)"

echo "=== Running TEEHR evaluation (timed Docker run) ==="
start_teehr=$(date +%s)
docker run --name "$CONTAINER_NAME" --rm -v "$DATA_FOLDER_PATH:/app/data" "${IMAGE_NAME}:${teehr_image_tag}"
end_teehr=$(date +%s)
teehr_time=$((end_teehr - start_teehr))

echo ""
echo "==================== SUMMARY ===================="
echo "Configuration:"
echo "  Gage ID:    $GAGE_ID"
echo "  Start Date: $START_DATE"
echo "  End Date:   $END_DATE"
echo "  Run Mode:   $RUN_MODE"
if [ "$RUN_MODE" = "parallel" ]; then
    echo "  Processes:  $NUM_CORES"
fi
echo ""
echo "Timing Results:"
echo "Data Preprocess Time: $preprocess_time seconds"
echo "NGIAB Run Time:      $ngen_time seconds"
echo "TEEHR Run Time:      $teehr_time seconds"
echo "================================================="

exit 0