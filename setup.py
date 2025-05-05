#!/data/data/com.termux/files/usr/bin/python3

import os
import subprocess
import sys
from time import sleep

# Colors
class Colors:
    RED = '\033[1;31m'
    GREEN = '\033[1;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[1;34m'
    NC = '\033[0m'  # No Color

def clear_screen():
    os.system('clear')

def show_banner():
    clear_screen()
    print(f"{Colors.BLUE}")
    print("  ____        _     _           ____ _               ")
    print(" |  _ \ ___  | |__ | | ___  ___/ ___| | __ _ ___ ___ ")
    print(" | |_) / _ \ | '_ \| |/ _ \/ __| |   | |/ _` / __/ __|")
    print(" |  _ <  __/ | |_) | |  __/\__ \ |___| | (_| \__ \__ \\")
    print(" |_| \_\___| |_.__/|_|\___||___/\____|_|\__,_|___/___/")
    print(f"{Colors.NC}")
    print(f"{Colors.YELLOW}Roblox Client Setup Assistant{Colors.NC}")
    print(f"{Colors.GREEN}Version 1.2 - With APK Installer{Colors.NC}")
    print("============================================")
    print()

def run_command(command, check=True):
    try:
        result = subprocess.run(command, shell=True, check=check, 
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        return True
    except subprocess.CalledProcessError:
        return False

def install_all():
    show_banner()
    print(f"{Colors.YELLOW}Installing all dependencies...{Colors.NC}")
    print()
    
    print(f"{Colors.BLUE}Updating packages...{Colors.NC}")
    run_command("pkg update -y && pkg upgrade -y")
    
    print(f"{Colors.BLUE}Installing Python...{Colors.NC}")
    run_command("pkg install python -y")
    
    install_python_packages()
    download_script()
    
    print(f"{Colors.GREEN}All dependencies installed successfully!{Colors.NC}")
    print()
    input("Press Enter to return to main menu...")
    main_menu()

def install_python_packages():
    show_banner()
    print(f"{Colors.YELLOW}Installing Python packages...{Colors.NC}")
    print()
    
    print(f"{Colors.BLUE}Installing required packages...{Colors.NC}")
    run_command("pip install requests aiohttp colorama psutil")
    
    print(f"{Colors.BLUE}Installing crypto packages...{Colors.NC}")
    run_command("pip install pycryptodome cryptography")
    
    print(f"{Colors.GREEN}Python packages installed successfully!{Colors.NC}")
    print()
    input("Press Enter to return to main menu...")
    main_menu()

def download_script():
    show_banner()
    print(f"{Colors.YELLOW}Downloading Roblox script...{Colors.NC}")
    print()
    
    script_dir = "/sdcard/download/roblox_scripts"
    os.makedirs(script_dir, exist_ok=True)
    
    try:
        os.chdir(script_dir)
    except:
        print(f"{Colors.RED}Failed to access directory!{Colors.NC}")
        return
    
    print(f"{Colors.BLUE}Downloading freerejoin.py...{Colors.NC}")
    if run_command('curl -L -o freerejoin.py "https://gofile.io/d/mpuQDV"'):
        print(f"{Colors.GREEN}Script downloaded successfully!{Colors.NC}")
        print(f"Location: {os.path.join(os.getcwd(), 'freerejoin.py')}")
    else:
        print(f"{Colors.RED}Failed to download script!{Colors.NC}")
    
    print()
    input("Press Enter to return to main menu...")
    main_menu()

def run_script():
    show_banner()
    print(f"{Colors.YELLOW}Running Roblox script...{Colors.NC}")
    print()
    
    script_path = "/sdcard/download/roblox_scripts/freerejoin.py"
    if os.path.exists(script_path):
        try:
            os.chdir("/sdcard/download/roblox_scripts")
            print(f"{Colors.BLUE}Starting script...{Colors.NC}")
            os.system("python freerejoin.py")
        except:
            print(f"{Colors.RED}Failed to access script directory!{Colors.NC}")
    else:
        print(f"{Colors.RED}Script not found! Please download it first.{Colors.NC}")
    
    print()
    input("Press Enter to return to main menu...")
    main_menu()

def download_and_install_apks():
    show_banner()
    print(f"{Colors.YELLOW}Downloading and installing APKs...{Colors.NC}")
    print()
    
    # Create download directory if it doesn't exist
    apk_dir = "/sdcard/download/apks"
    os.makedirs(apk_dir, exist_ok=True)
    
    try:
        os.chdir(apk_dir)
    except:
        print(f"{Colors.RED}Failed to access directory!{Colors.NC}")
        return
    
    # APK URLs
    roblox_apk_url = "https://download2433.mediafire.com/y2a1p2t11b7gW1DO_vV9uSaZjoc_DJ3pTEDFOILmWVkd78Agl81mVzuuBL-DhmiD8m-9trPvR8i3yw5Qw6zG17wpKaZIUCf26kM5ucQesw0Rptyicgk0PpjNG7SjG_mkwEQn197fxgzEeLOUk409kyfK6NQPX5VfGccsE_XRJmytSg/o1eg4e4aobwb6g0/Delta-670.714-01.apk"
    mtmanager_apk_url = "https://downloads.mt-manager.com/MTManager%20v3.0.5.apk"
    
    # Download Roblox APK
    print(f"{Colors.BLUE}Downloading Roblox APK...{Colors.NC}")
    if run_command(f'curl -L -o Roblox.apk "{roblox_apk_url}"'):
        print(f"{Colors.GREEN}Roblox APK downloaded successfully!{Colors.NC}")
        print(f"{Colors.BLUE}Installing Roblox APK...{Colors.NC}")
        if run_command("termux-open Roblox.apk"):
            print(f"{Colors.GREEN}Roblox APK installation started!{Colors.NC}")
        else:
            print(f"{Colors.RED}Failed to start Roblox APK installation!{Colors.NC}")
    else:
        print(f"{Colors.RED}Failed to download Roblox APK!{Colors.NC}")
    
    print()
    
    # Download MTManager APK
    print(f"{Colors.BLUE}Downloading MTManager APK...{Colors.NC}")
    if run_command(f'curl -L -o MTManager.apk "{mtmanager_apk_url}"'):
        print(f"{Colors.GREEN}MTManager APK downloaded successfully!{Colors.NC}")
        print(f"{Colors.BLUE}Installing MTManager APK...{Colors.NC}")
        if run_command("termux-open MTManager.apk"):
            print(f"{Colors.GREEN}MTManager APK installation started!{Colors.NC}")
        else:
            print(f"{Colors.RED}Failed to start MTManager APK installation!{Colors.NC}")
    else:
        print(f"{Colors.RED}Failed to download MTManager APK!{Colors.NC}")
    
    print()
    input("Press Enter to return to main menu...")
    main_menu()

def exit_script():
    show_banner()
    print(f"{Colors.GREEN}Thank you for using Roblox Client Setup Assistant!{Colors.NC}")
    print()
    sys.exit(0)

def invalid_option():
    print(f"{Colors.RED}Invalid option! Please try again.{Colors.NC}")
    sleep(2)
    main_menu()

def main_menu():
    show_banner()
    print(f"{Colors.YELLOW}Main Menu:{Colors.NC}")
    print(f"1) {Colors.GREEN}Install All Dependencies{Colors.NC}")
    print(f"2) {Colors.BLUE}Install Python Packages Only{Colors.NC}")
    print(f"3) {Colors.BLUE}Download Roblox Script{Colors.NC}")
    print(f"4) {Colors.BLUE}Run Roblox Script{Colors.NC}")
    print(f"5) {Colors.YELLOW}Download & Install APKs{Colors.NC}")
    print(f"6) {Colors.RED}Exit{Colors.NC}")
    print()
    
    try:
        choice = input("Select an option (1-6): ")
        {
            '1': install_all,
            '2': install_python_packages,
            '3': download_script,
            '4': run_script,
            '5': download_and_install_apks,
            '6': exit_script
        }.get(choice, invalid_option)()
    except KeyboardInterrupt:
        exit_script()

if __name__ == "__main__":
    # Check if running in Termux
    if not os.path.exists('/data/data/com.termux/files/usr/bin/'):
        print("This script is designed to run in Termux on Android.")
        sys.exit(1)
    
    # Check storage permission
    if not os.path.exists('/sdcard'):
        print("Please grant storage permission to Termux first.")
        print("Run: termux-setup-storage")
        sys.exit(1)
    
    main_menu()
