{ config, ... }:

let
  dotfiles = "${config.home.homeDirectory}/nix/.config";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  home.stateVersion = "26.05";

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
  };

  xdg.enable = true;
  xdg.configFile = {
    "zsh/.zshrc".source = link "zsh/.zshrc";
    "zsh/.zprofile".source = link "zsh/.zprofile";
    "zsh/.p10k.zsh".source = link "zsh/.p10k.zsh";
    "git/config".source = link "git/config";
    "git/ignore".source = link "git/ignore";
    "htop/htoprc".source = link "htop/htoprc";
    "karabiner/karabiner.json".source = link "karabiner/karabiner.json";
    "herdr/config.toml".source = link "herdr/config.toml";
    "apod-agent-memory/config.toml".source = link "apod-agent-memory/config.toml";
  };
}
