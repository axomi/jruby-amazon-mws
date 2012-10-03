#!/usr/bin/env ruby
 
#--
# Copyright &169;2001-2013 Integrallis Software, LLC. 
# All Rights Reserved.
# 
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#++

# encoding: utf-8

# --------------------------------------------------------------------

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

# --------------------------------------------------------------------

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "jruby-amazon-mws"
  gem.homepage = "http://github.com/integrallis/jruby-amazon-mws"
  gem.license = "MIT"
  gem.summary = "JRuby client for Amazon MWS"
  gem.description = "JRuby client for Amazon Marketplace Web Service (Amazon MWS)"
  gem.email = "bsbodden@integrallis.com"
  gem.authors = ["Brian Sam-Bodden"]
  gem.platform = "java"
  gem.files = FileList["VERSION", "History.txt", "Manifest.txt", "README.md", "Gemfile", "Gemfile.lock", "Rakefile", "LICENSE", "lib/**/*.rb", "lib/java/*.jar"]
end
Jeweler::RubygemsDotOrgTasks.new

# --------------------------------------------------------------------

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'spec/**/*_spec.rb'
  test.verbose = true
end

# --------------------------------------------------------------------

require 'simplecov'
desc "Run RSpec with code coverage"
task :simplecov do
  SimpleCov.start do
      add_filter "/test/"
  end
  Rake::Task['test'].execute
end

task :default => :test

# --------------------------------------------------------------------

require 'rdoc/task'
RDoc::Task.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "ruruenjin #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

# --------------------------------------------------------------------