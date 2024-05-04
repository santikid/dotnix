# Nix Experiment failed

# Installation on macOS

1. Install Xcode CLI Tools

```xcode-select --install```

2. Install Nix

```whatever the command is```

3. *Assign Full Disk Access permissions to Terminal.app*

```System Settings / Privacy / Full Disk Access -> add Terminal.app```

4. Clone and install

```nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake ~/.nix#santibook```

# Setting up Rust

Instead of using nix for Rust, it installs rustup-init through homebrew. To actually install a Rust toolchain, run:

````rustup-init```

# Setting up Neovim

This flake installs fnm to manage node versions. Before running neovim, install a node version through fnm so Mason can install LSPs.

# Rectangle and Hyperkey

I use Rectangle with Hyperkey for window management. The keyboard shortcuts need to be set up manually.

# NOTES

## macOS
- Disable Input Switching shortcut in System Settings; otherwise Ctrl + Space won't work.
