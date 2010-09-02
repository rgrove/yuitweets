module YUITweets

  CONFIG = OpenStruct.new({
    :database => {
      :uri => 'mysql2://yuitweets:fakepass@localhost/tweets'
    }
  })

end
