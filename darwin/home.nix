{
  config,
  pkgs,
  lib,
  ...
}: {
    imports = [ ../shared/home ];
    home.file = {
      "Library/Preferences/com.knollsoft.Rectangle.plist" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nix/configs/com.knollsoft.Rectangle.plist";
      };
      "Library/Preferences/com.knollsoft.Hyperkey.plist" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nix/configs/com.knollsoft.Hyperkey.plist";
      };
    };
}