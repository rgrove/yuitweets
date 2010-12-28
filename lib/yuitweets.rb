require 'logger'
require 'ostruct'
require 'set'

require 'mongo'

require 'yuitweets/bayes'
require 'yuitweets/version'

module YUITweets
  ROOT_DIR = ENV['YUITWEETS_ROOT'] || '.' unless const_defined?(:ROOT_DIR)
  CONF_DIR = File.join(ROOT_DIR, 'conf') unless const_defined?(:CONF_DIR)
  DB_DIR   = File.join(ROOT_DIR, 'db') unless const_defined?(:DB_DIR)
  LIB_DIR  = File.expand_path(File.join(File.dirname(__FILE__), 'yuitweets'))
  RACK_ENV = (ENV['RACK_ENV'] || :development).to_sym

  class << self
    attr_reader :bayes, :db, :queue

    def init
      load File.join(CONF_DIR, 'config.rb')
      load File.join(CONF_DIR, 'stopwords.rb')

      conf = {
        :db      => 'yuitweets',
        :uri     => 'mongodb://localhost',
        :options => {}
      }.merge(CONFIG[:mongo])

      @conn  = Mongo::Connection.from_uri(conf[:uri], conf[:options])
      @db    = @conn[conf[:db]]
      @bayes = Bayes.new(@db)

      # Create indexes (if necessary).
      @db['tokens'].ensure_index(
        [['type', Mongo::ASCENDING], ['token', Mongo::ASCENDING]],
        :unique    => true,
        :drop_dups => true
      )

      @db['tweets'].ensure_index([['type', Mongo::ASCENDING]])

      require 'yuitweets/tweet'
    end
  end
end
