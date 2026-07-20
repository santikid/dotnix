{
  config,
  inputs,
  lib,
  pkgs,
  user,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "1password"
      "1password-cli"
      "1password-gui"
      "chromium"
      "chromium-unwrapped"
      "discord"
      "nvidia-kernel-modules"
      "nvidia-settings"
      "nvidia-x11"
      "steam"
      "steam-original"
      "steam-run"
      "steam-unwrapped"
      "widevine-cdm"
    ];

  hardware.enableRedistributableFirmware = true;

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 8;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = ["btrfs" "ntfs"];

  zramSwap.enable = true;
  services.fstrim.enable = true;
  services.fwupd.enable = true;

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

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement = {
      enable = true;
      finegrained = true;
    };
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = lib.mkDefault "PCI:0:2:0";
      nvidiaBusId = lib.mkDefault "PCI:1:0:0";
    };
  };

  hardware.openrazer = {
    enable = true;
    users = [user.name];
  };

  programs.steam.enable = true;
  programs.gamemode.enable = true;

  programs._1password.enable = true;
  programs.librepods.enable = true;
  users.users.${user.name}.extraGroups = ["librepods"];
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [user.name];
  };

  nix.settings.trusted-users = ["root" "@wheel" user.name];

  environment.systemPackages = with pkgs; [
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    (chromium.override {
      enableWideVine = true;
    })
    discord
    brightnessctl
    libinput
    lm_sensors
    pciutils
    powertop
    usbutils
    mangohud
    protonup-qt
    vulkan-tools
    polychromatic
  ];

  home-manager.users.${user.name} = {
    programs.zsh.shellAliases = {
      steam-nvidia = "nvidia-offload steam";
    };

    xdg.desktopEntries.steam = {
      name = "Steam";
      comment = "Application for managing and playing games on Steam";
      exec = "nvidia-offload steam %U";
      icon = "steam";
      terminal = false;
      type = "Application";
      categories = ["Network" "FileTransfer" "Game"];
      mimeType = [
        "x-scheme-handler/steam"
        "x-scheme-handler/steamlink"
      ];
      settings = {
        PrefersNonDefaultGPU = "true";
        X-KDE-RunOnDiscreteGpu = "true";
      };
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
