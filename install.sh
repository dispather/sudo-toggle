#!/bin/bash
set -e

USERNAME="$(whoami)"

echo "=== Sudo Toggle 설치 ==="
echo "사용자: $USERNAME"
echo ""

# 의존성 확인
if ! command -v kdialog &>/dev/null; then
    echo "kdialog가 필요합니다. 설치 중..."
    sudo pacman -S --noconfirm kdialog
fi

# GUI 스크립트 설치
mkdir -p "$HOME/.local/bin"
cat > "$HOME/.local/bin/sudo-toggle-gui" << 'SCRIPT_EOF'
#!/bin/bash

USERNAME="$(whoami)"
SUDOERS_FILE="/etc/sudoers"
NOPASSWD_LINE="$USERNAME ALL=(ALL) NOPASSWD: ALL"
POLKIT_FILE="/usr/share/polkit-1/rules.d/49-nopasswd.rules"

is_nopasswd_enabled() {
    sudo grep -q "$USERNAME.*NOPASSWD" "$SUDOERS_FILE" 2>/dev/null
}

enable_nopasswd() {
    echo "$NOPASSWD_LINE" | pkexec tee -a "$SUDOERS_FILE" >/dev/null
    cat << POLKIT_EOF | pkexec tee "$POLKIT_FILE" >/dev/null
polkit.addRule(function(action, subject) {
    if (subject.user == "$USERNAME") {
        return polkit.Result.YES;
    }
});
POLKIT_EOF
    kdialog --icon "security-low" --title "Sudo 토글" \
        --passivepopup "비밀번호 비활성화됨 (편의 모드)\nsudo + Polkit 모두 해제" 4
}

disable_nopasswd() {
    pkexec sed -i "/$USERNAME.*NOPASSWD/d" "$SUDOERS_FILE"
    pkexec rm -f "$POLKIT_FILE"
    kdialog --icon "security-high" --title "Sudo 토글" \
        --passivepopup "비밀번호 활성화됨 (보안 모드)\nsudo + Polkit 모두 복원" 4
}

if is_nopasswd_enabled; then
    STATUS="현재: 비밀번호 없음 (편의 모드)"
    ACTION="비밀번호 요구로 전환하시겠습니까?"
    ICON="security-low"
else
    STATUS="현재: 비밀번호 필요 (보안 모드)"
    ACTION="비밀번호 없음으로 전환하시겠습니까?"
    ICON="security-high"
fi

kdialog --icon "$ICON" --title "Sudo 비밀번호 토글" \
    --yesno "$STATUS\n\n$ACTION" 2>/dev/null

if [ $? -eq 0 ]; then
    if is_nopasswd_enabled; then
        disable_nopasswd
    else
        enable_nopasswd
    fi
fi
SCRIPT_EOF
chmod +x "$HOME/.local/bin/sudo-toggle-gui"

# Fish 함수 설치
mkdir -p "$HOME/.config/fish/functions"
cat > "$HOME/.config/fish/functions/sudo-toggle.fish" << 'FISH_EOF'
function sudo-toggle
    set username (whoami)
    set sudoers_line "$username ALL=(ALL) NOPASSWD: ALL"
    set polkit_file "/usr/share/polkit-1/rules.d/49-nopasswd.rules"

    if sudo grep -q "$username.*NOPASSWD" /etc/sudoers
        sudo sed -i "/$username.*NOPASSWD/d" /etc/sudoers
        sudo rm -f $polkit_file
        echo "sudo + Polkit 비밀번호 활성화됨 (보안 모드)"
    else
        echo "$sudoers_line" | sudo tee -a /etc/sudoers >/dev/null
        printf 'polkit.addRule(function(action, subject) {\n    if (subject.user == "%s") {\n        return polkit.Result.YES;\n    }\n});\n' $username | sudo tee $polkit_file >/dev/null
        echo "sudo + Polkit 비밀번호 비활성화됨 (편의 모드)"
    end
end
FISH_EOF

# 데스크톱 파일 설치
mkdir -p "$HOME/.local/share/applications"
cat > "$HOME/.local/share/applications/sudo-toggle.desktop" << 'DESKTOP_EOF'
[Desktop Entry]
Name=Sudo 비밀번호 토글
Comment=sudo 비밀번호 요구 켜기/끄기 (sudo + Polkit)
Exec=sudo-toggle-gui
Icon=security-high
Terminal=false
Type=Application
Categories=System;Settings;
Keywords=sudo;password;toggle;보안;비밀번호;
DESKTOP_EOF

echo ""
echo "=== 설치 완료 ==="
echo "  터미널: sudo-toggle"
echo "  GUI: 앱 메뉴에서 'Sudo 비밀번호 토글' 검색"
echo ""
echo "제거: bash $(dirname "$0")/uninstall.sh"
