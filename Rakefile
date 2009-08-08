#!/usr/bin/env ruby

require 'rake'

require 'spec/rake/spectask'

desc "Generate rspec report"
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ["--color"]
  t.fail_on_error = false
end

desc "Generate rspec (and rcov) reports in HTML"
Spec::Rake::SpecTask.new('spec_html') do |t|
  t.fail_on_error = false

  t.spec_opts = ["--color", "--format", "progress", "--format", "html:doc/reports/spec.html", "--diff"]

  t.rcov = true
  t.rcov_dir = "doc/reports/coverage"
  t.rcov_opts = ["--exclude", "spec"]
end
