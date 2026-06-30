{
  config,
  lib,
  pkgs,
  inputs,
  user,
  ...
}: {
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "1password"
      "1password-cli"
      "chromium"
      "chromium-unwrapped"
      "widevine-cdm"
    ];

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 8;
  };
  boot.loader.efi.canTouchEfiVariables = false;
  boot.kernelParams = ["appledrm.show_notch=1"];
  boot.supportedFilesystems = ["btrfs"];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = ["subvol=root" "compress=zstd" "noatime"];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = ["subvol=nix" "compress=zstd" "noatime"];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = ["subvol=home" "compress=zstd" "noatime"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/EFI";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  swapDevices = [];
  zramSwap.enable = true;
  services.fstrim.enable = true;

  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
  };
  services.timesyncd = {
    enable = true;
    servers = [
      "time.cloudflare.com"
      "time.google.com"
      "pool.ntp.org"
    ];
    fallbackServers = [
      "time.nist.gov"
      "0.nixos.pool.ntp.org"
      "1.nixos.pool.ntp.org"
    ];
  };
  services.automatic-timezoned.enable = true;

  hardware.asahi.extractPeripheralFirmware = true;
  hardware.sensor.iio.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  services.tailscale.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchDocked = "suspend";
    HandleLidSwitchExternalPower = "suspend";
  };

  programs._1password.enable = true;
  programs.librepods.enable = true;
  users.users.${user.name}.extraGroups = ["librepods"];
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [user.name];
  };

  nix.settings = {
    trusted-users = ["root" "@wheel" user.name];
    extra-substituters = [
      "https://nixos-apple-silicon.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-apple-silicon.cachix.org-1:8psDu5SA5dAD7qA0zMy5UT292TxeEPzIz8VVEr2Js20="
    ];
  };

  environment.systemPackages = with pkgs; [
    inputs.zen-browser.packages.${pkgs.system}.default
    (chromium.override {
      enableWideVine = true;
    })
    teams-for-linux
    thunderbird
    vesktop
    brightnessctl
    libinput
    lm_sensors
    pciutils
    powertop
    usbutils
  ];

  home-manager.users.${user.name} = {
    home.sessionPath = [
      "$HOME/.npm-global/bin"
    ];

    home.sessionVariables = {
      NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    };
    programs.zsh.shellAliases = {
      macos = "nix shell nixpkgs#asahi-bless -c sh -c 'sudo \"$(command -v asahi-bless)\" --set-boot-macos --yes && sudo reboot'";
    };

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings."*" = {
        IdentityAgent = "~/.1password/agent.sock";
      };
    };
  };

  system.stateVersion = "26.05";
}
