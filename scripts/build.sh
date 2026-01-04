#!/bin/bash
# Build script for MyApp

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT="MyApp.xcodeproj"
SCHEME="MyApp"
CONFIGURATION="${1:-Debug}"  # Default to Debug, or use first argument

echo -e "${GREEN}🔨 Building MyApp (${CONFIGURATION})...${NC}"

# Find available simulator
SIM_UDID=$(xcrun simctl list devices --json | jq -r '.devices | to_entries[] | .value[] | select(.name | contains("iPhone")) | select(.isAvailable == true) | .udid' | head -1)

if [ -z "$SIM_UDID" ]; then
    echo -e "${RED}❌ No available iOS simulator found${NC}"
    exit 1
fi

echo -e "${YELLOW}📱 Using simulator: ${SIM_UDID}${NC}"

# Build
xcodebuild \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -destination "platform=iOS Simulator,id=${SIM_UDID}" \
    -configuration "$CONFIGURATION" \
    -derivedDataPath ./build \
    build

echo -e "${GREEN}✅ Build succeeded!${NC}"
