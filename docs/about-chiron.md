# What Chiron is

This guide is for the AI agent that works with a person who uses Chiron. Read it when
they ask what Chiron is, how to use it, what it is good for, or which plan they have.
Then explain in your own words, in plain language, and only as much as they asked.

## In one paragraph

Chiron gives AI assistants a long-term memory, shared across a team. It keeps what
people and their assistants saw, said and did: conversations, email threads, commits,
decisions, and reference material they chose to import. Each memory records who said
or did something, and when. The assistant recalls related memories as the person
works, in any project and in any session, so nothing has to be explained twice. With
the Chiron app, memory runs on each person's own computer. The team sees only what each
person chooses to share.

## How memory works

- **A memory is a record plus cues.** The record is the moment as it happened (the
  message, the thread, the commit). Cues are short sentences that bring it to mind. The
  assistant recalls by meaning, not by keyword, and can expand any cue to read the
  whole record. A long record comes in parts.
- **Who said what, and when.** Every memory carries its authors and its date. A memory
  says that someone said or did something on that day, not that it is true. A mistake
  or a change of mind is a newer memory, and the assistant weighs them by date.
- **Recall is automatic in Claude Code, Codex CLI and Gemini CLI.** Related memories
  come to mind with every message the person sends. In Claude Desktop (chat and Cowork)
  and the Connected apps (claude.ai, ChatGPT), the assistant recalls when it judges
  memory may help, and "check your memory" always works. Cues are matched in English:
  the assistant translates a question in another language before it recalls.
- **The assistant says when it uses memory.** When a memory shapes an answer or an
  action, the assistant tells the person it came from Chiron, whose memory it was and
  when. Cues it did not use, it does not mention.
- **Saving.** The assistant saves when the person asks ("remember that…", "save what
  we decided"), and when something worth keeping comes up: a decision and its reason,
  a change of mind, a lesson. It asks before it keeps anything personal. A save is
  always private, in the team the assistant uses: the assistant cannot write into the team's
  shared memory. To give the team a
  memory, it stages it for sharing and the person confirms in the Chiron app.
- **Importing.** History comes in through imports run by the person's own assistant:
  past Claude Code sessions, git repositories, email exports, chat exports, reference
  material. A bulk import (a mail export, many past sessions, a large archive) goes best
  through a coding agent such as Claude Code with the `import-history` skill. A memory
  plan, made when Chiron was installed, says what to import; "bring memory up to date"
  runs it again for what is new. A few files can be saved with the `preserve` tool in
  any assistant connected on this computer, Claude Desktop chat included. The Connected
  apps (claude.ai, ChatGPT) cannot save. No language model runs in
  Chiron: the person's own assistant writes the cues.
- **Private first.** Everything a person saves or imports is private to them, in the
  team the assistant uses, and stays on their computer. Chiron sends only a count of the
  private memories that are not backed up, with no content; Mad Science staff can see
  that count, and team owners and admins cannot. A problem report (Settings, then Help)
  carries their description, their reply address, the app's state and, unless they
  clear that option, the end of its log, with credentials and memory text removed. Only
  Mad Science staff read it; team owners and admins cannot. A report from a computer in a
  team names that computer, account and team. Mad Science keeps a report for 90 days, or
  until the person deletes their account.
  Private backup, a switch in the Chiron
  app (Settings, then Storage), keeps a copy on the team's server for their other
  devices and the Connected apps; the app asks before it turns on. Someone who leaves a
  team, or is removed, loses their private backups from the server; what they shared
  stays with the team.
- **Credentials are blanked.** Before a memory is saved, Chiron replaces credentials in
  its text with `[redacted]`: labeled passwords, PINs, secrets, tokens and API, access,
  secret and private keys, with a colon or an equals sign ("password: …", "PIN: …",
  "access_token=…", "API key: …"), "the password for … is …", "the wifi password,
  …" or "the gate password …" when the word looks like a credential, "the API key is
  …", "the PIN is …", Authorization headers and Bearer tokens,
  provider keys (OpenAI, Anthropic, Stripe, GitHub, Slack, AWS, Google and others),
  Chiron's own tokens and its offer and invite codes, JSON Web Tokens, the user and
  password in web addresses, Slack and Discord webhook addresses, private keys and card
  numbers. After a bare "pass:", "PIN:", "secret:" or "token:", or a label of two words
  such as "API key:", a plain word stays ("Bus pass: renewed"), and so does a plain
  word after "password" ("the password reset email"). Text that only looks like a
  credential, such as a number in the shape of a card number, can be blanked too. The
  team's server blanks them again. It does not catch every secret: a password with no
  label stays, and of a password with spaces that is not in quotes at most the first
  word is blanked, and none when that word is a common word such as "my" or "the". So
  the assistant still does not save one.
  Memories saved before Chiron began blanking credentials keep their text until they
  are shared, or backed up for the first time; then Chiron blanks them on the computer and on the server,
  and the person's other computers and teammates get the blanked copy. When the team's
  server cannot take the blanked text, the share is refused and the memory goes back
  to private. In the Memories tab, the memory's Visibility shows a warning sign; it and
  the memory's Sync field say "Not shared: the team's server couldn't take it with its
  passwords and keys removed". At that first refusal, Chiron stages the memory for
  deletion in Suggestions of the memory's own team, with a reason that says why. Sharing it again is refused at
  once with the same reason. It is deleted only if the person approves; if they
  decline, it stays private.
  The team's server can also refuse a share because it holds the memory as another
  person's (a computer that took over from someone keeps their memories). The memory
  then goes back to private and says "Not shared: the team's server holds it as
  another person's memory". Sharing it again is refused at once. Chiron does not stage
  it for deletion. Making such a shared memory private is refused for the same reason:
  after the next sync it shows as shared again, with no message, and teammates keep it.
  Chiron overwrites the text it replaces in its database file (`~/.chiron/chiron.db`).
  At the first start after the update that adds this check, Chiron rebuilds the
  database file once, before it serves the assistants. This clears old copies of text
  that earlier versions left in its free space, including text of memories deleted
  before. On a large memory, that start takes longer. When the disk has too little
  room for it (about twice the size of the database, plus 512 MB), Chiron starts
  without it. It rebuilds the next time it starts, opens its memory for a command, or
  replaces text, with room on the disk. When another read or write of the database
  lasts more than two seconds as Chiron rebuilds or replaces text, the old text stays
  in the database file and in its log file (`chiron.db-wal`) for a short time. Chiron
  saves the replaced text all the same, and tries again in the background until it can
  empty the log into the database file. When Chiron stops before that, the old text
  stays until a later write empties the log. The search index can
  keep three-letter pieces of it for a while. These keep the text as it was: the copies
  taken before each upgrade of the memory store (the newest three, in
  `~/.chiron/backups`), any copy made with `chiron backup`, and any file from
  "Download your memories" (Settings, Account). Chiron removes an upgrade copy when a
  newer upgrade of the store makes a fourth one; the person can delete those copies to
  remove the text sooner. On the team's server, older copies in the encrypted database
  backups expire with the backup retention.
- **Copies of shared sources.** The team's shared memory comes to every member's
  computer, grouped by source (a mailbox, a repository, an imported library). In the
  Chiron window, Settings, This computer, "Teammates' shared memories" lists each source
  with a "Keep a copy here" switch, which keeps or removes its copy on this computer;
  the app says what the copy takes first, and the copy arrives, or goes, at the next
  sync. A teammate's first run asks this too. The
  choice is this computer's, for the team the window shows. A source without a
  copy stays on the team's server: the Memories tab still shows it, with a "server
  only" tag, but the assistant cannot recall it on this computer until a copy is kept. A person's own memories always stay on the computer.
- **One person, several teams.** A person can join more than one team on one computer:
  their firm and a personal project, say. Each team keeps its own shared memories and
  its own private memories: a private memory belongs to the team it was saved in, or to
  the team the person moved it to, and only that team sees it or backs it up. To put
  memories in another team, the person opens the Memories tab of the Chiron window,
  with the window on the team that holds them. They select the memories: to select a
  whole source, they filter the Source column to it and tick the header checkbox. Then
  they press "Move N to team…" and pick the team. The button shows only when the
  computer is in another team on the same Chiron server; a team on another server
  cannot take the memories. The move takes the memories that the window counted, so
  memories that an import saves after that stay where they are. A later import in the old team takes the moved documents again, as new memories there. Only their own memories move, private ones and
  shared ones they wrote; an assistant cannot move them. A memory that the old team's
  server holds as another person's goes back to the old team, and the strip says so. They arrive private in the new
  team. They leave the old team: its other computers, teammates' computers included,
  drop them at their next sync. When private backup is on in the new team, a move that
  would take the person's private storage there past its limit is refused before
  anything moves. When backup is off there, the moved memories stay on this computer
  only. A strip in the window shows how far the move got, and then how it ended: how
  many moved and why any stayed. The move goes on after a restart. A moved memory reaches the new team's server only after the old
  team's server lets it go; until then the strip says how many wait for the old team. Assistants use the default team (the first
  team the computer joined, or, after the person leaves it, the first team that
  remains; on a computer in teams before Chiron 0.15.0, the team that was active at
  that update), except in a project folder whose `chiron-config.json` names another team
  (`chiron teams pin "Team name"` in the folder writes it). A session's project
  folder decides its team for the whole session; sessions elsewhere keep the default
  team, and so do Claude Desktop's chats and Cowork tasks (in Desktop's Code tab, the
  Chiron plugin's tools use the project folder's team). If the
  default team loses access while the window shows another team, the window warns
  about it. A
  Connected app (claude.ai, ChatGPT) uses the team chosen when it was connected. A
  `chiron-config.json` in a repository reaches everyone who clones it. The
  assistant cannot choose a team itself. A file that names a team the computer cannot
  use, such as a team it is not in or one whose subscription ended, stops memory in
  that folder; Chiron never uses another team instead. The team switcher in the Chiron
  app and the Chiron menu changes only which team the window shows. To leave a team, the person opens Settings, Team,
  and presses Leave. They can also choose to erase that team's memories from the
  computer, which includes private memories that were never backed up. The owner
  cannot leave: in the admin portal they make someone else the owner, or delete the
  team. Private backup is a choice for each team. `chiron status` counts the memories
  of every team on the computer; the Chiron menu and Settings count only the team the
  window shows. Private
  memories saved before private memory belonged to a team now belong to one team: the
  team with private backup on, or else the team the window showed at the update.
- **Published libraries.** Mad Science publishes libraries of reference material, such
  as game design writing or the reports on a disaster. A team holds at most two. The
  person who makes the team can pick them then, on the page where the computer
  connects or on the offer page; owners and admins pick or change them later on the
  Libraries sheet of the admin portal. A library
  comes to every computer in the team whole, and the assistant recalls it beside the
  team's own memory. Its memories are read-only: nobody in the team owns them, so
  nobody can share, move, stage or delete one. To remove a library, the team drops it.
  Libraries are free: they do not count against private or shared storage. The
  Memories tab of the Chiron window shows library memories with Whose set to Library,
  as view only; a library that has not fully reached the computer shows as "still
  arriving". The admin portal lists the team's libraries on its Libraries sheet.
- **Sharing is a review.** The assistant can stage memories for sharing (the `share`
  tool). The Chiron window usually comes forward on its Suggestions tab (on a computer
  without one, Chiron tries to open the page in a browser tab). The person looks them
  over there and approves them, one at a time or with one approve button for each group. The team's
  sharing policy, set by the owner or an admin, says what belongs in shared memory; the
  app shows it in Settings, Team, where an owner or admin can also change it. The policy
  is optional: sharing works without one. Without one, an assistant that suggests what to
  share follows Chiron's default rule when it calls `share`: work documents such as
  project notes, decisions and plans, never personal or private matters. A reference
  work is shared whole with "Share N" in the Memories tab. Deleting a memory works the
  same way: staged by the assistant (the `delete` tool), or by Chiron for a memory the
  team's server refused to share (see "Credentials are blanked"), and approved by the
  person. A memory made private again disappears from
  teammates at their next sync. A memory moved to another team leaves the Suggestions
  of its old team.

## What it is good for

- **The thing on the tip of the tongue.** "What did the client say about the hotel in
  Lisbon?", "Why did we drop that supplier?", "Who told me about the visa rule change?"
  One question brings back the moment, with who said it and when.
- **Related things, unasked.** While the person works on a topic, memories about the
  same people, places and problems come to mind on their own, including ones they had
  forgotten.
- **Decisions and their reasons.** What was decided, by whom, and why, so a later
  session does not reopen it or contradict it.
- **Continuity across sessions and projects.** The assistant starts the next session
  knowing what the last one learned, in any project.
- **Knowledge across a team.** What one person learned about a client, a tool or a
  process is there for a colleague's assistant too, once shared.
- **Reference material.** Regulations, standards and manuals the team works under,
  imported once or picked from Mad Science's published libraries, come to mind beside
  the team's own experience.

## What it is less good for

- **Exhaustive lists.** "Search all my email and list every message about X" is a
  search job, not a memory job. Recall returns the memories most related to a
  question, not a complete set. Use the source tool's search for a complete list.
- **Counting and totals.** "How many invoices did we send in March?" needs the system
  that holds the invoices.
- **A system of record.** Memory holds moments, not the current state of a file, a
  ticket or a booking. The source stays the source.
- **Long verbatim passages.** Expanding a record gives the moment as it was captured,
  with credentials blanked as "Credentials are blanked" above says; a long record
  comes back in parts, so it fits what every assistant takes in one reply. Memory is
  still not a document store for reading whole files.
- **What was never saved or imported.** A conversation in a tool that was not imported
  is not in memory. New items arrive with the next save or import, not by themselves,
  except on Enterprise with live connectors.

## Plans

- **Free trial.** 14 days, 2 seats, no card. The trial creates the team. Until the
  open beta starts, the site has no sign-up: Mad Science sets teams up one at a time ("Talk
  to us" on chironmemory.com) and sends an offer link. Its page gives a prompt for the
  person's Claude Code, which installs Chiron; the account and the team are created
  when the app connects, and the trial starts then. When the website offers the
  installers, the page gives the downloads instead: the person creates the account
  and names the team on the page, and the trial starts then. Then they install
  Chiron, and the app connects to that team. A team made from an offer gets the
  trial length and the seats that the offer gives, not the standard 14 days and 2 seats.
  An offer is billed monthly or yearly. A monthly offer takes its discount off for the
  months it names; a team that pays yearly instead gets the same value off its first
  yearly invoice. A team made from a yearly offer first subscribes yearly, and the
  discount comes off the first yearly invoice; later, the billing page can switch it
  to monthly billing.
  An invite link works the same way
  for a teammate: its page gives the prompt (a signed-in teammate first sees the button to accept on the page), or, with the installers, the teammate
  accepts on the page and then downloads Chiron. An owner or admin enters the teammate's email address on the admin
  portal's Members and invites sheet, or in the Chiron window (Settings, Team), and
  Chiron emails them the link. The portal and the window also show the link; if the
  email does not go, the owner or admin sends it themselves. The link works for 14 days. A new link for an invite ("New link") is emailed too, at most
  once an hour for each invite. The old link then says it was replaced by a newer one. A teammate also does not need the link: when they connect a computer without a code and sign in with the invited address, the page lists the invite, and "Join <team> with this computer" joins the team and connects the computer in one step. A team can make at most 50 invites in any 24 hours,
  withdrawn ones included. In the open beta, the website makes a limited number of new
  teams each day, counted in UTC (Coordinated Universal Time); a team from an offer is
  not limited. When the day's places are taken, the page offers "Join the waitlist".
  When a place is free, Chiron emails the person a link that opens the new-team form.
  After they start the team, they open Chiron on their computer to connect it. The place
  is held until the end of that day, UTC. If the person does not use it, Chiron holds it
  the next day too and emails again. After that second day, the person leaves the
  waitlist. They can start a team on a day with a free place, or join the waitlist again
  when the day is full.
- **Team.** Priced per person per month, or yearly at a saving; the current price is on
  chironmemory.com/pricing. Each person gets 5M tokens of private backup in each team
  they are in, and the team shares 15M tokens. Recall on every computer (Mac with
  macOS 14 or later, Windows, Linux). Each person imports with their own AI assistant.
  The admin portal manages members, seats,
  devices, the sharing policy and billing. Owners change seats any time; with more
  people than seats, everyone keeps access but nobody new can join. Each team can also
  hold up to two published libraries, which are free.
- **Enterprise.** Set up directly with Mad Science Software. Adds live connectors for
  email (Gmail, Outlook), team chat (Slack, Teams), files (Google Drive, SharePoint),
  project tools and meeting notes, which bring new items in as they arrive; connectors
  built for the team's own systems; guided onboarding; priority support; and limits
  set for the team.
- **At the limit.** When private backup is on and the person's 5M in that team is full,
  new private memories in that team stop saving until they delete private memories in
  the app, move them to another of their teams, or turn backup off. When the team's 15M
  shared pool is full, nothing more can be shared until someone makes memories private,
  deletes them or moves them to another team, or the team talks to Mad Science about Enterprise. A
  token is about four characters; 5M tokens is about 15,000 business emails. Every
  shared memory counts, an imported library as much as a conversation. A published
  library does not count.
- **When the trial or subscription ends**, memory turns off for the assistants. The
  memories stay on each computer and come back when the team subscribes. The team's
  copy on the server (shared memories and private backups) is deleted 30 days after
  the end unless the team subscribes again. The team's owner gets an email 3 days
  before a trial ends, when the trial or subscription ends, and 3 days before the
  deletion date. Without a connection to the server, memory keeps working for 30 days
  after the last sync, with what the computer holds. A pause for a required update has
  no such limit: memory keeps working until the computer updates.
- **Cancelling** is any time, from the billing page; the app keeps the memories it has.
  Each person downloads their memories in the Chiron app (Settings, Account). To delete
  their account, they press "Delete account…" there, then approve in the browser: they
  type their email, and the website asks for a sign-in from the last 5 minutes. The
  request expires after 15 minutes. A person without the app uses the "Delete your
  account" link on the website.

## Where things are

- **The first run** of the Chiron window, for a person who installs from the
  download (on Linux, `~/.chiron/bin/chiron review` opens it in the browser): sign in to the team, connect the AI assistants and run a memory check. An
  owner or admin then invites teammates: Chiron emails each one the link, and the
  window also shows it to send if the email does not go. The owner or admin can also
  write the sharing policy. A teammate sees the team's shared memory arrive and chooses
  which large sources this computer keeps, with each one's size. Settings opens these
  steps again.
- **The Chiron app** on each computer (on Linux, which has no Chiron window,
  `~/.chiron/bin/chiron review` opens the same page in the browser): on a Mac or
  Windows, the menu bar or tray icon
  shows the memory count of the team the window shows and
  its memories staged for review, opens the
  Chiron window, connects the computer to its team or adds another, changes which of the teams it joined the window shows, offers
  updates, opens the logs, and stops and starts memory. The window has three tabs.
  Memories is a sheet of every memory in the team the window shows: the person's own, teammates' shared
  ones and the team's libraries, with the columns Memory, Whose, Visibility, Source,
  Date and Size. The person can also move their own memories to another of their teams
  there; a strip shows the progress of the move. Suggestions holds what the assistant staged for sharing or deletion,
  and the memories that Chiron staged for deletion because the team's server refused to
  share them.
  Settings has seven sections: Team (the sharing policy, which an owner or admin
  can change; invites, for an owner or admin; add or leave a team), Storage (the
  private backup switch), AI assistants, Devices, This computer (version, the memory
  count of the team the window shows, embedding model, last sync, a memory check, what memory takes on
  disk, and the copies of teammates' shared memories), Account (download memories, sign
  out, delete the account) and Help (Contact Mad Science Software, with the support
  address and the support page, and Report a problem). Sign out disconnects this
  computer from every team: the person stays in the teams, the memories stay on the
  computer, and they show again when the person signs in to the same team. Until then
  no team is active: the Chiron menu and Settings count only memories saved before the
  computer joined a team (usually 0), and `chiron status` still counts them all.
  The assistant mentions a new version once and offers to install it (`chiron update`).
  For 3 days after an update, the assistant is told to call the `get_changelog` tool,
  which lists what changed for it.
  After some updates the app builds its search graph and the window's search index
  in the background. After a large import, its memories join the search graph the
  same way. Recall and search work meanwhile, only slower. The update that adds credential blanking also rebuilds the memory file
  once as the app starts, so that start takes longer on a large memory. An update that
  upgrades the memory store first saves a copy of it; with too little free disk space,
  Chiron says how much it needs, and memory stays as it was. While the upgrade runs, the
  Chiron menu or tray says "Chiron is upgrading its memory store…" (on a Mac, the window
  says it too; on Windows, the window opens when the upgrade ends), and the person keeps
  Chiron running. This happens once after the update and can take a few minutes on a
  large store.
  Mad Science can require a newer Chiron for a team, for example before its memory grows
  large: an older computer then pauses sync until it updates, keeps the memory it holds,
  and the assistant says so once. `chiron backup` writes a backup file.
- **The admin portal** at chironmemory.com, for owners and admins: a sheet each for
  the overview, members and invites, devices, the sharing policy, the team's published
  libraries, connectors, billing and team settings. A member sees one card there instead: how to
  install Chiron and how to connect a website such as claude.ai. Sharing, deleting,
  moving and downloading memories, leaving the team, signing out and deleting the account
  happen in the Chiron app. A person who no longer has the app can delete their account from the
  "Delete your account" link on the card, or in the portal's Account menu. Copies on
  their computers then stay there until they remove Chiron.
- **Connected apps**, in early access: claude.ai and ChatGPT reach the same memory
  through a connector address from the website's "Connect a website" card. For them recall runs on Chiron's server,
  and they can recall and read, not save, change or share.
- **Assistants**: Claude Code, Claude Desktop (chat and Cowork), Codex CLI, Gemini CLI,
  and any other assistant on the computer that supports the Model Context Protocol
  (MCP). Cowork uses memory in sessions on the computer, not in cloud sessions started
  from the web or phone.

Chiron is in beta. Anything that breaks, feels off or surprises the person is
worth a report: in the Chiron window, Settings, then Help, under Report a problem. Or they
email inquiries@madsciencesoftware.dev, or see https://chironmemory.com/support. Never
put their memories in it. If Settings has no Help section, Chiron is older: run
`chiron update`, or email instead.
