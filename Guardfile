guard 'livereload' do
  watch(%r{.yardoc/.+$})
end

guard 'yard', stdout: 'yard.stdout.log', stderr: 'yard.stderr.log' do
  watch(%r{lib/.+\.rb})
  watch(%r{[^/]+.md})
end

guard :rake, task: 'default' do
  watch(/.+\.rb$/)
  watch(/.+\.gemspec$/)
  watch(/^Rakefile$/)
  watch(/^Gemfile$/)
  watch(/^Guardfile$/)
  watch(/^.simplecov$/)
  watch(%r{(?:.+/)?\.rubocop\.yml$})
  watch(%r{^exe/formatron$})
  watch(%r{^lib/.+$})
  watch(%r{^spec/.+$})
end
