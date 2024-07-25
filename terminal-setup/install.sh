#!/bin/sh

# Check if neccessare packages are installed, if not install them
for pkg in zsh tmux jq curl; do
  command -v $pkg >/dev/null 2>&1 || {
    echo "Installing $pkg..."
    sudo apt install -y $pkg
  }
done

# Change shell to zsh if not already
[ -z "$ZSH_VERSION" ] && sudo chsh -s $(which zsh) $USER

# Create necessary directories
mkdir -p ~/.config/{tmux,ohmyposh,zsh}

# Copy configuration files
cp tmux.conf ~/.config/tmux/
cp zen.toml ~/.config/ohmyposh/
cp .zshrc ~/

# Clone zsh plugins
for repo in \
  Aloxaf/zsh-syntax-highlighting \
  zsh-users/zsh-completions \
  zsh-users/zsh-autosuggestions \
  Aloxaf/fzf-tab; do
  git clone https://github.com/$repo ~/.config/zsh/
done

# Download and install the latest release of oh-my-posh
latest_release_info=$(curl -s https://api.github.com/repos/JanDeDobbeleer/oh-my-posh/releases/latest | sed 's/[^[:print:]\t]//g')
download_url=$(echo $latest_release_info | jq -r '.assets[] | select(.name == "posh-linux-amd64") | .browser_download_url')
curl -L -o oh-my-posh $download_url
chmod +x oh-my-posh
sudo mv oh-my-posh /usr/bin

# Download and install the latest release of fzf
latest_release_info=$(curl -s https://api.github.com/repos/junegunn/fzf/releases/latest | sed 's/[^[:print:]\t]//g')
download_url=$(echo $latest_release_info | jq -r '.assets[] | select(.name | contains("linux_amd64.tar.gz")) | .browser_download_url')
curl -L -o fzf.tar.gz $download_url
tar -xzf fzf.tar.gz
chmod +x fzf
sudo mv fzf /usr/bin

# Define the plugin directory and tmux plugins
PLUGIN_DIR="$HOME/.tmux/plugins"
PLUGINS=(
  "tmux-plugins/tpm"
  "tmux-plugins/tmux-sensible"
  "christoomey/vim-tmux-navigator"
  "dreamsofcode-io/catppuccin-tmux"
  "tmux-plugins/tmux-yank"
)

# Create plugin directory if it doesn't exist and clone/update plugins
mkdir -p $PLUGIN_DIR
for plugin in "${PLUGINS[@]}"; do
  plugin_name=$(basename $plugin)
  if [ -d "$PLUGIN_DIR/$plugin_name" ]; then
    echo "Updating $plugin_name..."
    git -C "$PLUGIN_DIR/$plugin_name" pull
  else
    echo "Cloning $plugin_name..."
    git clone https://github.com/$plugin "$PLUGIN_DIR/$plugin_name"
  fi
done
