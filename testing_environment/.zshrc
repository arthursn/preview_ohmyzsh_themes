source "$ZDOTDIR/.zsh_theme"
source "$ZSH/oh-my-zsh.sh"

source .venv/bin/activate &>/dev/null

# Function to handle Enter key
function previous_theme() {
    exit 2
}

function next_theme() {
    exit 1
}

function stop_preview() {
    exit 0
}

# Prevent Ctrl+D from immediately exiting the shell
setopt ignoreeof

# Set up trap for Ctrl+C
trap stop_preview INT
# Create a ZLE widgets
zle -N stop_preview_widget stop_preview
zle -N next_theme_widget next_theme
zle -N previous_theme_widget previous_theme

bindkey '^D' stop_preview_widget
bindkey '^[[1;5D' previous_theme_widget # Ctrl + Arrow Left
bindkey '^[[1;5C' next_theme_widget     # Ctrl + Arrow Right
