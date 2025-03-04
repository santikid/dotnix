{pkgs, ...}:
with pkgs; [
  (vscode-with-extensions.override {
    vscode = vscodium;
    vscodeExtensions = with vscode-extensions;
      [
        bbenoist.nix
        ms-azuretools.vscode-docker
      ]
      ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "binary-plist";
          publisher = "dnicolson";
          version = "0.11.4";
          sha256 = "2f90f86dcdd1193badcd4c6124159746a9acb2c19e699fa7d39b4c341e872b49";
        }
      ];
  })
]
