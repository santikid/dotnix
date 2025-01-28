# WE SO BACK

# Installation on macOS

1. Install Xcode CLI Tools

`xcode-select --install`

2. Install Nix using the Determinate Systems installer

`curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install`

4. Clone to ~/.nix and install

`git clone https://github.com/santikid/dotnix.git ~/.nix`
`nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake ~/.nix#<host>`

# Rectangle and Hyperkey

Manually set up hyperkey to capslock and set HYPER + (h,j,k,l,n,m) as hotkeys in rectangle
