# Importing from a source Chiron doesn't support yet

This guide is for the AI agent (Claude Code) helping a user import history from a source
with no built-in importer: Slack, Microsoft Teams, Notion, meeting notes, a folder of
documents, a CRM export, and so on. Read [`docs/ingestion.md`](ingestion.md) first. This
guide replaces its step 1 and the clean-up in its step 3.

You write a small **converter** that turns the source into conversations. Then
`chiron ingest documents` checks them, skips what the folder's team stores already, and
writes the same documents and batch lists as the built-in importers. From there, the
normal sub-agent workflow takes over. You don't change Chiron's code.

## Ground rules

- **Get the data as an export the user downloads**, not through a live connection. Most
  tools offer one (Slack: Workspace settings → Import/Export Data; Notion: Export; Teams:
  Microsoft's data export). If only an API is available, explain what token it needs and
  what it can read, and let the user decide. Never put a token in a file inside
  `~/chiron-ingest` or in the converter. The one exception is the Gmail connector built into
  the person's Claude ("Email through the Claude Gmail connector", below): it needs no token
  in a file.
- **Everything stays on this computer.** Work in `~/chiron-ingest/<folder>/`, where
  `<folder>` is a plain name such as `slack` or `slack-acme`. Don't upload the data
  anywhere or paste large parts of it into the conversation.
- **Agree on the scope first**: which channels, folders, meetings or records, and which
  dates. Less is better: the user can import more later, and a rerun skips what this team
  stores.
- **Private is out unless the user names it.** Leave these out, and ask the user before you
  include them:
  - direct messages, group messages and private channels ("all channels" doesn't include them),
  - one-to-one meetings and calls (see "Meetings and calls" below),
  - sensitive folders, such as contracts, HR, health or personal folders,
  - personal contact details, such as phone numbers, home addresses and email addresses
    in a CRM or an address book. Names and job titles are fine.
- **Write the converter in a language this computer already has.** Don't make the user
  install anything for it. Check what is there, for example `python3 --version`,
  `node --version` or `perl -v`. Every Windows computer has PowerShell. Python 3 with only
  its standard library is a good choice when it is installed.
- **Save the converter** as `~/chiron-ingest/<folder>/convert` with the usual file
  extension for its language (for example `convert.py`). Then you can run it again later
  for new data. Give it these options:
  - `--out FILE`: it writes the conversations there itself, as UTF-8 with no byte order
    mark. (A shell redirect such as PowerShell's `>` can write UTF-16, which the import
    refuses.)
  - `--only PART`, which picks one part (a channel, a folder, a record or an id), and
    `--limit N`, for the trial.

  It prints one line per conversation (id and subject), then each item it skipped, with
  the reason.
- **Use absolute paths** in every command. A relative path breaks after `cd` to the project
  folder.

## Name the source

`source` is `<product>:<label>`. The Chiron window shows it as "Product · label", as a
source of its own that the user can back up. Show the user the `source` you chose.

- **Before the colon**, use the product's name in lower case: `slack`, `teams`, `notion`,
  `hubspot`, `otter`. If the export doesn't name the tool it came from, ask the user. Use a
  general word only when there is no product: `meetings`, or `documents` for a folder of
  files. Chiron's own importers use some names: don't use `mbox`, `git`, `claude-code` or
  `note`. Use `gmail` only for the Gmail connector, `library` only for reference works,
  and `documents` only for a folder of files.
- **After the colon**, use a stable label for the account: the workspace or company name,
  or the account's domain, such as `acme-corp` or `acme.example`. Use lower case, and no
  spaces or `@ / : (`, because Chiron cuts the label there. If the export has no account
  name, agree a short fixed label with the user. Never use the export's folder name: it
  changes on each download.

Keep `source` the same on every run. A changed `source` makes a new source in the window.

`conversation_id` is `<product>:<account id or the same label>:<native id>`. The native id
is the source's own id for the conversation: a thread's timestamp, a meeting id, a page id,
a record id. When the source has no id, use the file's path relative to the export's top
folder, with `/` between folders and `#` replaced by `-`. Never use a row number or the
order of the files: they change when the export changes. The id must not contain `#`.

## The conversation format

The converter writes one JSON object per line, one per **conversation**, with its
messages. Chiron renders the readable text itself, so every source looks the same to the
agents.

| Field | Meaning |
|---|---|
| `conversation_id` | Stable and unique (see "Name the source"). The same conversation must get the same id on every run, or Chiron stores it twice. |
| `source` | `<product>:<label>` (see "Name the source"). Shown with every memory. |
| `subject` | A short title, built the same way every time. Use the source's title when it has one (a page title, a deal name, a meeting title with its date). Otherwise use the first ~60 characters of the opening message, such as `#launch thread: Pricing page copy is ready for…`, or `#general on 2026-09-30`. Two conversations can have the same subject: the id tells them apart. A generic title that repeats (such as "Meeting notes") gets its parent's title, the same on every run: "Meeting notes (in Launch plan)". |
| `messages` | Every message in the conversation so far, at least one, each `{"at", "from", "text"}`. Optional: `"to"` and `"cc"`, each one string of addresses separated by commas, not a list. Chiron sorts messages by `at`. |

**`from`** is never empty. Use the sender's real name (resolve user ids). If the source
gives only a name or an address, use it as it is. If the source names no person, use the
label the source uses (such as "Speaker 3") or a neutral label that says what the text is
(such as "Meeting notes (summary)" or "CRM record"). Never credit a person who didn't
write the text.

**`at`** is an RFC 3339 timestamp, best in UTC (`2026-09-30T14:05:00Z`). Take it from the
source's own date. If there is none, use the file's modified time, and tell the user that
a copied folder shows the copy time. Read a date with no time zone as UTC, and tell the
user. A date with no time gets midnight.

**Always write the whole conversation**, including messages imported before. Chiron keeps
track of what it holds: on a rerun, a conversation that gained messages gets a follow-up
document with only the new ones, and one with nothing new is skipped. Chiron splits long
conversations into parts.

**Make the text readable.** Remove HTML tags, then decode HTML escapes (`&amp;`, `&lt;`,
`&gt;`). Write mentions as `@Name`, channel links as `#name`, and links as `label (url)`.
Leave text that is already readable as it is.

## Choose the conversation unit

Each conversation must be coherent and read well alone. Use the source's own structure:

- **Chat**: a thread (a message and its replies) is one conversation. Group the messages
  outside threads by channel and day. A thread's first message belongs only to its thread,
  not also to its day.
- **Meetings and calls**: one meeting is one conversation, with the subject
  `<title> (<date>)`. Each turn of a speaker is one message: join the consecutive lines of
  the same speaker. `at` is the meeting's start plus the line's offset. Use the transcript
  when there is one. For a meeting with no transcript, use the summary's overview and
  action items, with a neutral `from`. A meeting is one-to-one when it has exactly two
  attendees: count the unnamed speakers and the guests too. A "1:1" title with more
  attendees is a group meeting. When the signs disagree, ask the user once, with the list.
- **Pages and documents** (wiki pages, notes, files): one page or file is one conversation
  with one message. `from` is the page's author or owner. `at` is its last change, so an
  edited page comes back on a rerun as a follow-up. A database whose rows are also pages:
  import each row once, as its page, and add the row's other columns to the top of its
  text. When the rows come in a separate table (such as a CSV file), join each row to its
  page on more than its name, because names can repeat. Of files that are byte for byte
  the same, read one. A page is empty only when it has no text and no properties: a row
  page with only properties has content. Skip empty pages and list them for the user.
- **Records** (a CRM, a ticket system): one conversation per parent record (a deal, a case),
  with its notes as messages.
  - **The record's own fields** (name, stage, amount, owner, and its company's fields) go in
    a first message from "CRM record" or a similar label, because the owner didn't write it.
    Leave out empty fields. Its `at` is the record's creation date. If there is none, use
    the earliest stable date in the record, or one fixed date, so the message never moves on
    a rerun, and tell the user.
  - **Notes that belong to no parent** go in one conversation for their company or
    account. A company gets a conversation only when it has such notes.
  - **People** (contacts) are not conversations. Name each person with their job title in
    the notes about them, and leave out their phone numbers and email addresses. Tell the
    user.
  - Each note appears once. Tell the user whether you kept records with no notes.
- **Skip noise**: bot and integration messages, joins and leaves, reactions, empty
  messages, and files the user's tools make (`.DS_Store`, `~$` lock files).

## Reading files

Use tools that the computer already has:

- **PDF**: `pdftotext -layout file.pdf -` when it is installed. If nothing on the computer
  reads PDF, tell the user and let them decide.
- **Word (`.docx`)**: it is a zip file. Read `word/document.xml` (with `unzip -p` or the
  language's zip library) and join the text of its `<w:t>` elements, one paragraph per
  `<w:p>`.
- **A scanned PDF** has no text. It needs OCR, which is out of scope. Don't store it empty.

List every file that you skipped or could not read, with the reason, and show the list to
the user.

## Steps

Set these once. All paths are absolute:

```sh
SRC="$HOME/chiron-ingest/<folder>"   # the converter and its output
PROJECT="<project folder>"           # this session's project folder; it decides the team
```

The commands below run a Python converter. For another language, use the command for that
language.

1. **Agree** on the source, the scope and the export with the user, and have them download
   it. A folder that is already on this computer needs no download. With a memory plan
   ([`docs/memory-plan.md`](memory-plan.md)), the plan is this agreement: take the scope and
   the export's location from it.
2. **Write the converter.** Look at the export's structure first (a few files, not all of
   it).
3. **Try a small slice**, in its own output folder, so it doesn't mix with the full run.
   Choose a slice that shows the main case, not only the first items in the file:

   ```sh
   python3 "$SRC/convert.py" --only <one part> --limit 2 --out "$SRC/trial.jsonl"
   cd "$PROJECT" && ~/.chiron/bin/chiron ingest documents --in "$SRC/trial.jsonl" --out "$SRC/trial"
   ```

   Read the documents in `$SRC/trial/documents/` (a long conversation gives several, and one
   that is stored already gives none). Check that names are resolved, the timestamps are
   right, and the converter's list holds only what was agreed. Show the user the documents
   and the list. With a memory plan, check them yourself and go on. Then delete
   `$SRC/trial.jsonl` and `$SRC/trial`: the trial stores nothing.
4. **Run the full scope**, then import it:

   ```sh
   python3 "$SRC/convert.py" --out "$SRC/conversations.jsonl"
   cd "$PROJECT" && ~/.chiron/bin/chiron ingest documents --in "$SRC/conversations.jsonl" --out "$SRC/out"
   ```

   The import makes one batch list per 20 documents, balanced by size. With a memory plan,
   run the plan's command as it stands. The import stops at the first invalid line and says what is wrong.
   Fix the converter and run it again.
5. **Write the memories**: go on with step 2 of [`docs/ingestion.md`](ingestion.md), a
   sample batch first, then one sub-agent per batch.
6. **Check that nothing is left**, after every batch is saved: run step 4's two commands
   again. The import's last line must be "Not stored yet: none". Otherwise it says how many
   documents are not stored yet and where they are listed. Save the ones that failed. A
   document that a sub-agent skipped on purpose (no substance, or a credential) stays in
   this count on every rerun: list it for the user and don't save it again. If you ran
   `chiron ingest documents` with its own `--limit`, the line says how many documents are
   not stored yet and how many of them that run wrote. The converter's `--limit` does not
   change this line.
7. **Clean up** after that check, not before. Delete `$SRC/conversations.jsonl` and
   `$SRC/out`. They hold the user's private history. `conversations.jsonl` holds every
   credential in plain text. Chiron blanks the common forms of credentials in the
   documents it writes, and again when it saves. The export belongs to the user: ask
   before you delete it, and never delete a folder that the user keeps, such as their notes
   folder. Keep the converter for the next import. Tell the user that the Chiron team would
   welcome it as a start for a built-in importer.

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
link, or the list of links, in the plan's Scope line into `~/chiron-ingest/<folder>/`, and it can stay there
afterwards. Prefer the HTML or EPUB edition. For a PDF, see "Reading files" above.
Keep headings, lists and tables readable, and drop page headers
and footers. Long sections are split automatically. A library carries nothing personal,
so the plan usually gives it `Share: all`: imported private; after the import the user
opens the Memories tab in the Chiron window, filters the Source column to the source,
ticks the header checkbox, and presses "Share N". One press shares the whole source. On a
large source the button shows a spinner for a few seconds. Then the window offers Undo.
You stage nothing for it.

Shared, a library counts against the team's shared memory like any other source. Each
teammate then chooses in the Chiron window whether their computer keeps a copy of it
(Settings, This computer, "Teammates' shared memories": "Keep a copy here"). Without a
copy it stays on the team's server, with a "server only" tag in the Memories tab, and
memory on that computer cannot recall it until a copy is kept.

## Example: Slack

A Slack export is a folder (unzipped) that contains:

- `users.json`: user objects. Map `id` to `real_name` (or `profile.real_name`, then `name`).
  A deleted user (`"deleted": true`) keeps a name: use it. The workspace id is the
  `team_id` of the users.
- `channels.json`: `id` and `name` for each public channel. Private conversations, if the
  export has them, are in `groups.json`, `dms.json` and `mpims.json`. Leave them out unless
  the user asked for them. Direct-message folders are named by id, not by name.
- One folder per channel, named after it, with one file per day (`2026-09-30.json`, the
  workspace's local date), each a JSON array of messages.

Each message has `ts` (seconds since 1970 as a string, also its id in the channel), `user`,
`text`, and for threads `thread_ts` (the parent's `ts`; the parent itself has `thread_ts`
equal to its own `ts`). Replies can sit in later day files, so group threads across all of
a channel's files.

- **Skip** by `subtype` first, before you look at files or text. Skip bots (messages with a
  `bot_id`, or from users marked `is_bot`), housekeeping subtypes (`channel_join`,
  `channel_leave`, `channel_topic`, `bot_message`, …) and messages with no text and no
  files. Keep the subtypes that are real content: `thread_broadcast`, `file_share`,
  `me_message`. For a shared file, add its name to the text, for example
  `[file: plan.pdf]`.
- **Text** marks mentions as `<@U024BE7LH>`, channels as `<#C024BE91L|launch>`, links as
  `<https://example.com|label>`, and group mentions as `<!here>`, `<!channel>` or
  `<!subteam^S123|@team>`. The export can also hold a link escaped as
  `&lt;https://example.com|label&gt;`. Rewrite the tags first (`@Name`, `#launch`,
  `label (https://example.com)`), then decode the escapes, then rewrite any tag the
  decode uncovered.
- **Thread conversations**: group by `thread_ts`. `conversation_id` is
  `slack:<workspace id>:<channel id>:<thread_ts>`.
- **Day conversations** for the other messages: `conversation_id` is
  `slack:<workspace id>:<channel id>:<YYYY-MM-DD>`, from the day file's name. A thread's
  parent is not repeated in its day.
- Convert each message's `ts` to RFC 3339 UTC for `at`. A day conversation keeps the
  workspace's local date in its id, even when `at` in UTC falls on another date.
