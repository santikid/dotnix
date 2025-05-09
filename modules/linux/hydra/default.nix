{user, ...}: {
  services.hydra = {
    enable = true;
    hydraURL = "http://0.0.0.0:3000";
    notificationSender = "hydra@localhost";
  };
}
