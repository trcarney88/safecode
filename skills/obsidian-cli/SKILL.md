---
name: obsidian-cli
description: Use Obsidian CLI for project-first agent memory, including project/task Kanban updates, task lists, and durable memory notes.
license: MIT
compatibility: opencode
metadata:
  audience: engineers
  tool: obsidian
---

## What I do

- Use Obsidian from the terminal for scripting and automation.
- Build correct commands with `parameter=value` syntax and boolean flags.
- Target the right vault and file before running note operations.
- Maintain a project-first structure with top-level and per-project Kanban boards.

## When to use me

- The user asks to manage notes from terminal.
- You need repeatable project/task tracking and long-running memory.
- You need quick command examples without opening the Obsidian UI.

## Recommended structure

```text
L-Space/
  Projects.md
  Projects-Kanban.md
  Projects-Archive.md
  Projects/
    Archive/
    <project-slug>/
      README.md
      Tasks/
      Kanban.md
      Memory.md
      Log.md
```

- `Projects.md` is the master project list.
- `Projects-Kanban.md` is the top-level project board.
- `Projects-Archive.md` records archived projects.
- Each project folder contains its own task board, task notes folder, and memory.

## Prerequisites

- Obsidian 1.12 or later.
- CLI enabled in Obsidian: `Settings -> General -> Command line interface`.
- Obsidian app is running (first command can launch it).

## CLI-first with Documents fallback

- Prefer Obsidian CLI for all note operations when available.
- If CLI is unavailable or repeatedly fails, switch to direct markdown edits in a vault under `~/Documents`.
- Direct edits must preserve Obsidian compatibility (plain `.md`, standard headings, wikilinks, and frontmatter when present).

## Quick reference

```bash
# Get help
obsidian help

# Open interactive TUI
obsidian

# Create notes
obsidian create
obsidian create name=Note content="Hello world"
obsidian create name=Note content="# Title\n\nBody text" open overwrite

# Target a specific vault (vault must be first parameter)
obsidian vault=Notes daily
obsidian vault="My Vault" search query="test"

# Create a project note file (repeat for each file needed)
obsidian vault=Work create name="L-Space/Projects/New-Project/README" content="# New Project"
obsidian vault=Work create name="L-Space/Projects/New-Project/Kanban" content="# Kanban"
obsidian vault=Work create name="L-Space/Projects/New-Project/Memory" content="# Memory"
obsidian vault=Work create name="L-Space/Projects/New-Project/Log" content="# Log"
```

## Parameter rules

- Parameters use `key=value`.
- Quote values with spaces, for example `name="My Note"`.
- Flags are bare words with no value, for example `open` and `overwrite`.
- Use `\n` for newlines and `\t` for tabs in content.

## Targeting rules

- If terminal CWD is a vault folder, commands target that vault.
- Otherwise, commands target the currently active vault.
- Use `vault=<name>` or `vault=<id>` to force a target vault.
- Use `file=<name>` for wikilink-style resolution or `path=<vault/relative/path.md>` for exact file targeting.

## Fallback vault discovery (when CLI cannot be used)

- Only search for vaults in the current user's `~/Documents`.
- If a vault name is known (for example from `vault=<name>`), first try `~/Documents/<name>`.
- Otherwise, treat any directory containing `.obsidian/` as a vault candidate.
- If exactly one candidate exists, use it.
- If multiple candidates exist, prefer the one containing `L-Space/`; if still ambiguous, ask the user to choose.
- If no candidate is found in `~/Documents`, warn the user that no compatible vault was found, ask for permission to continue without vault updates, and stop until the user answers.

## Direct file editing mode (fallback)

- Edit markdown files directly inside the discovered vault path.
- Create missing parent directories before writing new notes.
- Keep filenames and paths consistent with Obsidian note conventions.
- Preserve existing markdown structure; append updates when possible rather than rewriting whole notes.
- Keep project and task status synchronization rules identical to CLI mode.
- Retry CLI opportunistically on later operations, but do not block work while fallback mode is functioning.

## Common mistakes

- Putting `vault=` after the command instead of before it.
- Forgetting to quote parameter values that contain spaces.
- Treating flags like parameters (`open=true`) instead of bare flags (`open`).
- Using `file=` when an exact `path=` is required.

## Kanban and task sync rules

- Update project status in both `L-Space/Projects.md` and `L-Space/Projects-Kanban.md`.
- Update task status in `L-Space/Projects/<project-slug>/Kanban.md` and the linked `L-Space/Projects/<project-slug>/Tasks/<task-slug>.md` note.
- Keep statuses aligned to: `todo`, `in_progress`, `blocked`, `done`.
- Keep memory append-only in `L-Space/Projects/<project-slug>/Memory.md`.
- Keep each task note updated with what was actually implemented under an `Implemented` section.
- In fallback mode, perform all updates directly in markdown while preserving structure.

## Archive rule (projects only)

- Apply archiving only to `L-Space/Projects-Kanban.md`.
- If `done` has more than 10 project cards, archive oldest done projects until 10 remain.
- For each archived project:
  - Move `L-Space/Projects/<project-slug>/` to `L-Space/Projects/Archive/<project-slug>/`.
  - Remove it from `L-Space/Projects.md` active table.
  - Remove its card from `L-Space/Projects-Kanban.md`.
  - Add an entry to `L-Space/Projects-Archive.md`.
- Do not apply this rule to per-project task boards (`L-Space/Projects/<project-slug>/Kanban.md`).

## Fallback examples

```bash
# Create or update notes directly in a discovered Documents vault
mkdir -p "$HOME/Documents/MyVault/L-Space/Projects/new-project/Tasks"
cat > "$HOME/Documents/MyVault/L-Space/Projects/new-project/README.md" <<'EOF'
# New Project
EOF

# Update per-project Kanban and task note in direct-edit mode
cat >> "$HOME/Documents/MyVault/L-Space/Projects/new-project/Kanban.md" <<'EOF'
## in_progress
- [ ] [[Tasks/setup-ci]]
EOF
```

## Troubleshooting

- `obsidian: command not found`: enter fallback mode and discover vault under `~/Documents`.
- `CLI is disabled`: enable it in Obsidian settings, or continue in direct-edit fallback mode.
- `Vault not found`: warn the user, request permission to continue without vault updates, and verify the vault folder exists in `~/Documents` with `.obsidian/`.
- Repeated command failures: stop using CLI for this task and complete updates via direct markdown edits.

## User warning template (vault missing)

Use this message pattern when no vault is found in `~/Documents`:

```text
I could not find an Obsidian vault in ~/Documents (no folder with a .obsidian directory was detected), so I cannot safely update project memory right now.

Do you want me to continue without vault updates for this task?
```

- Do not continue task execution that depends on vault writes until the user answers.
- If the user approves, continue and clearly note that vault updates were skipped.

## User warning template (multiple vault candidates)

Use this message pattern when more than one vault candidate is found in `~/Documents` and selection is still ambiguous:

```text
I found multiple Obsidian vault candidates in ~/Documents and could not choose safely:
- <vault-path-1>
- <vault-path-2>

Which vault should I use for updates?
```

- Do not continue task execution that depends on vault writes until the user chooses a vault.
- After selection, use the chosen vault path for all remaining updates in this task.
