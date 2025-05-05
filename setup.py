#!/data/data/com.termux/files/usr/bin/bash

# Title: Roblox Client Setup Assistant
# Version: 1.1
# Author: Your Name

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# Display title banner
show_banner() {
    clear
    echo -e "${BLUE}"
    echo "  ____        _     _           ____ _               "
    echo " |  _ \ ___  | |__ | | ___  ___/ ___| | __ _ ___ ___ "
    echo " | |_) / _ \ | '_ \| |/ _ \/ __| |   | |/ _\` / __/ __|"
    echo " |  _ <  __/ | |_) | |  __/\__ \ |___| | (_| \__ \__ \\"
    echo " |_| \_\___| |_.__/|_|\___||___/\____|_|\__,_|___/___/"
    echo -e "${NC}"
    echo -e "${YELLOW}Roblox Client Setup Assistant${NC}"
    echo -e "${GREEN}Version 1.1 - Automated Setup Tool${NC}"
    echo "============================================"
    echo ""
}

# Main menu
main_menu() {
    show_banner
    echo -e "${YELLOW}Main Menu:${NC}"
    echo -e "1) ${GREEN}Install All Dependencies${NC}"
    echo -e "2) ${BLUE}Install Python Packages Only${NC}"
    echo -e "3) ${BLUE}Download Roblox Script${NC}"
    echo -e "4) ${BLUE}Run Roblox Script${NC}"
    echo -e "5) ${RED}Exit${NC}"
    echo ""
    read -p "Select an option (1-5): " choice

    case $choice in
        1) install_all ;;
        2) install_python_packages ;;
        3) download_script ;;
        4) run_script ;;
        5) exit_script ;;
        *) invalid_option ;;
    esac
}

# Install all dependencies
install_all() {
    show_banner
    echo -e "${YELLOW}Installing all dependencies...${NC}"
    echo ""
    
    echo -e "${BLUE}Updating packages...${NC}"
    pkg update -y && pkg upgrade -y
    
    echo -e "${BLUE}Installing Python...${NC}"
    pkg install python -y
    
    install_python_packages
    download_script
    
    echo -e "${GREEN}All dependencies installed successfully!${NC}"
    echo ""
    read -p "Press Enter to return to main menu..."
    main_menu
}

# Install Python packages
install_python_packages() {
    show_banner
    echo -e "${YELLOW}Installing Python packages...${NC}"
    echo ""
    
    echo -e "${BLUE}Installing required packages...${NC}"
    pip install requests aiohttp colorama psutil
    
    echo -e "${BLUE}Installing crypto packages...${NC}"
    pip install pycryptodome cryptography
    
    echo -e "${GREEN}Python packages installed successfully!${NC}"
    echo ""
    read -p "Press Enter to return to main menu..."
    main_menu
}

# Download the script
download_script() {
    show_banner
    echo -e "${YELLOW}Downloading Roblox script...${NC}"
    echo ""
    
    mkdir -p /sdcard/download/roblox_scripts
    cd /sdcard/download/roblox_scripts || {
        echo -e "${RED}Failed to access directory!${NC}"
        return 1
    }
    
    echo -e "${BLUE}Downloading freerejoin.py...${NC}"
    if curl -L -o freerejoin.py "https://gofile.io/d/mpuQDV"; then
        echo -e "${GREEN}Script downloaded successfully!${NC}"
        echo -e "Location: $(pwd)/freerejoin.py"
    else
        echo -e "${RED}Failed to download script!${NC}"
    fi
    
    echo ""
    read -p "Press Enter to return to main menu..."
    main_menu
}

# Run the script
run_script() {
    show_banner
    echo -e "${YELLOW}Running Roblox script...${NC}"
    echo ""
    
    if [ -f "/sdcard/download/roblox_scripts/freerejoin.py" ]; then
        cd /sdcard/download/roblox_scripts || {
            echo -e "${RED}Failed to access script directory!${NC}"
            return 1
        }
        echo -e "${BLUE}Starting script...${NC}"
        python freerejoin.py
    else
        echo -e "${RED}Script not found! Please download it first.${NC}"
    fi
    
    echo ""
    read -p "Press Enter to return to main menu..."
    main_menu
}

# Exit script
exit_script() {
    show_banner
    echo -e "${GREEN}Thank you for using Roblox Client Setup Assistant!${NC}"
    echo ""
    exit 0
}

# Invalid option
invalid_option() {
    echo -e "${RED}Invalid option! Please try again.${NC}"
    sleep 2
    main_menu
}

# Start the script
main_menu
