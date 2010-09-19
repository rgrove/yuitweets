require 'logger'
require 'ostruct'
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
    attr_reader :bayes, :db, :queue

    def init
      load File.join(CONF_DIR, 'config.rb')
      load File.join(CONF_DIR, 'stopwords.rb')

      @db    = Sequel.connect(CONFIG[:database][:uri], :encoding => 'utf8')
      @bayes = Bayes.new(@db)

      require 'yuitweets/tweet'
    end
  end
end
