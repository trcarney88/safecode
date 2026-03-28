# safecode

A pre-configured, containerized AI software engineering workspace built on [opencode](https://opencode.ai). It ships a curated multi-agent team, persistent memory via Obsidian, and integrations with Linear and Context7 — ready to use out of the box.

## What it is

`safecode` packages the `opencode` terminal AI coding assistant into a Docker image with an opinionated agent team and workflow baked in. When you run the container, the **Engineer** agent takes over as lead developer, orchestrating specialized sub-agents for QA, code review, security auditing, documentation, and git commits.

All project context, task states, and decisions are written to your Obsidian vault — making the agent state resumable across container sessions when the vault is mounted as a volume.

## Agents

| Agent | Role |
|---|---|
| `Engineer` | Lead developer and orchestrator; runs the full plan → QA → review → commit workflow |
| `Project Planner` | Scopes work, decomposes tasks, syncs Obsidian task tracking |
| `Committer` | Semantic git commits following the Conventional Commits spec |
| `Reviewer` | Code review for SRP, complexity, performance, and readability |
| `QA` | Writes and runs tests in Go (`testing` package) and TypeScript (`vitest`) |
| `Security` | Security auditing across code, infrastructure, and dependencies |
| `Docs Generator` | Adds GoDoc/JSDoc/TSDoc inline docs to Go, TS, TSX, and Astro files |

## Skills

| Skill | Purpose |
|---|---|
| `context7` | Fetch up-to-date library documentation and code examples via `ctx7` |
| `linear-graphql-ops` | Create and manage Linear projects, issues, milestones, and comments |
| `obsidian-cli` | Read and write to your Obsidian vault for persistent agent memory |

## Prerequisites

- Docker
- `CONTEXT7_API_KEY` — for the Context7 MCP documentation integration
- `LINEAR_API_KEY` — for Linear GraphQL project management

## Build

```bash
# Using Make (recommended)
make build CONTEXT7_API_KEY=<your-key> LINEAR_API_KEY=<your-key>

# Or directly with Docker
docker build \
  --build-arg CONTEXT7_API_KEY=<your-key> \
  --build-arg LINEAR_API_KEY=<your-key> \
  -t safecode .
```

## Run

If you need to run the `opencode` cli, use the following command:
```bash
docker run -p 1455:1455 -v ~/.local/share/opencode:/home/clanker-1/.local/share/opencode -it safecode bash
```
and then run the `opencode` commands you need to.

`opencode` launches immediately in `/home/clanker-1/work`. Mount your project and vault as volumes for a persistent workspace:

```bash
docker run -it \
  -v /path/to/your/project:/home/clanker-1/work \
  -v /path/to/your/vault:/home/clanker-1/Documents/vault-name \
  -v /.local/share/opencode:/home/clanker-1/.local/share/opencode \
  safecode
```

I usually alias these two commands to `opencode-cli` and `opencode` respectively

## Workflow

The Engineer agent enforces a structured delivery loop:

1. **Project gate** — selects or creates a project context in the Obsidian vault before any code is written.
2. **Discovery & planning** — identifies relevant files, determines strategy, and defines a verification plan.
3. **Implementation loop** — writes code → delegates to the QA agent → fixes failures → repeats until tests pass.
4. **Review** — delegates to the Reviewer agent (up to 3 iterations); applies all requested changes.
5. **Finalize** — presents a commit summary, waits for explicit user approval, then delegates to the Committer agent.

Commits only happen after QA passes, review completes, and the user approves.

## Project structure

```
.
├── Dockerfile
├── Makefile
├── opencode.json        # opencode config: default agent, MCP integrations
├── tui.json             # Terminal UI theme (tokyonight)
├── agents/              # Agent persona definitions
│   ├── engineer.md
│   ├── project-planner.md
│   ├── committer.md
│   ├── reviewer.md
│   ├── qa.md
│   ├── security.md
│   └── docs_generator.md
└── skills/              # Reusable skill definitions
    ├── context7/SKILL.md
    ├── linear-graphql-ops/SKILL.md
    └── obsidian-cli/SKILL.md
```
