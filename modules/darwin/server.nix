{user, ...}: {
  # nix-darwin doesn't support structured openssh settings like NixOS,
  # so we use extraConfig for sshd hardening
  services.openssh = {
    enable = true;
    extraConfig = ''
      PasswordAuthentication no
      PermitRootLogin no
      AllowUsers ${user.name}
    '';
  };
  users.users.${user.name}.openssh.authorizedKeys.keys = user.sshKeys;
  services.tailscale.enable = true;

  power.restartAfterPowerFailure = true;
  power.restartAfterFreeze = true;
  power.sleep.computer = "never";
}
