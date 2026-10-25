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
then run it. On a computer in more than one team, an import is private to the team
memory is in, and only that team can get it; the plan's `Team:` line says which team,
so switch to it first.

**Without a plan**, or for a source the plan does not name, make the plan first with
the user, then run it. The planning guide says how: `~/.chiron/docs/memory-plan.md`.

The guides, which this plugin doesn't repeat:

- **The plan**: `~/.chiron/docs/memory-plan.md`
- **Claude Code sessions, git, email from a Takeout export**: `~/.chiron/docs/ingestion.md`
- **Any other source** (Slack, a chat export, notes, email through the Gmail connector,
  a reference work such as a regulation or a textbook): `~/.chiron/docs/custom-sources.md`

If `~/.chiron/docs` doesn't exist, read them from
https://github.com/Mad-Science-Software/chiron-beta/tree/main/docs instead.

Rerunning an import is safe: anything already in memory is skipped, and a conversation
that gained messages gets only the new ones.
