---
name: commit-convention
description: "Enforces commit message conventions and authorship rules. Triggers on: commit, git commit, create commit, push, PR, pull request. Format: <type>(optional-scope): <short summary> with optional body and footer. Rules: no Claude/Anthropic mentions, imperative mood, 50-char subject limit, no trailing period, explain why not what. Maintains .gitignore hygiene."
---

# Commit Convention

Enforces consistent commit message formatting and authorship rules across all repositories.

## When to Apply

This skill MUST be followed whenever:
- Creating a git commit
- Amending a commit
- Writing commit messages for PRs
- Rewriting commit history (rebase, filter-branch)

## Commit Message Format

```
<type>(optional-scope): <short summary>

[optional body]

[optional footer(s)]
```

### Types

| Type | Use When |
|------|----------|
| `feat` | Adding a new feature or capability |
| `fix` | Fixing a bug or incorrect behavior |
| `refactor` | Restructuring code without changing behavior |
| `perf` | Performance improvements |
| `style` | Formatting, whitespace, missing semicolons (not CSS) |
| `docs` | Documentation changes only |
| `test` | Adding or updating tests |
| `build` | Build system or dependency changes |
| `ci` | CI/CD pipeline changes |
| `chore` | Maintenance tasks, tooling, config |
| `revert` | Reverting a previous commit |

### Scope (Optional)

A noun in parentheses describing the area of change:
- `feat(auth):` `fix(api):` `refactor(ui):` `docs(readme):`

## Rules

### Subject Line
1. **50-character limit** - If you need more explanation, use the body
2. **Imperative mood** - "Fix bug" not "Fixed bug" or "Fixes bug"
3. **Capitalize first word** - "Add feature" not "add feature"
4. **No trailing period** - "Fix login flow" not "Fix login flow."

### Body (Optional)
- Separated from subject by a blank line
- Explain **why**, not just **what**
- Wrap at 72 characters per line
- Use bullet points with `-` for lists

### Footer (Optional)
- Breaking changes: `BREAKING CHANGE: description`
- Issue references: `Closes #123`, `Fixes #456`

## Authorship

- **NEVER** include `Co-Authored-By` lines mentioning Claude, Anthropic, or any AI
- **NEVER** mention Claude, Anthropic, or AI assistance in commit messages or descriptions
- The commit author must be the user alone

## .gitignore Hygiene

Always ensure these are in `.gitignore` and never committed:
- Environment files: `.env`, `.env.local`, `.env.*`
- Dependency folders: `node_modules/`, `vendor/`, `venv/`
- Build artifacts: `dist/`, `build/`, `out/`
- IDE files: `.idea/`, `.vscode/`, `*.swp`
- OS files: `.DS_Store`, `Thumbs.db`

## Examples

Good:
```
feat(auth): Add OAuth2 login support

Implement Google and GitHub OAuth2 providers to give users
alternative login options beyond email/password.

Closes #42
```

```
fix(api): Prevent race condition in session refresh
```

```
refactor(db): Extract query builder into separate module
```

Bad:
```
Fixed stuff                          # vague, past tense
update the login page.               # lowercase, trailing period
feat: Added a really long commit message that goes way beyond fifty characters  # too long, past tense
```

## Git Command Format

### Linux / macOS / Git Bash
Use a HEREDOC for multi-line messages:
```bash
git commit -m "$(cat <<'EOF'
<type>(scope): Subject line here

Optional body explaining the why.
EOF
)"
```

### Windows PowerShell / CMD
Use a simple quoted string (no HEREDOC):
```powershell
git commit -m "<type>(scope): Subject line here"
```
For multi-line messages in PowerShell, use a here-string variable:
```powershell
$msg = @"
<type>(scope): Subject line here

Optional body explaining the why.
"@
git commit -m $msg
```

## Smart Commit Script

Auto-stages, generates a conventional commit message, and pushes. Located in `scripts/`.

### Usage

Detect the current shell/OS and run the appropriate script:

| Environment | Command |
|---|---|
| **Bash** (Linux/macOS/Git Bash/WSL) | `bash scripts/smart_commit.sh` or `bash scripts/smart_commit.sh "feat: my message"` |
| **PowerShell** (Windows) | `pwsh scripts/smart_commit.ps1` or `pwsh scripts/smart_commit.ps1 "feat: my message"` |

### Selection Rules

- If the current shell is **PowerShell** (`$PSVersionTable` exists, or shell is `pwsh`/`powershell`), use `smart_commit.ps1`.
- If the current shell is **Bash**, **Zsh**, or any POSIX shell, use `smart_commit.sh`.
- On Windows with **Git Bash** or **WSL**, the `.sh` script works fine.
- When in doubt, check the `SHELL` environment variable or `$PSVersionTable`.