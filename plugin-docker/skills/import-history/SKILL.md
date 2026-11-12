---
name: import-history
description: Import existing history into Chiron memory, such as past Claude Code sessions, git repositories, email (Gmail exports or mailboxes), or another source like Slack. Use when the user asks to import, ingest, or load their history, to run or finish their memory plan, or to bring memory up to date with new items from a source imported before.
---

# Importing history into Chiron

Import only what the user agreed to, one source at a time.

**With a memory plan.** `~/chiron-ingest/plan.md` is the plan the user approved when
Chiron was installed. If it exists, follow "Run the memory plan" in the import guide:
"finish the memory plan" runs what is not yet imported and stages what is marked
`sharing pending`; "bring memory up to date" reruns every source, and only what is new
gets imported. A plan whose header says `Draft` instead of `Agreed on <date>` is read
back to the user for their yes first; on yes, write `Agreed on <date>` in the header,
then run it. On a computer in more than one team, an import is private to the team of
this session's project folder. The plan's `Team:` line
says which team. Run `~/.chiron/bin/chiron teams` from the project folder first: its
last line names the project's team. If it is another team, ask the user, then follow "Which team" in the
import guide.

**A few files only.** Save a handful of files that the user gives you with `preserve`,
one call each, with no plan. Give each one `source` `note:<project>` and `external_id`
the file's path, so a second save of it in this team is refused. Skip a file that holds a password
or key. The plan and the importers are for bulk imports: a mail export, many past
sessions, a large archive.

**Without a plan**, or for a source the plan does not name, make the plan first with
the user, then run it. The planning guide says how: `~/.chiron/docs/memory-plan.md`.

The guides, which this plugin doesn't repeat:

- **The plan**: `~/.chiron/docs/memory-plan.md`
- **Claude Code sessions, git, email from a Takeout export**: `~/.chiron/docs/ingestion.md`
- **Any other source** (Slack, a chat export, notes, email through the Gmail connector,
  a reference work such as a regulation or a textbook): `~/.chiron/docs/custom-sources.md`

If `~/.chiron/docs` doesn't exist, read them from
https://github.com/Mad-Science-Software/chiron-beta/tree/main/docs instead.

After a bulk import, tell the user that the private memories of the new source stay on
this computer until they back up the source in the Chiron window: Settings, then Storage,
with the window on the import's team. Files saved one by one with the `preserve` memory tool
and `source` `note:<project>`, as above, count as "Saved in conversation", which the
backup keeps from the start. The bulk import's `chiron preserve` does not.

Rerunning an import is safe: anything that this team stores already is skipped, and a conversation
that gained messages gets only the new ones.
