# nfl_platform

`main` is the official branch and always works. It changes only through a merged pull request.

## Workflow

1. `git checkout main && git pull origin main`.
2. Branch from `main`: `feature/<name>`, `fix/<name>`, `chore/<name>` or `docs/<name>` (kebab-case).
3. Commit as often as needed, one logical change each, imperative message.
4. Run tests and linters; every one is green before you push.
5. `git push -u origin <branch>`, then open a PR into `main`: what, why, how tested.
6. Enable auto-merge: `gh pr merge --auto --merge`. GitHub merges once the `main` ruleset's required checks (`dbt-build`, `dashboard`) pass. Keep commit history.
7. After the merge, `git checkout main && git pull` (the remote branch deletes itself); delete the local branch.

## Spec to production

`/to-spec` and `/to-tickets` publish a spec and its tickets as GitHub issues. `/implement-spec` then builds every ticket on one integration branch and opens one PR into `main`; auto-merge (step 6) and the `refresh` workflow deploy it. Run it end to end without waiting for the user. When a required check fails, fix the cause on the branch and push again.

Hard guardrails (no positive phrasing possible), each paired with its target:

- Reach `main` only through a PR that auto-merges after its required checks pass.
- Rebase or merge `main` into a branch that falls behind.
- Keep secrets, credentials and raw data files out of commits.
- Force-push only your own unshared branches.
- End agent commits with `Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>`.

## Agent skills

- **Issues** (create, read, label, close): read `docs/agents/issue-tracker.md` first. GitHub Issues via `gh`.
- **Domain language** (naming, glossary, ADRs): read `docs/agents/domain.md` first. Single-context.
