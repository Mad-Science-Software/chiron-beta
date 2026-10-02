# Setting up Chiron for a user

This guide is for an AI agent (Claude Code) installing Chiron on someone's computer so
their Claude has persistent memory. You are installing, not developing: don't change
Chiron's code, create branches, or install git hooks, whatever AGENTS.md or the README
say about development.

Everything runs locally in Docker. Memories are private to this computer: only the memory
server's port (8090) is published, and only on 127.0.0.1, so nothing is reachable from
the network.

Tell the user what you're doing as you go, in plain language. Ask before anything that
needs their password or touches their personal data.

Set expectations before starting: about 15 minutes, and if Docker isn't installed yet,
the user will need to be at the computer for three things only they can do: enter their
admin password, accept Docker's licence agreement, and pick an install option.

Don't create a `.env` file, even though the README mentions one: it's for developing
Chiron and changes what the commands below do.

Chiron lives in `~/chiron`. Beta testers get it from the public beta repository, which
holds only what installing needs (no GitHub account or key); step 1 clones it.
Developers working from the source repository use their clone instead, and add `--build`
wherever this guide runs `docker compose ... up`. Either way, `~/chiron` must be a
permanent spot (not Downloads, Desktop or an iCloud-synced folder): the plugin is
installed from this folder, so it must not be moved or deleted afterwards.

Before installing anything, show the user the beta terms in `BETA.md` (after cloning,
or at https://github.com/Mad-Science-Software/chiron-beta/blob/main/BETA.md), summed up in
a few plain sentences, and ask whether they agree. Stop if they don't.

## 1. Check prerequisites

- **Docker**: `docker info` must succeed. If `docker` isn't found, check
  `~/.docker/bin/docker` before concluding Docker is missing: Docker Desktop installed
  without admin rights puts the command there, off the `PATH`. If it exists, run
  `export PATH="$HOME/.docker/bin:$PATH"` in each shell that needs Docker, and pass that
  on to the sub-agent below. If Docker really is missing, ask the user to install Docker
  Desktop (https://www.docker.com/products/docker-desktop/) and start it. If it's a work
  computer, ask first: company IT may block it, and Docker Desktop needs a paid licence at
  larger companies (OrbStack is an alternative). If Docker is installed but not running,
  start it (`open -a Docker`) and wait for `docker info`. Have the user turn on **Start
  Docker Desktop when you sign in** in its settings: without it, memory silently stops
  working after a reboot.
- **Disk space**: about 3 GB free.
- **Python 3.9 or newer and git**: `python3 --version` and `git --version`. On a Mac
  without developer tools, the first one opens a system dialog offering to install them
  (both come with it); tell the user to click Install and wait, rather than waiting on the
  command yourself. Python runs the memory check and history imports, using only the
  standard library; recall itself needs no Python.
- **Claude Code**: `claude --version`.
- **Get Chiron**: if `~/chiron` doesn't exist yet,
  `git clone https://github.com/Mad-Science-Software/chiron-beta.git ~/chiron`.

## Steps 2 and 3 run in a sub-agent

Do step 1 yourself with the user, since it can need their password or a click in a system
dialog. Then hand steps 2 and 3 to one sub-agent, with this prompt, adding anything step 1
found about this computer (such as Docker's location):

> Follow steps 2 and 3 of `~/chiron/docs/setup.md` to start Chiron and install its Claude
> Code plugin. Prerequisites are already checked. Notes about this computer: <notes from
> step 1, or "none">. Run the verification commands in both steps. Step 3's install
> doesn't depend on step 2, so if step 2 fails, still do step 3's install, and skip only
> its memory check. Don't change any code or settings beyond what the steps say. If
> something fails and the guide doesn't cover it, stop and report the exact error instead
> of improvising. Report what you ran and each verification result.

If it reports a problem, explain it to the user in plain language and decide together how
to proceed. Then continue with step 4 yourself.

## 2. Start Chiron

```sh
cd ~/chiron
docker compose --profile app up -d
```

The first run takes a few minutes: it downloads Chiron's images, creates the database,
and downloads the embedding model (about 300 MB). Running it again is safe and fast, so if a
step fails on the first run, run the same command again before debugging.

Verify:

```sh
curl -s localhost:8090/readyz    # {"status":"ready"}
```

If it isn't ready, check `docker compose --profile app ps` and `docker compose logs api`.
On a new Docker Desktop, `ps` may show brand-new containers as "Up 3 hours": that's a clock
difference with Docker's virtual machine, not a problem.
If port 8090 is already in use, tell the user what is using it (`lsof -i :8090`) rather
than changing the port.

## 3. Install the Claude Code plugin

The `chiron` plugin connects Claude Code to the memory server and adds a hook that
recalls related memories for every message the user sends. It installs for the user, so
it applies in every project; that's intended, and these commands are the only settings
change setup makes. This repository is its marketplace, so install it from the clone (no
GitHub sign-in needed):

```sh
claude plugin marketplace add ~/chiron
claude plugin install chiron@mad-science
```

If `claude mcp list` shows a `chiron` server the user registered by hand earlier, remove
it with `claude mcp remove chiron` so the tools don't appear twice.

Verify:

```sh
claude plugin list                                  # chiron@mad-science, enabled
python3 ~/chiron/plugin/scripts/check_memory.py     # Chiron memory is working (empty so far).
```

The memory check makes a real recall, the same call the hook makes, and fails with the
reason if the server can't be reached. (The hook itself stays silent when memory is down,
so prompts never break; that's why it isn't used as the check.)

### Other coding agents

Do this only for tools the user actually uses (ask). Both read Chiron's MCP instructions,
so they need no extra instruction file. Their recall hook is a `curl` command; if Chiron
is down it fails quietly and the prompt goes ahead.

**Gemini CLI**: install the extension from the clone (`link` keeps it in step with
`git pull`), then restart Gemini CLI:

```sh
gemini extensions link ~/chiron/integrations/gemini
```

**Codex CLI**: add the server to `~/.codex/config.toml` and the hook to
`~/.codex/hooks.json` (read both first and merge; keep everything already there). If
Codex asks to review the new hook, the user approves it.

```toml
[mcp_servers.chiron]
url = "http://localhost:8090/mcp"
```

```json
{
  "hooks": {
    "UserPromptSubmit": [
      { "hooks": [ { "type": "command", "command": "curl -s --max-time 4 -X POST -H 'Content-Type: application/json' --data-binary @- 'http://localhost:8090/hooks/prompt?tool=codex'" } ] }
    ]
  }
}
```

## 4. Finish

Tell the user to start a new Claude Code session: the memory tools only load in a new
session. Then explain, briefly and in plain language:

- **What it does**: Claude can save things to memory and recall them in later sessions,
  in any project. Related memories also come to mind automatically as they type.
- **How to use it**: "remember that …", "what do you remember about …?", or "save what
  we decided today".
- **Privacy**: memories stay on this computer.
- **Memories are who said what, and when**: each one records that someone said or did
  something on a given day, not that it's true. A mistake or a change of mind is simply a
  newer memory, and Claude weighs them by date. Claude and Chiron never erase anything, so
  they should only agree to saving what they're comfortable keeping. The one way memories
  are lost is deleting Docker's stored data (see "Never" below), so a backup is worth it.

Offer to save a first memory: ask what they work on and save their answer, with consent.

Mention that this is a beta: anything that breaks, feels off or surprises them is worth
an email to james@madsciencesoftware.dev (never including their memories).

Don't import any existing history (email, past Claude sessions, git repositories) unless
the user explicitly asks. If they do, follow [`docs/ingestion.md`](ingestion.md).

## Day to day

All from `~/chiron`:

- **Update**: `git pull && docker compose --profile app pull && docker compose --profile app up -d && claude plugin marketplace update mad-science && claude plugin update chiron@mad-science`
  (from a source checkout, `up -d --build` replaces the `pull`). Gemini CLI's linked
  extension follows `git pull` on its own.
- **If memory stops working** (Claude says the chiron tools failed, or nothing is ever
  recalled): run `python3 ~/chiron/plugin/scripts/check_memory.py`. If it fails, make sure
  Docker Desktop is running, then `docker compose --profile app up -d`.
- **Back up**: `docker compose exec -T db pg_dump -U postgres chiron > ~/chiron-backup-$(date +%F).sql`
- **Stop**: `docker compose --profile app down`. Memories are kept.
- **Never** run `docker compose down -v` or delete Docker volumes unless the user wants
  their memory erased permanently. That deletes every memory.
