# AGENTS.md

## Project overview

Unofficial CodeMirror 6 `StreamLanguage` mode for the Caddyfile config format. Ruby generator script reads [seanthegeek/rouge-lexer-caddyfile](https://github.com/seanthegeek/rouge-lexer-caddyfile)'s lexer and emits a CodeMirror-compatible JS mode into `dist/`. Most of this repo's content is auto-generated daily, not hand-written.

## Setup

```sh
bundle install
```

## Build / Run

```sh
bundle exec ruby script/generate.rb
```

Regenerates `dist/` from the installed `rouge-lexer-caddyfile` gem version.

## Test

No automated test suite. `.github/workflows/sync.yml` runs the generator daily and auto-commits changes to `dist/` if the upstream vocabulary changed — that's the closest thing to a correctness check (it only commits if the generator ran successfully).

## Repository structure

- `script/generate.rb` — the generator: Rouge lexer classes → CodeMirror mode
- `template/` — templates used by the generator
- `dist/` — generated output (committed, auto-updated daily), including `dist/VERSION`
- `Gemfile` — pulls in `rouge-lexer-caddyfile` as the vocabulary source

## Commit and PR conventions

- Commit messages and PR titles must follow [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`, `ci:`, `build:`, `perf:`, `style:`, `revert:`), optionally with a scope, e.g. `fix(api): handle null response`.
- This repo squash-merges pull requests only; the PR title becomes the final commit message on `main`.
- A "Conventional Commits" CI check enforces this on both PR titles and direct-push commit messages.
- Branch protection on `main`: no force-pushes, no branch deletion, required status checks must pass.
- **Known issue:** `.github/workflows/sync.yml` commits directly to `main` with a `sync: rouge-lexer-caddyfile vX.Y.Z` message. `sync:` is not a recognized Conventional Commits type and this is a direct push, not a PR — this will likely fail the now-required "Conventional Commits" check on its next scheduled run. Needs a fix (e.g. change the prefix to `chore:` or route through a PR) — not addressed by this change.
