#!/usr/bin/env bash
set -euo pipefail

FLAKE_DIR="$(cd "$(dirname "$0")" && pwd)"
CURRENT_HOST="$(hostname)"

# Check for uncommitted changes
if ! git -C "$FLAKE_DIR" diff --quiet || ! git -C "$FLAKE_DIR" diff --cached --quiet; then
  echo "WARNING: You have uncommitted changes. Remote hosts won't get them."
  read -p "Continue anyway? [y/N] " -n 1 -r
  echo
  [[ $REPLY =~ ^[Yy]$ ]] || exit 1
fi

# Check for unpushed commits
if git -C "$FLAKE_DIR" status -sb | head -1 | grep -q 'ahead'; then
  echo "WARNING: You have unpushed commits. Remote hosts won't get them."
  read -p "Continue anyway? [y/N] " -n 1 -r
  echo
  [[ $REPLY =~ ^[Yy]$ ]] || exit 1
fi

succeeded=()
failed=()

# Get all host names from the flake
darwin_hosts=$(nix eval "$FLAKE_DIR#darwinConfigurations" --apply 'x: builtins.attrNames x' --json 2>/dev/null)
nixos_hosts=$(nix eval "$FLAKE_DIR#nixosConfigurations" --apply 'x: builtins.attrNames x' --json 2>/dev/null)
hosts=$(echo "$darwin_hosts $nixos_hosts" | nix-shell -p jq --run 'jq -s -r "add | .[]"')

for host in $hosts; do
  if [[ "$host" == "$CURRENT_HOST" ]]; then
    echo "==> $host (local)"
    if cd "$FLAKE_DIR" && git pull && make rebuild; then
      succeeded+=("$host")
    else
      failed+=("$host")
    fi
  else
    echo "==> $host (remote)"
    if ssh -t "$host" "cd ~/.nix 2>/dev/null || cd /.nix && git pull && make rebuild"; then
      succeeded+=("$host")
    else
      echo "==> FAILED on $host"
      failed+=("$host")
    fi
  fi
  echo
done

echo "=== Summary ==="
[[ ${#succeeded[@]} -gt 0 ]] && echo "Succeeded: ${succeeded[*]}"
[[ ${#failed[@]} -gt 0 ]] && echo "Failed: ${failed[*]}"
[[ ${#failed[@]} -gt 0 ]] && exit 1
