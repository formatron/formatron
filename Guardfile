guard 'livereload' do
  watch(%r{^coverage/.+$})
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
