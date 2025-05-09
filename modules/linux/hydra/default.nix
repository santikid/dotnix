{user, ...}: {
  services.hydra = {
    enable = true;
    hydraURL = "http://localhost:10001";
    notificationSender = "hydra@localhost";
  };
}
