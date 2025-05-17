#!/bin/bash

cd ~

if ! command -v yay &>/dev/null; then
	echo "Installing yay"
	sudo pacman -S --needed git base-devel --noconfirm
	git clone https://aur.archlinux.org/yay-bin.git
	cd yay-bin
	makepkg -si --noconfirm
	cd .. && rm -rf yay-bin
fi

if ! command -v rustc &>/dev/null; then
	echo "Install rustup toolchain"
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
	. "$HOME/.cargo/env"
fi

if yay -Q dolphin &>/dev/null; then
	echo "Removing dolphin"
	yay -Rcus dolphin --noconfirm
fi

packages=(
	1password
	1password-cli
	adwaita-fonts
	adwaita-icon-theme
	bat
	btop
	catppuccin-gtk-theme-mocha
	cava
	eza # ls replacement
	fd
	fuzzel
	fzf
	google-chrome
	go
	gnome-calculator
	grim # screenshot utility for wayland
	hyprlock
	hyprpaper
	jq
	lazygit
	loupe # images viewers
	man
	nemo
	neofetch
	neovim
	networkmanager
	network-manager-applet
	noto-fonts-emoji
	nwg-look
	pavucontrol
	ripgrep
	swww
	ttf-jetbrains-mono-nerd
	unzip
	vesktop
	vlc
	volta
	wezterm-git
	waybar
	wl-clipboard
	wlogout
	xdg-user-dirs
	xorg-xrdb
	xorg-xwayland
	yadm
	yazi
	zsh
)

echo "Installing packages:"
for pkg in "${packages[@]}"; do
	if yay -Q "$pkg" &>/dev/null; then
		echo "  - $pkg is already installed"
	else
		echo "  - Installing $pkg"
		yay -S "$pkg" --noconfirm
	fi
done

git_username=$(git config --global user.name)
git_email=$(git config --global user.email)
git_default_branch=$(git config --global init.defaultBranch)

if [ -z "$git_username" ]; then
	read -rp "Enter your Git username: " git_username
	git config --global user.name "$git_username"
else
	echo "Git username is already set to: $git_username"
fi

if [ -z "$git_email" ]; then
	read -rp "Enter your Git email: " git_email
	git config --global user.email "$git_email"
else
	echo "Git email is already set to: $git_email"
fi

if [ -z "$git_default_branch" ]; then
	git config --global init.defaultBranch main
	echo "Git default branch set to 'main'"
else
	echo "Git default branch is already set to: $git_default_branch"
fi

if [ ! -d "$HOME/Desktop" ]; then
	echo "Creating xdg directories"
	LC_ALL=C.UTF-8 xdg-user-dirs-update --force
fi

if ls /usr/share/applications | grep -q -i 'org.gnome.Loupe.desktop'; then
	echo "Set 'loupe' as the default image viewer (if available)..."
	xdg-mime default org.gnome.Loupe.desktop image/png
	xdg-mime default org.gnome.Loupe.desktop image/jpeg
	echo "Default image viewer set to 'Loupe'."
else
	echo "Loupe desktop entry not found. Skipping xdg-mime setup."
fi

gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"

zsh_path="$(which zsh)"
if ! grep -qx "$zsh_path" /etc/shells; then
	echo "Adding $zsh_path to /etc/shells"
	echo "$zsh_path" | sudo tee -a /etc/shells
fi

if [ "$SHELL" != "$zsh_path" ]; then
	echo "Changing default shell to zsh..."
	chsh -s "$zsh_path"
else
	echo "zsh is already the default shell."
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
	echo "Installing Oh My ZSH..."
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

	echo "Installing zsh plugins..."

	zsh_plugin_path=$HOME/.oh-my-zsh/custom/plugins
	git clone https://github.com/zsh-users/zsh-autosuggestions $zsh_plugin_path/zsh-autosuggestions
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $zsh_plugin_path/zsh-syntax-highlighting
	git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git $zsh_plugin_path/fast-syntax-highlighting
	git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git $zsh_plugin_path/zsh-autocomplete

	zsh_theme_path=$HOME/.oh-my-zsh/customs/themes
	echo "Installing zsh spaceship theme"
	git clone https://github.com/spaceship-prompt/spaceship-prompt.git $zsh_theme_path/spaceship-prompt --depth=1
	ln -s "$zsh_theme_path/spaceship-prompt/spaceship.zsh-theme" "$zsh_theme_path/spaceship.zsh-theme"
else
	echo "Oh My ZSH is already installed."
fi

wezterm_config_path=$HOME/.config/wezterm
if [ ! -d $wezterm_config_path ]; then
	echo "Creating '$wezterm_config_path'..."
	mkdir -p $wezterm_config_path
else
	echo "'$wezterm_config_path' already exists."
fi

bat_theme_path="$(bat --config-dir)/themes/Catppuccin-mocha.tmTheme"
if [ ! -f "$bat_theme_path" ]; then
	echo "Configuring 'bat'"
	mkdir -p "$(bat --config-dir)/themes"
	curl -o "$bat_theme_path" https://raw.githubusercontent.com/catppuccin/bat/refs/heads/main/themes/Catppuccin%20Mocha.tmTheme
else
	echo "'bat' theme already configured."
fi
bat cache --build

volta_node_path=$(volta which node 2>/dev/null)
if [ -n "$volta_node_path" ]; then
	echo "Volta Node is at: $volta_node_path"
else
	echo "Installing node with volta..."
	volta install node
fi

if [ ! -d ~/.config/nvim ]; then
	echo "Cloning neovim configuration..."
	git clone https://github.com/florentsorel/nvim.git ~/.config/nvim
	echo "Don't forget to change the remote with ssh key"
fi

if [ ! -d ~/.local/share/yadm ]; then
	echo "Cloning dotfiles..."
	yadm clone https://github.com/florentsorel/dotfiles.git
	echo "Don't forget to change the remote with ssh key"
fi

dunst_config_path=$HOME/.config/dunst
if [ ! -d $dunst_config_path ]; then
	echo "Creating '$dunst_config_path'..."
	mkdir -p $dunst_config_path
else
	echo "'$dunst_config_path' already exists."
fi

waybar_config_path=$HOME/.config/waybar
if [ ! -d $waybar_config_path ]; then
	echo "Creating '$waybar_config_path'..."
	mkdir -p $waybar_config_path/catppuccin/themes
else
	echo "'$waybar_config_path' already exists."
fi

fuzzel_config_path=$HOME/.config/fuzzel
if [ ! -d $fuzzel_config_path ]; then
	echo "Creating '$fuzzel_config_path'..."
	mkdir -p $fuzzel_config_path
else
	echo "'$fuzzel_config_path' already exists."
fi

btop_config_path=$HOME/.config/btop
if [ ! -d $btop_config_path ]; then
	echo "Creating '$btop_config_path'..."
	mkdir -p $btop_config_path/themes
else
	echo "'$btop_config_path' already exists."
fi

echo "
You can configure wifi connection with 'nmtui' command.

You can use 'nwg-look' to update your GTK theme.

SSH permissions should be:
chmod 700 ~/.ssh
chmod 644 ~/.ssh/id_rsa.pub
chmod 600 ~/.ssh/id_rsa
chmod 600 ~/.ssh/config
"
