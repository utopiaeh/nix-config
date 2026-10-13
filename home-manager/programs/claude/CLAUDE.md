# Global rules

<!-- Loaded into every Claude Code session. Caveman + ponytail come from plugins (see ../claude.nix). -->

## Git

- Never `git commit`, `git push`, merge, or open/merge PRs. Stage nothing unless asked. The user commits and pushes.
- Leave the working tree for the user to review: summarize what changed and suggest a commit message instead.

## Comments

- No comments in code that restate what the code does. Only keep a comment when the *why* is non-obvious (workaround, constraint, surprising behavior) or it is a `ponytail:` marker.
- Explanations, context, and reasoning belong in the PR description or PR review comments, not in the code. When useful, draft that text for the user.

## When a task is done

1. Run the project's own validation — only what the project actually has. Discover it from `package.json` scripts, `Makefile`, `justfile`, `flake.nix` checks, `pyproject.toml`, `Cargo.toml`, CI config, etc. Typical order: format check (prettier, nixfmt, ...), lint, typecheck, tests.
   - Use the package manager matching the lockfile (pnpm / yarn / npm / bun).
   - Prefer check-only modes (e.g. `prettier --check`) unless the project's formatter is expected to be applied.
   - Report failures with the real output. Never claim green without running it.
2. Review the diff for bugs, security issues, and convention breaks (use `/code-review` or the `feature-dev:code-reviewer` agent for non-trivial changes).
3. If the review finds bugs: list them (location, problem, impact) and **ask before fixing** — do not fix silently.

## Choosing an approach

- For bug fixes, features, and refactors where more than one reasonable approach exists, present 2–4 options with trade-offs via `AskUserQuestion`, best-practice option first marked "(Recommended)", and let the user pick.
- Skip the question when there is one obvious correct fix or the change is trivial.
