#!/bin/bash

# Installation script for Swift Boilerplate template

# Define colors for messages
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Path to Xcode templates directory
XCODE_TEMPLATES_DIR="${HOME}/Library/Developer/Xcode/Templates/Project Templates/iOS"

# Template name
TEMPLATE_NAME="Swift Boilerplate.xctemplate"

# Source path of the template (current directory)
TEMPLATE_SOURCE_DIR="$(pwd)/${TEMPLATE_NAME}"

# Check if source directory exists
if [ ! -d "${TEMPLATE_SOURCE_DIR}" ]; then
    echo -e "${RED}Error: Template directory '${TEMPLATE_NAME}' not found in the current directory.${NC}"
    exit 1
fi

# Create destination directory if it doesn't exist
if [ ! -d "${XCODE_TEMPLATES_DIR}" ]; then
    echo -e "${YELLOW}Creating Xcode templates directory...${NC}"
    mkdir -p "${XCODE_TEMPLATES_DIR}"
fi

# Remove old version of the template if it exists
if [ -d "${XCODE_TEMPLATES_DIR}/${TEMPLATE_NAME}" ]; then
    echo -e "${YELLOW}Removing old version of the template...${NC}"
    rm -rf "${XCODE_TEMPLATES_DIR}/${TEMPLATE_NAME}"
fi

# Copy the template
echo -e "${YELLOW}Installing Swift Boilerplate template...${NC}"
cp -R "${TEMPLATE_SOURCE_DIR}" "${XCODE_TEMPLATES_DIR}/"

# Verify installation
if [ -d "${XCODE_TEMPLATES_DIR}/${TEMPLATE_NAME}" ]; then
    echo -e "${GREEN}Swift Boilerplate template has been successfully installed!${NC}"
    echo -e "${GREEN}You can now create a new project in Xcode using this template.${NC}"
else
    echo -e "${RED}Error: Template installation failed.${NC}"
    exit 1
fi

exit 0 