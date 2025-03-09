{user, ...}: {
  services.tailscale.enable = true;
  services.openssh = {
    enable = true;
    ports = [22];
    settings = {
      PasswordAuthentication = false;
      AllowUsers = [user.name];
      X11Forwarding = true;
      PermitRootLogin = "no";
    };
  };
}
