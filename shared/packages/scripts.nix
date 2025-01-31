{pkgs, ...}:
with pkgs; [
  (
    pkgs.writeShellApplication {
      name = "llmexport";
      runtimeInputs = with pkgs; [];
      text = ''
#!/bin/bash

# Check if directory and file pattern are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <directory> <file-pattern>"
    echo "Example: $0 /path/to/folder \"*.nix\""
    exit 1
fi

DIRECTORY="$1"
PATTERN="$2"

# Find and iterate over all matching files
find "$DIRECTORY" -type f -name "$PATTERN" | while read -r file; do
    echo "### FILE: $file"
    echo '```' 
    cat "$file"
    echo '```'
    echo ""
done
      '';
    }
  )
  (
    pkgs.writeShellApplication {
      name = "ts";
      runtimeInputs = with pkgs; [tmux fzf];
      text = ''
set +e
set +o nounset

# SHAMELESSLY STOLEN FROM https://github.com/ThePrimeagen/.dotfiles/blob/master/bin/.local/scripts/tmux-sessionizer

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(find ~/Projects/co ~/Projects/p ~/Projects/w -mindepth 1 -maxdepth 1 -type d | fzf)
fi

if [[ -z $selected ]]; then
    exit 0
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -s "$selected_name" -c "$selected"
    exit 0
fi

if ! tmux has-session -t="$selected_name" 2> /dev/null; then
    tmux new-session -ds "$selected_name" -c "$selected"
fi

if [[ -z $TMUX ]]; then
		tmux attach -t "$selected_name"
fi

tmux switch-client -t "$selected_name"
      '';
    }
  )
]
