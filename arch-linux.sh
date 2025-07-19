#!/usr/bin/env bash
# simple, yet efficient
#     ___  ______  _____  _   _    ___  ________ _____ ______  ___ _____ _____ _____ _   _     _____ _____ ______ ___________ _____ 
#    / _ \ | ___ \/  __ \| | | |   |  \/  |_   _|  __ \| ___ \/ _ \_   _|_   _|  _  | \ | |   /  ___/  __ \| ___ \_   _| ___ \_   _|
#   / /_\ \| |_/ /| /  \/| |_| |   | .  . | | | | |  \/| |_/ / /_\ \| |   | | | | | |  \| |   \ `--.| /  \/| |_/ / | | | |_/ / | |  
#   |  _  ||    / | |    |  _  |   | |\/| | | | | | __ |    /|  _  || |   | | | | | | . ` |    `--. \ |    |    /  | | |  __/  | |  
#   | | | || |\ \ | \__/\| | | |   | |  | |_| |_| |_\ \| |\ \| | | || |  _| |_\ \_/ / |\  |   /\__/ / \__/\| |\ \ _| |_| |     | |  
#   \_| |_/\_| \_| \____/\_| |_/   \_|  |_/\___/ \____/\_| \_\_| |_/\_/  \___/ \___/\_| \_/   \____/ \____/\_| \_|\___/\_|     \_/  

# by konacode
# https://konacode.com/ | https://nightvoid.com/

# Scans your current system for explicitly installed pacman and AUR packages
# and produces an installer script, that installs them on other systems.

set -euo pipefail

# output filenames
PACMAN_LIST="pacman-packages.txt"
AUR_LIST="aur-packages.txt"
INSTALL_SCRIPT="install_packages.sh"

# export lists
echo "[INFO] Exporting official repo packages to $PACMAN_LIST..."
pacman -Qqe > "$PACMAN_LIST"

echo "[INFO] Exporting AUR (foreign) packages to $AUR_LIST..."
# Requires that foreign packages are listed via pacman
pacman -Qqm > "$AUR_LIST"

# create the installer script
cat << 'EOF' > "$INSTALL_SCRIPT"
#!/usr/bin/env bash
# Installs packages listed in pacman-packages.txt and aur-packages.txt

set -euo pipefail

# sync and install official packages
echo "[INFO] Installing official repo packages..."
pacman -Sy --needed --noconfirm - < pacman-packages.txt

# 2. Ensure AUR helper
if ! command -v yay &>/dev/null; then
    echo "[!] 'yay' not found. Please install an AUR helper (e.g. yay or paru) first."
    exit 1
fi

echo "[INFO] Installing AUR packages..."
yay -Sy --needed --noconfirm - < aur-packages.txt

echo "[COMPLETE] All packages installed."
EOF

# make installer script executable
chmod +x "$INSTALL_SCRIPT"

echo "[COMPLETE] Generated $INSTALL_SCRIPT (and package lists: $PACMAN_LIST, $AUR_LIST)"
