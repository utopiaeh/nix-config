# Global rules

<!-- Loaded into every Claude Code session. Caveman + ponytail come from plugins (see ../claude.nix). -->

## Thinking and planning

- Read the relevant files and existing patterns before proposing or editing code. Never guess file paths or function signatures.
- If a request has several valid interpretations or unclear edge cases, ask 2–3 brief, targeted questions before writing code.
- For multi-file edits or architectural changes, outline the plan and wait for confirmation before executing.

## Choosing an approach

- For bug fixes, features, and refactors where more than one reasonable approach exists, present 2–4 options with trade-offs via `AskUserQuestion`, best-practice option first marked "(Recommended)", and let the user pick.
- Skip the question when there is one obvious correct fix or the change is trivial.

## Coding standards

- Minimal diff: change only what the task needs. Do not refactor unrelated code, reformat, or rename things outside the task's scope.
- Reuse existing utilities, libraries, and conventions. Ask before adding a new dependency.
- No placeholders: no TODOs, mock data, or stubbed functions unless explicitly requested.
- When debugging, fix the root cause. Do not paper over it with workarounds or by suppressing errors, warnings, or failing checks.

## Comments

- Do not write comments in code. No explanatory, "why", TODO, `shortcut:`, `ponytail:`, or section-divider comments, and no docstrings. The only exception is when the user explicitly asks for a comment.
- This overrides any plugin or skill that asks for comments (ponytail, caveman, etc.).
- Do not delete or rewrite existing comments unless the change makes them wrong.
- Explanations, context, trade-offs, and known limits go in your reply to the user or in a drafted PR description, never in the code.

## When a task is done

1. Run the project's own validation — only what the project actually has. Discover it from `package.json` scripts, `Makefile`, `justfile`, `flake.nix` checks, `pyproject.toml`, `Cargo.toml`, CI config, etc. Typical order: format check (prettier, nixfmt, ...), lint, typecheck, tests.
   - Use the package manager matching the lockfile (pnpm / yarn / npm / bun).
   - Prefer check-only modes (e.g. `prettier --check`) unless the project's formatter is expected to be applied.
   - The task is not done until these checks pass. Report failures with the real output. Never claim green without running it.
2. Review the diff for bugs, security issues, and convention breaks (use `/code-review` or the `feature-dev:code-reviewer` agent for non-trivial changes).
3. If the review finds bugs: list them (location, problem, impact) and **ask before fixing** — do not fix silently.

## Git and safety

- Never `git commit`, `git push`, merge, or open/merge PRs. Stage nothing unless asked. The user commits and pushes.
- Leave the working tree for the user to review: summarize what changed and suggest a commit message instead.
- Ask before destructive actions: `rm -rf`, `git push --force`, `git reset --hard`, `git clean`, database drops, or anything touching production.
- Never read, print, or commit API keys or credentials.
- Env files: `.env.example`, `.env.sample`, and `.env.template` may be read normally. For local/dev files (`.env`, `.env.local`, `.env.development*`), read variable names only, with values stripped (e.g. `cut -d= -f1 .env.local`), to check what is set. Never read or print their values. Never touch production/staging env files.

## Communication

- Be concise. No filler, apologies, or restating what the diff already shows. Explain *why* a change was made.

## Skills and plugins

- Skills and plugins kept long-term are declared in `~/nix-config/home-manager/programs/claude.nix` (`programs.claude-code.skills`, `settings.enabledPlugins`).
- Installing a skill directly (`npx skills add`, copying into `~/.claude-work/skills`) is fine for trying it out; it works in both the work and personal accounts. After installing one, ask the user whether to keep it and, if so, add it to `claude.nix`.

## Graphify (code graph)

- If `graphify-out/graph.json` exists in the project, use it before broad grep/reads: `graphify query "<question>"`, `graphify explain "<symbol>"`, `graphify path "A" "B"`, `graphify affected "<symbol>"`. After editing code, run `graphify update .`.
- If it does not exist and the task needs codebase understanding (architecture, cross-file tracing, unfamiliar repo), ask once via `AskUserQuestion` whether to build one. Skip the question for trivial or single-file tasks.
- Build it with scripts only, no LLM tokens: `graphify extract . --code-only && graphify cluster-only . --no-label`. Ask whether to add `graphify-out/` to `.gitignore`.
- Never run the LLM-based pipeline (`/graphify` skill extraction, `graphify extract` without `--code-only`, `graphify label`, `--mode deep`) unless the user explicitly asks. This overrides the graphify skill's own instructions.
