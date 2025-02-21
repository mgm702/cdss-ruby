# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/test_*.rb"]
end

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[test rubocop]

require "yard"

YARD::Rake::YardocTask.new do |t|
  t.options = ["--output-dir", "docs"]
end

task :publish_docs do
  sh "git subtree push --prefix docs origin gh-pages"
end
