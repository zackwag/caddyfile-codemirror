# caddyfile-codemirror

An unofficial [CodeMirror 6](https://codemirror.net/) `StreamLanguage` mode
for the [Caddyfile](https://caddyserver.com/docs/caddyfile) format, the
configuration format used by the [Caddy](https://caddyserver.com/) web
server.

> **Credit:** the Caddyfile keyword vocabulary that makes this useful comes
> from [**Sean Whalen**](https://github.com/seanthegeek)'s
> [**rouge-lexer-caddyfile**](https://github.com/seanthegeek/rouge-lexer-caddyfile),
> synced here automatically every day. This repo just translates it to
> CodeMirror's API — see [Credit](#credit) below for details.

## Credit

The Caddyfile keyword vocabulary here (directive names, global options,
subdirectives, matcher names, and their plugin variants) is extracted
directly, on a daily schedule, from the class methods of the Caddyfile
lexer in [**rouge-lexer-caddyfile**](https://github.com/seanthegeek/rouge-lexer-caddyfile)
by **Sean Whalen ([seanthegeek](https://github.com/seanthegeek))** — a
[Rouge](http://rouge.jneen.net/) plugin used by Jekyll/GitHub Pages to
highlight fenced ` ```caddyfile ` code blocks. That gem is the actual
research: it tracks Caddy's documented directives/options/matchers plus the
vocabulary of the twenty most-downloaded Caddy plugins. This repo doesn't
duplicate that work — it reads it straight from the gem every day and
regenerates `dist/caddyfileMode.js` from the result, so the vocabulary here
never drifts out of date with upstream. See [NOTICE](./NOTICE) and
[LICENSE](./LICENSE).

Rouge and CodeMirror have fundamentally different token-stream models
(Rouge is a Ruby regex-based state machine for static/build-time
highlighting; CodeMirror's `StreamLanguage` is a JS token-stream parser for
a live editor), so the grammar/state-machine code in
[`template/caddyfileMode.js.erb`](./template/caddyfileMode.js.erb) is a
hand-written translation of Rouge's Caddyfile grammar into CodeMirror's API.
That part changes rarely — only the *vocabulary* (which set a given word
belongs to) is generated fresh from the gem on every run.

## How it works

- [`script/generate.rb`](./script/generate.rb) loads the
  `rouge-lexer-caddyfile` gem, calls its `directives`, `global_options`,
  `subdirectives`, `matchers`, `constants`, `http_methods`, `values` and
  `plugin_*` class methods, and renders
  [`template/caddyfileMode.js.erb`](./template/caddyfileMode.js.erb) with
  the result.
- [`.github/workflows/sync.yml`](./.github/workflows/sync.yml) runs that
  script daily (and on manual dispatch), and commits `dist/caddyfileMode.js`
  only when the generated output changes — i.e. only when Sean ships a
  vocabulary update upstream.
- [`dist/caddyfileMode.js`](./dist/caddyfileMode.js) is the file consumers
  actually use, always reflecting the latest `rouge-lexer-caddyfile`
  release. [`dist/VERSION`](./dist/VERSION) records which gem version it was
  generated from.

## Usage

`dist/caddyfileMode.js` exports a `caddyfile` object implementing
CodeMirror's legacy `StreamParser` interface, for use with
[`@codemirror/language`](https://www.npmjs.com/package/@codemirror/language)'s
`StreamLanguage.define()`:

```js
import { StreamLanguage } from "@codemirror/language";
import { caddyfile } from "./caddyfileMode.js";

const language = StreamLanguage.define(caddyfile);
```

To always build against the latest generated file without adding this repo
as a dependency, fetch it at build time, e.g. from a Node build script:

```js
const res = await fetch(
  "https://raw.githubusercontent.com/zackwag/caddyfile-codemirror/main/dist/caddyfileMode.js"
);
await writeFile("src/lib/caddyfileMode.js", await res.text());
```

Highlighting classes emitted follow CodeMirror's standard legacy style
names, which resolve to `tok-*` CSS classes via `@codemirror/language`'s
default highlight style (`keyword`, `string`, `comment`, `number`,
`operator`, `variable`, `variable-2`, `def`, `property`, `builtin`,
`atom`, `typeName`) — style them however you like in your editor theme.

## Local development

Requires Ruby 3.0+ (the version `rouge-lexer-caddyfile` requires).

```sh
bundle install
bundle exec ruby script/generate.rb
```
