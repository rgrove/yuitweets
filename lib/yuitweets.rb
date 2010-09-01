require 'logger'
require 'set'

require 'sequel'

require 'yuitweets/bayes'
require 'yuitweets/version'

module YUITweets
  ROOT_DIR = ENV['YUITWEETS_ROOT'] || '.' unless const_defined?(:ROOT_DIR)
  CONF_DIR = File.join(ROOT_DIR, 'conf') unless const_defined?(:CONF_DIR)
  DB_DIR   = File.join(ROOT_DIR, 'db') unless const_defined?(:DB_DIR)
  LIB_DIR  = File.expand_path(File.join(File.dirname(__FILE__), 'yuitweets'))
  RACK_ENV = (ENV['RACK_ENV'] || :development).to_sym

  class << self
    attr_reader :bayes, :db

    def init
      load File.join(CONF_DIR, 'stopwords.rb')

      @db    = Sequel.sqlite(File.join(DB_DIR, "#{RACK_ENV}.db"))
      @bayes = Bayes.new(@db)

      require 'yuitweets/tweet'
    end
  end
end
