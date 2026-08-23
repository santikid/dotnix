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
      "discord-unwrapped"
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
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.loader.limine = {
    enable = true;
    maxGenerations = 10;
  };
  boot.loader.efi.canTouchEfiVariables = true;

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
      finegrained = false;
    };

    dynamicBoost.enable = true;

    open = true;
    nvidiaSettings = true;

    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.openrazer = {
    enable = true;
    users = [user.name];
  };

  programs.steam.enable = true;
  programs.gamemode = {
    enable = true;
    settings.general = {
      desiredgov = "performance";
      desiredprof = "performance";
      inhibit_screensaver = 1;
    };
  };

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
    protonup-qt
    vulkan-tools
    polychromatic
  ];

  home-manager.users.${user.name} = {
    programs.mangohud = {
      enable = true;
      settings = {
        fps = true;
        fps_metrics = "avg,0.01,0.1";
        frametime = true;
        frame_timing = true;
        cpu_stats = true;
        cpu_temp = true;
        cpu_mhz = true;
        cpu_power = true;
        gpu_stats = true;
        gpu_temp = true;
        gpu_core_clock = true;
        gpu_mem_clock = true;
        gpu_power = true;
        gpu_power_limit = true;
        gpu_fan = true;
        vram = true;
        ram = true;
        gamemode = true;
        throttling_status_graph = true;
        toggle_hud = "Shift_R+F12";
        toggle_logging = "Shift_L+F2";
        output_folder = "/home/${user.name}/Documents/MangoHud";
        log_interval = 1000;
      };
    };

    programs.niri.settings.outputs."eDP-1".mode = {
      width = 2560;
      height = 1440;
      refresh = 165.003;
    };

    programs.zsh.shellAliases = {
      steam-gaming = "MANGOHUD=1 gamemoderun steam";
    };

    xdg.desktopEntries.steam = {
      name = "Steam";
      comment = "Application for managing and playing games on Steam";
      exec = "env MANGOHUD=1 gamemoderun steam %U";
      icon = "steam";
      terminal = false;
      type = "Application";
      categories = ["Network" "FileTransfer" "Game"];
      mimeType = [
        "x-scheme-handler/steam"
        "x-scheme-handler/steamlink"
      ];
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
