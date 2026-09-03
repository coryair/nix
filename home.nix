{ config, pkgs, zsh-bat, ... }:

let
  dotfiles = "${config.home.homeDirectory}/nix/.config";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
  ohMyZshCustom = pkgs.linkFarm "oh-my-zsh-custom" [
    {
      name = "plugins/you-should-use";
      path = "${pkgs.zsh-you-should-use}/share/zsh/plugins/you-should-use";
    }
    {
      name = "plugins/zsh-bat";
      path = zsh-bat;
    }
    {
      name = "plugins/zsh-autosuggestions";
      path = "${pkgs.zsh-autosuggestions}/share/zsh/plugins/zsh-autosuggestions";
    }
    {
      name = "plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh";
      path = "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
    }
    {
      name = "themes/powerlevel10k";
      path = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k";
    }
  ];
in
{
  home.stateVersion = "26.05";
  home.packages = [ pkgs.bat pkgs.fd pkgs.pre-commit pkgs.ripgrep ];

  home.file = {
    ".hushlogin".source = link "shell/.hushlogin";
    ".testcontainers.properties".source = link "testcontainers/testcontainers.properties";

    ".claude/settings.json".source = link "claude/settings.json";
    ".claude/statusline-command.sh".source = link "claude/statusline-command.sh";
    ".claude/hooks/herdr-agent-state.sh".source = link "claude/hooks/herdr-agent-state.sh";

    ".codex/config.toml".source = link "codex/config.toml";
    ".codex/AGENTS.md".source = link "codex/AGENTS.md";
    ".codex/hooks.json".source = link "codex/hooks.json";
    ".codex/herdr-agent-state.sh".source = link "codex/herdr-agent-state.sh";

    ".pi/agent/settings.json".source = link "pi/agent/settings.json";
    ".pi/agent/extensions/herdr-agent-state.ts".source = link "pi/agent/extensions/herdr-agent-state.ts";

    "Library/Application Support/com.mitchellh.ghostty/config.ghostty".source = link "ghostty/config.ghostty";
  };

  xdg.enable = true;
  xdg.configFile = {
    "zsh/.zshrc".source = link "zsh/.zshrc";
    "zsh/.zprofile".source = link "zsh/.zprofile";
    "zsh/.p10k.zsh".source = link "zsh/.p10k.zsh";
    "nvim/init.lua".source = link "nvim/init.lua";
    "zsh/.nix-omz.zsh".text = ''
      export ZSH="${pkgs.oh-my-zsh}/share/oh-my-zsh"
      export ZSH_CUSTOM="${ohMyZshCustom}"
      export PATH="${pkgs.bat}/bin:$PATH"
    '';
    "git/config".source = link "git/config";
    "git/ignore".source = link "git/ignore";
    "htop/htoprc".source = link "htop/htoprc";
    "karabiner/karabiner.json".source = link "karabiner/karabiner.json";
    "herdr/config.toml".source = link "herdr/config.toml";
    "apod-agent-memory/config.toml".source = link "apod-agent-memory/config.toml";
  };
}
