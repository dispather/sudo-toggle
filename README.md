# sudo-toggle

KDE GUI / CLI toggle for passwordless sudo + Polkit on Arch/CachyOS Linux.

One-click switch between **convenience mode** (no password) and **security mode** (password required) for both `sudo` and Polkit (GUI apps like Discover).

## Install

```bash
git clone https://github.com/dispather/sudo-toggle.git
cd sudo-toggle
bash install.sh
```

## Usage

**GUI:** Search "Sudo 비밀번호 토글" in the app menu.

**Terminal (fish):**
```bash
sudo-toggle
```

## What it does

- **Convenience mode (편의 모드):** Adds NOPASSWD to sudoers + Polkit rule → no password anywhere
- **Security mode (보안 모드):** Removes both → password required everywhere

## Uninstall

```bash
bash uninstall.sh
```

Automatically restores security mode on uninstall.

## Requirements

- Arch Linux / CachyOS
- KDE Plasma (for GUI toggle via `kdialog`)
- Fish shell (for terminal function; GUI works without fish)
