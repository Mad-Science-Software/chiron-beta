# Importing from a source Chiron doesn't support yet

This guide is for the AI agent (Claude Code) helping a user import history from a source
with no built-in importer (Slack, Microsoft Teams, Notion, a notes folder, a CRM export…).
Read [`docs/ingestion.md`](ingestion.md) first: this guide only replaces its step 1.

You write a small **converter** that turns the source into conversations, then hand
those to `chiron ingest documents`, which validates them, skips anything already stored, and
writes the same documents and batch lists the built-in importers do. From there the
normal sub-agent workflow takes over. You don't change Chiron's code.

## Ground rules

- **Get the data as an export the user downloads**, not through a live connection. Most
  tools offer one (Slack: Workspace settings → Import/Export Data; Notion: Export; Teams:
  Microsoft's data export). If only an API is available, explain what token it needs and
  what it can read, and let the user decide. Never put a token in a file inside `~/chiron-ingest`
  or in the converter itself. The one exception is the Gmail connector built into the
  person's Claude ("Email through the Claude Gmail connector", below): it needs no token
  in a file.
- **Everything stays on this computer.** Work in `~/chiron-ingest/<source>/`. Don't upload
  the data anywhere or paste large parts of it into the conversation.
- **Agree on scope first**: which channels, folders or date range. Less is better; the user
  can import more later, and reruns skip what's stored. Private conversations (direct
  messages, private channels) are out of scope unless the user names them explicitly;
  "all channels" doesn't include them.
- **Write the converter in a language this computer already has.** Do not make the
  user install anything for it. Check what is there, for example `python3 --version`,
  `node --version` or `perl -v`. Every Windows computer has PowerShell. Python 3 with
  only its standard library is a good choice when it is installed, but it is not
  necessary. If every option needs an install, tell the user and let them decide.
- **Save the converter** as `~/chiron-ingest/<source>/convert` with the usual file
  extension for its language (for example `convert.py` or `convert.ps1`). Then you can
  run it again later for new data. Give it options to limit what it converts (e.g.
  `--channels`, `--limit`) for the trial run.

## The conversation format

The converter writes `conversations.jsonl`: one JSON object per line, one per
**conversation**, with its messages. Chiron renders the readable text itself, so every
source looks the same to the agents.

| Field | Meaning |
|---|---|
| `conversation_id` | Stable, unique id built from the source's own ids: `<source>:<account>:<native id>`, e.g. `slack:T024BE7LD:C024BE91L:1696160000.000200` (workspace id, not its name). The same conversation must get the same id on every run, or it will be stored twice. Must not contain `#`. |
| `source` | Where it came from, e.g. `slack:acme`. Shown with every memory. |
| `subject` | Short title built mechanically, e.g. `#launch thread: Pricing page copy is ready for…` (the first ~60 characters of the opening message) or `#general on 2026-09-30`. |
| `messages` | Every message in the conversation so far, at least one, each `{"at", "from", "text"}` (optionally `"to"` and `"cc"`, each one string of addresses separated by commas, not a list): `at` an RFC 3339 timestamp, best in UTC (`2026-09-30T14:05:00Z`), `from` the sender's real name (resolve user ids), never empty. Messages are sorted by `at`, so their order in the file does not matter. |

**Always write the whole conversation**, including messages imported before. Chiron
keeps track of what it already holds: on a rerun, a conversation that gained replies
gets a follow-up document with only the new messages, and one with nothing new is
skipped. Long conversations are split into parts automatically.

Make the text readable: mentions as `@Name`, channel links as `#name`, links as
`label (url)`, and decode HTML escapes (`&amp;`, `&lt;`, `&gt;`).

**Choose the conversation unit** so each one is coherent:

- A thread (a message and its replies) is one conversation.
- Messages outside threads: group a channel's messages by day.
- Skip noise: bot and integration messages, joins and leaves, reactions, empty messages.

## Steps

1. Agree on the source, scope and export with the user, and have them download it.
   With a memory plan ([`docs/memory-plan.md`](memory-plan.md)), the plan is this
   agreement: take the scope and the export's location from it.
2. Look at the export's structure (a few files, not all of it) and write the converter.
3. Run it on a small slice first, import that slice (step 4 with `--limit 2`), and show
   the user the two rendered documents it writes. Check names are resolved, timestamps
   are right, and the list of conversations it read contains only what was agreed
   (print it). With a memory plan, make these checks yourself and go on.
4. Run it on the agreed scope, then import:

   ```sh
   OUT="$HOME/chiron-ingest/<source>/out"
   ~/.chiron/bin/chiron ingest documents --in "$HOME/chiron-ingest/<source>/conversations.jsonl" --out "$OUT"
   ```

   It stops at the first invalid line and says what's wrong; fix the converter and rerun.
5. Continue with step 2 of [`docs/ingestion.md`](ingestion.md): a sample batch first, then
   one sub-agent per batch.
6. When finished, delete the export and `out/` (they hold private data) but keep
   the converter for future imports, and tell the user the Chiron team would welcome it
   as a starting point for a built-in importer.

## Email through the Claude Gmail connector

When the person's Claude has the Gmail connector, new mail needs no Takeout export:
Claude searches the connector for threads since the last run (for example
`after:2026/10/07 (category:primary OR in:sent OR is:important)`), fetches each thread
as plain text, and writes the conversation file itself. One conversation per thread:
`conversation_id` is `gmail:<mailbox>:<thread id in decimal>`. The connector's thread
`id` is hexadecimal; convert it (`printf '%d' 0x<id>`), which gives the same digits as
`thread-f:` in the thread's URL and the `X-GM-THRID` of a Takeout export, so a thread
stored before gets only its new messages. `source` is `gmail:<mailbox>`; `from` is the
sender as the connector gives it (name and address when it has both), as the Takeout
import does; `text` is the body with the quoted earlier messages, signatures and
unsubscribe footers removed.
Skip threads where every sender is automated (invoices, notifications, newsletters).
A sub-agent can do the fetching when it has the connector's tools. The connector reaches
only the account it is connected to; other mailboxes still need an export.

## Reference works

A regulation, a standard, a textbook or a manual is a **library**: `source` is
`library:<name>` (`library:eu-ai-act`), and each section is one conversation with one
message. `conversation_id` is `library:<name>:<stable id>` built from the work's own
structure (the article number, the chapter and section number). `subject` is the
section's number and title (`Article 5: Prohibited AI practices`). The message has
`from` the plan's Credit line (the author or the publishing body as printed), `at` the
publication date as an RFC 3339 timestamp in UTC (`2024-06-13T00:00:00Z` for the act's
date; 1 January for a work dated only by year), and `text` the section's text.

The work holds no private data, so you download it yourself: `curl -fsSL -o` from the
link in the plan's Scope line into `~/chiron-ingest/<source>/`, and it can stay there
afterwards. Prefer the HTML or EPUB edition. For a PDF, use `pdftotext -layout` when it
is installed; if nothing on this computer reads PDF, tell the user and let them decide,
as the ground rules say. Keep headings, lists and tables readable, and drop page headers
and footers. Long sections are split automatically. A library carries nothing personal,
so the plan usually gives it `Share: all`: imported private, then staged for the user's
review like any import.

## Example: Slack

A Slack export is a folder (unzipped) containing:

- `users.json`: user objects; map `id` to `real_name` (or `profile.real_name`, then `name`).
- `channels.json`: `id` and `name` for each public channel. Private conversations, if the
  export has them, are in `groups.json`, `dms.json` and `mpims.json`; leave them out
  unless the user asked for them. Direct-message folders are named by id, not by name.
- One folder per channel, named after it, with one file per day (`2026-09-30.json`, the
  workspace's local date), each a JSON array of messages.

Each message has `ts` (seconds since 1970 as a string, also its id within the channel),
`user`, `text`, and for threads `thread_ts` (the parent's `ts`; the parent itself has
`thread_ts` equal to its own `ts`). Replies can sit in later day files, so group threads
across all of a channel's files.

- **Skip** bots (messages with a `bot_id`, or from users marked `is_bot`) and messages
  whose `subtype` is housekeeping (`channel_join`, `channel_leave`, `channel_topic`,
  `bot_message`, …). Keep the subtypes that are real content: `thread_broadcast`,
  `file_share`, `me_message`.
- **Text** marks mentions as `<@U024BE7LH>`, channels as `<#C024BE91L|launch>`, links as
  `<https://example.com|label>`, and group mentions as `<!here>`, `<!channel>` or
  `<!subteam^S123|@team>`.

- **Thread conversations**: group by `thread_ts`; `conversation_id`
  `slack:<workspace id>:<channel id>:<thread_ts>`.
- **Day conversations** for unthreaded messages: `conversation_id`
  `slack:<workspace id>:<channel id>:<YYYY-MM-DD>`, using the day file's name.
- Convert each message's `ts` to RFC 3339 UTC for `at`.
