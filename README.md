# betBetter

Michigan scratch-off research built with Jac and official Michigan Lottery data.

## macOS (Apple Silicon)

Open **Terminal**. Run each block in order. These commands install Jac **0.37.25**, the version verified locally. This release has no Intel Mac binary.

**1. Install Jac:**

```sh
curl -fsSL https://jaclang.org/install.sh | bash -s -- --version 0.37.25
~/.local/bin/jac --version
```

**2. Get the project and install dependencies:**

```sh
mkdir -p ~/Projects
cd ~/Projects
git clone https://github.com/elihelzberg/betbetter.git
cd betbetter
~/.local/bin/jac install
~/.local/bin/jac install --npm
```

If Git asks to install Apple's command-line tools, finish that installation and rerun step 2. If you already have the repository, open a terminal in that folder and run just the two `jac install` commands.

**3. Start the website and backend:**

```sh
cd ~/Projects/betbetter
~/.local/bin/jac run --dev
```

Wait for **Server ready**, then open **http://localhost:8000/**. Leave this terminal running. Press **Ctrl+C** to stop.

**4. Optional: run the mobile app.** Stop Jac with Ctrl+C, then restart it so your phone can connect:

```sh
cd ~/Projects/betbetter
~/.local/bin/jac run --dev --host 0.0.0.0
```

Open a **second Terminal window** and paste:

```sh
curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
. "$NVM_DIR/nvm.sh"
nvm install 24
cd ~/Projects/betbetter/mobile
npm ci
npx expo start --go
```

Install [Expo Go](https://expo.dev/go) compatible with **SDK 58** on your phone, connect it to the same Wi-Fi as your Mac, and scan the QR code. Keep both terminals running. Expo tunnel mode does not expose the local games API.

## Windows 11 / Windows 10 (WSL)

Use Ubuntu through [Windows Subsystem for Linux](https://learn.microsoft.com/en-us/windows/wsl/install); Jac's installer does not currently support native PowerShell.

**1. Open PowerShell as Administrator and paste:**

```powershell
wsl --install -d Ubuntu
```

Restart Windows if prompted. Open **Ubuntu** from the Start menu and create your Linux username and password when asked. Run all remaining commands in **Ubuntu**, not PowerShell.

**2. Install tools, get the project, and install dependencies:**

```bash
sudo apt-get update
sudo apt-get install -y curl git ca-certificates python3 build-essential
curl -fsSL https://jaclang.org/install.sh | bash -s -- --version 0.37.25
~/.local/bin/jac --version
mkdir -p ~/Projects
cd ~/Projects
git clone https://github.com/elihelzberg/betbetter.git
cd betbetter
~/.local/bin/jac install
~/.local/bin/jac install --npm
```

If you already cloned the repository inside Ubuntu, open that folder and run the two `jac install` commands instead of cloning again.

**3. Start the website and backend:**

```bash
cd ~/Projects/betbetter
~/.local/bin/jac run --dev
```

Wait for **Server ready**, then open **http://localhost:8000/** in your Windows browser. Leave Ubuntu running. Press **Ctrl+C** to stop. Windows/WSL startup has not yet been tested on this project.

**4. Optional: run the mobile app.** Phone access to WSL needs additional networking. On **Windows 11 22H2 or later**, open PowerShell and paste:

```powershell
notepad.exe "$env:USERPROFILE\.wslconfig"
```

Add these lines to the file (merge them into an existing `[wsl2]` section if present), then save:

```ini
[wsl2]
networkingMode=mirrored
```

Close your running Ubuntu processes, then run in PowerShell:

```powershell
wsl --shutdown
```

Reopen Ubuntu and start Jac:

```bash
cd ~/Projects/betbetter
~/.local/bin/jac run --dev --host 0.0.0.0
```

Open a **second Ubuntu terminal** and paste:

```bash
curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
. "$NVM_DIR/nvm.sh"
nvm install 24
cd ~/Projects/betbetter/mobile
npm ci
npx expo start --go --lan
```

Use Expo Go compatible with **SDK 58**, put your phone on the same Wi-Fi, and scan the QR code. Allow local-network access in Windows/Hyper-V firewall settings if needed. First check that your phone can open `http://<Windows-LAN-IP>:8000/`. See Microsoft's [WSL networking guide](https://learn.microsoft.com/en-us/windows/wsl/networking) if either the API or Expo is unreachable. Windows 10's default WSL networking needs manual port forwarding for phone access; the website instructions above do not need this.

## Everyday commands (macOS or Ubuntu)

**Start again after setup:**

```sh
cd ~/Projects/betbetter
~/.local/bin/jac run --dev
```

**Check the games API from another terminal:**

```sh
curl --fail-with-body http://localhost:8000/api/games \
  -H 'Content-Type: application/json' \
  -d '{"state":"MI","min_price":0,"max_price":100,"sort_by":"jackpot_boost","search":"","limit":1000}'
```

Expect a JSON array. Send the full payload: an empty `{}` request failed with Jac 0.37.25.

**Refresh lottery data manually** (requires Python 3; on macOS install it from [python.org](https://www.python.org/downloads/macos/) if missing):

```sh
cd ~/Projects/betbetter
python3 test_lottery.py
```

## Quick troubleshooting

- Use `~/.local/bin/jac` as shown above; the older Homebrew Jac 0.16.7 cannot run this app. `jac.toml` targets 0.37.23; startup and a games request were verified with 0.37.25.
- If you cloned elsewhere, replace `~/Projects/betbetter` in the commands with your folder. Do not clone again into an existing `betbetter` directory.
- Keep ports **8000** (website and mobile API proxy) and **8001** (backend) free. Stop previous instances with Ctrl+C.
- Startup downloads real lottery data. Internet access is required for the first collection; failed refreshes keep the previous cache. Game counts change over time.
- Jac manages its local database. No separate `server.py`, manual Postgres setup, or lottery API key is needed. Email/scheduler-disabled messages are optional-service notices.
- Client changes hot-reload; restart Jac after backend changes.
- If Expo Go reports an SDK mismatch, install a compatible client or use an [Expo development build](https://docs.expo.dev/develop/development-builds/introduction/).

Installer references: [Jac](https://jaclang.org/docs/latest/quick-guide/install), [Node version manager](https://github.com/nvm-sh/nvm/tree/v0.40.3), and [Expo](https://docs.expo.dev/get-started/start-developing/).

## Collection and storage

`michigan_live.py` stores complete, validated collections atomically in `.data/michigan.sqlite3`. Reads share that cache for six hours. The first read collects if the database is empty; the first read after expiry refreshes it. Failed refreshes retain the last successful collection and retry after five minutes. A failed initial collection produces an error, never fictional games. The details view shows collection and source-update timestamps. The dashboard defaults to estimated jackpot probability change since launch.

For a refresh independent of visitor traffic, schedule this command every six hours using cron or your hosting provider's job scheduler:

```sh
cd /absolute/path/to/betBetter && python3 test_lottery.py
```

This command refreshes the database used by the website, without rebuilding the frontend. A scheduler is not installed automatically. `MICHIGAN_CACHE_PATH` optionally sets a durable database location shared by the server and refresh job. Back up this file to preserve history. SQLite fits a single-server deployment; use a shared Postgres database and one refresh worker for multiple application servers. An in-process lock prevents concurrent refreshes within one server process; scheduled collectors or multiple processes should be coordinated by a single writer. Snapshot history grows with successful collections.

Public reads no longer use the old Jac graph fixture fallback. Existing fictional graph records are ignored. The legacy `ingest.jac` graph command is not needed for the website.

## Data and calculations

Official data supplies ticket price, advertised overall odds, catalog date, original and unclaimed prize counts, and source update time. Duplicate cash amounts are aggregated. Unrecognized amounts, missing tiers, invalid counts or API errors reject the complete refresh rather than publishing a partial catalog.

The catalog's `dateAdded` is displayed as the launch date; it is catalog metadata, not independently verified first-sale timing. Both ticket inventories are modeled because the official queries do not publish them. Estimated launch tickets = starting winning-prize counts × advertised overall odds (rounded to an integer). Estimated remaining fraction = pooled remaining / starting prize counts for tiers paying at most twice the ticket price. If no such tier exists, the lowest three tiers excluding the jackpot where possible are used. Estimated remaining tickets = launch tickets × that fraction, rounded and bounded between the count of remaining winners and launch inventory. A bound adjustment is disclosed in game details. These assumptions do not correct for sold-but-unclaimed winners or discarded tickets. Rounded published odds add uncertainty. Top-prize retention is remaining divided by original count of the largest prize. Estimated relative probability change = (remaining category winners / estimated remaining tickets) / (starting category winners / estimated launch tickets) − 1; positive means a modeled boost, negative a modeled drop. EV change remains a difference in return per dollar, expressed in percentage points. Each cached observation, including older snapshots, is evaluated using the same model on read. Zero-inventory games are excluded from rankings. Categories with no starting profit prizes are labeled “No launch profit prizes” rather than assigning a fictional change. Advertised overall odds are the published launch odds, not current odds.

Unclaimed prizes can belong to purchased tickets. Prize retention alone does not establish favorable current odds or positive expected value. Demo snapshots remain available only as arithmetic test fixtures. The question feature remains a limited rule-based parser.

## Validation

```sh
jac check --nowarn
jac test
jac build --as client
python3 -m unittest discover -s tests -p 'test_*.py'
```

The Jac tests cover calculation, filtering, all 107 results without truncation, missing inventory, estimated probability changes, ingestion idempotency and service history with a mocked source. Python tests cover collector parsing, complete batch storage, cache reuse, failed-refresh retention, pooled estimates, fallbacks and feasibility bounds. Live collection can be verified with `python3 test_lottery.py`.

## Jackpot and smaller-prize metrics

The dashboard keeps total gross EV per dollar and also shows estimated jackpot odds and estimated net EV per ticket excluding jackpot. Jackpot means the largest cash prize tier. Non-jackpot net EV = sum of smaller prize amounts × remaining counts / estimated remaining tickets − ticket price. Jackpot-winning tickets remain in the denominator, with their payout omitted from this particular metric. It is not conditional on avoiding a jackpot. Negative amounts mean an expected loss from the smaller-prize contribution. Both metrics are available for ranking and in game details; all rely on the same inventory assumptions.
