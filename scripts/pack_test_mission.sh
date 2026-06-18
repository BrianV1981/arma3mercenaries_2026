#!/bin/bash

# A.I.M. Automated Mission Packer (TEST BUILD EDITION)
# This script forcefully creates a timestamped test build and will NEVER bump the production version.

if [ -z "$1" ]; then
    echo "Usage: ./pack_test_mission.sh <path_to_mission_folder>"
    echo "Example: ./pack_test_mission.sh /home/brian-vasquez/aim-a3m/arma3mercenaries_2026.Altis"
    exit 1
fi

MISSION_DIR="$1"
DESC_FILE="$MISSION_DIR/description.ext"
SERVER_CFG="/home/brian-vasquez/arma3server/server.cfg"

# 1. Extract the base version from description.ext
major=$(grep -oP 'OnLoadName\s*=\s*".*?Bv\K[0-9]+' "$DESC_FILE" | head -n 1)
minor=$(grep -oP 'OnLoadName\s*=\s*".*?Bv[0-9]+\.\K[0-9]+' "$DESC_FILE" | head -n 1)

if [ -z "$major" ] || [ -z "$minor" ]; then
    echo "Failed to extract version from description.ext. Falling back to default."
    major="0"
    minor="000"
fi

# Generate timestamp (YYYYMMDD-HHMM)
timestamp=$(date +"%Y%m%d-%H%M")

# 2. Create the versioned staging folder (ALWAYS FORCED AS A TEST BUILD)
STAGING_NAME="2026_arma3mercenaries_v${major}${minor}-TESTBUILD-${timestamp}.Altis"
STAGING_DIR="/tmp/$STAGING_NAME"

echo "Staging TEST BUILD $STAGING_NAME..."
rm -rf "$STAGING_DIR"
cp -r "$MISSION_DIR" "$STAGING_DIR"

# Remove Git metadata from staging
rm -rf "$STAGING_DIR/.git"

# 3. Pack the PBO from the staging folder
OUTPUT_PBO="/home/brian-vasquez/arma3server/mpmissions/${STAGING_NAME}.pbo"

if [ -f "$OUTPUT_PBO" ]; then
    echo "[ERROR] A PBO with the name ${STAGING_NAME}.pbo already exists in the mpmissions folder!"
    rm -rf "$STAGING_DIR"
    exit 1
fi

echo "Packing to $OUTPUT_PBO..."

cd /home/brian-vasquez/aim-a3m/external-tools/arma3pbo && PYTHONPATH=src python3 -m arma3pbo.main build -p "$STAGING_DIR" -o "$OUTPUT_PBO"

if [ $? -eq 0 ]; then
    echo "Successfully packed to $OUTPUT_PBO"
    
    # 4. Update server.cfg template
    python3 -c "
import re
try:
    with open('$SERVER_CFG', 'r') as f:
        content = f.read()
    new_content = re.sub(r'template\s*=\s*\"[^\"]+\";', 'template = \"$STAGING_NAME\";', content)
    with open('$SERVER_CFG', 'w') as f:
        f.write(new_content)
    print('Updated server.cfg template to $STAGING_NAME')
except Exception as e:
    print(f'Failed to update server.cfg: {e}')
"
    
    # 5. Cleanup Staging Folder
    rm -rf "$STAGING_DIR"
    echo "Cleanup complete. Ready for server boot."
else
    echo "Failed to pack mission."
    rm -rf "$STAGING_DIR"
    exit 1
fi
