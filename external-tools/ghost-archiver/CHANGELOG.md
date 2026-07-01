# Ghost-Archiver Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]
### Fixed
- **The "Silent Death" Background Bug (Agent Execution Trap):** Discovered that launching Chromium using `systemd-run --scope` inside an AI agent session still resulted in the browser being killed when the agent's turn ended, because `--scope` bounds the process to the agent's ephemeral systemd session. Updated documentation to mandate the use of `systemd-run --unit=<name>` to register the browser as a permanent transient background service that survives the agent's session.
- **Dependency Crash Trap:** AI agents were repeatedly attempting to launch background scripts using the system default `python3` command, causing instant silent crashes in background logs due to missing `bs4` (BeautifulSoup). Documentation explicitly updated to mandate the use of `venv/bin/python` for all script execution.