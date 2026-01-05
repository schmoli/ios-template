#!/bin/bash
# Test script for MyApp

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT="MyApp.xcodeproj"
SCHEME="MyApp"

echo -e "${GREEN}🧪 Running tests...${NC}"

# Find available simulator
SIM_UDID=$(xcrun simctl list devices --json | jq -r '.devices | to_entries[] | .value[] | select(.name | contains("iPhone")) | select(.isAvailable == true) | .udid' | head -1)

if [ -z "$SIM_UDID" ]; then
    echo -e "${RED}❌ No available iOS simulator found${NC}"
    exit 1
fi

echo -e "${YELLOW}📱 Using simulator: ${SIM_UDID}${NC}"

# Run tests
xcodebuild \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -destination "platform=iOS Simulator,id=${SIM_UDID}" \
    test || {
        echo -e "${RED}❌ Tests failed${NC}"
        exit 1
    }

echo -e "${GREEN}✅ Tests passed!${NC}"
