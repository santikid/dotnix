{
  config,
  inputs,
  lib,
  pkgs,
  user,
  ...
}: let
  razer-performance = pkgs.stdenv.mkDerivation {
    pname = "razer-performance";
    version = "1";
    src = ./razer-performance.c;
    dontUnpack = true;
    buildPhase = ''
      $CC -std=c11 -D_DEFAULT_SOURCE -O2 -Wall -Wextra -Werror "$src" -o razer-performance
    '';
    installPhase = ''
      install -Dm755 razer-performance "$out/bin/razer-performance"
    '';
  };
  razer-performance-default = pkgs.writeShellScript "razer-performance-default" ''
    ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance
    ${razer-performance}/bin/razer-performance custom-max
  '';
in {
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
      "vmware-workstation"
    ];

  hardware.enableRedistributableFirmware = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  virtualisation.vmware.host.enable = true;

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

  # Minimal local controller for the Blade 15's EC performance profiles.
  services.udev.extraRules = ''
    KERNEL=="hidraw*", ATTRS{idVendor}=="1532", ATTRS{idProduct}=="0276", GROUP="openrazer", MODE="0660"
  '';

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
    razer-performance
  ];

  home-manager.users.${user.name} = {
    systemd.user.services.razer-performance-default = {
      Unit = {
        Description = "Set the Razer Blade gaming performance profile";
        After = ["graphical-session-pre.target"];
      };
      Service = {
        Type = "oneshot";
        ExecStart = razer-performance-default;
        RemainAfterExit = true;
      };
      Install.WantedBy = ["graphical-session.target"];
    };

    programs.mangohud = {
      enable = true;
      settings = {
        fps = true;
        fps_metrics = "avg,0.01,0.1";
        frametime = true;
        frame_timing = true;
        frame_count = true;
        cpu_stats = true;
        core_load = true;
        cpu_temp = true;
        cpu_mhz = true;
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
        throttling_status = true;
        throttling_status_graph = true;
        vulkan_driver = true;
        present_mode = true;
        log_versioning = true;
        toggle_hud = "Shift_R+F12";
        toggle_logging = "Shift_L+F2";
        output_folder = "/home/${user.name}/Documents/MangoHud";
        log_interval = 100;
      };
    };

    programs.niri.settings.outputs."eDP-1".mode = {
      width = 2560;
      height = 1440;
      refresh = 165.003;
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
