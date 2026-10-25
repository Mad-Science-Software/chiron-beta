# Planning what goes into memory

This guide is for the AI agent (Claude Code) installing Chiron for someone. Use it
before the install (step 3 of [`docs/setup.md`](setup.md)). You and the user decide
together which history Chiron imports, and you write that down as a plan. After the
install, you run the plan on your own, with no more questions ("Run the memory plan" in
[`docs/ingestion.md`](ingestion.md)).

Memory is only as useful as what is in it. On an empty memory, Claude knows nothing on
day one. With the user's history in it, Claude knows their projects, their people and
their decisions from the first session. The plan makes the user choose that history
once, on purpose. Then they do not have to sit through the import.

In this step you only read and count; the one file you write is the plan. Do not
change Chiron's code and do not write to the user's data.

## 1. Learn what the user does

Ask, in plain language:

- Their full name, as it must appear on their memories.
- What they work on, and with whom. Which clients, projects or teams matter most.
- What they want Claude to know on day one. Ask for examples: "the decisions in my
  projects", "what my clients asked for", "how we do things here".
- Whether they are on a team that shares memory, and what the team may see of their
  history. If they do not know, the team's sharing policy decides at staging time
  (step 3). When they are in more than one team on this computer, which team the
  import is for: it stays private in that team, and only that team can get it.

Their answers decide which sources matter and which to leave out.

## 2. Find the sources

Chiron imports these sources itself:

| Source | What becomes a memory | Where it is | Before the import |
|---|---|---|---|
| Claude Code sessions | each conversation, in segments | `~/.claude/projects` on this computer | nothing: it is already here |
| Git repositories | each commit: its message and the files it changed | the folders where they keep code | nothing |
| Email | each email thread, with the people in it | a Google Takeout `.mbox` export of Gmail, another `.mbox` file, or the Gmail connector in the user's Claude (that account only; "Email through the Claude Gmail connector" in [`custom-sources.md`](custom-sources.md)) | the user requests the export; Google takes hours to days to make it. Nothing when Claude has the Gmail connector |
| Anything else (Slack, Teams, Notion, a notes folder, a CRM export…) | each conversation or page | an export the user downloads | the user downloads the export; after the install you write a converter ([`custom-sources.md`](custom-sources.md)); the plan is its scope agreement |

Look at what is on this computer, read-only, and tell the user what you find. Ask
before you open a folder they did not name:

```sh
find ~/.claude/projects -name '*.jsonl' | wc -l; du -sh ~/.claude/projects   # sessions
git -C "$REPO" rev-list --count HEAD; git -C "$REPO" log -1 --format=%cd    # a repository
ls -la ~/Downloads/Takeout* 2>/dev/null; du -sh "$MBOX"                     # an export
```

Estimate each source in documents: about one document for each 16,000 characters of
conversation, one for each commit, one for each email thread kept, one for each section
of a reference work (more when a section passes about 16,000 characters). Each document is one
pass of a sub-agent's reading and writing, so the count sets the Claude usage and the
time. Give the user round numbers.

If a source needs an export, tell the user how to request it now, so it is ready after
the install:

- **Gmail**: https://takeout.google.com, deselect everything except Mail, choose the
  `.mbox` format. Google sends a download link by email when it is ready. Not needed
  when the user's Claude has the Gmail connector for that account.
- **Slack**: Workspace settings, Import/Export Data (admins only; public channels).
- **Other tools**: the export is in the tool's settings. Do not use a live connection
  or an API token.

### Reference material the user does not have yet

Memory can also hold what the user's field runs on, and nobody has to write it: the
regulations they work under, a regulator's guidance, a code of practice, a standard
that is free to download, a free textbook or a training manual. Ask what they look up
most. Then suggest three to five concrete items for their field, with links, and let
the user pick.

- Only material the licence lets them copy: government publications (public domain in
  many countries, or under an open licence such as CC BY), open-access books and
  textbooks (OpenStax and the like), standards that their body publishes free. Not a
  paywalled text, a subscription database or a scan of a bought book.
- A legal download of the text (PDF, HTML, EPUB), not a crawl of a website.
- Size: a regulation is tens to a few hundred documents; a textbook can be a few
  thousand. Give the estimate, and start with the parts the user uses. Estimate its
  tokens too (characters divided by four): shared, the whole work counts against the
  team's shared pool, so a work that does not fit stays out, goes in part, or needs a
  larger pool.
- Reference material carries nothing personal, so the plan usually shares all of it
  (section 3, "Private, or shared with the team"): imported private, then shared by the
  user with "Share all" in the Chiron app, one confirmation. Shared, it counts against
  the team's shared memory like anything else, and each teammate chooses in the Chiron
  window whether their computer keeps a copy of it.
- The import is a converter job: "Reference works" in
  [`custom-sources.md`](custom-sources.md).

## 3. Decide, source by source

For each source, agree on:

- **In or out.** Less is better. The user can import more later; a rerun of the plan
  adds only what is new.
- **Scope.** Which repositories, and a date range for their commits (`--since`). Which
  Gmail labels (`--include`, default `Category Personal,Sent,Important`). Which
  channels. Sessions and a Takeout export have no date filter: their scope is the whole
  source, or for Gmail its labels. Email through the Gmail connector takes a date
  (`after:`) and the same categories. Name what stays out: a personal repository, a
  mailbox, direct messages.
- **Who is credited.** The user's full name on their own messages. Other people keep
  the names the source gives them.
- **Private, or shared with the team.** Every import is private to the user. If the
  team may see part of it, write down which kind: "decisions and project knowledge from
  the work repositories", "nothing from email". After the import you stage those
  memories for sharing, and the user confirms them in the Chiron app. If the user does
  not know what the team may see, write `Share: per team policy`: the `stage_for_sharing`
  tool returns the team's policy when it is called with no record ids, and the policy
  decides at staging time. Reference material the whole team may use gets
  `Share: all`: after the import, tell the user to open the source under Yours in the
  Chiron app and press "Share all", which shares every memory of the source at once
  after one confirmation; you stage nothing for it. Every import is written private
  first; nothing reaches the team without that review. While private backup is on
  in a team, private memories in that team stop at the person's limit there, so a
  source larger than that needs backup off in that team (the gear, then Private
  memories) before the import, or a smaller scope.
  If the
  computer is in more than one team, the `Team:` line names the team the import is
  for. An import is private to the team that memory is in when it runs, so the user
  switches to that team before the import runs.
- **Order.** Most useful first. Sessions and repositories need no export, so they
  usually go first. Email goes when the export has arrived, or at once through the
  Gmail connector.

Say these once, so the user knows them before they agree:

- Writing memories uses their Claude usage, in proportion to the size of the history.
  The history passes through Claude as sub-agents read it, including what other people
  wrote in it.
- Sub-agents skip any document that holds a password or an access key. You list those
  at the end.
- A memory can be deleted later, but only after a review in the Chiron app. An import
  is quicker than its undo. That is why the plan matters.
- The import runs after the install, on its own. You report at the end; you do not ask
  along the way. If something blocks a source (an export that has not arrived), you
  mark it blocked, go on, and say so in the report.

## 4. Write the plan

Write it to `~/chiron-ingest/plan.md`. It is the agreement and the checklist: you
update the status of each source as you go, and a later session can continue it. Every
Scope line carries the estimate in documents. Write each command so it runs as it
stands: the full program path, `~/.chiron/bin/chiron` (`chiron.exe` on Windows); a
working folder per source under `~/chiron-ingest`, as in the import guide; the export's
real path, not a placeholder; and `--batches`, the estimate divided by 20, rounded up
(`--batches 30` for 600 documents). Use this shape:

```markdown
# Memory plan for <Full Name>

Agreed on <date>. Team: <team name, or "none">. Share with the team: <which kind, "per team policy", or "nothing">.

## 1. Claude Code sessions
- Status: planned
- Scope: all projects under ~/.claude/projects (about 140 sessions, about 600 documents, 2026-03 to now)
- Credit: Full Name
- Command: ~/.chiron/bin/chiron ingest claude-code --projects "$HOME/.claude/projects" --owner "Full Name" --out "$HOME/chiron-ingest/claude-code" --batches 30
- Share: nothing

## 2. Git: acme-api, acme-web
- Status: planned
- Scope: commits since 2026-01-01 (about 900 documents)
- Command: ~/.chiron/bin/chiron ingest git --repo ~/code/acme-api --repo ~/code/acme-web --since 2026-01-01 --out "$HOME/chiron-ingest/git" --batches 45
- Share: decisions and how the systems work; nothing that names a client

## 3. Email: work Gmail
- Status: waiting for export
- Scope: labels Sent, Important (about 2,000 threads, about 2,000 documents); export requested 2026-10-21
- Command: ~/.chiron/bin/chiron ingest mbox --mbox "$HOME/Downloads/Takeout/Mail/All mail Including Spam and Trash.mbox" --mailbox work --include "Sent,Important" --out "$HOME/chiron-ingest/mbox" --batches 100
- Share: nothing

## 4. Slack: acme workspace
- Status: waiting for export
- Scope: channels #launch and #support, 2026 (about 300 conversations, about 400 documents); export at ~/Downloads/acme-slack-export/
- Command: write a converter (custom-sources.md), then ~/.chiron/bin/chiron ingest documents --in "$HOME/chiron-ingest/slack/conversations.jsonl" --out "$HOME/chiron-ingest/slack/out" --batches 20
- Share: nothing

## 5. Library: EU AI Act
- Status: planned
- Scope: Regulation (EU) 2024/1689, articles and annexes (about 250 documents); download https://eur-lex.europa.eu/eli/reg/2024/1689/oj to ~/chiron-ingest/ai-act/
- Credit: European Union
- Command: write a converter (custom-sources.md, "Reference works"), then ~/.chiron/bin/chiron ingest documents --in "$HOME/chiron-ingest/ai-act/conversations.jsonl" --out "$HOME/chiron-ingest/ai-act/out" --batches 13
- Share: all

## 6. Library: state solar law
- Status: planned
- Scope: the solar statutes and rulings of the three states the team works in (about 4,000 documents, about 3M tokens); downloads listed in ~/chiron-ingest/solar-law/sources.md
- Credit: as printed on each work
- Command: write a converter (custom-sources.md, "Reference works"), then ~/.chiron/bin/chiron ingest documents --in "$HOME/chiron-ingest/solar-law/conversations.jsonl" --out "$HOME/chiron-ingest/solar-law/out" --batches 200
- Share: all

## Left out
- ~/code/personal-site (personal)
- Slack direct messages
```

Status is one of `planned`, `waiting for export`, `importing <date>`,
`imported <date>: N documents`, `imported <date>: N documents, sharing pending`,
`blocked: <reason>` or `skipped: <reason>`. `sharing pending` at the end of an
`imported` line means the staging is still to do. `skipped` is set only when the user
says, in any session, to leave a source out for good. Under an imported source, a line
`- Skipped for a credential: <subjects>` lists the documents the sub-agents left out.

If the user wants nothing imported, the plan is the header and a `## Left out` list of
what they declined. `Agreed on <date>` still goes in.

## 5. Get the user's yes

Read the plan back in plain language: what goes in, in which order, about how much,
what the team will see, and what it costs in usage and time. One yes approves the
whole plan. Then write `Agreed on <date>` in the plan's header. A plan without that
line is a draft: no session runs it. If the user wants time to think, write the header
as `Draft. Team: …` in place of `Agreed on <date>. Team: …` and go ahead with the
install. The Finish step of the setup guide asks once more; after that, the
`import-history` skill writes the date and runs the plan when they approve.

Then continue with the install (section A of the setup guide).
