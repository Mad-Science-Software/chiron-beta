---
name: import-history
description: Import existing history into Chiron memory, such as past Claude Code sessions, git repositories, email (Gmail exports or mailboxes), or another source like Slack. Use when the user asks to import, ingest, or load their history, or to bring memory up to date with new items from a source imported before.
---

# Importing history into Chiron

Only import what the user explicitly asks for, one source at a time.

Follow the import guide, which this plugin doesn't repeat:

- **Claude Code sessions, git, email**: `~/chiron/docs/ingestion.md`
- **Any other source** (Slack, a chat export, notes): `~/chiron/docs/custom-sources.md`

If `~/chiron` doesn't exist, read them from
https://github.com/Mad-Science-Software/chiron-beta/tree/main/docs instead.

Rerunning an import is safe: anything already in memory is skipped, and a conversation
that gained messages gets only the new ones. So "bring memory up to date" is the same
steps run again over the same sources.
