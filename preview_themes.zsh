#!/usr/bin/zsh

zdotdir=$PWD/testing_environment
zsh_theme_file="$zdotdir/.zsh_theme"
zsh_plugins_file="$zdotdir/.zsh_plugins"

# Default options
reset=false
help=false
start_theme=""
plugins=()

# Parse command line arguments using getopt
zparseopts -D -E -- r=reset_opt -reset=reset_opt h=help_opt -help=help_opt t:=theme_opt -theme:=theme_opt p:=plugin_opt -plugin:=plugin_opt

if (($#help_opt > 0)); then
    help=true
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -r, --reset                Start from the beginning instead of resuming"
    echo "  -t THEME, --theme THEME    Start with the specified theme (name or index number)"
    echo "  -p PLUGIN, --plugin PLUGIN Activate the specified plugin (can be used multiple times)"
    echo "  -h, --help                 Display this help message"
    exit 0
fi

if (($#reset_opt > 0)); then
    reset=true
    # Remove the last theme file if it exists
    [[ -f "$zsh_theme_file" ]] && rm "$zsh_theme_file"
fi

if (($#theme_opt > 0)); then
    # Extract the theme name/index (it's the second element in the array)
    start_theme="${theme_opt[2]}"
fi

# Process plugin options (can be specified multiple times)
if (($#plugin_opt > 0)); then
    # Extract plugins (every second element starting from position 2)
    for ((i = 2; i <= $#plugin_opt; i += 2)); do
        plugins+=(${plugin_opt[$i]})
    done
fi

# Write plugins to file
echo 'plugins=('"${plugins[@]}"')' >$zsh_plugins_file

echo "Theme preview script"
echo "Press Ctrl + [right arrow | left arrow] to navigate to the next or previous theme"
echo "Press Ctrl+C to exit the entire script"
echo "Use --reset or -r to start from the beginning"
echo ""

# Source zsh configuration to make omz available
source "$HOME/.zshrc"

# Get all available themes
# Store themes in an array
themes=($(omz theme list))

# Find starting index - note: zsh arrays are 1-indexed
start_index=1

# Otherwise, try to resume from last theme if not resetting
if ! [[ -n "$start_theme" ]] && [[ -f "$zsh_theme_file" ]] && ! $reset; then
    source "$zsh_theme_file"
    start_theme="$ZSH_THEME"
fi

# If theme is populated, use that
if [[ -n "$start_theme" ]]; then
    # Check if it's a number
    if [[ "$start_theme" =~ ^[0-9]+$ ]]; then
        # It's a number, perform bounds check and use it as an index
        if [[ $start_theme -ge 1 && $start_theme -le ${#themes[@]} ]]; then
            start_index=$start_theme
            echo "Starting with theme index: $start_index (${themes[$start_index]})"
        else
            echo "Invalid theme index: $start_theme. Must be between 1 and ${#themes[@]}"
            exit 1
        fi
    else
        # It's a name, find its index
        found=false
        for index in {1..${#themes[@]}}; do
            if [[ "${themes[$index]}" == "$start_theme" ]]; then
                start_index=$index
                found=true
                echo "Starting with theme: $start_theme"
                break
            fi
        done
        if ! $found; then
            echo "Theme '$start_theme' not found. Available themes:"
            echo "${themes[@]}"
            exit 1
        fi
    fi
fi

# Initialize index
index=$start_index

# Loop through themes using while true
while true; do
    # Check if index is out of bounds
    if [[ $index -lt 1 ]]; then
        i=1
        echo "Already at the first theme."
    elif [[ $index -gt ${#themes[@]} ]]; then
        echo "Theme preview completed."
        break
    fi

    theme="${themes[$index]}"
    echo "Setting theme to: $theme ($index/${#themes[@]}) [← Previous | Next →]"
    echo 'ZSH_THEME="'"$theme"'"' >$zsh_theme_file

    # Start an interactive shell with our temporary zshrc
    # ZSH was sourced from ~/.zshrc
    ZSH=$ZSH ZDOTDIR=$zdotdir zsh -i
    exit_code=$?

    # Update index based on exit code
    if [[ $exit_code -eq 2 ]]; then
        # Go back one theme
        index=$((index - 1))
    elif [[ $exit_code -eq 0 ]]; then
        # Exit code 0 means stop the preview
        echo "Theme preview stopped."
        break
    else
        # Any other exit code means continue to next theme
        index=$((index + 1))
    fi
done
