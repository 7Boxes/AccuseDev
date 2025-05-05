import os
import subprocess

def fix_termux_permission():
    termux_dir = os.path.expanduser("~/.termux")
    properties_file = os.path.join(termux_dir, "termux.properties")
    
    # Create ~/.termux directory if missing
    os.makedirs(termux_dir, exist_ok=True)
    
    # Read existing content (if file exists)
    lines = []
    if os.path.exists(properties_file):
        with open(properties_file, "r") as f:
            lines = f.readlines()
    
    # Check/edit the property
    found = False
    for i, line in enumerate(lines):
        if line.strip().startswith(("allow-external-apps", "#allow-external-apps")):
            lines[i] = "allow-external-apps=true\n"  # Force update
            found = True
            break
    
    # Add the line if not found
    if not found:
        lines.append("allow-external-apps=true\n")
    
    # Write back to file (ensure Unix line endings)
    with open(properties_file, "w", newline="\n") as f:
        f.writelines(lines)
    
    print("[✓] Updated termux.properties: allow-external-apps=true")
    
    # Reload settings
    try:
        subprocess.run(["termux-reload-settings"], check=True)
        print("[✓] Termux settings reloaded!")
    except:
        print("[!] Manually restart Termux if changes don't apply.")

if __name__ == "__main__":
    fix_termux_permission()
