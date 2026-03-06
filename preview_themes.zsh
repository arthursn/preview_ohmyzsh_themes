#!/usr/bin/zsh

# Source zsh configuration to make omz available
source ~/.zshrc

ZDOTDIR=$PWD/testing_environment
ZSH_THEME_FILE="$ZDOTDIR/.zsh_theme"

# Get all available themes
# Store themes in an array
themes=($(omz theme list))

# Parse command line arguments - resume by default, reset with option
reset=false
if [[ "$1" == "--reset" || "$1" == "-r" ]]; then
    reset=true
    # Remove the last theme file if it exists
    [[ -f "$ZSH_THEME_FILE" ]] && rm "$ZSH_THEME_FILE"
fi

echo "Theme preview script"
echo "Press Ctrl + [right arrow | left arrow] to navigate to the next or previous theme"
echo "Press Ctrl+C to exit the entire script"
echo "Use --reset or -r to start from the beginning"
echo ""

# Find starting index - note: zsh arrays are 1-indexed
start_index=1
if [[ -f "$ZSH_THEME_FILE" ]] && ! $reset; then
    source "$ZSH_THEME_FILE"
    for i in {1..${#themes[@]}}; do
        if [[ "${themes[$i]}" == "$ZSH_THEME" ]]; then
            start_index=$i
            echo "Resuming from theme: $ZSH_THEME"
            break
        fi
    done
fi

# Initialize index
i=$start_index

# Loop through themes using while true
while true; do
    # Check if index is out of bounds
    if [[ $i -lt 1 ]]; then
        i=1
        echo "Already at the first theme."
    elif [[ $i -gt ${#themes[@]} ]]; then
        echo "Theme preview completed."
        break
    fi

    theme="${themes[$i]}"
    echo "Setting theme to: $theme ($i/${#themes[@]}) [← Previous | Next →]"
    echo 'ZSH_THEME="'"$theme"'"' >$ZSH_THEME_FILE

    # Start an interactive shell with our temporary zshrc
    ZDOTDIR=$ZDOTDIR zsh -i
    exit_code=$?

    # Update index based on exit code
    if [[ $exit_code -eq 2 ]]; then
        # Go back one theme
        i=$((i - 1))
    elif [[ $exit_code -eq 0 ]]; then
        # Exit code 0 means stop the preview
        echo "Theme preview stopped."
        break
    else
        # Any other exit code means continue to next theme
        i=$((i + 1))
    fi
done
