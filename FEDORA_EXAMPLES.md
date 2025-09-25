# Fedora-Specific AI Command Examples

This plugin is optimized for Fedora Linux with zsh shell. Here are some examples of what you can ask for and the expected Fedora-specific commands you'll get.

## Package Management (DNF)

| Query | Expected Command |
|-------|------------------|
| `/AI install docker` | `sudo dnf install docker` |
| `/AI install nodejs and npm` | `sudo dnf install nodejs npm` |
| `/AI update all packages` | `sudo dnf update` |
| `/AI search for python packages` | `dnf search python` |
| `/AI remove old packages` | `sudo dnf autoremove` |
| `/AI install development tools` | `sudo dnf groupinstall "Development Tools"` |
| `/AI install media codecs` | `sudo dnf install gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel` |

## System Services (systemctl)

| Query | Expected Command |
|-------|------------------|
| `/AI start docker service` | `sudo systemctl start docker` |
| `/AI enable ssh on boot` | `sudo systemctl enable sshd` |
| `/AI restart network service` | `sudo systemctl restart NetworkManager` |
| `/AI check service status` | `systemctl status servicename` |
| `/AI stop and disable apache` | `sudo systemctl stop httpd && sudo systemctl disable httpd` |
| `/AI list all running services` | `systemctl list-units --type=service --state=running` |

## Firewall Management (firewall-cmd)

| Query | Expected Command |
|-------|------------------|
| `/AI open port 8080` | `sudo firewall-cmd --permanent --add-port=8080/tcp && sudo firewall-cmd --reload` |
| `/AI enable ssh in firewall` | `sudo firewall-cmd --permanent --add-service=ssh && sudo firewall-cmd --reload` |
| `/AI list firewall rules` | `sudo firewall-cmd --list-all` |
| `/AI block port 443` | `sudo firewall-cmd --permanent --remove-port=443/tcp && sudo firewall-cmd --reload` |
| `/AI add http service` | `sudo firewall-cmd --permanent --add-service=http && sudo firewall-cmd --reload` |

## System Information

| Query | Expected Command |
|-------|------------------|
| `/AI check fedora version` | `cat /etc/fedora-release` |
| `/AI show kernel version` | `uname -r` |
| `/AI check system uptime` | `uptime` |
| `/AI show memory usage` | `free -h` |
| `/AI display disk usage` | `df -h` |
| `/AI check cpu info` | `lscpu` |
| `/AI show running processes` | `ps aux` |

## File and Directory Operations (zsh-optimized)

| Query | Expected Command |
|-------|------------------|
| `/AI find large files in home` | `find ~ -type f -size +100M -exec ls -lh {} \; 2>/dev/null` |
| `/AI create directory structure` | `mkdir -p project/{src,docs,tests}` |
| `/AI compress current directory` | `tar -czf "$(basename "$PWD")_$(date +%Y%m%d).tar.gz" .` |
| `/AI extract tar file` | `tar -xzf filename.tar.gz` |
| `/AI change permissions recursively` | `chmod -R 755 directory/` |
| `/AI find files modified today` | `find . -type f -newermt $(date +%Y-%m-%d) -ls` |

## Development Tools

| Query | Expected Command |
|-------|------------------|
| `/AI install vscode` | `sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc && echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo && sudo dnf check-update && sudo dnf install code` |
| `/AI install python development` | `sudo dnf install python3-devel python3-pip python3-virtualenv` |
| `/AI setup git user` | `git config --global user.name "Your Name" && git config --global user.email "your.email@example.com"` |
| `/AI install docker compose` | `sudo dnf install docker-compose` |

## Network Operations

| Query | Expected Command |
|-------|------------------|
| `/AI check open ports` | `ss -tuln` |
| `/AI test internet connection` | `ping -c 4 google.com` |
| `/AI show network interfaces` | `ip addr show` |
| `/AI restart network` | `sudo systemctl restart NetworkManager` |
| `/AI check dns resolution` | `nslookup google.com` |

## Docker Operations

| Query | Expected Command |
|-------|------------------|
| `/AI install docker on fedora` | `sudo dnf install docker && sudo systemctl enable --now docker && sudo usermod -aG docker $USER` |
| `/AI stop all containers` | `docker stop $(docker ps -q)` |
| `/AI remove unused images` | `docker image prune -f` |
| `/AI show docker disk usage` | `docker system df` |

## Log Analysis

| Query | Expected Command |
|-------|------------------|
| `/AI check system logs` | `sudo journalctl -f` |
| `/AI check last boot logs` | `sudo journalctl -b` |
| `/AI check service logs` | `sudo journalctl -u servicename.service` |
| `/AI check kernel messages` | `sudo dmesg | tail -20` |

## Tips for Better Results

### 1. Be Specific About Fedora
- The AI knows you're on Fedora and will use `dnf` instead of `apt` or `yum`
- It will use `systemctl` for services and `firewall-cmd` for firewall

### 2. Mention Version When Needed
- For version-specific features: `/AI install python 3.11 on fedora`
- For newer features: `/AI enable podman instead of docker`

### 3. Use Natural Language
- "install" → will use `sudo dnf install`
- "start service" → will use `sudo systemctl start`
- "open port" → will use `firewall-cmd --permanent --add-port`

### 4. Combine Operations
- `/AI install and start nginx` → will install with dnf and enable/start with systemctl
- `/AI update system and clean cache` → will update and clean dnf cache

## Fedora-Specific Features

The AI understands these Fedora-specific concepts:

- **DNF**: Primary package manager (not yum or apt)
- **RPM**: Package format
- **SELinux**: Security context (when relevant)
- **Firewalld**: Default firewall
- **systemd**: Init system and service manager
- **Wayland**: Default display server (Fedora 42)
- **Flatpak**: Universal package format
- **Toolbox**: Container-based development environment

## Environment Detection

The plugin automatically detects your system information:
- **OS**: Fedora 42 (Adams)
- **Shell**: zsh 5.9
- **Architecture**: x86_64

This information is sent to the AI to ensure you get the most appropriate commands for your specific setup.

---

**Need more examples?** Just ask the AI naturally - it's trained to understand Fedora Linux systems!