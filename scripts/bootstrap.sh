#!/bin/bash
# Bootstrap development environment
# Installs dependencies needed for build/test scripts

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🔧 Bootstrapping MyApp development environment...${NC}"

# Check for Homebrew
if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}⚠️  Homebrew not found. Installing...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo -e "${GREEN}✅ Homebrew installed${NC}"
fi

# Check for jq (used by build/test/install scripts)
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}⚠️  jq not found. Installing...${NC}"
    brew install jq
else
    echo -e "${GREEN}✅ jq installed${NC}"
fi

# Check for Xcode Command Line Tools
if ! xcode-select -p &> /dev/null; then
    echo -e "${YELLOW}⚠️  Xcode Command Line Tools not found. Installing...${NC}"
    xcode-select --install
    echo -e "${YELLOW}⏳ Please complete the Xcode CLI tools installation and re-run this script${NC}"
    exit 1
else
    echo -e "${GREEN}✅ Xcode Command Line Tools installed${NC}"
fi

# Verify xcrun and simulators
if xcrun simctl list devices --json &> /dev/null; then
    SIM_COUNT=$(xcrun simctl list devices --json | jq -r '.devices | to_entries[] | .value[] | select(.isAvailable == true)' | wc -l | tr -d ' ')
    echo -e "${GREEN}✅ Found ${SIM_COUNT} available simulators${NC}"
else
    echo -e "${RED}❌ Cannot access iOS simulators. Install Xcode from the App Store.${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ Bootstrap complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Open MyApp.xcodeproj in Xcode"
echo "  2. Run: ./scripts/build.sh"
echo "  3. Run: ./scripts/install.sh"
echo ""
echo "To customize this template for your project, run: ./scripts/setup.sh"
