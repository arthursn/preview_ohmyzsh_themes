# Oh My Zsh Theme Preview Tool

A command-line utility to interactively preview and cycle through Oh My Zsh themes.

## Overview

This tool allows you to quickly preview all available Oh My Zsh themes without having to manually edit your `.zshrc` file. It creates a temporary environment where you can cycle through themes using keyboard shortcuts.

## Prerequisites

- Zsh shell
- Oh My Zsh installed

## Usage

Run the script:

```
./preview_themes.zsh
```

### Command-line Options

- `-r, --reset`: Start from the beginning instead of resuming where you left off
- `-t THEME, --theme THEME`: Start with a specific theme (name or index number)
- `-p PLUGIN, --plugin PLUGIN`: Activate a specific Oh My Zsh plugin (can be used multiple times)
- `-h, --help`: Display help message

### Navigation

While previewing themes:
- `Ctrl + Right Arrow`: Move to the next theme
- `Ctrl + Left Arrow`: Move to the previous theme
- `Ctrl + C` or `Ctrl + D`: Exit the preview

## How It Works

The script creates a temporary environment in the `testing_environment` directory with its own `.zshrc` file. It then launches interactive Zsh sessions with different themes applied, allowing you to see how each theme looks with your current terminal settings.

## Examples

Start from the beginning:
```
./preview_themes.zsh --reset
```

Start with a specific theme:
```
./preview_themes.zsh --theme robbyrussell
```

Start with a specific theme index:
```
./preview_themes.zsh --theme 5
```

Enable plugins while previewing:
```
./preview_themes.zsh --plugin git --plugin docker
```