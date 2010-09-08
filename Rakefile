require 'rake/gempackagetask'
require './lib/yuitweets/version'

gemspec = Gem::Specification.new do |s|
  s.name     = 'yuitweets'
  s.summary  = 'Bayesian tweet filter for YUI Library tweets.'
  s.version  = YUITweets::VERSION
  s.author   = 'Ryan Grove'
  s.email    = 'ryan@wonko.com'
  s.homepage = 'http://github.com/rgrove/yuitweets/'
  s.platform = Gem::Platform::RUBY

  s.require_path          = 'lib'
  s.required_ruby_version = '>= 1.9.1'

  # Runtime dependencies.
  s.add_dependency('builder',       '~> 2.1.2')
  s.add_dependency('erubis',        '~> 2.6.6')
  s.add_dependency('htmlentities',  '~> 4.2.1')
#  s.add_dependency('mysql2',        '~> 0.2.3')
  s.add_dependency('sequel',        '~> 3.15')
  s.add_dependency('sinatra',       '~> 1.0.0')
  s.add_dependency('sqlite3-ruby',  '~> 1.3.1')
  s.add_dependency('trollop',       '~> 1.16.2')
  s.add_dependency('unicode_utils', '~> 1.0.0')
  s.add_dependency('yajl-ruby',     '~> 0.7.7')

  # Development dependencies.
  s.add_development_dependency('rake', '~> 0.8.7')

  # Gem just installs the executable and the library files for now. Pull the
  # rest from git.
  s.files = FileList[
    # 'config.ru',
    'bin/yuitweets',
    # 'conf/*.rb',
    # 'db/**/*.rb',
    'lib/**/*.rb',
    # 'public/**/*',
    # 'views/**/*'
  ].to_a

  s.executables = ['yuitweets']
end

Rake::GemPackageTask.new(gemspec) do |p|
end

desc 'Run a development server.'
task :devserver do
  sh 'ruby -Ilib `which thin` -R config.ru start'
end

desc 'Generate an updated gemspec.'
task :gemspec do
  filename = File.join(File.dirname(__FILE__), "#{gemspec.name}.gemspec")
  File.open(filename, 'w') {|f| f << gemspec.to_ruby }
  puts "Created gemspec: #{filename}"
end

desc 'Build and install the gem.'
task :install => :gem do
  sh "gem install pkg/yuitweets-#{YUITweets::VERSION}.gem"
end

desc 'Create or migrate the database schema.'
task :migrate, :url do |t, args|
  unless url = args[:url]
    puts 'Usage  : rake migrate[<db url>]'
    puts 'Example: rake migrate[sqlite://db/development.db]'
    abort
  end

  sh "sequel -m db/migrations #{url}"
end

desc 'Fetch new tweets.'
task :tweets do
  sh 'ruby -Ilib bin/yuitweets'
end
