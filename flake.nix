{
  description = "Cory's nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nix-homebrew, nixpkgs }:
  let
    configuration = { config, pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget

      nixpkgs.config.allowUnfree = true;
      system.primaryUser = "cory.hernandez";

      nix-homebrew = {
        enable = true;
        user = "cory.hernandez";
        autoMigrate = true;
        enableRosetta = true;
      };

      environment.systemPackages =
        [ pkgs.neovim
          pkgs.mkalias
          pkgs.obsidian
          pkgs.uv
          pkgs.codex
          pkgs.claude-code
          pkgs.awscli2

        ];

      homebrew = {
        enable = true;
        casks = [
          "iina"
          "firefox"
          "ghostty"
          "chatgpt"
          "claude-code"
          "wispr-flow"
          "windows-app"
          "orbstack"
          "raycast"
          "slack"
          "utm"
          "visual-studio-code"
          "karabiner-elements"
          "yaak"
          "cleanshot"
        ];
        onActivation.cleanup = "zap";
      };

      system.activationScripts.applications.text = let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = [ "/Applications" ];
        };
      in
      pkgs.lib.mkForce ''
        # Set up applications.
        echo "setting up /Applications..." >&2
        rm -rf /Applications/Nix\ Apps
        mkdir -p /Applications/Nix\ Apps
        find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
        while read -r src; do
          app_name=$(basename "$src")
          echo "copying $src" >&2
          ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
        done
      '';

      # Manage macOS settings.
      system.defaults = {
        NSGlobalDomain = {
          AppleInterfaceStyleSwitchesAutomatically = true;
          NSAutomaticCapitalizationEnabled = true;
          NSAutomaticPeriodSubstitutionEnabled = true;
          "com.apple.trackpad.forceClick" = true;
        };

        dock = {
          autohide = true;
          launchanim = true;
          orientation = "bottom";
          show-process-indicators = true;
          show-recents = false;
          tilesize = 40;
        };

        finder = {
          FXPreferredViewStyle = "Nlsv";
          NewWindowTarget = "Recents";
          ShowExternalHardDrivesOnDesktop = true;
          ShowHardDrivesOnDesktop = false;
          ShowRemovableMediaOnDesktop = true;
        };
      };

      system.activationScripts.keyboardShortcuts.text = ''
        shortcuts_plist="/Users/${config.system.primaryUser}/Library/Preferences/com.apple.symbolichotkeys.plist"

        if ! sudo --user=${config.system.primaryUser} -- /usr/libexec/PlistBuddy \
          -c "Print :AppleSymbolicHotKeys" "$shortcuts_plist" >/dev/null 2>&1; then
          sudo --user=${config.system.primaryUser} -- /usr/libexec/PlistBuddy \
            -c "Add :AppleSymbolicHotKeys dict" "$shortcuts_plist"
        fi

        # Screenshots, input-source switching, and Spotlight.
        for shortcut_id in 28 29 30 31 184 60 61 64 65; do
          if ! sudo --user=${config.system.primaryUser} -- /usr/libexec/PlistBuddy \
            -c "Set :AppleSymbolicHotKeys:$shortcut_id:enabled false" "$shortcuts_plist"; then
            if ! sudo --user=${config.system.primaryUser} -- /usr/libexec/PlistBuddy \
              -c "Add :AppleSymbolicHotKeys:$shortcut_id:enabled bool false" "$shortcuts_plist"; then
              sudo --user=${config.system.primaryUser} -- /usr/libexec/PlistBuddy \
                -c "Add :AppleSymbolicHotKeys:$shortcut_id dict" "$shortcuts_plist"
              sudo --user=${config.system.primaryUser} -- /usr/libexec/PlistBuddy \
                -c "Add :AppleSymbolicHotKeys:$shortcut_id:enabled bool false" "$shortcuts_plist"
            fi
          fi
        done

        killall -u ${config.system.primaryUser} cfprefsd 2>/dev/null || true
      '';

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."macbook" = nix-darwin.lib.darwinSystem {
      modules = [ nix-homebrew.darwinModules.nix-homebrew configuration ];
    };
  };
}
