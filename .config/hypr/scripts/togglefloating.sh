active_class=$(hyprctl activewindow | awk -F": " '/class:/ {print $2}')
is_floating=$(hyprctl activewindow | awk -F": " '/floating:/ {print $2}')

if [[ $is_floating == "1" ]]; then
	hyprctl dispatch togglefloating
	exit 0
fi

hyprctl dispatch togglefloating
if [[ $active_class == *"wezterm"* ]]; then
	hyprctl dispatch resizeactive exact 80% 80%
else
	hyprctl dispatch resizeactive exact 50% 50%
fi
hyprctl dispatch centerwindow
