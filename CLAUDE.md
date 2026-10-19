# Selvo iPhone app: rules for agents

Read `PLAN.md` and `PROGRESS.md` before doing anything. Design references are in `docs/`.

## Working rules
- Work the next unchecked items in `PLAN.md`, in order. Keep going until the current day's items are done, then pull from the next day.
- Small commits straight to `main`, each with a clear message. Never force-push. Never rewrite history.
- After every push, check the GitHub Actions run for that commit (`gh api repos/emily-bradley/personalized_communication_companion/actions/runs`). A red CI run is the top priority before any new feature.
- Never delete files or code you did not write in this run. Move retired work to `legacy/` and note it in PROGRESS.md.
- Do not touch `legacy/flutter-prototype/`.
- Keep solutions simple: the smallest readable code that meets the design. No speculative abstractions.

## Design and copy rules
- Colors, type, spacing, and radii come only from the generated theme (from `docs/design/system/tokens.json`). No hex literals in views.
- Copy matches the artboards. Product terms exactly: Speak, Incorrect, Another, Show.
- No em dashes or en dashes anywhere (code comments, copy, docs). No exclamation marks in UI copy. Never "user", "voiceless", "patient" in UI copy.
- Speak bottom center full width; Back top left; Clear top right, never beside Speak; Help top right.
- Tile positions never move. Suggestions arrive three at a time. Nothing times out or auto-dismisses.
- One glowing object per screen at most (the orb).

## Reporting
- Update `PROGRESS.md` at the end of every run: date and time, what changed, what was verified and how, what is next, blockers that need Emily.
