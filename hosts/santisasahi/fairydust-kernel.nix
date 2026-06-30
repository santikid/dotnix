{inputs, ...}: let
  asahiKernel = {
    version = "7.0.13-fairydust";
    modDirVersion = "7.0.13";
    branch = "7.0";
    rev = "c83992242bc1e38bfc861a91696534479a2dbdf4";
    hash = "sha256-sGcgrrf/rpb8u9dvwiTFdNjp18UyuRhW94biH1WMO5I=";
  };

  asahiOverlay = final: prev: let
    upstreamAsahi = inputs.nixos-apple-silicon.overlays.default final prev;
    linuxAsahiFairydust = {
      lib,
      callPackage,
      linuxPackagesFor,
      _kernelPatches ? [],
    }: let
      linuxAsahiFairydustPkg = {
        stdenv,
        lib,
        fetchFromGitHub,
        buildLinux,
        ...
      }:
        buildLinux rec {
          inherit stdenv lib;

          pname = "linux-asahi";
          inherit (asahiKernel) version modDirVersion;
          extraMeta.branch = asahiKernel.branch;

          src = fetchFromGitHub {
            owner = "AsahiLinux";
            repo = "linux";
            inherit (asahiKernel) rev hash;
          };

          kernelPatches = [
            {
              name = "Asahi config";
              patch = null;
              structuredExtraConfig = with lib.kernel; {
                # Needed for GPU
                ARM64_16K_PAGES = yes;

                ARM64_MEMORY_MODEL_CONTROL = yes;
                ARM64_ACTLR_STATE = yes;

                # Might lead to the machine rebooting if not loaded soon enough
                APPLE_WATCHDOG = yes;

                # Can not be built as a module, defaults to no
                APPLE_M1_CPU_PMU = yes;

                # Defaults to 'y', but we want to allow the user to set options in modprobe.d
                HID_APPLE = module;

                APPLE_PMGR_MISC = yes;
                APPLE_PMGR_PWRSTATE = yes;
              };
              features.rust = true;
            }
          ]
          ++ _kernelPatches;
        };
      kernel = callPackage linuxAsahiFairydustPkg {};
    in
      lib.recurseIntoAttrs (linuxPackagesFor kernel);
  in
    upstreamAsahi
    // {
      linux-asahi = final.callPackage linuxAsahiFairydust {};
    };
in {
  hardware.asahi.overlay = asahiOverlay;
}
