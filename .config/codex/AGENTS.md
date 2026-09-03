# global agent instructions

- Automatically pin recent chats and cleanup old chats when starting a new feature or bugfix
- When on the Chief of Staff project/thread always launch agents inside their own project. for example, "investigate XYZ in apod_ui|apod_infra|apod_provisioning" you should spawn a new thread inside that project/repo.
- Make sure you rebase of latest origin/main branch before code changes unless on apod_infra_drivers repo, which uses next-release as a feature branch that goes into main. So rebase off origin/next-release
- Avoid overengineering code like adding wrapper functions when not needed and avoid Classes, use patterns from existing codebase
- Never use the em dash "—". Use plain dash "-" instead
- Don't use the word "contract" - be more specific
- When writing commit messages, NEVER auto-add your agent name as co-author
- When making technical decisions, do not give much weight to development cost. Instead, prefer quality, simplicity, robustness, scalability, and long term maintainability.
- When doing bug fixes, always start with reproducing the bug in an E2E setting as closely aligned with how an end user would experience it as possible. This makes sure you find the real problem so your fix will actually solve it.
- When changing configuration that a running application reads, inspect the resolved live configuration before and after the change. Do not assume a repository file, Home Manager symlink, generated file, or cached in-memory configuration is what the application is currently using. Applications may replace managed symlinks with standalone files.
- For operating system configuration, prioritize the Nix configuration as the source of truth. Apply and validate the resolved live configuration before considering the task complete.
- For Karabiner changes, compare the repository JSON with `~/.config/karabiner/karabiner.json`, verify the active file contains the intended rules and no stale rules, then force a real reload without using `karabiner_cli --select-profile` because it may replace the Home Manager symlink with stale content. Reproduce the shortcut through the live Karabiner event path and do not claim it works based only on JSON validation or directly executing a shell command.
- When end-to-end testing a product, be picky about the UI you see and be obsessed with pixel perfection.
  If something clearly looks off, even if it is not directly related to what you are doing, try to get it fixed along the way.
- Apply that same high standard to engineering excellence: lint, test failures, and test flakiness.
  If you see one, even if it is not caused by what you are working on right now, still get it fixed.
- Treat CHANGELOG.md and VERSION.txt as feature-branch deliverables, not per-commit or per-direction updates. Update them once for a net-new customer-facing feature or bug fix, based on the complete feature-branch diff from main. Do not add another changelog entry or bump the version for follow-up commits that refine, validate, or support the same feature or bug fix. Write changelog entries in customer-facing language, for example:
  Fixed issue where Deploy button was flickering when pressed
  Fast Deploy is now handled behind the scenes for `/apod` POST requests: normal deploys automatically claim matching warm-pool inventory when available and fall back to standard deployment when no match exists.
- Try to run limited tests. Don't run the full test suite by default after each code change. Never run --runInBand.
