module YUITweets
  ROOT_DIR = ENV['YUITWEETS_ROOT'] || File.expand_path('.')
end

require 'yuitweets/server'

YUITweets.init
run YUITweets::Server
