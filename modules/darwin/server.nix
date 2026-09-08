{user, ...}: {
  # nix-darwin doesn't support structured openssh settings like NixOS,
  # so we use extraConfig for sshd hardening
  services.openssh = {
    enable = true;
    extraConfig = ''
      PasswordAuthentication no
      PermitRootLogin no
      KbdInteractiveAuthentication no
      AllowUsers ${user.name} restic

      Match User restic
        ForceCommand internal-sftp
        DisableForwarding yes
        PermitTTY no
      Match all
    '';
  };
  users.users.${user.name}.openssh.authorizedKeys.keys = user.sshKeys;

  power.restartAfterPowerFailure = true;
  power.restartAfterFreeze = true;
  power.sleep.computer = "never";
}
