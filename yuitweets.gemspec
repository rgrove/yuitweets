# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{yuitweets}
  s.version = "2010.08.31"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ryan Grove"]
  s.date = %q{2010-08-31}
  s.default_executable = %q{yuitweets}
  s.email = %q{ryan@wonko.com}
  s.executables = ["yuitweets"]
  s.files = ["bin/yuitweets", "lib/yuitweets/bayes.rb", "lib/yuitweets/server.rb", "lib/yuitweets/tweet.rb", "lib/yuitweets/version.rb", "lib/yuitweets.rb"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.1")
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Bayesian tweet filter for YUI Library tweets.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<erubis>, ["~> 2.6.6"])
      s.add_runtime_dependency(%q<sequel>, ["~> 3.14"])
      s.add_runtime_dependency(%q<sinatra>, ["~> 1.0.0"])
      s.add_runtime_dependency(%q<sqlite3-ruby>, ["~> 1.3.1"])
      s.add_runtime_dependency(%q<unicode_utils>, ["~> 1.0.0"])
      s.add_runtime_dependency(%q<yajl-ruby>, ["~> 0.7.7"])
      s.add_development_dependency(%q<rake>, ["~> 0.8.7"])
    else
      s.add_dependency(%q<erubis>, ["~> 2.6.6"])
      s.add_dependency(%q<sequel>, ["~> 3.14"])
      s.add_dependency(%q<sinatra>, ["~> 1.0.0"])
      s.add_dependency(%q<sqlite3-ruby>, ["~> 1.3.1"])
      s.add_dependency(%q<unicode_utils>, ["~> 1.0.0"])
      s.add_dependency(%q<yajl-ruby>, ["~> 0.7.7"])
      s.add_dependency(%q<rake>, ["~> 0.8.7"])
    end
  else
    s.add_dependency(%q<erubis>, ["~> 2.6.6"])
    s.add_dependency(%q<sequel>, ["~> 3.14"])
    s.add_dependency(%q<sinatra>, ["~> 1.0.0"])
    s.add_dependency(%q<sqlite3-ruby>, ["~> 1.3.1"])
    s.add_dependency(%q<unicode_utils>, ["~> 1.0.0"])
    s.add_dependency(%q<yajl-ruby>, ["~> 0.7.7"])
    s.add_dependency(%q<rake>, ["~> 0.8.7"])
  end
end
