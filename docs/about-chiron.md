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
  whole record.
- **Who said what, and when.** Every memory carries its authors and its date. A memory
  says that someone said or did something on that day, not that it is true. A mistake
  or a change of mind is a newer memory, and the assistant weighs them by date.
- **Recall is automatic in Claude Code, Codex CLI and Gemini CLI.** Related memories
  come to mind with every message the person sends. In Claude Desktop (chat and Cowork)
  and the Connected apps (claude.ai, ChatGPT), the assistant recalls when it judges
  memory may help, and "check your memory" always works. Cues are matched in English:
  the assistant translates a question in another language before it recalls.
- **Saving.** The assistant saves when the person asks ("remember that…", "save what
  we decided"), and when something worth keeping comes up: a decision and its reason,
  a change of mind, a lesson. It asks before it keeps anything personal.
- **Importing.** History comes in through imports run by the person's own assistant:
  past Claude Code sessions, git repositories, email exports, chat exports, reference
  material. A memory plan, made when Chiron was installed, says what to import; "bring
  memory up to date" runs it again for what is new.
- **Private first.** Everything a person saves or imports is private to them and stays
  on their computer. Private backup, a switch in the Chiron app, keeps a copy on the
  team's server for their other devices and the Connected apps. Someone who leaves a
  team, or is removed, loses their private backups from the server; what they shared
  stays with the team.
- **Sharing is a review.** The assistant can stage memories for sharing; the person
  looks them over in the Chiron app (Review and share) and confirms. The team's sharing
  policy, set by the owner, says what belongs in shared memory. Deleting a memory works
  the same way: staged by the assistant, confirmed by the person. A memory made private
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
  imported once, come to mind beside the team's own experience.

## What it is less good for

- **Exhaustive lists.** "Search all my email and list every message about X" is a
  search job, not a memory job. Recall returns the memories most related to a
  question, not a complete set. Use the source tool's search for a complete list.
- **Counting and totals.** "How many invoices did we send in March?" needs the system
  that holds the invoices.
- **A system of record.** Memory holds moments, not the current state of a file, a
  ticket or a booking. The source stays the source.
- **Long verbatim passages.** Expanding a record gives the moment as it was captured,
  but memory is not a document store for reading whole files.
- **What was never saved or imported.** A conversation in a tool that was not imported
  is not in memory. New items arrive with the next save or import, not by themselves,
  except on Enterprise with live connectors.

## Plans

- **Free trial.** 14 days, 2 seats, no card. The trial creates the team. During the
  private beta the site has no sign-up: Mad Science sets teams up one at a time ("Talk
  to us" on chironmemory.com), and the trial starts then.
- **Team.** Priced per person per month, or yearly at a saving; the current price is on
  chironmemory.com/pricing. Each person gets 5M tokens of private backup, and the team
  shares 15M tokens. Recall on every computer (Mac, Windows, Linux). Each person
  imports with their own AI assistant. The owner dashboard manages members, seats,
  devices, the sharing policy and billing. Owners change seats any time; with more
  people than seats, everyone keeps access but nobody new can join.
- **Enterprise.** Set up directly with Mad Science Software. Adds live connectors for
  email (Gmail, Outlook), team chat (Slack, Teams), files (Google Drive, SharePoint),
  project tools and meeting notes, which bring new items in as they arrive; connectors
  built for the team's own systems; guided onboarding; priority support; and limits
  set for the team.
- **At the limit.** When private backup is on and the person's 5M is full, new private
  memories stop saving until they delete private memories in the app or turn backup
  off. When the team's 15M shared pool is full, nothing more can be shared until
  someone unshares memories, or the team talks to Mad Science about Enterprise. A
  token is about four characters; 5M tokens is about 15,000 business emails.
- **When the trial or subscription ends**, memory turns off for the assistants. The
  memories stay on each computer and come back when the team subscribes. The team's
  copy on the server (shared memories and private backups) is deleted 30 days after
  the end unless the team subscribes again. Without a connection to the server, memory
  keeps working for 30 days after the last sync.
- **Cancelling** is any time, from the billing page; the app keeps the memories it has.
  The dashboard's account page can download a person's memories and delete their
  account.

## Where things are

- **The Chiron app** on each computer: the menu bar or tray icon shows the memory
  count and the memories staged for review, opens Review and share, connects the
  computer to its team, offers updates, opens the logs, and stops and starts memory.
  The assistant mentions a new version once and offers to install it; `chiron backup`
  writes a backup file.
- **The dashboard** at chironmemory.com: members, seats, devices, sharing policy,
  billing, and a view of shared memories and one's own private backups, where a
  person can delete their own memories (owners and admins any shared one). Sharing
  and unsharing happen in the Chiron app.
- **Connected apps**, in early access: claude.ai and ChatGPT reach the same memory
  through a connector the dashboard sets up. For them recall runs on Chiron's server,
  and they can recall and read, not save, change or share.
- **Assistants**: Claude Code, Claude Desktop (chat and Cowork), Codex CLI, Gemini CLI,
  and any other assistant on the computer that supports the Model Context Protocol
  (MCP). Cowork uses memory in sessions on the computer, not in cloud sessions started
  from the web or phone.

Chiron is in private beta. Anything that breaks, feels off or surprises the person is
worth an email to james@madsciencesoftware.dev, never with their memories in it.
