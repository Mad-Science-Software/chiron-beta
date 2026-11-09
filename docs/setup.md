# Setting up Chiron for a user

This guide is for an AI agent (Claude Code) installing Chiron on someone's computer so
their Claude has persistent memory. You are installing, not developing: don't change
Chiron's code, create branches, or install git hooks, whatever AGENTS.md or the README
say about development.

Chiron needs a team with an active free trial or subscription. Until this computer joins
one, memory is off: the assistant can't recall or save. The memory server can't be reached
from the network. Private memories stay on this computer. They go to the team's Chiron
server only if the user turns on private backup in the Chiron app. Without backup,
Chiron sends only a count of the private memories that are not backed up, with no
content. Mad Science staff can see that count; team owners and admins cannot. A problem
report, which the user sends from Settings, then Help, carries their description, their
reply address, the app's state and, unless they clear that option, the end of its log,
with credentials and memory text removed. Only Mad Science staff read it; team owners
and admins cannot. A report from a computer in a team names that computer, account and
team. Mad Science keeps a report for 90 days, or until the user deletes their account.
Shared memories sync through the team's server, and the team sees only what the user
chooses to share.

Tell the user what you're doing as you go, in plain language. Ask before anything that
needs their password or touches their personal data. Don't create a `.env` file, even if
a README mentions one: it's for developing Chiron.

## What gets installed

- **The Chiron app** (section A), on Mac (macOS 14 or later, Apple silicon or Intel),
  Windows or Linux: one download, about 5 minutes, no admin password, no Docker. On an
  older macOS, stop and tell the user that Chiron needs macOS 14 or later.
- **Also using the Claude Desktop app** (chat or Cowork)? After installing, section B
  connects it to the same memory.

This guide is the Claude-guided install. A user can also install from the download
(the Mac disk image, the Windows installer or the Linux install command) with no
guide. When the website offers the installers, the offer page and the invite page
give these downloads: the user accepts on the page first, then downloads. Then the
Chiron window's first run takes them through the same team and assistant steps. On
Linux, which has no Chiron window, `~/.chiron/bin/chiron review` opens these steps in
the browser. It imports no history:

1. Sign in to the team (A2), connect the AI assistants (A3), and run the memory check.
2. **An owner or admin**, after the check, invites teammates. Chiron emails each invite
   link to the teammate, and the window also shows the link to send if the email does
   not go. The owner or admin can also write the sharing policy. The policy is optional: without one,
   suggestions follow Chiron's default rule.
3. **A teammate**, after the check, chooses which of the team's shared sources this
   computer keeps, with each one's size.

Finish ends the first run. Settings opens the last step again: Team (invites and
policy) and This computer (copies of shared sources). A bulk import (a mail export,
many past sessions, a large archive) goes through a coding agent such as Claude Code
with the `import-history` skill. A few files can be saved with the `preserve` tool in
any assistant connected on this computer. The Connected apps (claude.ai, ChatGPT)
cannot save.

**First:**

1. **The code in the prompt.** The user may have pasted an offer code or an invite code
   together with this guide. The code is the part of the offer link after `/o/`
   (`…/o/CODE`), or of the invite link after `/invite/` (`…/invite/CODE`). Do not
   include a `?` or the text after it. Before the website offers the installers, the
   offer page and the invite page give a prompt with the code. When it offers them,
   these pages have the user accept on the page, then download Chiron. If the user
   accepted the offer or the invite on the website already, the team exists: do not
   use the code. Keep the code for step A2: it creates the user's account and team, or
   joins their team, when the app connects. Without a code, A2 says what to do.
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
running, skip to A2. If it also says the team needs a newer Chiron, or if
`~/.chiron/bin/chiron teams` is an unknown command, run `~/.chiron/bin/chiron update`
first.

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
embeddings ready. The Chiron icon (a key over a circle) appears in the Mac menu bar or
the Windows tray (under the taskbar's arrow until the user pins it): it shows the memory count of
the team the window shows, opens the Chiron window (**Open Chiron**), changes which team the window shows when the computer is in more than one,
offers updates, opens the logs, and can stop memory until the next login.
(`"menu_bar": false` in `~/.chiron/config.json` hides it.) The Chiron window shows the
user's memories. It has three tabs: Memories, Suggestions and Settings. Memories is a
sheet of every memory in the team the window shows, with the columns Memory, Whose,
Visibility, Source, Date and Size. The user can also move their own memories to another of their teams there.
Suggestions holds what the assistants staged for
sharing or deletion. When an assistant stages memories with the `share` or `delete`
tool, the window usually comes forward on this tab, at most once in 2 minutes. On a
computer with no Chiron window, Chiron tries to open the page in a new browser tab
instead, with the same limit. Chiron also
stages for deletion, in the memory's own team, a memory that the team's server could not take with its
credentials blanked, so it refused to share it. Settings has seven sections: Team (the
sharing policy, which an owner or admin can change; invites, for an owner or admin; add
or leave a team), Storage (the private backup switch), AI assistants, Devices, This computer
(version, the memory count of the team the window shows, embedding model, last sync, a memory check,
what memory takes on disk, and the copies of teammates' shared memories), Account
(download your memories, sign out, delete your account) and Help (Contact Mad Science
Software, with the support address and the support page, and Report a problem). Sign out
disconnects this computer from every team: the user stays in the teams, the memories
stay on the computer, and they show again when the user joins the same team. Until then
no team is active: the Chiron menu and Settings, This computer, count only memories saved
before the computer joined a team (usually 0), and `chiron status` still counts every
memory on the computer. Memory is off for the assistants until the computer joins a team
again with
`~/.chiron/bin/chiron connect` (step A2).
On a Mac, Chiron also appears in Spotlight and Launchpad (`~/Applications/Chiron.app`):
opening it shows the Chiron window. Uninstall removes it.

If it fails, read `~/.chiron/logs/chiron.log` and the embedding server's log (`ollama.log`
on a Mac, `llama.cpp.log` on Windows and Linux) in the same folder, tell the user what
went wrong in plain language, and stop rather than improvising. Then tell the user how
to get help: email inquiries@madsciencesoftware.dev, or see
https://chironmemory.com/support. If the Chiron window opens to its tabs (not the setup
window or an error screen), they can send a problem report from Settings, then Help.
Under Report a problem, they describe it. Your email address is needed only when the
computer is in no team, for example after Sign out; in a team it starts with the
account's address. Then they choose Review the report, then Send report. By default it
carries the end of the app's log, with passwords, sign-in tokens and memory text
removed. They can clear Include the app's log, and they see the whole report before they
send. The setup window and the error screens show the support address instead.

### A2. Join a team

Memory is off until this computer joins a team with a free trial or a subscription.
If `~/.chiron/bin/chiron check` shows the team already, skip to A3.

- **With an offer code** from the prompt: run `~/.chiron/bin/chiron connect --offer CODE`.
- **With an invite code** from the prompt: run `~/.chiron/bin/chiron connect --invite CODE`.
- **If the user accepted the offer or the invite on the website already**, or the team
  exists already for another reason, run `~/.chiron/bin/chiron connect` without a code.
  The user picks that team.
- **Without a code**, ask the user whether their team uses Chiron already. If a teammate
  invited them, the invite link is in an email from Chiron ("… invited you to … on
  Chiron"), or the teammate sent it. If the email is not in the inbox, tell the user to
  check spam or to ask the teammate for the link. The invite code is in the link
  (`…/invite/CODE`; see First, step 1). Use that code as above. If no teammate invited them, tell
  the user to start a free trial on the website, or, before the open beta starts, to
  ask Mad Science for an offer ("Talk to us" on chironmemory.com). The offer code is in the
  offer link (`…/o/CODE`; see First, step 1). For a team that exists already, see the
  bullet above.

The command shows a link and a code, and opens the link in the browser. With an offer
code, the page asks the user to create their account with the address the offer was
sent to and to name their team (at most 80 characters, on one line). With an invite
code, it asks them to sign in or create their account with the invited address. Without
a code, the user signs in and picks a team, or, with no team yet, names a new one on the
page (at most 80 characters, on one line); a teammate's invite link is the way into a
team that exists. If the browser opened an offer link before and the offer is still
open, a user with no team sees that offer first. The user starts the team with the
offer, then picks it and approves the code.

In the open beta, the website makes a limited number of new teams each day, counted in
UTC (Coordinated Universal Time). A team from an offer is not limited. When the day's
places are taken, the page shows "Join the waitlist" in place of the team name field.
This is not an error. Tell the user to press it. The page then shows their place in
line; a user who is on the waitlist already sees their place without the button. Then
stop the `chiron connect` command. If a place is free when the user presses the button,
such as after midnight UTC, the page says "A place for a new team is free now" and shows
the team name field again. The user names the team, and the command continues. If the
page says the account already used its free trial, the user must subscribe to start
another team.

When a place is free, Chiron emails the user "Your place to start a team on Chiron". The
place is held until the end of that day, UTC. If the user does not use it, Chiron holds
it the next day too and emails again. The email's "Start your team" link opens the
new-team form on the website. After the user makes the team there, run
`~/.chiron/bin/chiron connect` on its own and pick that team. Or run
`~/.chiron/bin/chiron connect` while the place is held, and the user names the team on
the page. A user who does not use the place by the end of the second held day leaves the
waitlist. They can start a team on a day with a free place, or join the waitlist again
when the day's places are taken.

When the page makes a new team and Mad Science has published
libraries, it lists them: the user can pick up to two, or none. An owner or admin can
pick or change them later on the Libraries sheet of the admin portal. A team that the
user made on the offer page has its libraries already. After creating an
account the user may have to verify their email: they open the link in the email and
press "I've verified my email". That is not an error. If the page says the account's
name is too long (more than 80 characters) or has a line break or another control
character, tell the user to change the name on the account they sign in with (for
example their Google account), then sign in again. Tell the user to check that the page
shows the same code once they are signed in. The Chiron app shows the same connection
and code (in the setup window on the first run; later in Settings, Team, Add a team, or
in the window's team menu). The command waits until the page has approved this computer
and the app has joined the team; a team the computer was in already does not end the
wait. The page then says the app finishes on its own, and the user can close the tab.
The code works for 15 minutes: if the command times out, run it again for a new code. If
the page says the offer or the invite has expired or was already used, ask the user if
they accepted it on the website. If they did, the page lists their teams: the user
picks that team and approves. If they did not, tell the user to ask for a new link.
For an expired invite, an owner or admin presses "New link" on the
invite in the admin portal's Members and invites sheet. Chiron emails the new link to
the invited address. If the email does not go, the owner or admin sends the link that
the portal shows. They can make a new link for one invite at most once an hour. For an
invite that was already used or withdrawn, they make a new invite. Do not guess another
code. Then
`~/.chiron/bin/chiron check` shows the team, and
`~/.chiron/bin/chiron teams` lists every team this computer is in, with the team ID of
each. Its last line names the team that agents in this session's project folder use.

A user can be in more than one team on this computer, for example their firm and a
personal project. Run `~/.chiron/bin/chiron connect` again to join another team; on the
approval page the user picks the team. Every team stays in sync.

Agents use one team for each call:

- **The default team**: the first team this computer joined. On a computer that was in
  teams before Chiron 0.15.0, it is the team that was active at that update, so agents
  keep their team. If the user leaves the default team, the first team that the
  computer stays in becomes the default. `chiron teams` marks it `(default)`. If agents
  can't use the default team while the window shows another team, the window warns
  about it. Agents use it in a project folder with no `chiron-config.json`, and in
  apps with no project folder. Claude Desktop starts Chiron once for all its chats and
  Cowork tasks, not in a project folder, so they use the default team: a
  `chiron-config.json` in a Cowork folder has no effect. A Connected app (claude.ai,
  ChatGPT) uses the team chosen when it was connected on the website.
- **A pinned folder**: a project folder can hold a `chiron-config.json` that names a
  team. Agents in a session of that project use that team.

The session's project folder decides the team for everything in the session: the
memory tools, the prompt hook, `chiron ingest`, `chiron preserve` and `chiron teams`. A `cd` inside the
session does not change it. The project folder is the one in `CLAUDE_PROJECT_DIR`
(Claude Code sets it) or `GEMINI_PROJECT_DIR` (Gemini CLI sets it for its hooks), else
the folder the command starts in, so run `chiron ingest`, `chiron preserve` and
`chiron teams` from the project folder. Chiron looks for `chiron-config.json` in the project folder, then in
each parent folder, as git looks for `.git`. A file that names no team does not stop
the search.

To pin a project folder, run `~/.chiron/bin/chiron teams pin "Team name"` from it (a
team ID also works). The command writes the file in the session's project folder
(`CLAUDE_PROJECT_DIR` or `GEMINI_PROJECT_DIR` when set, else the current folder), not
in a folder you `cd` to. If Chiron can't use the team, such as a lapsed team, it still
writes the file and prints a warning: calls there are refused until that is fixed. Pin a folder only when the user asks. A pin applies to every folder below it, so
never pin the home folder or a folder that holds many projects unless the user wants
all of them in that team. Tell the user which folder you will pin before you run it.
A `chiron-config.json` in a repository reaches everyone who clones it: a person whose
computer is not in that team has no memory in that folder. The command writes this file:

```json
{
  "team": {
    "id": "5ac68fa2-a1f1-4b51-82af-9ce40bd630c2",
    "name": "Team name"
  }
}
```

Chiron reads only `team.id`; `name` is for people. `chiron teams` lists the IDs. If you
write the file yourself, keep `team` as the first field. Later project settings go
beside it. Memory tools have no team parameter, so an agent cannot pick a team in a call.

A pinned team that this computer cannot use stops memory in that folder. Examples: a
team the computer is not in, or a team whose trial or subscription ended. Chiron refuses
each memory call there with a message that names the file and the team. It never uses
the default team instead. Tell the user, and fix the file or join the team.

The team switcher in the Chiron menu and the Chiron window changes only which team the
window shows. It does not change the team agents use.

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

The memory check makes a real recall, the same call the hook makes, in the team the
window shows. It fails with the reason if memory can't be reached or the sync of any team on this
computer is refused; the message names that team. It does not read a folder's `chiron-config.json`: `chiron teams` from the project folder
says which team agents in that project use. (The hook stays silent
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
memory tools then appear twice, the plugin's and Desktop's own. In a project folder
with no `chiron-config.json`, both use the default team. In a pinned folder, the
plugin's tools use the folder's team and Desktop's own tools use the default team, so
use the plugin's tools there. The plugin is still what gives the Code tab automatic
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
  what is new. A few files can be saved in any assistant connected on this computer
  ("save this file to memory"); a bulk import goes through Claude Code with the `import-history` skill.
- **Team and subscription**: memory works only while this computer is in a team with an
  active free trial or subscription. When the trial or subscription ends, memory turns off
  for their assistants. Their memories stay on this computer, and they can still view and
  delete them in the Chiron app. Everything comes back when the team subscribes. The
  team's owner gets an email 3 days before the trial ends, when the trial or subscription
  ends, and 3 days before the team's data on the server is deleted. Without a
  connection to the server, memory keeps working for 30 days after the last sync, with
  what the computer holds. A pause
  for a required update has no such limit: memory keeps working until the computer updates.
- **More than one team**: they can join a second team (their firm and a personal project,
  say). Claude uses the default team (the first team this computer joined, or the team
  that was active when it updated to Chiron 0.15.0; after they leave the default team,
  the first team that remains), except in a project folder whose
  `chiron-config.json` names another team. `chiron teams pin "Team name"` in a folder
  writes that file. The team switcher in the Chiron menu and the Chiron app changes
  only which team the window shows. Each team has its own private memories: a memory
  saved or imported in a team is private in that team, and they can share it only
  with that team. So an import runs in a session whose project folder uses the right
  team. Later, they can move their own memories to another of their teams in the
  Chiron window (Memories, select, "Move N to team…"); Claude cannot move them. Private
  backup is a choice for each team. `chiron status` counts the memories of every team
  on this computer. The Chiron menu and Settings, This computer, count only the team
  the window shows.
- **Privacy**: private memories stay on this computer. To keep a copy on the team's
  Chiron server, they turn on private backup in the Chiron app (Settings, then Storage;
  the app asks them to confirm), for each team. Without backup, Chiron sends only a
  count of the private memories that are not backed up, with no content. Mad Science
  staff can see that count; team owners and admins cannot. A problem report (Settings,
  then Help) carries their description, their reply address, the app's state and,
  unless they clear that option, the end of its log, with credentials and memory text
  removed. Only Mad Science staff read it; team owners and admins cannot. A report from
  a computer in a team names that computer, account and team. Mad Science keeps a
  report for 90 days, or until the user deletes their account. With backup on, their
  other computers and that team's Connected apps (claude.ai, ChatGPT) can see them
  too. The team sees only what they choose to share. While backup is on in a
  team, private memories in that team stop at their limit there, so a large import
  needs backup off in that team first. Chiron blanks passwords, keys and card
  numbers in their common forms before it saves; Claude still does not save a
  credential.
- **Copies of shared sources**: the team's shared memory comes to this computer whole.
  In the Chiron window, Settings, This computer, "Teammates' shared memories" lists each
  shared source (a mailbox, a repository, an imported library) with a "Keep a copy
  here" switch that keeps or removes its copy on this computer; the
  app says what the copy takes before it is kept, and the copy arrives, or goes, at the
  next sync. A teammate's first run asks this too. The
  choice is this computer's, for the team the window shows. A source without
  a copy stays on the team's server: the Memories tab still shows it, with a "server
  only" tag, but Claude cannot recall it on this computer until a copy is kept; the
  prompt hook names such sources, so Claude can say so. Settings, This computer, and
  `chiron status` show what memory takes and which sources are on the server only.
- **Published libraries**: the team can hold up to two libraries of reference material
  from Mad Science. Each comes to this computer whole, and Claude recalls it beside the
  team's memory. Its memories are read-only, and they do not count against storage. The
  Memories tab shows their memories with Whose set to Library, as view only; a library
  that has not fully reached this computer shows as "still arriving". Owners and admins
  pick them on the Libraries sheet of the admin portal.
- **Memories are who said what, and when**: each one records that someone said or did
  something on a given day, not that it's true. A mistake or a change of mind is simply
  a newer memory, and Claude weighs them by date. When a memory shapes Claude's answer
  or action, Claude says so: that it came from Chiron, whose memory it was, and when.
  No memory is deleted on its own: Claude can stage memories for deletion, and so can
  Chiron for a memory the team's server refused to share. They approve them in the
  Suggestions tab of the Chiron window: one at a time, or with the one approve button
  for the whole group. So they
  should only agree to saving what they're comfortable keeping. A backup now and then is
  worth it (below).
- **Updates**: when a new version is out, Claude mentions it once in a session and offers
  to install it. Mad Science can set, for a team, the oldest Chiron its computers may sync
  with, for example before the team's memory grows large. A computer on an older version
  then pauses sync until it updates; `chiron status`, `chiron check` and the Chiron menu
  show the reason. Memory keeps working with what the computer holds, and Claude says so
  once and offers the update. What the user saves, shares or makes private meanwhile reaches
  the team and their private backup after the update, and turning private backup on also waits for it.
  For 3 days after an update, Claude is told to call the `get_changelog` tool once,
  which lists what changed for it.
  After the update that brings the search graph, recall stays correct but is slower while
  the app builds the graph in the background: a few minutes on a large memory, longer on
  a very large one. A large import leaves the same wait while its memories join the
  graph. After some updates the app also fills the window's search index
  again. An example is the update that makes a search of three letters or more ignore
  accents. Until the
  fill ends, search in the Memories tab stays correct but is slower. The first start after the
  update that adds credential blanking rebuilds the memory file once. On a large memory
  it takes longer, and until it finishes `chiron status` says memory is not running.
  Wait for it, then check again; do not run `chiron install` meanwhile.

The memory tools aren't loaded in this session, so you can't save a memory here. The
memory plan gives memory its first content. Without one, suggest that in their new
session they tell Claude what they work on and ask it to remember.

Mention that this is a beta: anything that breaks, feels off or surprises them is worth
a report. In the Chiron window they open Settings, then Help, and fill in Report a
problem. They can also email inquiries@madsciencesoftware.dev or see
https://chironmemory.com/support.
Never include their memories. If Settings has no Help section, Chiron is older: run
`chiron update`, or email instead.

**Then run the memory plan** (`~/chiron-ingest/plan.md`), in this session: follow "Run
the memory plan" in [`docs/ingestion.md`](ingestion.md). Run it only when its header
says `Agreed on <date>`. If it says `Draft`, ask once whether they approve now: on yes,
write `Agreed on <date>` and run it; otherwise leave the file and tell them that "finish
the memory plan" in a later session runs it when they approve. An agreed plan carries
the user's decisions, so don't ask again; the user doesn't need to stay at the keyboard.
Report when it's done. The memory tools aren't loaded in this session, so a source the
plan marks for sharing, except `Share: all`, ends as `sharing pending`: tell the user to
start a new session and say "finish the memory plan". A `Share: all` source the user
shares themselves in the Memories tab of the Chiron window: they filter the Source
column to that source, tick the header checkbox, and press "Share N" (N is the count).
One press shares the whole source. On a large source the button shows a spinner for a
few seconds. Then the window offers Undo.

Without an approved plan, don't import any history unless the user asks. When they do,
the `import-history` skill makes the plan with them and runs it.

## Day to day

`chiron` is `~/.chiron/bin/chiron` (`chiron.exe` on Windows):

- **Update**: `chiron update`. That one step also updates the Claude Code plugin and the
  other assistants' settings, for the assistants the user connected. The update keeps
  the previous version and goes back to it if the new one doesn't start. An update that
  upgrades the memory store first saves a copy of it. That needs free disk space of
  about the size of the store, plus 10%, plus 512 MB. With too little room, Chiron
  does not upgrade: it says how much it needs and how much is free, and memory stays as
  it was. The user frees disk space, then starts Chiron again. While Chiron upgrades the
  memory store, the Chiron menu (on a Mac, also the Chiron window; on Windows, the tray
  icon) says "Chiron is upgrading its memory store…". On Windows, the Chiron window opens
  when the upgrade ends. `chiron update` waits for the upgrade too. On a large store this can take a few minutes. Until it ends, `chiron status`
  says memory is not running. Wait for the upgrade to end, then check again. Do not run
  `chiron install` meanwhile.
- **Assistants**: `chiron assistants` shows which are connected and when each last used
  memory; `chiron assistants connect <id>` and `chiron assistants disconnect <id>` change
  that.
- **Teams**: `chiron teams` lists the teams this computer is in, with their IDs, and the
  team that agents in the session's project folder use. `chiron teams pin "Team name"`
  makes agents in the project folder use that team. `chiron connect` joins another team
  (`--offer CODE` or `--invite CODE`, with the code from the offer or invite link, as in
  First, step 1).
- **Is it working?** `chiron status`, and `chiron check`.
  Logs are in `~/.chiron/logs`. If it's stopped, `chiron install` starts it again.
- **Open the window**: `chiron review` opens the Chiron window, or the review page in
  the browser where there is no window (Linux). Open Chiron in the menu bar or tray
  does the same.
- **Help**: in the Chiron window, Settings, then Help: the support address and Report a
  problem. Or email inquiries@madsciencesoftware.dev, or see
  https://chironmemory.com/support.
- **Back up**: `chiron backup` writes `~/chiron-backup-<date>.db`, safely while it runs.
- **Stop**: `chiron uninstall` stops it starting at login. Memories are kept.
- **Never** delete `~/.chiron` unless the user wants their memory erased permanently.
