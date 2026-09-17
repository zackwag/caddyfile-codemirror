#!/usr/bin/env ruby
# frozen_string_literal: true

require "rouge"
require "rouge/lexers/caddyfile"
require "erb"
require "json"
require "time"
require "fileutils"

ROOT = File.expand_path("..", __dir__)

lexer = Rouge::Lexers::Caddyfile

vocab = {
  directives: (lexer.directives | lexer.plugin_directives).to_a.sort,
  global_options: (lexer.global_options | lexer.plugin_global_options).to_a.sort,
  subdirectives: (lexer.subdirectives | lexer.plugin_subdirectives).to_a.sort,
  matchers: (lexer.matchers | lexer.plugin_matchers).to_a.sort,
  constants: lexer.constants.to_a.sort,
  values: (lexer.http_methods | lexer.values | lexer.plugin_values).to_a.sort,
}

gem_version = Gem.loaded_specs["rouge-lexer-caddyfile"]&.version.to_s
gem_version = "unknown" if gem_version.nil? || gem_version.empty?

template_src = File.read(File.join(ROOT, "template", "caddyfileMode.js.erb"))
template = ERB.new(template_src, trim_mode: "-")

def render(template, generated_at:, gem_version:, vocab:)
  template.result_with_hash(generated_at: generated_at, gem_version: gem_version, vocab: vocab)
end

dist_dir = File.join(ROOT, "dist")
dist_path = File.join(dist_dir, "caddyfileMode.js")

# Reuse the previous run's timestamp when nothing else has changed, so a
# daily regen with an identical vocabulary doesn't produce a diff (and thus
# a pointless sync PR) for the timestamp comment alone.
previous_generated_at = File.exist?(dist_path) && File.read(dist_path)[/^\/\/ Generated (\S+) from/, 1]
generated_at = previous_generated_at || Time.now.utc.iso8601
output = render(template, generated_at: generated_at, gem_version: gem_version, vocab: vocab)

if previous_generated_at && File.exist?(dist_path) && output != File.read(dist_path)
  generated_at = Time.now.utc.iso8601
  output = render(template, generated_at: generated_at, gem_version: gem_version, vocab: vocab)
end

FileUtils.mkdir_p(dist_dir)

File.write(dist_path, output)
File.write(File.join(dist_dir, "VERSION"), "#{gem_version}\n")

puts "Generated dist/caddyfileMode.js from rouge-lexer-caddyfile v#{gem_version}"
