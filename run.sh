#!/bin/bash

# ==============================================================================
# Purpose:
# - Checks for a virtual environment and sets it up if needed.
# - Activates the environment and run the bot.
# ==============================================================================

# if any command fails program will force stop.
set -e

# --- Colors Output ---
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[1;33m'
COLOR_BLUE='\033[0;34m'
COLOR_NC='\033[0m'

echo
echo -e "${COLOR_YELLOW}Checking Mandatory Environment${COLOR_NC}"

# --- Prerequisite Check & Setup ---
if [ ! -f "venv/bin/activate" ]; then
    echo -e "${COLOR_YELLOW}Info: Virtual Environment Not Found. Performing Setup${COLOR_NC}"

    if [ -d "venv" ]; then
        echo "Removing Incomplete 'venv' Directory"
        sudo -E rm -rf venv
    fi

    echo "1. Creating Virtual Environment"
    python3 -m venv venv

    echo "2. Activating Virtual Environment"
    source venv/bin/activate

    echo "3. Installing Packages Requirements"
    sudo -E pip3 install --no-cache-dir -r requirements.txt

    echo
    echo -e "${COLOR_GREEN}Setup Complete${COLOR_NC}"
else
    echo "Activating Virtual Environment"
    source venv/bin/activate
    echo -e "${COLOR_GREEN}Virtual Environment Activated${COLOR_NC}"
fi

# Running Main Program
echo
echo -e "${COLOR_GREEN}Running Program${COLOR_NC}"
python3 cli.py
