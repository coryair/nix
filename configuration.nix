{
  pkgs,
  inputs,
  system,
  hostName,
  userName,
  homeDirectory,
  ...
}:

{
  nixpkgs.hostPlatform = system;

  nix = {
    package = pkgs.nix;
    channel.enable = false;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        "@admin"
      ];
    };
  };

  networking.hostName = hostName;
  networking.localHostName = hostName;
  system.primaryUser = userName;

  users.users.${userName}.home = homeDirectory;

  environment.systemPackages = with pkgs; [
    firefox
    jq
  ];

  programs.zsh.enable = true;
  time.timeZone = "America/Denver";

  system.defaults = {
    NSGlobalDomain = {
      ApplePressAndHoldEnabled = false;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      NSAutomaticSpellingCorrectionEnabled = false;
    };

    dock = {
      autohide = true;
      autohide-delay = 0.0;
      show-recents = false;
      tilesize = 48;
    };

    finder = {
      AppleShowAllExtensions = true;
      FXPreferredViewStyle = "Nlsv";
      ShowPathbar = true;
      ShowStatusBar = true;
    };

    loginwindow.GuestEnabled = false;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    extraSpecialArgs = { inherit userName homeDirectory; };
    users.${userName} = import ./home.nix;
  };

  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
  system.stateVersion = 7;
}
