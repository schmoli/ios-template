#!/bin/bash
# Install MyApp on simulator

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Find available simulator
SIM_UDID=$(xcrun simctl list devices --json | jq -r '.devices | to_entries[] | .value[] | select(.name | contains("iPhone")) | select(.isAvailable == true) | .udid' | head -1)

if [ -z "$SIM_UDID" ]; then
    echo -e "${RED}❌ No available iOS simulator found${NC}"
    exit 1
fi

echo -e "${GREEN}📱 Installing on simulator: ${SIM_UDID}${NC}"

# Boot simulator if needed
xcrun simctl boot "$SIM_UDID" 2>/dev/null || echo "Simulator already booted"

# Find app bundle
APP_PATH=$(find ./build -name "MyApp.app" -type d | head -1)

if [ -z "$APP_PATH" ]; then
    echo -e "${RED}❌ MyApp.app not found. Run ./scripts/build.sh first${NC}"
    exit 1
fi

# Install and launch
xcrun simctl install "$SIM_UDID" "$APP_PATH"
xcrun simctl launch "$SIM_UDID" com.example.MyApp

echo -e "${GREEN}✅ App installed and launched${NC}"
