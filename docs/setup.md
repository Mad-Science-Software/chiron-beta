# Setting up Chiron for a user

This guide is for an AI agent (Claude Code) installing Chiron on someone's computer so
their Claude has persistent memory. You are installing, not developing: don't change
Chiron's code, create branches, or install git hooks, whatever AGENTS.md or the README
say about development.

Memories are private to this computer: nothing about them is sent anywhere, and the
memory server can't be reached from the network.

Tell the user what you're doing as you go, in plain language. Ask before anything that
needs their password or touches their personal data. Don't create a `.env` file, even if
a README mentions one: it's for developing Chiron.

## Which install

- **Mac or Linux: the Chiron app** (section A). One download, about 5 minutes, no admin
  password, no Docker.
- **Windows: the Docker install** (section B). About 20–30 minutes; Docker Desktop needs
  an admin password and may need a restart. A Windows app is coming.
- **Already running the Docker install on a Mac or Linux?** Section C moves the memories
  into the app.

**First, for any of them:**

1. **Beta terms.** Show the user the terms in `BETA.md`
   (https://github.com/Mad-Science-Software/chiron-beta/blob/main/BETA.md), summed up in a
   few plain sentences, and ask whether they agree. Stop if they don't.
2. **Claude Code**: `claude --version`.
3. **Python 3.9 or newer and git**: `python3 --version` and `git --version` (on Windows,
   `python` or `py` may be the Python command). On a Mac without developer tools, the
   first one opens a system dialog offering to install them (both come with it); tell
   the user to click Install and wait, rather than waiting on the command yourself.
   Python runs the memory check and history imports; recall itself needs no Python.
4. **Get Chiron's files**: if `~/chiron` doesn't exist yet,
   `git clone https://github.com/Mad-Science-Software/chiron-beta.git ~/chiron`.
   It holds this guide, the plugins and helper scripts (no source code, no GitHub account
   needed). Keep it in that permanent spot (not Downloads, Desktop or an iCloud-synced
   folder): the plugin is installed from it. Developers using the source repository use
   their clone instead.

## A. The Chiron app (Mac and Linux)

### A1. Install the app

```sh
sh ~/chiron/install.sh
```

It downloads the app for this computer, checks it against the release's checksums,
puts it in `~/.chiron/bin`, and starts it at every login (a LaunchAgent on Mac, a
systemd user service on Linux). The first start also downloads the embedding model
(about 430 MB) and can take a few minutes; it prints its progress and finishes with
"Chiron … is running". Everything lives in `~/.chiron`.

Verify: `~/.chiron/bin/chiron status` says it's running with embeddings ready. On a Mac
a flask icon appears in the menu bar: it shows the memory count, offers updates, opens
the logs, and can stop memory until the next login. (`"menu_bar": false` in
`~/.chiron/config.json` hides it.)

If it fails, read `~/.chiron/logs/chiron.log` and `~/.chiron/logs/ollama.log`, tell the
user what went wrong in plain language, and stop rather than improvising.

### A2. Install the Claude Code plugin

The `chiron` plugin connects Claude Code to the app and adds a hook that recalls
related memories for every message the user sends. It installs for the user, so it
applies in every project; that's intended, and these commands are the only settings
change setup makes.

```sh
claude plugin marketplace add ~/chiron
claude plugin install chiron@mad-science
```

If `claude plugin list` also shows `chiron-docker@mad-science` or `chiron-app@mad-science`
(older names), uninstall them (`claude plugin uninstall <name>@mad-science`); if `claude mcp list` shows a `chiron`
server registered by hand, remove it (`claude mcp remove chiron`), so the tools don't
appear twice.

Verify:

```sh
claude plugin list                                  # chiron@mad-science, enabled
python3 ~/chiron/plugin/scripts/check_memory.py     # Chiron memory is working (empty so far).
```

The memory check makes a real recall, the same call the hook makes, and fails with the
reason if memory can't be reached. (The hook stays silent when memory is down, so
prompts never break; that's why it isn't the check.)

### A3. Other coding agents

Only for tools the user actually uses (ask). Both read Chiron's MCP instructions, so
they need no instruction file. If Chiron is down, their hook stays quiet.

**Gemini CLI**: `gemini extensions link ~/chiron/integrations/gemini`, then restart it.

**Codex CLI**: add to `~/.codex/config.toml` and `~/.codex/hooks.json` (read both first
and merge; keep everything already there). If Codex asks to review the hook, the user
approves it.

```toml
[mcp_servers.associative-memory]
command = "sh"
args = ["-c", "exec \"$HOME/.chiron/bin/chiron\" mcp"]
```

```json
{
  "hooks": {
    "UserPromptSubmit": [
      { "hooks": [ { "type": "command", "command": "\"$HOME/.chiron/bin/chiron\" hook --tool codex" } ] }
    ]
  }
}
```

Then go to **Finish**.

## B. The Docker install (Windows)

Set expectations: about 20–30 minutes, and if Docker isn't installed yet, the user will
need to be at the computer to enter their admin password, accept Docker's licence, pick
an install option, and possibly restart. After a restart they reopen Claude Code and ask
to continue installing Chiron.

### B1. Docker

`docker info` must succeed. If Docker is missing, ask the user to install Docker Desktop
(https://www.docker.com/products/docker-desktop/); on Windows it uses WSL 2, which it
offers to set up, and virtualization must be on (if Docker reports it's off, that's a
BIOS setting: stop and tell the user). On a work computer, ask first: IT may block it, and
Docker Desktop needs a paid licence at larger companies. If Docker is installed but not
running, start Docker Desktop and wait for `docker info`. Have the user turn on **Start
Docker Desktop when you sign in** in its settings: without it, memory silently stops
after a reboot. About 3 GB of free disk space is needed.

### B2. Start Chiron

```sh
cd ~/chiron
docker compose --profile app up -d
```

The first run downloads Chiron's images and the embedding model and takes a few
minutes. Running it again is safe, so if it fails the first time, run it again before
debugging. Verify: `curl -s localhost:8090/readyz` prints `{"status":"ready"}`. If not,
check `docker compose --profile app ps` and `docker compose logs api`. If port 8090 is
taken, tell the user what holds it rather than changing the port.

### B3. Install the Claude Code plugin

```sh
claude plugin marketplace add ~/chiron
claude plugin install chiron-docker@mad-science
```

Verify: `claude plugin list` shows `chiron-docker@mad-science` enabled, and
`python3 ~/chiron/plugin/scripts/check_memory.py` says memory is working (use `python` or
`py` if that's this computer's Python).

**Gemini CLI**: `gemini extensions link ~/chiron/integrations/gemini-docker`. **Codex CLI**:
`[mcp_servers.chiron]` with `url = "http://localhost:8090/mcp"`, and a `UserPromptSubmit`
command hook running
`curl -s --max-time 4 -X POST -H 'Content-Type: application/json' --data-binary @- 'http://localhost:8090/hooks/prompt?tool=codex'`.

Then go to **Finish**.

## C. Moving from the Docker install to the app (Mac and Linux)

Do the steps in this order, so memory keeps working at every point. Docker must be
running for the copy.

1. **Back up** the Docker memory first:
   `cd ~/chiron && docker compose exec -T db pg_dump -U postgres chiron > ~/chiron-backup-$(date +%F).sql`
2. **Get the newest files**: `cd ~/chiron && git pull`.
3. **Install the app** (section A1). It starts with an empty memory.
4. **Copy the memories over**: `~/.chiron/bin/chiron import-from-docker`. It copies every
   record and cue, checks they all arrived and that sample searches give the same
   results in both, and restarts the app. If any check fails it stops and leaves Docker
   as it was; show the user its output.
5. **Switch the plugin**: `claude plugin marketplace update mad-science && claude plugin update chiron@mad-science`
   (the `chiron` plugin now belongs to the app; if `claude plugin list` doesn't then
   show version 0.4.2 or later, run `claude plugin uninstall chiron@mad-science && claude plugin install chiron@mad-science`),
   then check with `python3 ~/chiron/plugin/scripts/check_memory.py` and the user's
   memory count in `~/.chiron/bin/chiron status`. Gemini or Codex users: switch them to
   section A3's settings.
6. **Stop Docker's Chiron**: `cd ~/chiron && docker compose --profile app down` (never
   `-v`). Its data stays in Docker until the user decides to delete it
   (`docker compose --profile app down -v`, which removes the old copy for good); the
   backup from step 1 is a second safety net. Docker Desktop itself can stay or go.
7. Tell the user to start a new Claude Code session.

## Finish

Tell the user to start a new Claude Code session: the memory tools only load in a new
session. Then explain, briefly and in plain language:

- **What it does**: Claude can save things to memory and recall them in later sessions,
  in any project. Related memories also come to mind automatically as they type.
- **How to use it**: "remember that …", "what do you remember about …?", or "save what
  we decided today". Claude can also import their history (past sessions, git, email)
  whenever they ask.
- **Privacy**: memories stay on this computer.
- **Memories are who said what, and when**: each one records that someone said or did
  something on a given day, not that it's true. A mistake or a change of mind is simply
  a newer memory, and Claude weighs them by date. Claude and Chiron never erase anything,
  so they should only agree to saving what they're comfortable keeping. A backup now and
  then is worth it (below).
- **Updates**: when a new version is out, Claude mentions it once in a session and offers
  to install it.

Offer to save a first memory: ask what they work on and save their answer, with consent.

Mention that this is a beta: anything that breaks, feels off or surprises them is worth
an email to james@madsciencesoftware.dev (never including their memories).

Don't import any existing history (email, past Claude sessions, git repositories) unless
the user explicitly asks. If they do, follow [`docs/ingestion.md`](ingestion.md).

## Day to day

**The app** (`chiron` is `~/.chiron/bin/chiron`):

- **Update**: `chiron update`, then
  `cd ~/chiron && git pull && claude plugin marketplace update mad-science && claude plugin update chiron@mad-science`.
  The update keeps the previous version and goes back to it if the new one doesn't start.
- **Is it working?** `chiron status`, and `python3 ~/chiron/plugin/scripts/check_memory.py`.
  Logs are in `~/.chiron/logs`. If it's stopped, `chiron install` starts it again.
- **Back up**: `chiron backup` writes `~/chiron-backup-<date>.db`, safely while it runs.
- **Stop**: `chiron uninstall` stops it starting at login. Memories are kept.
- **Never** delete `~/.chiron` unless the user wants their memory erased permanently.

**The Docker install**, all from `~/chiron`:

- **Update**: `git pull && docker compose --profile app pull && docker compose --profile app up -d && claude plugin marketplace update mad-science && claude plugin update chiron-docker@mad-science`
  (from a source checkout, `up -d --build` replaces the `pull`). Gemini CLI's linked
  extension follows `git pull` on its own.
- **If memory stops working**: run the memory check; if it fails, make sure Docker
  Desktop is running, then `docker compose --profile app up -d`.
- **Back up**: `docker compose exec -T db pg_dump -U postgres chiron > ~/chiron-backup-$(date +%F).sql`
- **Stop**: `docker compose --profile app down`. Memories are kept.
- **Never** run `docker compose down -v` or delete Docker volumes unless the user wants
  their memory erased permanently.
