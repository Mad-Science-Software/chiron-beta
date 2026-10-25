# Setting up Chiron for a user

This guide is for an AI agent (Claude Code) installing Chiron on someone's computer so
their Claude has persistent memory. You are installing, not developing: don't change
Chiron's code, create branches, or install git hooks, whatever AGENTS.md or the README
say about development.

Chiron needs a team with an active free trial or subscription. Until this computer joins
one, memory is off: the assistant can't recall or save. The memory server can't be reached
from the network. Private memories stay on this computer. They go to the team's Chiron
server only if the user turns on private backup in the Chiron app. Shared memories sync
through the team's server, and the team sees only what the user chooses to share.

Tell the user what you're doing as you go, in plain language. Ask before anything that
needs their password or touches their personal data. Don't create a `.env` file, even if
a README mentions one: it's for developing Chiron.

## What gets installed

- **The Chiron app** (section A), on Mac, Windows or Linux: one download, about 5
  minutes, no admin password, no Docker.
- **Also using the Claude Desktop app** (chat or Cowork)? After installing, section B
  connects it to the same memory.

**First:**

1. **The code in the prompt.** The user may have pasted an offer code or an invite code
   together with this guide. The offer page and the invite page on the website give
   them. Keep the code for step A2: it creates the user's account and team, or joins
   their team, when the app connects. Without a code, A2 says what to do.
2. **Beta terms.** Tell the user in two or three plain sentences what `BETA.md`
   (https://github.com/Mad-Science-Software/chiron-beta/blob/main/BETA.md) says. Chiron is
   early software. Private memories stay on this computer, and the team sees only what
   they share. They agree to the Terms of Service on the website when they sign in or
   create their account (step A2). Don't ask them to agree here as well.
3. **The memory plan.** Before anything is installed, decide with the user which history
   Chiron imports: past Claude Code sessions, git repositories, email, other exports.
   Follow [`docs/memory-plan.md`](memory-plan.md). It ends with a plan the user approved
   in `~/chiron-ingest/plan.md`. After the install you run that plan on your own
   (**Finish**, below). If the user wants no history imported, write a plan that says so.
4. **Nothing else to install first.** Chiron needs no git, no Python and no copy of a
   repository: the app carries the plugin and the settings for each AI assistant.

## A. The Chiron app (Mac, Windows and Linux)

### A1. Install the app

If `~/.chiron/bin/chiron status` (`chiron.exe` on Windows) already says Chiron is
running, skip to A2. If it also says the team needs a newer Chiron, run
`~/.chiron/bin/chiron update` first.

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
embeddings ready. The Chiron icon (a key over a circle) appears in the Mac menu bar or the Windows tray (under the
taskbar's arrow until the user pins it): it shows the memory count, opens the Chiron
window (**Open Chiron**), switches between teams when the computer is in more than one,
offers updates, opens the logs, and can stop memory until the next login.
(`"menu_bar": false` in `~/.chiron/config.json` hides it.) The Chiron window shows the
user's memories, and the gear in its top right corner opens Settings: the team (sharing
policy, add a team), private memories (the backup switch), the AI assistants, this
computer (version, memory count, embedding model, last sync, a memory check, what
memory takes on disk, and which shared sources stay on the server).
On a Mac, Chiron also appears in Spotlight and Launchpad (`~/Applications/Chiron.app`):
opening it shows the Chiron window. Uninstall removes it.

If it fails, read `~/.chiron/logs/chiron.log` and the embedding server's log (`ollama.log`
on a Mac, `llama.cpp.log` on Windows and Linux) in the same folder, tell the user what
went wrong in plain language, and stop rather than improvising.

### A2. Join a team

Memory is off until this computer joins a team with a free trial or a subscription.

- **With an offer code** from the prompt: run `~/.chiron/bin/chiron connect --offer CODE`.
- **With an invite code** from the prompt: run `~/.chiron/bin/chiron connect --invite CODE`.
- **Without a code**, ask the user whether their team uses Chiron already. If a teammate
  sent an invite link, tell the user to open it: the page shows a prompt with an invite
  code in it. Use that code as above. If not, tell the user to start a free trial on the
  website, or, during the private beta, to ask Mad Science for an offer ("Talk to us" on
  chironmemory.com). An offer link gives a prompt with an offer code. With a team that
  exists already, run `~/.chiron/bin/chiron connect` on its own.

The command shows a link and a code, and opens the link in the browser. With an offer
code, the page asks the user to create their account with the address the offer was
sent to and to name their team. With an invite code, it asks them to sign in or create
their account with the invited address. Without a code, the user signs in and picks a
team, or, with no team yet, names a new one on the page; a teammate's invite link is
the way into a team that exists. When the page makes a new team and Mad Science has
published libraries, it lists them: the user can pick up to two, or none. An owner or
admin can pick or change them later on the dashboard's Libraries page. After creating an account the user may have to verify
their email: they open the link in the email and press "I've verified my email". That is
not an error. Tell the user to check that the page shows the same code once they are
signed in. The Chiron app shows the same connection and code (in the setup window on
the first run; later under the gear, Add a team). The command waits until the page has
approved this computer and the app has joined the team; a team the computer was in
already does not end the wait. The page then says the app finishes on its own, and the
user can close the tab. The code works for 15 minutes: if the command times out, run it
again for a new code. If the page says the offer or the invite has expired or was
already used, tell the user to ask for a new link. Do not guess another code. Then
`~/.chiron/bin/chiron check` shows the team, and
`~/.chiron/bin/chiron switch` lists every team this computer is in and marks the one
memory is in.

A user can be in more than one team on this computer, for example their firm and a
personal project. Run `~/.chiron/bin/chiron connect` again to join another team; on the
approval page the user picks the team. Memory works in one team at a time. Every team
stays in sync, and `~/.chiron/bin/chiron switch` lists the teams or switches to one
(`chiron switch "Team name"`). The user can also switch in the Chiron menu or the Chiron
app. An agent can ask to switch with the `switch_team` tool; the user confirms the switch
in the Chiron app, and the agent cannot switch on its own.

### A3. Connect the AI assistants

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
reason if memory can't be reached or the team's sync is refused. (The hook stays silent
when memory is down, so prompts never break; that's why it isn't the check.)

If the check's `Sync` line says the team needs a newer Chiron than this computer runs,
run `~/.chiron/bin/chiron update` and run the check again. Memory keeps working
meanwhile; only sync waits for the update.

### A4. If `chiron assistants connect` can't do it

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
be installed and running first (section A). If A3 connected `claude-desktop`, Claude
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

Tell the user that the memory tools load in a new Claude Code session, and to start one
after this session reports that the memory plan has run (below). Then explain, briefly
and in plain language ([`docs/about-chiron.md`](about-chiron.md) has the full picture,
for when they ask more; after the install it is also `~/.chiron/docs/about-chiron.md`):

- **What it does**: Claude can save things to memory and recall them in later sessions,
  in any project. Related memories also come to mind automatically as they type.
- **How to use it**: "remember that …", "what do you remember about …?", or "save what
  we decided today". "Bring memory up to date" runs their memory plan again and imports
  what is new.
- **Team and subscription**: memory works only while this computer is in a team with an
  active free trial or subscription. When the trial or subscription ends, memory turns off
  for their assistants. Their memories stay on this computer, and they can still view and
  delete them in the Chiron app. Everything comes back when the team subscribes. Without a
  connection to the server, memory keeps working for 30 days after the last sync, with
  what the computer holds. A pause
  for a required update has no such limit: memory keeps working until the computer updates.
- **More than one team**: they can join a second team (their firm and a personal project,
  say). Memory is in one team at a time; they switch in the Chiron menu, in the Chiron
  app, or with `chiron switch`. Claude can ask to switch, and they confirm in the Chiron
  app. Each team has its own private memories: a memory saved or imported while memory
  is in a team stays private in that team, and they can share it only with that team.
  So they switch to the right team before an import. Private backup is a choice for
  each team.
- **Privacy**: private memories stay on this computer. To keep a copy on the team's
  Chiron server, they turn on private backup in the Chiron app (the gear, then Private
  memories; the app asks them to confirm), for each team. Then their
  other computers, that team's Connected apps (claude.ai, ChatGPT) and its dashboard can
  see them too. The team sees only what they choose to share. While backup is on in a
  team, private memories in that team stop at their limit there, so a large import
  needs backup off in that team first.
- **Copies of shared sources**: the team's shared memory comes to this computer whole.
  Under "Everything shared", and under each teammate, in the Chiron window, each source (a mailbox, a repository,
  an imported library) has a button to keep or remove its copy on this computer; the
  app says what the copy takes before it is kept, and the copy arrives, or goes, at the
  next sync. The choice is this computer's, for the team memory is in. A source without
  a copy stays on the team's server: the window still shows it in the team's memory,
  but Claude cannot recall it on this computer until a copy is kept; the prompt hook
  names such sources, so Claude can say so. The settings sheet (the gear, then This
  computer) and `chiron status` show what memory takes and which sources are on the
  server only.
- **Published libraries**: the team can hold up to two libraries of reference material
  from Mad Science. Each comes to this computer whole, and Claude recalls it beside the
  team's memory. Its memories are read-only, and they do not count against storage. The
  Chiron window lists them under "Published libraries". Owners and admins pick them on
  the dashboard's Libraries page.
- **Memories are who said what, and when**: each one records that someone said or did
  something on a given day, not that it's true. A mistake or a change of mind is simply
  a newer memory, and Claude weighs them by date. When a memory shapes Claude's answer
  or action, Claude says so: that it came from Chiron, whose memory it was, and when.
  Nothing is erased on its own: Claude
  can stage memories for deletion, and they confirm each one in the Chiron app. So they
  should only agree to saving what they're comfortable keeping. A backup now and then is
  worth it (below).
- **Updates**: when a new version is out, Claude mentions it once in a session and offers
  to install it. Mad Science can set, for a team, the oldest Chiron its computers may sync
  with, for example before the team's memory grows large. A computer on an older version
  then pauses sync until it updates; `chiron status`, `chiron check` and the Chiron menu
  show the reason. Memory keeps working with what the computer holds, and Claude says so
  once and offers the update. What the user saves or shares meanwhile reaches the team and
  their private backup after the update, and turning private backup on also waits for it.
  After the update that brings the search graph, recall stays correct but is slower while
  the app builds the graph in the background: a few minutes on a large memory, longer on
  a very large one.

The memory tools aren't loaded in this session, so you can't save a memory here. The
memory plan gives memory its first content. Without one, suggest that in their new
session they tell Claude what they work on and ask it to remember.

Mention that this is a beta: anything that breaks, feels off or surprises them is worth
an email to james@madsciencesoftware.dev (never including their memories).

**Then run the memory plan** (`~/chiron-ingest/plan.md`), in this session: follow "Run
the memory plan" in [`docs/ingestion.md`](ingestion.md). Run it only when its header
says `Agreed on <date>`. If it says `Draft`, ask once whether they approve now: on yes,
write `Agreed on <date>` and run it; otherwise leave the file and tell them that "finish
the memory plan" in a later session runs it when they approve. An agreed plan carries
the user's decisions, so don't ask again; the user doesn't need to stay at the keyboard.
Report when it's done. The memory tools aren't loaded in this session, so a source the
plan marks for sharing, except `Share: all`, ends as `sharing pending`: tell the user to
start a new session and say "finish the memory plan". A `Share: all` source the user
shares themselves with "Share all" in the Chiron window.

Without an approved plan, don't import any history unless the user asks. When they do,
the `import-history` skill makes the plan with them and runs it.

## Day to day

`chiron` is `~/.chiron/bin/chiron` (`chiron.exe` on Windows):

- **Update**: `chiron update`. That one step also updates the Claude Code plugin and the
  other assistants' settings, for the assistants the user connected. The update keeps
  the previous version and goes back to it if the new one doesn't start.
- **Assistants**: `chiron assistants` shows which are connected and when each last used
  memory; `chiron assistants connect <id>` and `chiron assistants disconnect <id>` change
  that.
- **Teams**: `chiron switch` lists the teams this computer is in; `chiron switch "Team
  name"` moves memory to one. `chiron connect` joins another team (`--offer CODE` or
  `--invite CODE` with a code from the website).
- **Is it working?** `chiron status`, and `chiron check`.
  Logs are in `~/.chiron/logs`. If it's stopped, `chiron install` starts it again.
- **Back up**: `chiron backup` writes `~/chiron-backup-<date>.db`, safely while it runs.
- **Stop**: `chiron uninstall` stops it starting at login. Memories are kept.
- **Never** delete `~/.chiron` unless the user wants their memory erased permanently.
