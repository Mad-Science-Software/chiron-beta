# Importing from a source Chiron doesn't support yet

This guide is for the AI agent (Claude Code) helping a user import history from a source
with no built-in importer (Slack, Microsoft Teams, Notion, a notes folder, a CRM export…).
Read [`docs/ingestion.md`](ingestion.md) first: this guide only replaces its step 1.

You write a small **converter** that turns the source into conversations, then hand
those to `ingest-documents`, which validates them, skips anything already stored, and
writes the same documents and batch lists the built-in importers do. From there the
normal sub-agent workflow takes over. You don't change Chiron's code.

## Ground rules

- **Get the data as an export the user downloads**, not through a live connection. Most
  tools offer one (Slack: Workspace settings → Import/Export Data; Notion: Export; Teams:
  Microsoft's data export). If only an API is available, explain what token it needs and
  what it can read, and let the user decide. Never put a token in a file inside `~/chiron`
  or in the converter itself.
- **Everything stays on this computer.** Work in `~/chiron-ingest/<source>/`. Don't upload
  the data anywhere or paste large parts of it into the conversation.
- **Agree on scope first**: which channels, folders or date range. Less is better; the user
  can import more later, and reruns skip what's stored. Private conversations (direct
  messages, private channels) are out of scope unless the user names them explicitly;
  "all channels" doesn't include them.
- **Write the converter in Python with only the standard library**, saved as
  `~/chiron-ingest/<source>/convert.py`, so it can be rerun later for new data. Give it
  options to limit what it converts (e.g. `--channels`, `--limit`) for the trial run.

## The conversation format

The converter writes `conversations.jsonl`: one JSON object per line, one per
**conversation**, with its messages. Chiron renders the readable text itself, so every
source looks the same to the agents.

| Field | Meaning |
|---|---|
| `conversation_id` | Stable, unique id built from the source's own ids: `<source>:<account>:<native id>`, e.g. `slack:T024BE7LD:C024BE91L:1696160000.000200` (workspace id, not its name). The same conversation must get the same id on every run, or it will be stored twice. Must not contain `#`. |
| `source` | Where it came from, e.g. `slack:acme`. Shown with every memory. |
| `subject` | Short title built mechanically, e.g. `#launch thread: Pricing page copy is ready for…` (the first ~60 characters of the opening message) or `#general on 2026-09-30`. |
| `messages` | Every message in the conversation so far, each `{"at", "from", "text"}` (optionally `"to"` and `"cc"`): `at` an RFC 3339 timestamp in UTC (`2026-09-30T14:05:00Z`), `from` the sender's real name (resolve user ids). |

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
2. Look at the export's structure (a few files, not all of it) and write `convert.py`.
3. Run it on a small slice first, import that slice (step 4 with `--limit 2`), and show
   the user the two rendered documents it writes. Check names are resolved, timestamps
   are right, and the list of conversations it read contains only what was agreed
   (print it).
4. Run it on the agreed scope, then import, from `~/chiron`:

   ```sh
   cd ~/chiron
   OUT="$HOME/chiron-ingest/<source>/out"
   docker compose --profile ingest run --rm -v "$HOME/chiron-ingest:$HOME/chiron-ingest" \
     ingest ingest-documents --in "$HOME/chiron-ingest/<source>/conversations.jsonl" --out "$OUT"
   ```

   It stops at the first invalid line and says what's wrong; fix the converter and rerun.
5. Continue with step 2 of [`docs/ingestion.md`](ingestion.md): a sample batch first, then
   one sub-agent per batch.
6. When finished, delete the export and `out/` (they hold private data) but keep
   `convert.py` for future imports, and tell the user the Chiron team would welcome it
   as a starting point for a built-in importer.

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
