#!/bin/bash

# ==============================================================================
# Menu & Execution
# Purpose:
# - Checks for a virtual environment and sets it up if needed.
# - Displays a menu for the user to select a specific bot.
# - Activates the environment and runs the chosen bot.
# ==============================================================================

# if any command fails program will force stop.
set -e

# --- Colors Output ---
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[1;33m'
COLOR_BLUE='\033[0;34m'
COLOR_NC='\033[0m'

echo
echo -e "${COLOR_YELLOW}Starting Execution...${COLOR_NC}"

# --- Prerequisite Check & Setup ---
if [ ! -f "venv/bin/activate" ]; then
    echo -e "${COLOR_YELLOW}Info: Virtual Environment Not Found. Performing Setup...${COLOR_NC}"
    
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

# --- Menu Function ---
display_menu() {
    echo
    echo -e "${COLOR_BLUE}==================================================${COLOR_NC}"
    echo -e " ${COLOR_YELLOW}1)${COLOR_NC} ${COLOR_GREEN}Octra Network CLI${COLOR_NC}"
    echo -e " ${COLOR_YELLOW}2)${COLOR_NC} ${COLOR_GREEN}Octra Network Auto Bot${COLOR_NC}"
    echo -e " ${COLOR_YELLOW}0)${COLOR_NC} Exit"
    echo -e "${COLOR_BLUE}==================================================${COLOR_NC}"
}

# --- Main Loop ---
while true; do
    display_menu
    read -p "Enter Menu [0, 1-2]: " choice

    case $choice in
        1)
            echo -e "Running | Octra Network CLI"
            python cli.py
            echo -e "Starting Execution"
            ;;
        2)
            echo -e "Running | Octra Network Auto Bot"
            python auto_running.py
            echo -e "Starting Execution"
            ;;
        0)
            echo -e "Info: Run ./run.sh to Restart Program"
            break
            ;;
        *)
            echo -e "Invalid Option. Please Try Again"
            ;;
    esac
done
