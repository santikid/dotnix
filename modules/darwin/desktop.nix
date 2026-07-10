{pkgs, ...}: {
  homebrew.casks = [
    "secretive"
    "iina"
    "zen"
  ];

  environment.systemPackages = with pkgs; [
    emacs
    lazygit
  ];
}
