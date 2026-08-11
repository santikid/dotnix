{
  config,
  lib,
  pkgs,
  user,
  ...
}: let
  asahiPkgs = config.hardware.asahi.pkgs;

  fairydustKernel =
    (asahiPkgs.linux-asahi.override {
      _kernelPatches = config.boot.kernelPatches;
    })
    .kernel
    .override {
      buildLinux = args:
        asahiPkgs.buildLinux (args
          // {
            version = "7.1.5-fairydust";
            modDirVersion = "7.1.5";
            src = asahiPkgs.fetchFromGitHub {
              owner = "AsahiLinux";
              repo = "linux";
              rev = "eb8089bbc11872c50fcf5138ff069d51b4ae996f";
              hash = "sha256-NmYFKR4WxWOnfYFWcOBfvVFPwM09DZyVAc2kJb6I000=";
            };
          });
    };

  allowedUnfreePackages = [
    "1password"
    "1password-cli"
    "chromium"
    "chromium-unwrapped"
    "widevine-cdm"
  ];
in {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.kernelPackages = lib.mkForce (asahiPkgs.linuxPackagesFor fairydustKernel);

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) allowedUnfreePackages;

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 8;
  };
  boot.loader.efi.canTouchEfiVariables = false;
  boot.kernelParams = [
    "appledrm.show_notch=1"
    "hid_apple.fnmode=2"
  ];

  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
  };

  services = {
    fstrim.enable = true;
    automatic-timezoned.enable = true;
    blueman.enable = true;
    tailscale.enable = true;
    upower.enable = true;
    power-profiles-daemon.enable = true;
    timesyncd = {
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
    logind.settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchDocked = "suspend";
      HandleLidSwitchExternalPower = "suspend";
    };
  };

  programs = {
    _1password.enable = true;
    librepods.enable = true;
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [user.name];
    };
  };
  users.users.${user.name}.extraGroups = ["librepods" "networkmanager"];

  environment.systemPackages = with pkgs; [
    (chromium.override {
      enableWideVine = true;
    })
    teams-for-linux
    thunderbird
    brightnessctl
    libinput
    lm_sensors
    pciutils
    powertop
    usbutils
  ];

  home-manager.users.${user.name} = {
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
