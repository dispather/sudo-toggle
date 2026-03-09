#!/bin/bash
set -e

echo "=== Sudo Toggle 제거 ==="

rm -f "$HOME/.local/bin/sudo-toggle-gui"
rm -f "$HOME/.config/fish/functions/sudo-toggle.fish"
rm -f "$HOME/.local/share/applications/sudo-toggle.desktop"

# 보안 모드로 복원
USERNAME="$(whoami)"
if sudo grep -q "$USERNAME.*NOPASSWD" /etc/sudoers 2>/dev/null; then
    sudo sed -i "/$USERNAME.*NOPASSWD/d" /etc/sudoers
    echo "sudoers NOPASSWD 제거됨"
fi
if [ -f /usr/share/polkit-1/rules.d/49-nopasswd.rules ]; then
    sudo rm -f /usr/share/polkit-1/rules.d/49-nopasswd.rules
    echo "Polkit 규칙 제거됨"
fi

echo "=== 제거 완료 (보안 모드로 복원됨) ==="
