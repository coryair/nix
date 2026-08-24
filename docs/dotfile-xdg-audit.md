# Dotfile XDG audit

## Non-Codex paths

| Current live path | Can live under `~/.config`? | Supported mechanism | What moves |
| --- | --- | --- | --- |
| `~/.zshrc`, `~/.zprofile` | Yes, natively | Set `ZDOTDIR=$XDG_CONFIG_HOME/zsh` before Zsh starts. Zsh reads `.zprofile`, `.zshrc`, and its other user startup files from `$ZDOTDIR`, falling back to `$HOME` only when `ZDOTDIR` is unset. | Startup configuration only. History and cache locations remain controlled separately. |
| `~/.p10k.zsh` | Yes, by explicit sourcing | Store it under `$ZDOTDIR` and source that path from `.zshrc`. Powerlevel10k itself documents `~/.p10k.zsh`, and `p10k configure` generates that default path, so a later wizard run may recreate the home-level file. | The Powerlevel10k configuration file only. |
| `~/.gitconfig` | Yes, natively | Use `${XDG_CONFIG_HOME:-$HOME/.config}/git/config`. Remove the home-level file or link after migration because Git reads the XDG file and then `~/.gitconfig`, allowing the latter to override it. | Global Git configuration only. |
| `~/.hushlogin` | No | Apple/OpenSSH checks `.hushlogin` under the account home directory and provides no XDG override. A symlink may point into `~/.config`, but the home-level entry must remain. | This is only a marker file. |
| `~/.testcontainers.properties` | No native XDG path | Testcontainers Java checks the user-home file and does not document a config-path variable. Individual properties can instead be expressed as `TESTCONTAINERS_*` environment variables. A symlink may point into `~/.config`, but the home-level entry must remain. | Configuration only. |
| `~/.claude/settings.json` | Technically yes, but only by moving Claude's whole home | Set `CLAUDE_CONFIG_DIR=$XDG_CONFIG_HOME/claude`. Claude applies that directory to every documented `~/.claude` path. | Settings plus session history, plugins, and other application data. On Linux and Windows it also moves credentials; macOS credentials remain in Keychain. |
| Claude hook and status-line scripts | Yes, independently | Their settings accept a shell command or script path, so the scripts can live under `~/.config/claude/` and the commands in `settings.json` can point there. This does not require changing `CLAUDE_CONFIG_DIR`. | Only the scripts. |
| `~/.pi/agent/settings.json` | Technically yes, but only by moving Pi's whole agent directory | Set `PI_CODING_AGENT_DIR=$XDG_CONFIG_HOME/pi/agent`. Pi describes this as overriding its config directory, and that directory also contains credentials, extensions, skills, packages, models, and other global resources. Sessions can be split out separately with `PI_CODING_AGENT_SESSION_DIR` or `sessionDir`. | The whole global agent directory, not only `settings.json`. |
| Pi extension scripts | Yes, independently | Keep `settings.json` at Pi's normal location and list an absolute path under its `extensions` setting, or load an explicit path with `--extension`. Pi documents absolute extension paths in settings. | Only the extension scripts. |
| `~/.codex/config.toml`, `AGENTS.md`, `hooks.json` | Technically yes, but only by moving Codex's whole home | Set `CODEX_HOME=$XDG_CONFIG_HOME/codex`. Codex discovers all three files relative to `CODEX_HOME`. | Config plus authentication, logs, sessions, skills, SQLite state, and standalone package metadata. |
| Codex hook scripts | Yes, independently | Hook commands accept script paths, so scripts can live under `~/.config/codex/` while `hooks.json` remains under the normal Codex home. | Only the scripts. |

## Recommendation

Move Zsh and Git natively. Move the Powerlevel10k file and the Claude, Codex, and Pi helper scripts by explicit path. Keep the required home-level entries for `.hushlogin` and `.testcontainers.properties`.

For Claude, Codex, and Pi, do not set their whole-directory environment variables merely to make the tree look XDG-compliant. Those variables mix authored configuration with sessions, plugins, credentials, packages, and other mutable data under `~/.config`. Keep their application homes in place and continue managing only the authored files with Nix links, unless moving their entire application data directories is intentional.

## Official sources

- Zsh: [startup file locations](https://zsh.sourceforge.io/Intro/intro_3.html) and [`ZDOTDIR` parameter](https://zsh.sourceforge.io/Doc/Release/Parameters.html#index-ZDOTDIR)
- Powerlevel10k: [official README configuration wizard](https://github.com/romkatv/powerlevel10k/blob/master/README.md#configuration-wizard)
- Git: [`git-config` file locations and `--global` behavior](https://git-scm.com/docs/git-config)
- macOS/OpenSSH: [Apple OpenSSH `check_quietlogin` implementation](https://github.com/apple-oss-distributions/OpenSSH/blob/main/openssh/session.c#L2406-L2425)
- Testcontainers Java: [configuration file and environment-variable lookup](https://java.testcontainers.org/features/configuration/)
- Claude Code: [`CLAUDE_CONFIG_DIR` and application data](https://code.claude.com/docs/en/env-vars), [the `.claude` directory](https://code.claude.com/docs/en/claude-directory), [hooks](https://code.claude.com/docs/en/hooks), and [status-line script paths](https://code.claude.com/docs/en/statusline)
- Codex: [`CODEX_HOME` contents](https://learn.chatgpt.com/docs/config-file/environment-variables), [configuration locations](https://learn.chatgpt.com/docs/config-file/config-basic), [`AGENTS.md` discovery](https://learn.chatgpt.com/docs/agent-configuration/agents-md), and [hook locations and commands](https://learn.chatgpt.com/docs/hooks)
- Pi: [official CLI environment variables](https://github.com/badlogic/pi-mono/blob/main/packages/coding-agent/README.md#environment-variables), [settings and resource paths](https://github.com/badlogic/pi-mono/blob/main/packages/coding-agent/docs/settings.md), and [SDK global-directory contents](https://github.com/badlogic/pi-mono/blob/main/packages/coding-agent/docs/sdk.md#directories)
