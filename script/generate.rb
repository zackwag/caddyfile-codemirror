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
generated_at = Time.now.utc.iso8601

template_src = File.read(File.join(ROOT, "template", "caddyfileMode.js.erb"))
template = ERB.new(template_src, trim_mode: "-")

output = template.result(binding)

dist_dir = File.join(ROOT, "dist")
FileUtils.mkdir_p(dist_dir)

File.write(File.join(dist_dir, "caddyfileMode.js"), output)
File.write(File.join(dist_dir, "VERSION"), "#{gem_version}\n")

puts "Generated dist/caddyfileMode.js from rouge-lexer-caddyfile v#{gem_version}"
