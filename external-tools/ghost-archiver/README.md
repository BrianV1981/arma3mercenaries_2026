# Ghost-Archiver (The Sovereign Mirror)

Ghost-Archiver is a stealth-oriented, high-fidelity website preservation tool. Designed to bypass aggressive anti-bot measures (like Cloudflare Turnstile) and generate true "Sovereign" offline mirrors.

## The Core Concept
Unlike traditional scrapers (`wget`, `HTTrack`, `requests`) which are easily blocked by modern CDN defenses, Ghost-Archiver utilizes **[Clawgle](https://github.com/BrianV1981/clawgle)** as its engine. By driving a genuine Chromium instance via the Chrome DevTools Protocol (CDP), it perfectly mimics human browsing behavior.

It doesn't just download code; it waits for JavaScript to render, solves challenges, and then "rips" the final DOM state.

## 🚨 CRITICAL GUARDRAIL: THE SUBPROCESS TRAP 🚨
**ATTENTION ALL AI AGENTS & ORCHESTRATORS:**
If you are operating inside a headless CLI environment (like `gemini-cli`), you will experience catastrophic, silent failures if you attempt to launch the required Chromium browser using standard bash backgrounding (`nohup`, `&`, `is_background: true`).

**The Trap:** When you execute a command, your host environment spawns an ephemeral subshell. When your "turn" ends, that subshell is ruthlessly terminated by the OS. If Chromium was spawned as a child of your shell (or even using `systemd-run --scope` which binds to the agent's transient session), it will be killed instantly. *This often masquerades as a hardware failure in the logs (e.g., `FATAL: GPU process isn't usable`).* **Do NOT rewrite working code or attempt Xvfb workarounds to fix this.**

**The Rule:** You MUST use the `systemd-run --user --unit=<name>` escape hatch to launch the browser. This registers the browser as a permanent transient systemd service, completely detaching it from your fragile agent session and attaching it to the host desktop session.

**The ONLY acceptable way to launch the Chromium dependency from an agent shell is:**
```bash
# This registers it as a background service that survives your session ending:
systemd-run --user --unit=clawgle-browser env DISPLAY=:0 chromium --remote-debugging-port=9222 --user-data-dir=$HOME/.openclaw/clawgle-profile --no-sandbox about:blank
```

### 🚨 VIRTUAL ENVIRONMENT TRAP
The python scripts in this project depend on `BeautifulSoup4`. The host system's default python will NOT have this installed. If you attempt to run scripts via `python3 script.py`, they will instantly crash with `ModuleNotFoundError`, but because they run in the background, you might miss the error.
**Always execute python scripts using the project's virtual environment:**
```bash
# Correct:
venv/bin/python scripts/total_reconstruction.py
```

---

## Dependencies
*   **Clawgle:** The core browser-control dependency layer. Ghost-Archiver is essentially a highly specialized orchestration script built on top of Clawgle's primitives.
*   **Python 3.10+**
*   **BeautifulSoup4** (for DOM parsing and link localization)

## The Two-Phase Algorithm
1.  **Phase 1: Deep Discovery (The Mapper)**
    *   Initiates a Breadth-First Search (BFS) starting from a target portal URL.
    *   Crawls internal links, mapping the site's structure while strictly obeying domain boundaries.
    *   Generates a `master_map.json` file.
2.  **Phase 2: Total Reconstruction (The Mirror)**
    *   Iterates through the Master Map.
    *   **Human Mimicry:** Performs randomized scrolling, mouse wiggles, and idle pauses to maintain stealth.
    *   **Asset Harvesting:** Downloads photos, icons, and stylesheets into a local `assets/` directory.
    *   **Link Localization:** Rewrites every internal `<a href="...>` to point to a relative `./Local_Page.html`, ensuring the resulting mirror is 100% disconnected and browseable offline.
    *   **Memory Safety:** Employs a strict "Two-Tab" limit (Nuclear Tab Sweep) to ensure the browser never crashes from memory bloat during multi-hour runs.

## Origin
Originally developed by Brian Vasquez to surgically extract and localize the massive Arma 3 Biki and ALiVE wikis.
