# Stage 2 — Git

## Position in Pipeline
```
Linux → ⭐ Git ← SQL (next)
```

Git tracks every change to your files over time. Every dbt model, Airflow DAG, and Python ETL script in a real DE job lives in a git repo — no version control means no safe way to change a production pipeline.

---

## Core Workflow

```bash
git init                  # create a new repo
git clone <url>           # copy an existing repo locally, with full history
git status                # what's changed, what's staged
git add <file>            # stage a file (mark for the next commit)
git commit -m "message"    # save a snapshot of staged changes
git push                      # send commits to the remote (GitHub)
git pull                        # fetch + merge remote changes into local
git log                            # commit history
git log --oneline --graph --all      # visual history with branches
git diff                                # see unstaged changes line by line
```

**Order matters:** `add` → `commit` → `push`. Pull before you push if working with others (or just resuming after time away), otherwise you risk conflicts.

---

## Branching

```bash
git branch <name>          # create a new branch (doesn't switch to it)
git checkout <name>          # switch to a branch
git checkout -b <name>          # create + switch in one step
git switch <name>                  # modern alternative to checkout
```

A branch is an independent line of work. You experiment/build a feature on a branch without touching `main`, then merge it back when ready.

---

## Merge — Fast-Forward vs Real Merge

```bash
git checkout main
git merge <branch-name>
```

**Fast-forward merge** happens when `main` has had *no new commits* since the branch was created — git just moves the `main` pointer forward, no merge commit is created.

```
Before:  main ──A──B
                  \
        feature     C──D

After merge (fast-forward):
         main ──A──B──C──D
```

**Real merge** (with a merge commit) happens when both branches diverged — `main` got new commits *while* the feature branch also got commits. Git has to combine both histories:

```
Before:  main ──A──B────────E
                  \         /
        feature     C──D──┘

After merge:
         main ──A──B────────E──M   (M = merge commit, combines both)
```

If the same lines were changed on both sides → **merge conflict**. Git marks the conflicting section with `<<<<<<<`, `=======`, `>>>>>>>` in the file, and you manually pick what stays before committing the resolution.

> ⚠️ **Known gap:** real merge with divergent branches and manual conflict resolution was skipped during practice (twice across two learning cycles). Only fast-forward merge was exercised hands-on. Revisit before relying on this in an interview or real team workflow.

---

## .gitignore

Prevents files from ever being tracked — used for `.venv/`, credentials, IDE clutter, OS junk. Doesn't affect files already committed; for those you'd need `git rm --cached`.

---

## Common Mistakes

| Mistake | Why it's bad | Fix |
|---|---|---|
| Huge commit once a day | Hard to tell what changed, hard to revert cleanly | Commit often, in small logical chunks |
| Vague message like "fix" | `git log` becomes useless months later | Descriptive: `stage-2: add merge concepts` |
| `git push` without `git pull` first | Risk of overwriting others' (or your own remote) changes | Pull first, then push |
| Committing `.venv`, secrets, credentials | Bloats repo / leaks data | `.gitignore` set up in advance |
| Working directly on `main` for experiments | Breaks the working version for everyone | Use a feature branch |

---

## Commit Convention Used in This Repo
```
stage-N: short description
```
Examples: `stage-1: linux notes + cheatsheet + practice tasks done`, `stage-2: add practice material`.

---

## Interview Questions

**Q: What does `git clone` do?**
A: Copies a remote repo to your local machine, including its full commit history.

**Q: What is a merge conflict and when does it happen?**
A: When two commits change the same line(s) of a file in different ways, git can't auto-resolve and asks you to pick manually.

**Q: Difference between fast-forward merge and a regular merge?**
A: Fast-forward just moves the branch pointer forward (no divergent history, no merge commit). A regular merge creates a merge commit because both branches have independent commits that need to be combined.

**Q: You accidentally committed to `main` instead of your feature branch — what do you do?**
A: Depends on whether it's pushed yet. If local only: create the correct branch from the current state (`git branch feature-x`), then reset `main` back (`git reset --hard <previous-commit>`). If already pushed and shared with others, prefer `git revert` over rewriting shared history.