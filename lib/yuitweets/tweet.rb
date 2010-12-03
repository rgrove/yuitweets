require 'htmlentities'
require 'time'

# Listen up. We need to have a talk about tweet ids.
#
# Tweet ids are big longass 64-bit integers. They make JavaScript crap its
# pants, but Mongo and Ruby like them just fine.
#
# The _id field of each tweet in Mongo is the original tweet id, as an int. The
# id_str field is this id as a string. When finding, filtering, or sorting
# tweets in Mongo or Ruby, we use the int. When sending data to JavaScript, we
# use the string. When a request comes in from JavaScript that contains an id,
# it will be a string, and we must cast it to an int.
#
# Remember this. If you forget it, strange things will happen.

module YUITweets; class Tweet
  attr_reader :tweet

  # Class methods.
  def self.[](id)
    tweet = YUITweets.db['tweets'].find_one({'_id' => id.to_i})
    tweet ? Tweet.new(tweet) : nil
  end

  def self.last_id
    tweet = YUITweets.db['tweets'].find_one({}, {
      :fields => ['id_str'],
      :sort   => ['_id', :desc]
    })

    tweet ? tweet['id_str'] : '0'
  end

  def self.recent(criteria = {}, options = {})
    YUITweets.db['tweets'].find(criteria, {
      :limit => 20,
      :sort  => ['_id', :desc]
    }.merge(options)).map{|doc| Tweet.new(doc) }
  end

  # Instance methods.
  def initialize(tweet = {})
    @cache = {}
    @tweet = tweet
  end

  def clear_cache
    @cache = {}
  end

  def created_at
    @cache[:created_at] ||= Time.parse(@tweet['created_at'])
  end

  def method_missing(name, *args, &block)
    if @tweet.has_key?(name.to_s)
      @tweet[name.to_s]
    else
      super
    end
  end

  def respond_to_missing?(name, *)
    @tweet.has_key(name.to_s) || super
  end

  def scores(refresh = false)
    @cache[:scores] = nil if refresh
    @cache[:scores] ||= YUITweets.bayes.score(specimen)
  end

  def specimen
    @cache[:specimen] ||= HTMLEntities.new.decode("@#{from_user} #{text}")
  end

  def type
    @tweet['type'] || nil
  end

  def update(doc, refresh = true)
    @tweet = YUITweets.db['tweets'].find_and_modify(
      :query  => {'_id' => @tweet['_id']},
      :update => doc,
      :new    => refresh
    )

    clear_cache if refresh
  end

  def votes
    @tweet['votes'] || 0
  end

end; end
