#!/bin/bash

# ==============================================================================
# Smart Installer Script for Octra Client
#
# This version has been refactored for:
# 1. Modularity: Each step is wrapped in a function.
# 2. Idempotency: Safe to run multiple times. The script checks
#    if something already exists before trying to create it again.
# 3. Readability: Uses colors and clear messages for each step.
# 4. Configuration: Important variables are placed at the top for easy modification.
# 5. Error Handling: Uses 'set -e' to stop the script on any error.
# 6. Specificity: Ensures Python 3.10 is installed and used.
# ==============================================================================

# --- Configuration ---
# Change these variables if needed
REPO_URL="https://github.com/fryzeee/octra_pre_client.git"
DEST_DIR_NAME="octra-network"
VENV_DIR="venv"
MAIN_DEST_DIR="$HOME"
PYTHON_VERSION="3.10"

# --- Colors for Output ---
# Logic to make the output more visually readable
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[1;33m'
COLOR_BLUE='\033[0;34m'
COLOR_RED='\033[0;31m'
COLOR_NC='\033[0m' # No Color

# 'set -e' will cause the script to exit immediately if a command fails.
set -e

# --- Helper Functions ---

# Function to print a neat step header
log_step() {
    STEP_NUM=$1
    STEP_DESC=$2
    echo -e "\n${COLOR_BLUE}==================================================================${COLOR_NC}"
    echo -e "${COLOR_BLUE}[${STEP_NUM}/10] ${STEP_DESC}${COLOR_NC}"
    echo -e "${COLOR_BLUE}==================================================================${COLOR_NC}"
}

# Function to mark the success of a step
log_success() {
    echo -e "${COLOR_GREEN}✔ Success: $1${COLOR_NC}"
}

# Function to mark a warning or a skipped step
log_warn() {
    echo -e "${COLOR_YELLOW}ℹ Info: $1${COLOR_NC}"
}

# --- Main Functions ---

# Step 1 & 2: Update system and install base packages
prepare_system() {
    log_step 1 "Updating System Package"
    sudo -E apt-get update -y
    log_success "Package list has been updated."

    log_step 2 "Installing Mandatory Packages"
    sudo -E apt-get install -y apt-utils nano ca-certificates curl wget software-properties-common git
    log_success "Mandatory packages have been installed."
}

# Step 3: Check for and install Python 3.10
check_and_install_python310() {
    log_step 3 "Checking Python V${PYTHON_VERSION} Installation"
    if command -v python${PYTHON_VERSION} >/dev/null 2>&1; then
        log_warn "Python ${PYTHON_VERSION} is already installed. Skipping."
    else
        echo "Installing Python ${PYTHON_VERSION}..."
        log_warn "Adding 'deadsnakes' PPA repository."
        sudo -E add-apt-repository ppa:deadsnakes/ppa -y
        log_warn "Updating package list from new repository."
        sudo -E apt-get update -y
        sudo -E apt-get install -y python${PYTHON_VERSION}
        log_success "Python ${PYTHON_VERSION} has been installed."
    fi
}

# Step 4: Install Python dependencies for the specific version
install_python_dependencies() {
    log_step 4 "Installing Python ${PYTHON_VERSION} Dependencies"
    sudo -E apt-get install -y python${PYTHON_VERSION}-venv python${PYTHON_VERSION}-dev
    log_success "Dependencies for Python ${PYTHON_VERSION} have been installed."
}

# Step 5: Clone or update repository
clone_or_update_repo() {
    log_step 5 "Cloning Repository"
    # Change to the main destination directory
    cd "$MAIN_DEST_DIR"

    # SMART LOGIC: Check if the directory already exists
    if [ -d "$DEST_DIR_NAME" ]; then
        log_warn "Directory '$DEST_DIR_NAME' already exists. Attempting to update (git pull)."
        cd "$DEST_DIR_NAME"
        git pull origin main # Assuming the main branch is 'main', can be changed to 'master'
        log_success "Repository updated successfully."
    else
        echo "Cloning repository..."
        git clone "$REPO_URL" "$DEST_DIR_NAME"
        cd "$DEST_DIR_NAME"
        log_success "Repository cloned successfully."
    fi
}

# Step 6 & 7: Create and activate virtual environment
setup_virtual_env() {
    log_step 6 "Creating Virtual Environment"
    # SMART LOGIC: Only create venv if it doesn't exist
    if [ ! -d "$VENV_DIR" ]; then
        python${PYTHON_VERSION} -m venv "$VENV_DIR"
        log_success "Virtual environment created successfully."
    else
        log_warn "Virtual environment directory '$VENV_DIR' already exists. Skipping creation."
    fi

    log_step 7 "Activating Virtual Environment"
    # 'source' will activate the venv for the rest of this script
    source "$VENV_DIR/bin/activate"
    
    # Verify activation
    if [[ -z "$VIRTUAL_ENV" ]]; then
        echo -e "${COLOR_RED}Failed to activate virtual environment. Aborting.${COLOR_NC}"
        exit 1
    fi
    log_success "Virtual environment activated successfully."
}

# Step 8 & 9: Install Python packages from requirements.txt
install_python_packages() {
    log_step 8 "Upgrading PIP"
    pip install --upgrade pip
    log_success "PIP has been upgraded to the latest version."

    log_step 9 "Installing Packages Requirements"
    sudo -E pip install --no-cache-dir -r requirements.txt
    log_success "All required Python packages have been installed."
}

# Step 10: Set up configuration file
setup_config_file() {
    log_step 10 "Setting Up 'wallet.json' Configuration File"
    # SMART LOGIC: Only copy if 'wallet.json' file does not exist
    if [ ! -f "wallet.json" ]; then
        cp wallet.json.example wallet.json
        log_success "File 'wallet.json' created successfully from template."
    else
        log_warn "File 'wallet.json' already exists. No changes were made."
    fi
}


# --- Main Execution ---
# The main logic sequence that calls each function in order.
main() {
    echo -e "${COLOR_GREEN}Starting Smart Installation Process...${COLOR_NC}"
    
    prepare_system
    check_and_install_python310
    install_python_dependencies
    clone_or_update_repo
    setup_virtual_env
    install_python_packages
    setup_config_file

    echo -e "\n${COLOR_GREEN}==================================================================${COLOR_NC}"
    echo -e "${COLOR_GREEN}🎉  Installation Complete! �${COLOR_NC}"
    echo -e "Installation location: ${COLOR_YELLOW}$MAIN_DEST_DIR/$DEST_DIR_NAME${COLOR_NC}"
    echo -e "Next steps:"
    echo -e "1. Open your directory installation: ${COLOR_YELLOW}cd $MAIN_DEST_DIR/$DEST_DIR_NAME${COLOR_NC}"
    echo -e "2. Edit the configuration file: ${COLOR_YELLOW}nano wallet.json${COLOR_NC}"
    echo -e "3. Activate the venv: ${COLOR_YELLOW}source venv/bin/activate${COLOR_NC}"
    echo -e "4. Run the program: ${COLOR_YELLOW}python${PYTHON_VERSION} cli.py${COLOR_NC}"
    echo -e "${COLOR_GREEN}==================================================================${COLOR_NC}"
}

# Call the main function to start the script
main
