#!/bin/bash
# Template customization script
# Renames MyApp to your project name and updates bundle identifiers

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${BLUE}  MyApp Template Customization${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo ""

# Get current values
CURRENT_NAME="MyApp"
CURRENT_BUNDLE="com.example.MyApp"

# Prompt for new values
echo -e "${YELLOW}Enter your app name (e.g., 'PhotoEditor'):${NC}"
read -r NEW_NAME

if [ -z "$NEW_NAME" ]; then
    echo -e "${RED}❌ App name cannot be empty${NC}"
    exit 1
fi

echo -e "${YELLOW}Enter your bundle identifier (e.g., 'com.yourcompany.PhotoEditor'):${NC}"
read -r NEW_BUNDLE

if [ -z "$NEW_BUNDLE" ]; then
    echo -e "${RED}❌ Bundle ID cannot be empty${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}Configuration:${NC}"
echo -e "  App Name: ${GREEN}${CURRENT_NAME}${NC} → ${GREEN}${NEW_NAME}${NC}"
echo -e "  Bundle ID: ${GREEN}${CURRENT_BUNDLE}${NC} → ${GREEN}${NEW_BUNDLE}${NC}"
echo ""
echo -e "${YELLOW}Continue? (y/n)${NC}"
read -r CONFIRM

if [ "$CONFIRM" != "y" ]; then
    echo -e "${RED}❌ Cancelled${NC}"
    exit 0
fi

echo ""
echo -e "${GREEN}🔄 Customizing template...${NC}"

# Function to replace in file
replace_in_file() {
    local file=$1
    local old=$2
    local new=$3

    if [ -f "$file" ]; then
        sed -i '' "s/${old}/${new}/g" "$file"
    fi
}

# 1. Update source files (bundle ID first, then app name)
echo -e "${BLUE}→ Updating source files...${NC}"
find . -type f \( -name "*.swift" -o -name "*.md" -o -name "*.sh" \) -not -path "./.git/*" -not -path "./build/*" | while read -r file; do
    replace_in_file "$file" "$CURRENT_BUNDLE" "$NEW_BUNDLE"
    replace_in_file "$file" "$CURRENT_NAME" "$NEW_NAME"
done

# 2. Update Xcode project file (bundle ID first, then app name)
echo -e "${BLUE}→ Updating Xcode project...${NC}"
if [ -f "MyApp.xcodeproj/project.pbxproj" ]; then
    replace_in_file "MyApp.xcodeproj/project.pbxproj" "$CURRENT_BUNDLE" "$NEW_BUNDLE"
    replace_in_file "MyApp.xcodeproj/project.pbxproj" "$CURRENT_NAME" "$NEW_NAME"
fi

# 3. Rename main app file
echo -e "${BLUE}→ Renaming main app file...${NC}"
if [ -f "MyApp/MyAppApp.swift" ]; then
    mv "MyApp/MyAppApp.swift" "MyApp/${NEW_NAME}App.swift"
fi

# 4. Rename directories
echo -e "${BLUE}→ Renaming directories...${NC}"
if [ -d "MyApp" ]; then
    mv "MyApp" "${NEW_NAME}"
fi

if [ -d "MyAppTests" ]; then
    mv "MyAppTests" "${NEW_NAME}Tests"
fi

# 5. Rename Xcode project
echo -e "${BLUE}→ Renaming Xcode project...${NC}"
if [ -d "MyApp.xcodeproj" ]; then
    mv "MyApp.xcodeproj" "${NEW_NAME}.xcodeproj"
fi

# 6. Update scheme file (if exists)
if [ -d "${NEW_NAME}.xcodeproj/xcshareddata/xcschemes" ]; then
    if [ -f "${NEW_NAME}.xcodeproj/xcshareddata/xcschemes/MyApp.xcscheme" ]; then
        mv "${NEW_NAME}.xcodeproj/xcshareddata/xcschemes/MyApp.xcscheme" \
           "${NEW_NAME}.xcodeproj/xcshareddata/xcschemes/${NEW_NAME}.xcscheme"
    fi
fi

# 7. Clean build artifacts
echo -e "${BLUE}→ Cleaning build artifacts...${NC}"
rm -rf build/
rm -rf DerivedData/

echo ""
echo -e "${GREEN}✅ Template customization complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Open ${NEW_NAME}.xcodeproj in Xcode"
echo "  2. Verify scheme is set to ${NEW_NAME}"
echo "  3. Run: ./scripts/build.sh"
echo "  4. Run: ./scripts/install.sh"
echo ""
echo -e "${YELLOW}⚠️  Recommendation: Create a new git commit after customization${NC}"
echo "     git add -A"
echo "     git commit -m \"chore: customize template for ${NEW_NAME}\""
