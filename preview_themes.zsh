#!/usr/bin/zsh

# Source zsh configuration to make omz available
source ~/.zshrc

# Store the script's PID
SCRIPT_PID=$$

# File to store the last viewed theme
LAST_THEME_FILE="$PWD/.last_theme"

# Get all available themes
# Store themes in an array
themes=($(omz theme list | grep -v "Current theme\|Custom themes\|Built-in themes" | tr -s ' ' | grep -v '^$'))

# Parse command line arguments - resume by default, reset with option
reset=false
if [[ "$1" == "--reset" || "$1" == "-r" ]]; then
    reset=true
    # Remove the last theme file if it exists
    [[ -f "$LAST_THEME_FILE" ]] && rm "$LAST_THEME_FILE"
fi

echo "Theme preview script"
echo "Press Enter to try the next theme"
echo "Press Ctrl+C to exit the entire script"
echo "Use --reset or -r to start from the beginning"
echo ""

# Find starting index
start_index=0
if [[ -f "$LAST_THEME_FILE" ]] && ! $reset; then
    last_theme=$(cat "$LAST_THEME_FILE")
    for i in {1..${#themes[@]}}; do
        if [[ "${themes[$i]}" == "$last_theme" ]]; then
            # Start from the next theme
            start_index=$((i + 1))
            echo "Resuming from theme: $last_theme"
            break
        fi
    done
fi

# Initialize index
i=$start_index

# Loop through themes using while true
while true; do
    # Check if index is out of bounds
    if [[ $i -lt 0 ]]; then
        i=0
        echo "Already at the first theme."
    elif [[ $i -ge ${#themes[@]} ]]; then
        echo "Theme preview completed."
        break
    fi

    theme="${themes[$i]}"
    echo "Setting theme to: $theme ($((i + 1))/${#themes[@]}) [← Previous | Next →]"
    omz theme set "$theme" &>/dev/null

    # Save current theme to file
    echo "$theme" >"$LAST_THEME_FILE"

    # Start an interactive shell with our temporary zshrc
    ZDOTDIR=$PWD/testing_environment zsh -i
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
