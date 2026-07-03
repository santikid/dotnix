{user, ...}: {
  home-manager.users.${user.name} = {
    home.sessionPath = [
      "$HOME/.npm-global/bin"
    ];

    home.sessionVariables = {
      NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    };
  };
}
