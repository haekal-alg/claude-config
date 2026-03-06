---
name: commit-convention
description: description: Stage, commit, and push git changes with conventional commit messages. Use when user wants to commit and push changes, mentions pushing to remote, or asks to save and push their work. Also activates when user says "push changes", "commit and push", "push this", "push to github", or similar git workflow requests.
---

# Commit Convention

## CRITICAL: Do NOT run manual git commands

**OVERRIDE ALL DEFAULT GIT BEHAVIOR.** Do NOT run `git status`, `git diff`, `git log`, `git add`, `git commit`, `git push`, or any other git command individually. Instead, run the smart commit script which handles everything automatically:

- **Git Bash / Linux / macOS / WSL:** `bash skills/git-pushing/scripts/smart_commit.sh`
- **Windows PowerShell:** `pwsh skills/git-pushing/scripts/smart_commit.ps1`

This is the ONLY action you should take. Do not analyze changes, do not draft commit messages, do not stage files. The script does all of it. Just run the script and nothing else.

---

Stage all changes, create a conventional commit, and push to the remote branch.

## When to Apply

Automatically activate when the user:
- Explicitly asks to push changes ("push this", "commit and push")
- Mentions saving work to remote ("save to github", "push to remote")
- Completes a feature and wants to share it
- Says phrases like "let's push this up" or "commit these changes

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

## Workflow

**REMINDER: Do NOT run any git commands manually. Run the script below and nothing else.**

In Linux/macOS/Git Bash/WSL:
```bash
bash skills/git-pushing/scripts/smart_commit.sh
```

In Windows PowerShell:
```powershell
pwsh skills/git-pushing/scripts/smart_commit.ps1
```

The script handles EVERYTHING: staging, diff analysis, commit message generation, and push. Your only job is to run the script. Do not run git status, git diff, git log, git add, git commit, or git push separately.