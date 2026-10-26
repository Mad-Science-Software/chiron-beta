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
  always private, in the team memory is in: the assistant cannot write into the team's
  shared memory. To give the team a
  memory, it stages it for sharing and the person confirms in the Chiron app.
- **Importing.** History comes in through imports run by the person's own assistant:
  past Claude Code sessions, git repositories, email exports, chat exports, reference
  material. A memory plan, made when Chiron was installed, says what to import; "bring
  memory up to date" runs it again for what is new.
- **Private first.** Everything a person saves or imports is private to them, in the
  team memory is in, and stays on their computer. Chiron sends only a count of the
  private memories that are not backed up, with no content; Mad Science staff can see
  that count, and team owners and admins cannot. Private backup, a switch in the Chiron
  app (Settings, then Storage), keeps a copy on the team's server for their other
  devices and the Connected apps; the app asks before it turns on. Someone who leaves a
  team, or is removed, loses their private backups from the server; what they shared
  stays with the team.
- **Copies of shared sources.** The team's shared memory comes to every member's
  computer, grouped by source (a mailbox, a repository, an imported library). In the
  Chiron window, Settings, This computer, "Teammates' shared memories" lists each source
  with a "Keep a copy here" switch, which keeps or removes its copy on this computer;
  the app says what the copy takes first, and the copy arrives, or goes, at the next
  sync. The choice is this computer's, for the team memory is in. A source without a
  copy stays on the team's server: the Memories tab still shows it, with a "server
  only" tag, but the assistant cannot recall it on this computer until a copy is kept. A person's own memories always stay on the computer.
- **One person, several teams.** A person can join more than one team on one computer:
  their firm and a personal project, say. Each team keeps its own shared memories and
  its own private memories: a private memory belongs to the team that memory was in
  when it was saved, and only that team sees it or backs it up. Memory works in one
  team at a time. The person switches in the Chiron app, the Chiron menu, or with
  `chiron switch`; the assistant can ask to switch (the `switch_team` tool), and the
  person confirms in the Chiron app. To leave a team, the person opens Settings, Team,
  and presses Leave. They can also choose to erase that team's memories from the
  computer, which includes private memories that were never backed up. The owner
  cannot leave: in the admin portal they make someone else the owner, or delete the
  team. Private backup is a choice for each team. Private
  memories saved before private memory belonged to a team now belong to one team: the
  team with private backup on, or else the team memory was in at the update.
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
- **Sharing is a review.** The assistant can stage memories for sharing; the person
  looks them over in the Suggestions tab of the Chiron window and approves them, one
  at a time or with one approve button for each group. The team's sharing policy, set
  by the owner, says what belongs in shared memory; the app shows it in Settings,
  Team. Deleting a memory works
  the same way: staged by the assistant, approved by the person. A memory made private
  again disappears from teammates at their next sync.

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
- **Long verbatim passages.** Expanding a record gives the moment as it was captured;
  a long record comes back in parts, so it fits what every assistant takes in one
  reply. Memory is still not a document store for reading whole files.
- **What was never saved or imported.** A conversation in a tool that was not imported
  is not in memory. New items arrive with the next save or import, not by themselves,
  except on Enterprise with live connectors.

## Plans

- **Free trial.** 14 days, 2 seats, no card. The trial creates the team. During the
  private beta the site has no sign-up: Mad Science sets teams up one at a time ("Talk
  to us" on chironmemory.com) and sends an offer link. Its page gives a prompt for the
  person's Claude Code, which installs Chiron; the account and the team are created
  when the app connects, and the trial starts then. An invite link works the same way
  for a teammate.
- **Team.** Priced per person per month, or yearly at a saving; the current price is on
  chironmemory.com/pricing. Each person gets 5M tokens of private backup in each team
  they are in, and the team shares 15M tokens. Recall on every computer (Mac, Windows,
  Linux). Each person imports with their own AI assistant. The admin portal manages members, seats,
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
  the app or turn backup off. When the team's 15M shared pool is full, nothing more can be shared until
  someone makes memories private or deletes them, or the team talks to Mad Science about Enterprise. A
  token is about four characters; 5M tokens is about 15,000 business emails. Every
  shared memory counts, an imported library as much as a conversation. A published
  library does not count.
- **When the trial or subscription ends**, memory turns off for the assistants. The
  memories stay on each computer and come back when the team subscribes. The team's
  copy on the server (shared memories and private backups) is deleted 30 days after
  the end unless the team subscribes again. Without a connection to the server, memory
  keeps working for 30 days after the last sync, with what the computer holds. A
  pause for a required update has no such limit: memory keeps working until the
  computer updates.
- **Cancelling** is any time, from the billing page; the app keeps the memories it has.
  Each person downloads their memories in the Chiron app (Settings, Account). To delete
  their account, they press "Delete account…" there, then approve in the browser: they
  type their email, and the website asks for a sign-in from the last 5 minutes. The
  request expires after 15 minutes. A person without the app uses the "Delete your
  account" link on the website.

## Where things are

- **The Chiron app** on each computer: the menu bar or tray icon shows the memory
  count and the memories staged for review, opens the Chiron window, connects the
  computer to its team or adds another, switches between the teams it joined, offers
  updates, opens the logs, and stops and starts memory. The window has three tabs.
  Memories is a sheet of every memory in the team: the person's own, teammates' shared
  ones and the team's libraries, with the columns Memory, Whose, Visibility, Source,
  Date and Size. Suggestions holds what the assistant staged for sharing or deletion.
  Settings has six sections: Team (sharing policy, add or leave a team), Storage (the
  private backup switch), AI assistants, Devices, This computer (version, memory count,
  embedding model, last sync, a memory check, what memory takes on disk, and the
  copies of teammates' shared memories) and Account (download memories, delete the
  account).
  The assistant mentions a new version once and offers to install it (`chiron update`).
  After some updates the app rebuilds its search graph and the window's search index
  in the background; recall and search work meanwhile, only slower. An update that
  upgrades the memory store first saves a copy of it; with too little free disk space,
  Chiron says how much it needs, and memory stays as it was.
  Mad Science can require a newer Chiron for a team, for example before its memory grows
  large: an older computer then pauses sync until it updates, keeps the memory it holds,
  and the assistant says so once. `chiron backup` writes a backup file.
- **The admin portal** at chironmemory.com, for owners and admins: a sheet each for
  the overview, members and invites, devices, the sharing policy, the team's published
  libraries, connectors, billing and team settings. A member sees one card there instead: how to
  install Chiron and how to connect a website such as claude.ai. Sharing, deleting
  and downloading memories, leaving the team and deleting the account happen in the
  Chiron app. A person who no longer has the app can delete their account from the
  "Delete your account" link on the card, or in the portal's Account menu. Copies on
  their computers then stay there until they remove Chiron.
- **Connected apps**, in early access: claude.ai and ChatGPT reach the same memory
  through a connector address from the website's "Connect a website" card. For them recall runs on Chiron's server,
  and they can recall and read, not save, change or share.
- **Assistants**: Claude Code, Claude Desktop (chat and Cowork), Codex CLI, Gemini CLI,
  and any other assistant on the computer that supports the Model Context Protocol
  (MCP). Cowork uses memory in sessions on the computer, not in cloud sessions started
  from the web or phone.

Chiron is in private beta. Anything that breaks, feels off or surprises the person is
worth an email to james@madsciencesoftware.dev, never with their memories in it.
