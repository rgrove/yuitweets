module YUITweets
  ROOT_DIR = ENV['YUITWEETS_ROOT'] || File.expand_path('.')
end

require 'yuitweets/web'

YUITweets.init
run YUITweets::Web
