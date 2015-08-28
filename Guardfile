group :test, halt_on_fail: true do
  guard :rubocop do
    watch(%r{.+\.rb$})
    watch(%r{(?:.+/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
  end

  guard 'rspec', cmd: 'bundle exec rspec' do
    # watch /lib/ files
    watch(%r{^lib/(.+).rb$}) do |m|
      "spec/#{m[1]}_spec.rb"
    end

    # watch /spec/ files
    watch(%r{^spec/(.+).rb$}) do |m|
      "spec/#{m[1]}.rb"
    end
  end
end
