require "rspec/core/rake_task"

desc "Run all specs in spec directory (excluding plugin specs)"
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :default => :spec

# Cargo-culted from Jim Weirich's Rakefile
begin
  gem 'rdoc'
  require 'rdoc/task'
rescue Gem::LoadError
end

BASE_RDOC_OPTIONS = [
  '--line-numbers', '--show-hash',
  '--main', 'README.rdoc',
  '--title', 'Rake -- Ruby Make'
]

if defined?(RDoc::Task) then
  RDoc::Task.new do |rdoc|
    rdoc.rdoc_dir = 'doc'
    rdoc.options = BASE_RDOC_OPTIONS.dup

    rdoc.rdoc_files.include('lib/**/*.rb', 'doc/**/*.rdoc')
  end
else
  warn "RDoc 2.4.2+ is required to build documentation"
end
