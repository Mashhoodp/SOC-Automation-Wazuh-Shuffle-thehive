## Introduction

This guide will walk you through the process of installing Alpine Linux on VirtualBox. Alpine Linux is a lightweight distribution, ideal for systems with limited resources. We'll also install essential tools like Docker and Git.

## Step-by-Step Installation

### 1. Download Alpine Linux ISO

- Visit [Alpine Linux Downloads](https://alpinelinux.org/downloads/) and download the latest stable release ISO.

### 2. Create a New Virtual Machine in VirtualBox

- **Name**: Give your VM a name (e.g., AlpineLinuxServer).
- **Type**: Linux
- **ISO Image**: Add the downloaded Alpine Linux ISO as the optical drive.
- **Version**: Linux 2/3/4/5 (64-bit)
- **Memory**: Allocate memory as per your requirement (e.g., 512 MB).
- **Processors**: Set the number of processors (e.g., 1 or 2).
- **Hard Disk**: Create a new virtual hard disk and allocate disk space (e.g., 10 GB).

### 3. Configure VM Settings

- **Display**: Set Graphics Controller to VBoxVGA.

### 4. Boot the VM

- Start the VM and boot from the Alpine Linux ISO.

### 5. Initial Setup

1. **Login**:
    - Username: `root` (default user)
2. **Start Setup**:
    - Run: `setup-alpine`
3. **Configure Keyboard**:
    - Keyboard layout: `us`
4. **Set Timezone**:
    - Choose your preferred timezone.
5. **Set Root Password**:
    - Enter a new password for the root user.
6. **Add a New User**:
    - Follow prompts to create a new user account.
7. **Select Repository**:
    - Enter `1` to select the first repository or `f` to find the fastest repository.
8. **Choose Hard Disk**:
    - Type `sda` for the hard disk.
9. **Installation Mode**:
    - Type `sys` to install Alpine Linux to disk.

### 6. Reboot the System

- Run: `reboot`
- Login with your root account.

### 7. Install Essential Tools

1. **Install Text Editor**:
    - Run: `apk add nano` (or `apk add vi` if you prefer `vi`).
2. **Edit Repository Configuration**:
    - Run: `nano /etc/apk/repositories`
    - Uncomment all repository lines to enable additional repositories.
3. **Update Package Index**:
    - Run: `apk update`
4. **Install Necessary Tools**:
    - Run: `apk add curl sudo`
    - Additional Tools: `git tmux docker docker-cli-compose htop`
	- For docker use `service docker start` and `rc-update add docker default`
8. **Verify Installation**:
    - After installation, Alpine Linux should use less than 150 MB of RAM.