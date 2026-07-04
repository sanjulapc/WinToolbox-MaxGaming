# WinToolbox — Max Gaming

Windows 10/11 gaming tuning, two toolboxes behind one launcher.

- **WinToolbox** — a single-file PowerShell + WinForms toolbox, **30 tools**, built-in Windows tooling only, all reversible via JSON backups and `-Revert`.
- **God Server** — an all-in-one batch toolbox (debloat, tweaks, GOD MODE, process killer, BIOS tweaker).
- **WinToolbox Hub** — a small white/blue launcher that **downloads** either toolbox from this repo or **runs** it, with its own greeting.

## Repo contents

| File | What it is |
|------|-----------|
| `WinToolbox-Hub.ps1` | The launcher. A **Download** and a **Run** button for each toolbox. |
| `WinToolbox-Hub.vbs` | Double-click launcher for the hub (hidden console, no admin needed). |
| `WinToolbox.ps1` | The 30-tool gaming toolbox — GUI, console menu, every tool. |
| `WinToolbox-GUI.vbs` | Double-click launcher for WinToolbox's own GUI. |
| `GodServer-AllInOne.bat` | The batch all-in-one toolbox. |
| `README.md` | This file. |

---

## Quick start — the Hub

**Easiest:** double-click **`WinToolbox-Hub.vbs`**. The launcher opens with:

- a greeting and your Windows/build line,
- a card for **WinToolbox** and a card for **God Server**, each with:
  - **↓ Download** — pulls the latest copy of that toolbox from GitHub into this folder,
  - **Run ▶** — launches it (Run stays greyed until the file has been downloaded).

The hub itself needs no admin. Each toolbox asks for admin on its own when you run it.

Other buttons: **Open folder** (where downloads land), **Get everything** (grabs every file at once), **GitHub repo** (opens this repo in your browser).

**From PowerShell instead of the .vbs:**
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\WinToolbox-Hub.ps1
```

---

## Install from PowerShell (one line)

Once the files are in the repo, you can fetch and open the launcher with a single command — no manual download. Paste into **Windows PowerShell**:

```powershell
$d=Join-Path ([Environment]::GetFolderPath('DesktopDirectory')) 'WinToolbox'; New-Item $d -ItemType Directory -Force | Out-Null; [Net.ServicePointManager]::SecurityProtocol='Tls12'; Invoke-WebRequest "https://raw.githubusercontent.com/sanjulapc/WinToolbox-MaxGaming/main/WinToolbox-Hub.ps1" -OutFile "$d\WinToolbox-Hub.ps1" -UseBasicParsing; Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$d\WinToolbox-Hub.ps1`""
```

It downloads the launcher to a **`WinToolbox` folder on your Desktop** and opens it; the **Download** buttons then pull the toolboxes into that same folder. It runs whatever is in the repo at that moment, so only share this line from a repo you control.

**Raw links** (what the launcher and the one-liner use):
- Hub — `https://raw.githubusercontent.com/sanjulapc/WinToolbox-MaxGaming/main/WinToolbox-Hub.ps1`
- WinToolbox — `https://raw.githubusercontent.com/sanjulapc/WinToolbox-MaxGaming/main/WinToolbox.ps1`
- God Server — `https://raw.githubusercontent.com/sanjulapc/WinToolbox-MaxGaming/main/GodServer-AllInOne.bat`

---

## Put it on GitHub

**1. Create an empty repo** on GitHub named `WinToolbox-MaxGaming` (don't add a README or .gitignore — keep it empty so the first push is clean).

**2. Tell the hub where the repo is.** Open `WinToolbox-Hub.ps1` and edit the block near the top:
```powershell
$GH = @{
    User   = 'your-github-username'   # <-- your username
    Repo   = 'WinToolbox-MaxGaming'   # <-- your repo name
    Branch = 'main'
}
```
The Download buttons build URLs like
`https://raw.githubusercontent.com/<User>/<Repo>/<Branch>/WinToolbox.ps1`.

**3. Push everything** (run in the folder that holds these files):
```bash
git init
git add .
git commit -m "WinToolbox + God Server + Hub launcher"
git branch -M main
git remote add origin https://github.com/your-github-username/WinToolbox-MaxGaming.git
git push -u origin main
```

That's it. From then on, editing a toolbox is just: change the file → `git add` → `git commit` → `git push`, and the hub's **Download** button always pulls the latest.

**Sharing tip:** you only need to hand someone the two small hub files (`WinToolbox-Hub.ps1` + `WinToolbox-Hub.vbs`). They double-click the .vbs and hit **Download** — the big toolboxes come down on demand.

---

## WinToolbox — the details

### Run it directly

**GUI:**
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\WinToolbox.ps1 -Gui
```
**Console menu:**
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\WinToolbox.ps1
```
**A single tool, no menu:**
```powershell
.\WinToolbox.ps1 -Tool GpuPref            # emulator exes -> High-perf GPU + HAGS
.\WinToolbox.ps1 -Tool GpuPref -Status
.\WinToolbox.ps1 -Tool GpuPref -Revert
```

### The MAX button

In the GUI, **MAX** ticks every applicable tool with full options and sets the correct mode for each, then you press **RUN SELECTED**. It intentionally leaves off:

- **16 Drive Lock** and **17 Download Browsers** (not gaming perf).
- **CPU boot-timer tweaks** (can *raise* latency on some boards).
- **Skip HAGS** stays unticked, so Hardware-accelerated GPU scheduling is turned **on**.
- **Set Sri Lanka time zone** stays off (it's not a performance tweak).

Tools **18 Windows Settings** and **20 Startup manager** run **silently** on Apply — no separate window pops up mid-run. Pick **Open settings** / **Open manager** from that tool's dropdown if you want their full UI.

After a run that applied changes, the GUI asks **"Restart now?"** — some tweaks (HAGS, GPU scheduling, timers, network, drivers) only fully take effect after a reboot.

### Tool 30 — Graphics Pref

Forces the GameLoop / PUBG emulator executables onto the **High-performance GPU** and enables **HAGS**:

- Targets `AndroidEmulatorEn.exe`, `AndroidEmulator.exe`, `AndroidEmulatorEx.exe`, `GameLoop.exe`, `aow_exe.exe` (under `Program Files\TxGameAssistant`).
- `-AddApp "C:\path\to\game.exe"` — add any other game.
- `-NoHags` — set the GPU preference only, leave GPU scheduling as-is.
- `-Status` / `-Revert` as usual.

### Safety

- Everything writes a JSON backup first and can be undone with that tool's `-Revert`, or all at once with **Revert All** (`-Tool RevertAll`).
- **Snapshot** (`-Tool Snapshot -Action Save`) bundles every current backup so you can restore a known-good state later.
- **APPLY ALL / MAX** reduce security (CPU mitigations off, VBS/Hyper-V off). Use them on a single-user gaming box, not a shared/work machine.
- A System Restore point is offered/created before the big batch actions.

Backups live in your user profile (e.g. `%USERPROFILE%\*.backup.json`) and, for a couple of tools, under `%LOCALAPPDATA%`.

---

## God Server — the details

A single batch file combining five tools behind one menu: Permanent Debloater, EXM Premium Tweaks, GOD MODE Ultimate, Nuclear Process Killer, and Auto BIOS Tweaker (the BIOS tweaker needs `SCEWIN_64.exe` in the same folder). It self-elevates to Administrator on launch and offers a single reboot after **RUN ALL**. These are aggressive system changes — run on a personal machine.
