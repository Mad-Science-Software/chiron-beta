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

## What gets installed

- **The Chiron app** (section A), on Mac, Windows or Linux: one download, about 5
  minutes, no admin password, no Docker.
- **Also using the Claude Desktop app** (chat or Cowork)? After installing, section B
  connects it to the same memory.

**First:**

1. **Beta terms.** Show the user the terms in `BETA.md`
   (https://github.com/Mad-Science-Software/chiron-beta/blob/main/BETA.md), summed up in a
   few plain sentences, and ask whether they agree. Stop if they don't.
2. **Nothing else to install first.** Chiron needs no git, no Python and no copy of a
   repository: the app carries the plugin and the settings for each AI assistant.

## A. The Chiron app (Mac, Windows and Linux)

### A1. Install the app

On a Mac or Linux:

```sh
curl -fsSL https://github.com/Mad-Science-Software/chiron-beta/releases/latest/download/install.sh | sh
```

On Windows:

```sh
curl -fsSL -o "$TEMP/install.ps1" https://raw.githubusercontent.com/Mad-Science-Software/chiron-beta/main/install.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File "$TEMP/install.ps1"
```

(The bypass applies to this one script; Windows blocks scripts by default.)

It downloads the app for this computer, checks it against the release's checksums,
puts it in `~/.chiron/bin`, and starts it at every login (a LaunchAgent on Mac, a
systemd user service on Linux, a Run registry entry on Windows). On Windows that's two
files, `chiron.exe` and `chironw.exe` (the same program without a console window, which
runs at login). The beta isn't code-signed yet: if Windows Defender quarantines it, the
user can allow it in Windows Security, and that's their call to make. The first start also downloads the embedding model
(about 430 MB) and can take a few minutes; it prints its progress and finishes with
"Chiron … is running". Everything lives in `~/.chiron`.

Verify: `~/.chiron/bin/chiron status` (`chiron.exe` on Windows) says it's running with
embeddings ready. A flask icon appears in the Mac menu bar or the Windows tray (under the
taskbar's arrow until the user pins it): it shows the memory count, offers updates, opens
the logs, and can stop memory until the next login. (`"menu_bar": false` in
`~/.chiron/config.json` hides it.)
On a Mac, Chiron also appears in Spotlight and Launchpad (`~/Applications/Chiron.app`):
opening it shows the review window. Uninstall removes it.

If it fails, read `~/.chiron/logs/chiron.log` and the embedding server's log (`ollama.log`
on a Mac, `llama.cpp.log` on Windows and Linux) in the same folder, tell the user what
went wrong in plain language, and stop rather than improvising.

### A2. Connect the AI assistants

Chiron finds the AI assistants on this computer and connects them itself: Claude Code,
Claude Desktop (chat and Cowork), Codex CLI and Gemini CLI. It adds its entry to each
one's settings and keeps every other setting. (On Windows, `chiron` is
`~/.chiron/bin/chiron.exe`.)

```sh
~/.chiron/bin/chiron assistants
```

This lists each assistant, whether it is on this computer, and whether it is connected.
Ask the user which ones they use. Then connect those, one at a time:

```sh
~/.chiron/bin/chiron assistants connect claude-code     # also: claude-desktop, codex, gemini
```

Or connect every one that is installed: `~/.chiron/bin/chiron assistants connect --all`.

- **Claude Code** gets the Chiron plugin. The plugin adds the memory tools and a hook that
  recalls related memories for every message the user sends. It installs for the user,
  so it applies in every project. Chiron runs the `claude` command for this, also the copy
  inside the Claude Desktop app when `claude` isn't on the PATH.
- **Claude Desktop** gets an entry in `claude_desktop_config.json` that runs Chiron
  directly. If the Chiron extension (`chiron.mcpb`) is already installed, Chiron leaves it
  and adds nothing.
- **Codex CLI** gets an MCP server in `~/.codex/config.toml` and a hook in
  `~/.codex/hooks.json`. If Codex asks to review the hook, the user approves it.
- **Gemini CLI** gets the Chiron extension, linked from `~/.chiron/assistants/gemini`.

Chiron keeps a copy of each file it changes, with `.chiron-backup` at the end of the name.
"Restart it to load Chiron" means the assistant reads the change when it starts next.

If a connect reports a problem, tell the user in plain language. It says what to do. For
example, when Chiron can't find the `claude` command, the user types two `/plugin`
commands in Claude Code. If an assistant's settings file can't be read, Chiron changes
nothing; don't repair the file without the user's yes.

If `claude plugin list` also shows `chiron-docker@mad-science` or `chiron-app@mad-science`
(older names), uninstall them (`claude plugin uninstall <name>@mad-science`); if
`claude mcp list` shows a `chiron` server registered by hand, remove it
(`claude mcp remove chiron`), so the tools don't appear twice.

Verify:

```sh
~/.chiron/bin/chiron assistants                    # the assistants you connected: connected
~/.chiron/bin/chiron check                         # the memory check passes
```

The memory check makes a real recall, the same call the hook makes, and fails with the
reason if memory can't be reached. (The hook stays silent when memory is down, so
prompts never break; that's why it isn't the check.)

### A3. If `chiron assistants connect` can't do it

Use these steps only when a connect fails and its message doesn't help. Run
`chiron assistants connect` once first: it writes the files these steps use.

**Claude Code** (on Windows the plugin is `chiron-windows`):

```sh
claude plugin marketplace add ~/.chiron/assistants/claude-code
claude plugin install chiron@mad-science          # Windows: chiron-windows@mad-science
```

**Gemini CLI**: `gemini extensions link ~/.chiron/assistants/gemini`, then restart it.

**Codex CLI**: add to `~/.codex/config.toml` and `~/.codex/hooks.json` (read both first
and merge; keep everything already there). On Windows, use
`$USERPROFILE/.chiron/bin/chiron.exe` where these say `$HOME/.chiron/bin/chiron`,
without the `sh -c` wrapper.

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

**Claude Desktop**: see section B.

Then go to section B if they use Claude Desktop, otherwise **Finish**.

## B. Claude Desktop and Cowork (optional)

Only if the user also uses the Claude Desktop app's chat or Cowork (ask). The app must
be installed and running first (section A). If A2 connected `claude-desktop`, Claude
Desktop is already connected: ask the user to quit Claude Desktop completely and open
it again, then skip to the verify step (3). Otherwise:

1. Run `~/.chiron/bin/chiron assistants connect claude-desktop`. If it reports a
   problem, use the Chiron extension instead: download it with
   `curl -fsSL -o ~/Downloads/chiron.mcpb https://github.com/Mad-Science-Software/chiron-beta/releases/latest/download/chiron.mcpb`.
2. For the extension only: ask the user to double-click `chiron.mcpb` in their Downloads
   folder and click **Install**. If double-clicking does nothing (the Microsoft Store
   version of Claude for Windows ignores it), have them open Claude Desktop's Settings →
   Extensions and drag the file onto that page, or use **Advanced settings → Install
   Extension…** there. Desktop notes the extension isn't verified: it isn't signed yet,
   which is expected for the beta.
3. Verify: in a new Desktop chat, "what do you remember about …?" should show Claude
   recalling.

Tell the user: chats that were already open don't get Chiron; start a new
chat. Desktop has no automatic recall on every message (that's Claude Code's
hook), so in Desktop Claude recalls when it judges memory might help, and asking
"check your memory" always works. Cowork can use it in sessions on this computer, not
in cloud sessions started from the web or phone. In the Desktop app's Code tab the
memory tools then appear twice, the plugin's and Desktop's own: both reach the same
memory, so it's harmless, and the plugin is still what gives the Code tab automatic
recall. If Chiron isn't running, the tools report that instead of answering.

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

`chiron` is `~/.chiron/bin/chiron` (`chiron.exe` on Windows):

- **Update**: `chiron update`. That one step also updates the Claude Code plugin and the
  other assistants' settings, for the assistants the user connected. The update keeps
  the previous version and goes back to it if the new one doesn't start.
- **Assistants**: `chiron assistants` shows which are connected and when each last used
  memory; `chiron assistants connect <id>` and `chiron assistants disconnect <id>` change
  that.
- **Is it working?** `chiron status`, and `chiron check`.
  Logs are in `~/.chiron/logs`. If it's stopped, `chiron install` starts it again.
- **Back up**: `chiron backup` writes `~/chiron-backup-<date>.db`, safely while it runs.
- **Stop**: `chiron uninstall` stops it starting at login. Memories are kept.
- **Never** delete `~/.chiron` unless the user wants their memory erased permanently.
