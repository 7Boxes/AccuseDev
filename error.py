import os
import subprocess

def fix_termux_permission():
    termux_dir = os.path.expanduser("~/.termux")
    properties_file = os.path.join(termux_dir, "termux.properties")
    
    # Create ~/.termux directory if it doesn't exist
    if not os.path.exists(termux_dir):
        os.makedirs(termux_dir)
        print(f"[+] Created directory: {termux_dir}")
    
    # Ensure the property is set in termux.properties
    with open(properties_file, "a+") as f:
        f.seek(0)
        content = f.read()
        if "allow-external-apps" not in content:
            f.write("allow-external-apps=true\n")
            print("[+] Added 'allow-external-apps=true' to termux.properties")
        else:
            print("[✓] 'allow-external-apps' already exists (check if it's set to 'true')")
    
    # Reload Termux settings
    try:
        subprocess.run(["termux-reload-settings"], check=True)
        print("[✓] Termux settings reloaded successfully!")
    except subprocess.CalledProcessError:
        print("[!] Failed to reload settings. Restart Termux manually.")

if __name__ == "__main__":
    fix_termux_permission()
