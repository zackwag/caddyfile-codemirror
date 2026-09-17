# Contributing to caddyfile-codemirror

An unofficial [CodeMirror 6](https://codemirror.net/) `StreamLanguage` mode for the Caddyfile format. The keyword vocabulary in `dist/` is regenerated automatically every day from [seanthegeek/rouge-lexer-caddyfile](https://github.com/seanthegeek/rouge-lexer-caddyfile) — see the README's Credit section — so most changes to that vocabulary should go upstream rather than here.

## Getting started

```sh
git clone https://github.com/zackwag/caddyfile-codemirror.git
cd caddyfile-codemirror
bundle install
```

## Development

The generator is `script/generate.rb`, a Ruby script that reads the `rouge-lexer-caddyfile` gem's lexer classes and emits the CodeMirror mode into `dist/`:

```sh
bundle exec ruby script/generate.rb
```

`.github/workflows/sync.yml` runs this daily and auto-commits any changes to `dist/`. If you're changing the *translation* from Rouge's lexer to CodeMirror's API (rather than the underlying Caddyfile vocabulary), that logic lives in `script/` and `template/`.

There is no automated test suite for this repo.

## Commit messages and pull requests

This repo uses [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:`, `chore:`, etc.). Pull requests are squash-merged, and the **PR title** becomes the commit on `main` — so PR titles must follow this format. This is enforced automatically by the "Conventional Commits" check.

Direct pushes to `main` are allowed but must also use a Conventional Commits-formatted commit message (validated by the same check). Note: the daily sync job commits directly as `github-actions[bot]` and is exempt in practice since it only touches generated `dist/` content.

## Opening a pull request

1. Fork the repo and create a branch off `main`.
2. Make your changes.
3. Open a pull request with a Conventional Commits-formatted title.
4. Wait for CI to pass — required checks must be green before merge.

## Reporting issues

Use [GitHub Issues](../../issues) for bugs and feature requests.
